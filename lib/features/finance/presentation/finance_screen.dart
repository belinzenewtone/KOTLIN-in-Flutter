/// 1:1 port of FinanceScreen.kt — page scaffold, quick actions, hero card,
/// filter segments, transaction list, and dialog orchestration.
/// Tapping a row opens the small detail popup (AlertDialog) like Compose.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:share_plus/share_plus.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/designsystem/banners.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/designsystem/tokens.dart' show AppSpacing;
import '../../../core/security/session_store.dart';
import '../../../core/utils/date_utils.dart';
import '../../../navigation/routes.dart';
import '../../../core/platform/sms_bridge.dart';
import '../../dashboard/data/providers.dart';
import '../../sms/ingestion/ingestion_types.dart';
import '../../sms/parser/institution_detector.dart';
import '../data/finance_repository.dart';
import '../domain/finance_models.dart';
import '../../../core/designsystem/controls.dart';
import 'finance_dialogs.dart';
import 'finance_widgets.dart';
import 'transaction_detail_dialog.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({
    super.key,
    this.initialTransactionId,
    this.onOpenHub,
    this.onExportPdf,
  });

  final int? initialTransactionId;
  final VoidCallback? onOpenHub;
  final VoidCallback? onExportPdf;

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  FinanceRepository? _repo;
  FinanceTransactionFilter _filter = FinanceTransactionFilter.last1Month;
  String _query = '';
  List<FinanceTransaction> _transactions = [];

  // Flat list for the virtualized SliverList: String = date-section header,
  // FinanceTransaction = transaction row. Recomputed only when _transactions
  // changes, never inside build().
  List<Object> _flatItems = [];
  final ScrollController _scrollController = ScrollController();

  FinanceSpendingSummary _summary = FinanceSpendingSummary.empty;
  bool _loading = true;
  String? _error;
  Timer? _debounce;

  FinanceTransaction? _detailTarget;
  FinanceTransaction? _deleteTarget;
  bool _showAddDialog = false;
  bool _dialogBusy = false;
  FinanceTransaction? _categoryPickerTarget;
  FinanceTransaction? _editTarget;
  bool _pickerAutoOpened = false;
  bool _showSmsImportSheet = false;
  bool _showCsvImportSheet = false;
  bool _showFulizaLimitDialog = false;
  double? _fulizaLimit;
  final _smsSheetStateKey = GlobalKey<_SmsSheetHostState>();

  // Guard: only one postFrameCallback registered at a time so _flushDialogs
  // is not called multiple times per frame when build() is called rapidly.
  bool _flushPending = false;

  void _scheduleFlush() {
    if (_flushPending || !mounted) return;
    _flushPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flushPending = false;
      if (mounted) _flushDialogs();
    });
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final db = await ref.read(lifeOsDatabaseProvider.future);
      final userId = await ref.read(userIdProvider.future);
      _repo = FinanceRepository(db, userId);
      await _reload();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _reload() async {
    final repo = _repo;
    if (repo == null) return;
    try {
      final (txs, summary) = await (
        repo.pageTransactions(filter: _filter, start: 0, pageSize: 200, query: _query),
        repo.summary(),
      ).wait;
      if (!mounted) return;
      setState(() {
        _transactions = txs;
        _flatItems = _buildFlatItems(txs);
        _summary = summary;
        _loading = false;
        _error = null;
      });
      // finance?transactionId= deep-link: auto-open the category picker
      // (FinanceScreen.kt LaunchedEffect parity).
      final deepLinkId = widget.initialTransactionId;
      if (deepLinkId != null && !_pickerAutoOpened) {
        FinanceTransaction? tx;
        for (final t in txs) {
          if (t.id == deepLinkId) {
            tx = t;
            break;
          }
        }
        if (tx != null) {
          _pickerAutoOpened = true;
          setState(() => _categoryPickerTarget = tx);
        }
      }
      _maybeShowFulizaDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  /// Kotlin maybeShowFulizaLimitDialog parity: prompt once when Fuliza activity
  /// exists and no limit has been stored yet.
  Future<void> _maybeShowFulizaDialog() async {
    if (_dialogBusy || _showFulizaLimitDialog) return;
    final repo = _repo;
    if (repo == null) return;
    final prefs = await ref.read(sharedPrefsProvider.future);
    final stored = prefs.getDouble('fuliza_limit_kes');
    if (stored != null) return; // already configured — don't prompt again
    final hasActivity = await repo.hasFulizaActivity();
    if (!hasActivity) return; // no Fuliza transactions at all
    if (!mounted) return;
    setState(() {
      _fulizaLimit = null;
      _showFulizaLimitDialog = true;
    });
  }

  Future<void> _saveFulizaLimit(double limit) async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.setDouble('fuliza_limit_kes', limit);
  }

  /// Fire-and-forget budget alert check after a transaction is added.
  /// Queries current month spend for the category and compares to the budget
  /// limit (if one exists). Sends the notification via NotificationService.
  void _maybeSendBudgetAlert(String category, double addedAmount) {
    final repo = _repo;
    if (repo == null) return;
    unawaited(() async {
      try {
        final spendMap = await repo.summary();
        // Get per-category spend from the updated summary.
        final spent = spendMap.categoryBreakdown
            .where((b) => b.category.toLowerCase() == category.toLowerCase())
            .fold<double>(0, (sum, b) => sum + b.total);
        final budgetLimit = _summary.totalMonthBudget;
        if (budgetLimit <= 0 || spent <= 0) return;
        // Only alert when spending crosses 80 % or 100 % of budget.
        final ratio = spent / budgetLimit;
        if (ratio >= 0.8) {
          await NotificationService.maybeSendBudgetAlert(
            budgetId: category.hashCode,
            category: category,
            spent: spent,
            limit: budgetLimit,
          );
        }
      } catch (_) {
        // Non-critical — swallow silently.
      }
    }());
  }

  void _onQueryChanged(String v) {
    _query = v;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), _reload);
  }

  /// Show the detail dialog directly without going through the setState→rebuild
  /// cycle. This avoids re-rendering all 200 transaction rows before the dialog
  /// appears, eliminating the visible stutter on transaction tap.
  Future<void> _openDetailDirect(FinanceTransaction tx) async {
    if (_dialogBusy || !mounted) return;
    _dialogBusy = true;
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => TransactionDetailDialog(
        transaction: tx,
        onDismiss: () => Navigator.of(dialogCtx).pop(),
        onEdit: () {
          _dialogBusy = false;
          Navigator.of(dialogCtx).pop();
          // _editTarget triggers the edit sheet on next flush
          setState(() => _editTarget = tx);
        },
        onDelete: () {
          _dialogBusy = false;
          Navigator.of(dialogCtx).pop();
          setState(() => _deleteTarget = tx);
        },
        onShare: () {
          _dialogBusy = false;
          Navigator.of(dialogCtx).pop();
          final code = (tx.mpesaCode?.isNotEmpty ?? false) ? '\n📟 ${tx.mpesaCode}' : '';
          final dateStr = AppDateUtils.formatRelativeTime(tx.date);
          final text =
              '${AppDateUtils.formatCurrency(tx.amount)} — ${tx.merchant}$code\n'
              '📅 $dateStr · ${tx.category} · via M-Pesa';
          SharePlus.instance.share(ShareParams(text: text));
        },
      ),
    );
    if (_dialogBusy) _dialogBusy = false;
    // Ensure any pending follow-up dialog (edit/delete) gets shown.
    if (mounted && (_editTarget != null || _deleteTarget != null)) {
      setState(() {});
    }
  }

  /// Flattens grouped transactions: String items are date-section headers,
  /// FinanceTransaction items are rows. O(n), called only on data reload.
  static List<Object> _buildFlatItems(List<FinanceTransaction> txs) {
    final items = <Object>[];
    String? cur;
    for (final tx in txs) {
      final label = _dayLabel(tx.date);
      if (label != cur) {
        items.add(label);
        cur = label;
      }
      items.add(tx);
    }
    return items;
  }

  static String _dayLabel(int epochMs) {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final today = DateTime.now();
    final todayD = DateTime(today.year, today.month, today.day);
    final date = DateTime(d.year, d.month, d.day);
    if (date == todayD) return 'Today';
    if (date == todayD.subtract(const Duration(days: 1))) return 'Yesterday';
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only schedule a flush when there is actually a pending dialog to show,
    // avoiding a postFrameCallback registration on every build.
    // NOTE: _editTarget MUST be included here — without it, pressing "Edit"
    // in the detail dialog sets _editTarget but the edit sheet never opens.
    if (!_dialogBusy &&
        (_detailTarget != null ||
            _deleteTarget != null ||
            _showAddDialog ||
            _editTarget != null ||
            _categoryPickerTarget != null ||
            _showFulizaLimitDialog ||
            _showSmsImportSheet ||
            _showCsvImportSheet)) {
      _scheduleFlush();
    }

    // One CustomScrollView scrolls everything together (hero card, filters,
    // and transactions) as a single unit — matching the Kotlin LazyColumn
    // behaviour. SliverList.builder virtualizes the transaction rows so only
    // the ~12 visible ones are built at any given time.
    return PageScaffold(
      title: 'Finance',
      scrollable: false,
      topBanner: (_error != null)
          ? TopBanner(message: _error!, tone: TopBannerTone.error)
          : null,
      contentPadding: EdgeInsets.zero,
      child: _loading
          ? const ShimmerLoadingState(rows: 5)
          : _buildScrollView(context),
    );
  }

  Widget _buildScrollView(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasTxs = _transactions.isNotEmpty;

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // ── Fixed header items ─────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              FinanceQuickActions(
                onAdd: () => setState(() => _showAddDialog = true),
                onOpenHub: widget.onOpenHub,
                onExportPdf: widget.onExportPdf,
                onImportSms: () => setState(() => _showSmsImportSheet = true),
                onImportCsv: () => setState(() => _showCsvImportSheet = true),
              ),
              const SizedBox(height: 12),
              FinanceSpendingHeroCard(
                monthSpend: _summary.monthTotal,
                todaySpend: _summary.todayTotal,
                weekSpend: _summary.weekTotal,
                monthIncome: _summary.totalMonthBudget,
              ),
              const SizedBox(height: 12),
              SegmentedControl(
                items: const ['23 hrs', '1 month', '3 months', '6 months'],
                selectedIndex:
                    FinanceTransactionFilter.values.indexOf(_filter),
                onSelected: (i) {
                  setState(
                      () => _filter = FinanceTransactionFilter.values[i]);
                  _reload();
                },
              ),
              const SizedBox(height: 12),
              if (_summary.uncategorizedCount > 0) ...[
                UncategorizedBanner(
                  count: _summary.uncategorizedCount,
                  // Reload summary when the user returns from the Categorize
                  // page so the banner count decrements (or disappears) without
                  // needing a manual refresh.
                  onTap: () async {
                    await context.push('/${AppRoute.categorize}');
                    if (mounted) _reload();
                  },
                ),
                const SizedBox(height: 12),
              ],
              // Search bar
              SearchField(
                value: _query,
                onValueChange: _onQueryChanged,
                placeholder: 'Search merchant, category, code or amount.',
              ),
              const SizedBox(height: 8),
              // "Transactions" label or empty state
              if (!hasTxs)
                EmptyState(
                  title: _query.isEmpty
                      ? 'No transactions yet'
                      : 'No matching transactions',
                  description: _query.isEmpty
                      ? 'Import MPESA messages or add a transaction to start your ledger.'
                      : 'Try another filter or refine your search.',
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('Transactions',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ),
            ]),
          ),
        ),

        // ── Virtualized transaction rows ───────────────────────────────────
        if (hasTxs)
          SliverPadding(
            padding: EdgeInsets.only(
              left: AppSpacing.screenHorizontal,
              right: AppSpacing.screenHorizontal,
              bottom: AppSpacing.bottomSafeWithFloatingNav,
            ),
            sliver: SliverList.builder(
              itemCount: _flatItems.length,
              itemBuilder: (ctx, i) {
                final item = _flatItems[i];
                if (item is String) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox.shrink(),
                        Text(item,
                            style: Theme.of(ctx)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }
                final tx = item as FinanceTransaction;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: FinanceTransactionRowWidget(
                    transaction: tx,
                    onRecategorize: () =>
                        setState(() => _categoryPickerTarget = tx),
                    onDelete: () => setState(() => _deleteTarget = tx),
                    onMerchantClick: (m) => context.push(
                        '/${AppRoute.merchantDetail}/${Uri.encodeComponent(m)}'),
                    onClick: () => _openDetailDirect(tx),
                  ),
                );
              },
            ),
          ),

        // Bottom safe area when list is empty (no SliverList above)
        if (!hasTxs)
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.bottomSafeWithFloatingNav),
          ),
      ],
    );
  }

  // ── SMS import wizard (SmsImportBottomSheet parity) ───────────────────────

  /// Step 2: scan the inbox for the selected period and count by institution.
  Future<Map<String, int>?> _detectSms(int days) async {
    if (!await SmsPlatformBridge.hasSmsPermissions()) {
      await SmsPlatformBridge.requestSmsPermissions();
      if (!await SmsPlatformBridge.hasSmsPermissions()) return null;
    }
    final messages = await SmsPlatformBridge.readInbox();
    final cutoff = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;
    final counts = <String, int>{};
    for (final m in messages) {
      if (m.receivedAtMs < cutoff) continue;
      final detection = InstitutionDetector.detect(m.sender, m.body);
      if (detection != null) {
        counts[detection.institutionId] = (counts[detection.institutionId] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Step 3: run the full historical import for the chosen window.
  Future<BatchIngestionResult?> _importSms(int days, {String source = 'all'}) async {
    return runHistoricalSmsImport(ref, source: source);
  }

  // ── CSV import (CsvImportModal.kt parity) ─────────────────────────────────

  Future<CsvParseResult> _pickCsvFile() async {
    try {
      final filePath = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      ).then((res) => res?.files.single.path);
      if (filePath == null) {
        return const CsvParseResult(rows: [], errors: 0);
      }
      final bytes = await File(filePath).readAsBytes();
      final content = utf8.decode(bytes);
      return _parseCsv(content);
    } catch (_) {
      return const CsvParseResult(rows: [], errors: 0);
    }
  }

  CsvParseResult _parseCsv(String content) {
    final rows = <CsvRow>[];
    var errors = 0;
    final lines = content.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    for (var i = 0; i < lines.length; i++) {
      final parts = _splitCsvLine(lines[i]);
      if (parts.length < 3) {
        errors++;
        continue;
      }
      final dateMs = _parseCsvDate(parts[0]);
      final amount = double.tryParse(parts[1].replaceAll(',', ''));
      final rawType = parts.length > 2 ? parts[2].trim().toUpperCase() : '';
      final category = parts.length > 3 ? parts[3].trim() : 'Other';
      final description = parts.length > 4 ? parts[4].trim() : '';
      if (dateMs == null || amount == null || rawType.isEmpty) {
        errors++;
        continue;
      }
      final isIncome = rawType == 'INCOME' ||
          rawType == 'IN' ||
          rawType == 'CREDIT' ||
          rawType == 'RECEIVED';
      rows.add(CsvRow(
        date: dateMs,
        amount: isIncome ? amount.abs() : -amount.abs(),
        type: isIncome ? 'INCOME' : 'EXPENSE',
        category: category.isEmpty ? 'Other' : category,
        description: description,
      ));
    }
    return CsvParseResult(rows: rows, errors: errors);
  }

  List<String> _splitCsvLine(String line) {
    final out = <String>[];
    final buf = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buf.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        out.add(buf.toString().trim());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    out.add(buf.toString().trim());
    return out;
  }

  int? _parseCsvDate(String raw) {
    final s = raw.trim();
    final now = DateTime.now();
    DateTime? d;
    // yyyy-MM-dd
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
    if (iso != null) {
      d = DateTime(int.parse(iso.group(1)!), int.parse(iso.group(2)!),
          int.parse(iso.group(3)!));
    }
    // dd/MM/yyyy or MM/dd/yyyy
    final slash = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})').firstMatch(s);
    if (slash != null) {
      final a = int.parse(slash.group(1)!);
      final b = int.parse(slash.group(2)!);
      final y = int.parse(slash.group(3)!);
      d = a > 12 ? DateTime(y, b, a) : DateTime(y, a, b);
    }
    if (d == null) return null;
    return DateTime(d.year, d.month, d.day, now.hour, now.minute)
        .millisecondsSinceEpoch;
  }

  Future<int> _importCsvRows(List<CsvRow> rows) async {
    final repo = _repo;
    if (repo == null) return 0;
    var count = 0;
    for (final row in rows) {
      await repo.addManual(
        amount: row.amount,
        merchant: row.description.isEmpty ? row.category : row.description,
        category: row.category,
        notes: null,
        fee: 0,
        dateOverrideMs: row.date,
        typeOverride: row.type,
      );
      count++;
    }
    _reload();
    return count;
  }

  // ── Dialog orchestration (Compose side-effect parity) ────────────────────

  void _flushDialogs() {
    if (!mounted || _dialogBusy) return;
    if (_detailTarget != null) {
      final tx = _detailTarget!;
      _dialogBusy = true;
      showDialog<void>(
        context: context,
        builder: (dialogCtx) => TransactionDetailDialog(
          transaction: tx,
          onDismiss: () => Navigator.of(dialogCtx).pop(),
          onEdit: () {
            _dialogBusy = false; // reset early so the next _flushDialogs works
            Navigator.of(dialogCtx).pop();
            setState(() {
              _detailTarget = null;
              _editTarget = tx;
            });
          },
          onDelete: () {
            _dialogBusy = false;
            Navigator.of(dialogCtx).pop();
            setState(() {
              _detailTarget = null;
              _deleteTarget = tx;
            });
          },
          onShare: () {
            _dialogBusy = false;
            Navigator.of(dialogCtx).pop();
            setState(() => _detailTarget = null);
            final code = (tx.mpesaCode?.isNotEmpty ?? false) ? '\n📟 ${tx.mpesaCode}' : '';
            final dateStr = AppDateUtils.formatRelativeTime(tx.date);
            final text =
                '${AppDateUtils.formatCurrency(tx.amount)} — ${tx.merchant}$code\n'
                '📅 $dateStr · ${tx.category} · via M-Pesa';
            SharePlus.instance.share(ShareParams(text: text));
          },
        ),
      ).then((_) {
        if (_dialogBusy) _dialogBusy = false;
        if (mounted && _detailTarget != null) setState(() => _detailTarget = null);
        // Ensure any pending dialog (e.g. category picker) gets a chance to open.
        if (mounted) setState(() {});
      });
    } else if (_deleteTarget != null) {
      final tx = _deleteTarget!;
      _dialogBusy = true;
      showDialog<void>(
        context: context,
        builder: (dialogCtx) => DeleteTransactionDialog(
          merchant: tx.merchant,
          formattedAmount: AppDateUtils.formatCurrency(tx.amount),
          onDelete: () async {
            _dialogBusy = false;
            Navigator.of(dialogCtx).pop();
            await _repo?.delete(tx.id);
            if (mounted) setState(() => _deleteTarget = null);
            _reload();
          },
          onCancel: () {
            _dialogBusy = false;
            Navigator.of(dialogCtx).pop();
            if (mounted) setState(() => _deleteTarget = null);
          },
        ),
      ).then((_) {
        if (_dialogBusy) _dialogBusy = false;
        if (mounted && _deleteTarget != null) setState(() => _deleteTarget = null);
      });
    } else if (_showAddDialog) {
      _dialogBusy = true;
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => AddTransactionBottomSheet(
          onDismiss: () {
            Navigator.of(context, rootNavigator: true).pop();
            if (mounted) setState(() => _showAddDialog = false);
          },
          onAdd: (amount, merchant, category, notes, fee) async {
            Navigator.of(context, rootNavigator: true).pop();
            await _repo?.addManual(
                amount: amount,
                merchant: merchant,
                category: category,
                notes: notes,
                fee: fee);
            if (mounted) setState(() => _showAddDialog = false);
            _reload();
            // Fire budget alert if this category has a budget.
            _maybeSendBudgetAlert(category, amount);
          },
        ),
      ).then((_) {
        _dialogBusy = false;
        if (mounted && _showAddDialog) setState(() => _showAddDialog = false);
      });
    } else if (_editTarget != null) {
      final tx = _editTarget!;
      _dialogBusy = true;
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => EditTransactionBottomSheet(
          transaction: tx,
          onDismiss: () {
            Navigator.of(context, rootNavigator: true).pop();
            if (mounted) setState(() => _editTarget = null);
          },
          onSave: (category) async {
            Navigator.of(context, rootNavigator: true).pop();
            // Only category is editable; preserve all other auto-filled fields.
            await _repo?.updateTransaction(
              id: tx.id,
              amount: tx.amount,
              merchant: tx.merchant,
              category: category,
              notes: tx.notes,
              fee: tx.fee,
            );
            if (mounted) setState(() => _editTarget = null);
            _reload();
          },
        ),
      ).then((_) {
        _dialogBusy = false;
        if (mounted && _editTarget != null) setState(() => _editTarget = null);
      });
    } else if (_categoryPickerTarget != null) {
      final tx = _categoryPickerTarget!;
      _dialogBusy = true;
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => CategoryPickerBottomSheet(
          currentCategory: tx.category,
          onDismiss: () {
            Navigator.of(context, rootNavigator: true).pop();
            if (mounted) setState(() => _categoryPickerTarget = null);
          },
          onSelect: (c) async {
            Navigator.of(context, rootNavigator: true).pop();
            await _repo?.recategorize(tx, c);
            if (mounted) setState(() => _categoryPickerTarget = null);
            _reload();
          },
        ),
      ).then((_) {
        _dialogBusy = false;
        if (mounted && _categoryPickerTarget != null) {
          setState(() => _categoryPickerTarget = null);
        }
      });
    } else if (_showSmsImportSheet) {
      _dialogBusy = true;
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _SmsSheetHost(
          key: _smsSheetStateKey,
          onDetect: (days, source) async {
            final counts = await _detectSms(days);
            _smsSheetStateKey.currentState?.completeDetection(counts);
            return counts;
          },
          onImportDays: (days, source) async {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() => _showSmsImportSheet = false);
            final result = await _importSms(days, source: source);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result == null
                  ? 'SMS permission required for import.'
                  : 'Imported ${result.imported}, '
                      '${result.duplicates} duplicates, '
                      '${result.ignored} ignored.'),
            ));
            _reload();
          },
          onDismiss: () {
            Navigator.of(context, rootNavigator: true).pop();
            if (mounted) setState(() => _showSmsImportSheet = false);
          },
        ),
      ).then((_) {
        _dialogBusy = false;
        if (mounted && _showSmsImportSheet) {
          setState(() => _showSmsImportSheet = false);
        }
      });
    } else if (_showCsvImportSheet) {
      _dialogBusy = true;
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => CsvImportBottomSheet(
          onDismiss: () {
            Navigator.of(context, rootNavigator: true).pop();
            if (mounted) setState(() => _showCsvImportSheet = false);
          },
          onPickFile: _pickCsvFile,
          onImport: _importCsvRows,
        ),
      ).then((_) {
        _dialogBusy = false;
        if (mounted && _showCsvImportSheet) {
          setState(() => _showCsvImportSheet = false);
        }
      });
    } else if (_showFulizaLimitDialog) {
      _dialogBusy = true;
      showDialog<void>(
        context: context,
        // Use the dialog's own context (dialogCtx) for pop() so we never
        // accidentally pop the parent Finance route instead of the dialog.
        builder: (dialogCtx) => FulizaLimitDialog(
          initialLimitKes: _fulizaLimit,
          onDismiss: () {
            Navigator.of(dialogCtx).pop();
          },
          onSave: (limit) async {
            Navigator.of(dialogCtx).pop();
            await _saveFulizaLimit(limit);
            if (mounted) {
              setState(() {
                _showFulizaLimitDialog = false;
                _fulizaLimit = limit;
              });
            }
          },
        ),
      ).then((_) {
        _dialogBusy = false;
        if (mounted && _showFulizaLimitDialog) {
          setState(() => _showFulizaLimitDialog = false);
        }
      });
    }
  }
}

/// Host widget bridging the SmsImportBottomSheet's internal step state with the
/// async detect callbacks from the Finance screen (detect → counts → import).
class _SmsSheetHost extends StatefulWidget {
  const _SmsSheetHost({
    super.key,
    required this.onDetect,
    required this.onImportDays,
    required this.onDismiss,
  });

  final Future<Map<String, int>?> Function(int days, String source) onDetect;
  final Future<void> Function(int days, String source) onImportDays;
  final VoidCallback onDismiss;

  @override
  State<_SmsSheetHost> createState() => _SmsSheetHostState();
}

class _SmsSheetHostState extends State<_SmsSheetHost> {
  bool _detecting = false;
  Map<String, int>? _detected;
  int? _pendingDays;

  // Source filter (1:1 with Kotlin SmsImportBottomSheet source selector).
  // 'all' = M-Pesa + Banks, 'mpesa' = M-Pesa Only, 'banks' = Banks Only.
  String _source = 'all';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_detecting)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scanning inbox…',
                          style: Theme.of(context).textTheme.titleSmall),
                      Text('Detecting financial SMS',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            )
          else if (_detected != null)
            _buildDetected(context, _detected!)
          else
            _buildFilterStep(context),
        ],
      ),
    );
  }

  // Pre-sorted entries cached once so _buildDetected never sorts in build().
  List<MapEntry<String, int>>? _detectedSorted;

  void completeDetection(Map<String, int>? detected) {
    if (!mounted) return;
    // Filter the raw detection results to match the chosen source.
    Map<String, int>? filtered = detected;
    if (detected != null && _source != 'all') {
      filtered = {
        for (final e in detected.entries)
          if (_source == 'mpesa'
              ? e.key == 'mpesa'
              : e.key != 'mpesa' && e.key != 'airtel')
            e.key: e.value,
      };
    }
    final sorted = filtered?.entries.toList()
      ?..sort((a, b) => b.value.compareTo(a.value));
    setState(() {
      _detecting = false;
      _detected = filtered;
      _detectedSorted = sorted;
    });
  }

  Future<void> _startDetect(int days) async {
    setState(() {
      _pendingDays = days;
      _detecting = true;
      _detected = null;
    });
    final counts = await widget.onDetect(days, _source);
    completeDetection(counts);
  }

  Widget _buildFilterStep(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const sources = [
      ('all', 'M-Pesa + Banks'),
      ('mpesa', 'M-Pesa Only'),
      ('banks', 'Banks Only'),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text('Import SMS Transactions',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Choose what to import',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ),
        const SizedBox(height: 4),
        // Source filter radio group (1:1 Kotlin SmsImportBottomSheet parity).
        for (final (value, label) in sources)
          RadioListTile<String>(
            value: value,
            groupValue: _source,
            dense: true,
            title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            activeColor: scheme.primary,
            onChanged: (v) => setState(() => _source = v ?? _source),
          ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Select time period to scan',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ),
        const SizedBox(height: 8),
        for (final (label, days) in kSmsImportWindows)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: InkWell(
              onTap: () => _startDetect(days),
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
              ),
            ),
          ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildDetected(BuildContext context, Map<String, int> detected) {
    final scheme = Theme.of(context).colorScheme;
    final total = detected.values.fold<int>(0, (a, b) => a + b);
    // Use pre-sorted entries cached in completeDetection(); never sort in build.
    final entries = _detectedSorted ?? (detected.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text('Import SMS Transactions',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            total == 0
                ? 'No new messages found for this period.'
                : 'Found $total messages across ${detected.length} source${detected.length == 1 ? '' : 's'}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        if (detected.isNotEmpty) ...[
          Divider(height: 1, color: scheme.outlineVariant),
          for (final entry in entries)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(institutionDisplayName(entry.key),
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text('${entry.value} msg${entry.value == 1 ? '' : 's'}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          Divider(height: 1, color: scheme.outlineVariant),
          const SizedBox(height: 12),
        ],
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: widget.onDismiss,
                  child: Text('Cancel',
                      style: TextStyle(color: scheme.onSurfaceVariant))),
              if (total > 0) ...[
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final days = _pendingDays;
                    if (days != null) widget.onImportDays(days, _source);
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Import All'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
