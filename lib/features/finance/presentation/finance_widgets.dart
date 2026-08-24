/// 1:1 ports of FinanceSpendingHeroCard.kt + FinanceQuickActions +
/// FinanceTransactionList.kt + FinanceTransactionRow + UncategorizedBanner.kt.
library;

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/banners.dart';
import '../../../core/designsystem/controls.dart';
import '../../../core/designsystem/tokens.dart';
import '../../../core/utils/date_utils.dart';
import '../../../ui/theme/theme.dart';
import '../domain/finance_models.dart';

// ── FinanceSpendingHeroCard ──────────────────────────────────────────────────

class FinanceSpendingHeroCard extends StatelessWidget {
  const FinanceSpendingHeroCard({
    super.key,
    required this.monthSpend,
    required this.todaySpend,
    required this.weekSpend,
    required this.monthIncome,
  });

  final double monthSpend;
  final double todaySpend;
  final double weekSpend;
  final double monthIncome;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Spent this month',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          Text(AppDateUtils.formatCurrency(monthSpend),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700, color: scheme.primary)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metric(context, 'Today', todaySpend),
              _metric(context, 'This week', weekSpend),
              _metric(context, 'Income', monthIncome, isPrimary: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String label, double amount,
      {bool isPrimary = false}) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant)),
        Text(AppDateUtils.formatCurrency(amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isPrimary ? scheme.primary : scheme.onSurface)),
      ],
    );
  }
}

// ── Quick actions chips row ────────────────────────────────────────────────

typedef QuickActionCallback = VoidCallback?;

class FinanceQuickActions extends StatelessWidget {
  const FinanceQuickActions({
    super.key,
    this.onAdd,
    this.onOpenHub,
    this.onImportSms,
    this.onImportCsv,
    this.onExportPdf,
  });

  final VoidCallback? onAdd;
  final VoidCallback? onOpenHub;
  final VoidCallback? onImportSms;
  final VoidCallback? onImportCsv;
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = [
      (Icons.add_outlined, 'Add', onAdd ?? () {}),
      (Icons.account_balance_outlined, 'Hub', onOpenHub ?? () {}),
      (Icons.file_download_outlined, 'Import SMS', onImportSms ?? () {}),
      (Icons.table_view_outlined, 'Import CSV', onImportCsv ?? () {}),
      (Icons.file_upload_outlined, 'Export Data', onExportPdf ?? () {}),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (i, (icon, label, action)) in items.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            Material(
              color: scheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
                side: BorderSide(color: scheme.outlineVariant),
              ),
              child: InkWell(
                onTap: action,
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text(label,
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── UncategorizedBanner ────────────────────────────────────────────────────

class UncategorizedBanner extends StatelessWidget {
  const UncategorizedBanner({super.key, required this.count, this.onTap});

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.tertiaryContainer.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.category_outlined, size: 18, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$count uncategorized transaction${count == 1 ? '' : 's'} — tap to sort them.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Icon(Icons.chevron_right,
                  size: 16, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Transaction list ───────────────────────────────────────────────────────

const List<String> kMonthNamesShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String dayLabelFor(int epochMillis) {
  final d = DateTime.fromMillisecondsSinceEpoch(epochMillis);
  final today = DateTime.now();
  final todayD = DateTime(today.year, today.month, today.day);
  final date = DateTime(d.year, d.month, d.day);
  if (date == todayD) return 'Today';
  if (date == todayD.subtract(const Duration(days: 1))) return 'Yesterday';
  return '${kMonthNamesShort[d.month - 1]} ${d.day}';
}

class FinanceTransactionListWidget extends StatefulWidget {
  const FinanceTransactionListWidget({
    super.key,
    required this.transactions,
    required this.query,
    required this.onQueryChange,
    required this.onRecategorize,
    required this.onDelete,
    required this.onMerchantClick,
    required this.onTransactionClick,
  });

  final List<FinanceTransaction> transactions;
  final String query;
  final ValueChanged<String> onQueryChange;
  final ValueChanged<FinanceTransaction> onRecategorize;
  final ValueChanged<FinanceTransaction> onDelete;
  final ValueChanged<String> onMerchantClick;
  final ValueChanged<FinanceTransaction> onTransactionClick;

  @override
  State<FinanceTransactionListWidget> createState() =>
      _FinanceTransactionListWidgetState();
}

class _FinanceTransactionListWidgetState
    extends State<FinanceTransactionListWidget> {
  final ScrollController _scrollController = ScrollController();

  // Sections are computed once when transactions change, never inside build().
  List<(String, List<FinanceTransaction>)> _sections = [];

  @override
  void initState() {
    super.initState();
    _sections = _computeSections(widget.transactions);
  }

  @override
  void didUpdateWidget(covariant FinanceTransactionListWidget old) {
    super.didUpdateWidget(old);
    if (!identical(old.transactions, widget.transactions)) {
      _sections = _computeSections(widget.transactions);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Groups transactions by date label into sections.  O(n) — called only
  /// when the transactions list reference changes, not on every build.
  static List<(String, List<FinanceTransaction>)> _computeSections(
      List<FinanceTransaction> transactions) {
    final sections = <(String, List<FinanceTransaction>)>[];
    String? curDate;
    var curTxs = <FinanceTransaction>[];
    for (final tx in transactions) {
      final label = dayLabelFor(tx.date);
      if (label != curDate) {
        if (curDate != null && curTxs.isNotEmpty) {
          sections.add((curDate, List.unmodifiable(curTxs)));
          curTxs = [];
        }
        curDate = label;
      }
      curTxs.add(tx);
    }
    if (curDate != null && curTxs.isNotEmpty) {
      sections.add((curDate, List.unmodifiable(curTxs)));
    }
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final transactions = widget.transactions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: SearchField(
            value: widget.query,
            onValueChange: widget.onQueryChange,
            placeholder: 'Search merchant, category, code or amount.',
          ),
        ),
        if (transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: EmptyState(
              title: widget.query.isEmpty
                  ? 'No transactions yet'
                  : 'No matching transactions',
              description: widget.query.isEmpty
                  ? 'Import MPESA messages or add a transaction to start your ledger.'
                  : 'Try another filter or refine your search.',
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('Transactions',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          // Sections are pre-computed in _computeSections (called only when
          // transactions change) so build() is pure layout with no O(n) work.
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (date, txs) in _sections) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox.shrink(),
                      Text(date,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                AppCard(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < txs.length; i++) ...[
                        if (i > 0) const SizedBox(height: 6),
                        FinanceTransactionRowWidget(
                          transaction: txs[i],
                          onRecategorize: () => widget.onRecategorize(txs[i]),
                          onDelete: () => widget.onDelete(txs[i]),
                          onMerchantClick: widget.onMerchantClick,
                          onClick: () => widget.onTransactionClick(txs[i]),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// Row layout parity: AppCard with merchant (primary), "Category · date"
/// subtitle, Category/Delete/Share inline buttons, amount right-aligned.
class FinanceTransactionRowWidget extends StatelessWidget {
  const FinanceTransactionRowWidget({
    super.key,
    required this.transaction,
    required this.onRecategorize,
    required this.onDelete,
    required this.onMerchantClick,
    required this.onClick,
  });

  final FinanceTransaction transaction;
  final VoidCallback onRecategorize;
  final VoidCallback onDelete;
  final ValueChanged<String> onMerchantClick;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tx = transaction;
    final dateStr =
        AppDateUtils.formatDate(tx.date, 'MMM dd, yyyy').replaceAll(', yyyy', '');
    // Kotlin uses pattern "MMM d, h:mm a".
    final d = DateTime.fromMillisecondsSinceEpoch(tx.date);
    var hour = d.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    final timeStr =
        '${kMonthNamesShort[d.month - 1]} ${d.day}, $hour:${d.minute.toString().padLeft(2, '0')} $ampm';

    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: onClick,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => onMerchantClick(tx.merchant),
                    behavior: HitTestBehavior.opaque,
                    child: Text(tx.merchant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: scheme.primary)),
                  ),
                  const SizedBox(height: 4),
                  Text('${tx.category} · $timeStr',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  Row(
                    children: [
                      _miniBtn(context, 'Category', onRecategorize),
                      _miniBtn(context, 'Delete', onDelete, error: true),
                      _miniIconBtn(context, Icons.share_outlined, () {
                        final dateStr = AppDateUtils.formatRelativeTime(tx.date);
                        final isIncome = tx.transactionType == 'RECEIVED' ||
                            tx.transactionType == 'DEPOSIT';
                        final sign = isIncome ? '+' : '-';
                        final lines = [
                          '📱 LifeOS Transaction',
                          '${isIncome ? '↓ Received' : '↑ Sent'}  $sign${AppDateUtils.formatCurrency(tx.amount)}',
                          '🏪 ${tx.merchant}',
                          '🏷 ${tx.category}  ·  $dateStr',
                          if (tx.mpesaCode != null && tx.mpesaCode!.isNotEmpty)
                            '🔖 Ref: ${tx.mpesaCode}',
                          if (tx.fee > 0)
                            '💸 Fee: ${AppDateUtils.formatCurrency(tx.fee)}',
                        ];
                        SharePlus.instance.share(
                          ShareParams(text: lines.join('\n')),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Kotlin: income (RECEIVED/DEPOSIT) → "+KSh X" in Success;
            // expense → plain "KSh X" in onSurface.
            Builder(builder: (context) {
              final isIncome =
                  transaction.transactionType == 'RECEIVED' || transaction.transactionType == 'DEPOSIT';
              return Text(
                isIncome
                    ? '+${AppDateUtils.formatCurrency(transaction.amount)}'
                    : AppDateUtils.formatCurrency(transaction.amount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          isIncome ? LifeOsColors.success : Theme.of(context).colorScheme.onSurface,
                    ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _miniBtn(BuildContext context, String label, VoidCallback onTap,
      {bool error = false}) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: error ? scheme.error : null)),
    );
  }

  Widget _miniIconBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon,
          size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      constraints: const BoxConstraints(minWidth: 28, minHeight: 24),
    );
  }
}

// ── FinanceInsightCard (200dp wide, Budget/Fuliza/Fees chips) ────────────────

class FinanceInsightCard extends StatelessWidget {
  const FinanceInsightCard({
    super.key,
    required this.label,
    required this.amount,
    required this.sub,
    this.onAction,
  });

  final String label;
  final double amount;
  final String sub;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 200,
      child: AppCard(
        contentPadding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: onAction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
              Text(AppDateUtils.formatCurrency(amount),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(sub,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  if (onAction != null)
                    Text('View',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: scheme.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
