/// 1:1 ports of FinanceDialogs.kt — AddTransactionBottomSheet,
/// CategoryPickerBottomSheet, SmsImportBottomSheet (3-step wizard),
/// FulizaLimitDialog and the delete-confirmation dialog from FinanceScreen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/date_utils.dart';
import '../../../ui/theme/colors.dart';
import '../../../core/designsystem/dialogs.dart';

const List<String> kFinanceCategories = [
  'Food',
  'Transport',
  'Rent',
  'Utilities',
  'Airtime',
  'Shopping',
  'Entertainment',
  'Health',
  'Education',
  'Savings',
  'Investment',
  'Income',
  'Fuliza',
  'Other',
];

/// Category icon resolver (Kotlin `categoryIcon(name)` parity).
IconData categoryIcon(String category) {
  switch (category.toUpperCase()) {
    case 'FOOD':
      return Icons.restaurant_outlined;
    case 'TRANSPORT':
      return Icons.directions_bus_outlined;
    case 'RENT':
      return Icons.home_outlined;
    case 'UTILITIES':
      return Icons.bolt_outlined;
    case 'AIRTIME':
      return Icons.smartphone_outlined;
    case 'SHOPPING':
      return Icons.shopping_bag_outlined;
    case 'ENTERTAINMENT':
      return Icons.movie_outlined;
    case 'HEALTH':
      return Icons.favorite_outline;
    case 'EDUCATION':
      return Icons.school_outlined;
    case 'SAVINGS':
      return Icons.savings_outlined;
    case 'INVESTMENT':
      return Icons.trending_up_outlined;
    case 'INCOME':
      return Icons.payments_outlined;
    case 'FULIZA':
      return Icons.bolt_outlined;
    default:
      return Icons.category_outlined;
  }
}

// ── SMS import windows (SMS_IMPORT_WINDOWS parity) ─────────────────────────

const List<(String, int)> kSmsImportWindows = [
  ('23 hrs', 1),
  ('1 month', 30),
  ('3 months', 90),
  ('6 months', 180),
];

String institutionDisplayName(String id) {
  switch (id) {
    case 'mpesa':
      return 'M-Pesa';
    case 'airtel':
      return 'Airtel Money';
    case 'tkash':
      return 'T-Kash';
    case 'kcb':
      return 'KCB';
    case 'equity':
      return 'Equity Bank';
    case 'coopbank':
      return 'Co-op Bank';
    case 'ncba':
      return 'NCBA / Loop';
    case 'absa':
      return 'Absa';
    case 'stanchart':
      return 'StanChart';
    case 'dtb':
      return 'DTB';
    case 'family':
      return 'Family Bank';
    case 'im':
      return 'I&M Bank';
    case 'stanbic':
      return 'Stanbic';
    case 'sbm':
      return 'SBM Bank';
    case 'hfgroup':
      return 'HF Group';
    case 'gulf':
      return 'Gulf African Bank';
    case 'boa':
      return 'Bank of Africa';
    case 'primebank':
      return 'Prime Bank';
    case 'pesalink':
      return 'PesaLink';
    default:
      return id.isEmpty ? id : id[0].toUpperCase() + id.substring(1);
  }
}

// ── Add Transaction — ModalBottomSheet (AddTransactionDialog.kt) ────────────

class AddTransactionBottomSheet extends StatefulWidget {
  const AddTransactionBottomSheet({
    super.key,
    required this.onDismiss,
    required this.onAdd,
  });

  final VoidCallback onDismiss;
  final void Function(
          double amount, String merchant, String category, String? notes, double fee)
      onAdd;

  @override
  State<AddTransactionBottomSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionBottomSheet> {
  final _amount = TextEditingController();
  final _merchant = TextEditingController();
  final _fee = TextEditingController();
  final _notes = TextEditingController();
  String _category = 'Other';

  @override
  void dispose() {
    _amount.dispose();
    _merchant.dispose();
    _fee.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom +
              MediaQuery.paddingOf(context).bottom,
          top: 4),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Add Transaction',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: scheme.onSurface)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _outlinedField(
                  _amount, 'Amount (KES)', TextInputType.numberWithOptions(decimal: true)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _outlinedField(_merchant, 'Merchant / Payee', TextInputType.text),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
                items: [
                  for (final c in kFinanceCategories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'Other'),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _outlinedField(
                  _fee, 'Transaction Fee (KES)', TextInputType.numberWithOptions(decimal: true)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _notes,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: widget.onDismiss,
                      child: Text('Cancel',
                          style: TextStyle(color: scheme.onSurfaceVariant))),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final amount = double.tryParse(_amount.text.trim());
                      final merchant = _merchant.text.trim();
                      if (amount != null && merchant.isNotEmpty) {
                        widget.onAdd(
                          amount,
                          merchant,
                          _category,
                          _notes.text.trim().isEmpty ? null : _notes.text.trim(),
                          double.tryParse(_fee.text.trim()) ?? 0.0,
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _outlinedField(
      TextEditingController controller, String label, TextInputType type) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: scheme.primary),
        ),
      ),
    );
  }
}

// ── Edit Transaction — ModalBottomSheet ─────────────────────────────────────

/// Bottom sheet that lets the user re-categorize a transaction.
/// All other fields (amount, merchant, fee, notes) are auto-filled from the
/// SMS parse and are shown read-only — only the category can be changed.
class EditTransactionBottomSheet extends StatefulWidget {
  const EditTransactionBottomSheet({
    super.key,
    required this.transaction,
    required this.onDismiss,
    required this.onSave,
  });

  final dynamic transaction; // FinanceTransaction
  final VoidCallback onDismiss;
  /// Called with the newly selected category string.
  final void Function(String category) onSave;

  @override
  State<EditTransactionBottomSheet> createState() =>
      _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<EditTransactionBottomSheet> {
  late String _category;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    final stored = (tx.category ?? 'Other') as String;
    _category = kFinanceCategories.firstWhere(
      (c) => c.toLowerCase() == stored.toLowerCase(),
      orElse: () => 'Other',
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tx = widget.transaction;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom +
              MediaQuery.paddingOf(context).bottom,
          top: 4),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Edit Category',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: scheme.onSurface)),
            ),
            const SizedBox(height: 4),
            // ── Read-only transaction summary ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${tx.merchant} · ${tx.amount < 0 ? '-' : ''}KSh ${tx.amount.abs().toStringAsFixed(0)}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            // ── Category picker ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DropdownButtonFormField<String>(
                value: _category,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: scheme.primary),
                  ),
                ),
                items: [
                  for (final c in kFinanceCategories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'Other'),
              ),
            ),
            const SizedBox(height: 16),
            // ── Actions ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: widget.onDismiss,
                      child: Text('Cancel',
                          style: TextStyle(color: scheme.onSurfaceVariant))),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => widget.onSave(_category),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Category picker — ModalBottomSheet (CategoryPickerBottomSheet.kt) ───────

class CategoryPickerBottomSheet extends StatelessWidget {
  const CategoryPickerBottomSheet({
    super.key,
    required this.currentCategory,
    required this.onDismiss,
    required this.onSelect,
  });

  final String currentCategory;
  final VoidCallback onDismiss;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheetHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text('Change Category',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final c in kFinanceCategories)
                InkWell(
                  onTap: () => onSelect(c),
                  child: Container(
                    color: c.toLowerCase() == currentCategory.toLowerCase()
                        ? scheme.primary.withValues(alpha: 0.10)
                        : Colors.transparent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        Icon(categoryIcon(c),
                            size: 22,
                            color: categoryColorFor(c)),
                        const SizedBox(width: 14),
                        Text(
                          c,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: c.toLowerCase() ==
                                        currentCategory.toLowerCase()
                                    ? scheme.primary
                                    : scheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
      ],
    );
  }
}

// ── SMS import — 3-step ModalBottomSheet (SmsImportBottomSheet.kt) ──────────

class SmsImportBottomSheet extends StatefulWidget {
  const SmsImportBottomSheet({
    super.key,
    required this.onDismiss,
    required this.onDetect,
    required this.onImportDays,
  });

  final VoidCallback onDismiss;
  final void Function(int days) onDetect;
  final void Function(int days) onImportDays;

  @override
  State<SmsImportBottomSheet> createState() => _SmsImportBottomSheetState();
}

class _SmsImportBottomSheetState extends State<SmsImportBottomSheet> {
  String _filter = 'ALL'; // ALL | MPESA_ONLY | BANKS_ONLY
  int? _pendingDays;
  bool _detecting = false;
  Map<String, int>? _detected;

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
            // Step 2a: scanning in progress
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
            // Step 2b: show counts → confirm import
            _buildDetected(context, _detected!)
          else
            // Step 1: filter + time period selection
            _buildFilterStep(context),
        ],
      ),
    );
  }

  Widget _buildFilterStep(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
        const SizedBox(height: 8),
        // Filter radio group
        for (final (value, label) in [
          ('ALL', 'M-Pesa + Banks'),
          ('MPESA_ONLY', 'M-Pesa Only'),
          ('BANKS_ONLY', 'Banks Only'),
        ])
          InkWell(
            onTap: () => setState(() => _filter = value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Radio<String>(
                    value: value,
                    groupValue: _filter,
                    onChanged: (_) => setState(() => _filter = value),
                  ),
                  const SizedBox(width: 8),
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Select time period to scan',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ),
        const SizedBox(height: 8),
        // Time-window options
        for (final (label, days) in kSmsImportWindows)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: InkWell(
              onTap: () {
                setState(() {
                  _pendingDays = days;
                  _detecting = true;
                });
                widget.onDetect(days);
              },
              borderRadius: BorderRadius.circular(6),
              child: Ink(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Text('$label',
                    style: Theme.of(context).textTheme.bodyLarge),
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
    final entries = detected.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
                    if (days != null) widget.onImportDays(days);
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
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

  void completeDetection(Map<String, int>? detected) {
    if (!mounted) return;
    setState(() {
      _detecting = false;
      _detected = detected;
    });
  }
}

// ── Fuliza limit dialog (FulizaLimitDialog.kt) ───────────────────────────────

class FulizaLimitDialog extends StatefulWidget {
  const FulizaLimitDialog({
    super.key,
    this.initialLimitKes,
    required this.onDismiss,
    required this.onSave,
  });

  final double? initialLimitKes;
  final VoidCallback onDismiss;
  final ValueChanged<double> onSave;

  @override
  State<FulizaLimitDialog> createState() => _FulizaLimitDialogState();
}

class _FulizaLimitDialogState extends State<FulizaLimitDialog> {
  late final TextEditingController _limit =
      TextEditingController(text: widget.initialLimitKes?.toInt().toString() ?? '');

  @override
  void dispose() {
    _limit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LifeOsAlertDialog(
      title: Text('Set Fuliza Limit', style: TextStyle(color: scheme.onSurface)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'We detected Fuliza activity. Enter your personal Fuliza limit in KES to improve debt tracking accuracy.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _limit,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Fuliza limit (KES)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: widget.onDismiss,
            child: Text('Later',
                style: TextStyle(color: scheme.onSurfaceVariant))),
        FilledButton(
          onPressed: () {
            final limit = double.tryParse(_limit.text);
            if (limit != null && limit >= 0) widget.onSave(limit);
          },
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ── CSV import — 3-step ModalBottomSheet (CsvImportModal.kt) ─────────────────

class CsvRow {
  const CsvRow({
    required this.date,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
  });
  final int date;
  final double amount;
  final String type; // INCOME | EXPENSE
  final String category;
  final String description;
}

class CsvImportBottomSheet extends StatefulWidget {
  const CsvImportBottomSheet({
    super.key,
    required this.onDismiss,
    required this.onPickFile,
    required this.onImport,
  });

  final VoidCallback onDismiss;

  /// Returns parsed rows + errors for the picked file path.
  final Future<CsvParseResult> Function() onPickFile;

  /// Persists the confirmed rows; returns the imported count.
  final Future<int> Function(List<CsvRow> rows) onImport;

  @override
  State<CsvImportBottomSheet> createState() => _CsvImportBottomSheetState();
}

class CsvParseResult {
  const CsvParseResult({required this.rows, required this.errors});
  final List<CsvRow> rows;
  final int errors;
}

class _CsvImportBottomSheetState extends State<CsvImportBottomSheet> {
  CsvParseResult? _parsed;
  bool _picking = false;
  bool _importing = false;
  int? _importedCount;

  Future<void> _pick() async {
    setState(() => _picking = true);
    final result = await widget.onPickFile();
    if (!mounted) return;
    setState(() {
      _picking = false;
      _parsed = result;
    });
  }

  Future<void> _confirm() async {
    final rows = _parsed?.rows ?? const <CsvRow>[];
    if (rows.isEmpty) return;
    setState(() => _importing = true);
    final count = await widget.onImport(rows);
    if (!mounted) return;
    setState(() {
      _importing = false;
      _importedCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget step;
    if (_importedCount != null) {
      step = _doneStep(context, _importedCount!);
    } else if (_parsed != null && (_parsed!.rows.isNotEmpty || _parsed!.errors > 0)) {
      step = _previewStep(context);
    } else {
      step = _pickStep(context);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: step,
          ),
        ],
      ),
    );
  }

  Widget _pickStep(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Import from CSV',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          'Select a CSV file with columns: date, amount, type, category, description. '
          'Supported date formats: yyyy-MM-dd, dd/MM/yyyy, MM/dd/yyyy. '
          'Type values: INCOME, EXPENSE (or IN/CREDIT/RECEIVED for income).',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: _picking ? null : _pick,
            style: FilledButton.styleFrom(
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: _picking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Choose File'),
          ),
        ),
        TextButton(
            onPressed: widget.onDismiss,
            child: const Text('Cancel')),
      ],
    );
  }

  Widget _previewStep(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rows = _parsed!.rows;
    final errors = _parsed!.errors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Preview — ${rows.length} transaction${rows.length == 1 ? '' : 's'}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        if (errors > 0) ...[
          const SizedBox(height: 4),
          Text(
            '$errors row${errors == 1 ? '' : 's'} could not be parsed and will be skipped.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.error),
          ),
        ],
        if (rows.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: rows.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.4)),
              itemBuilder: (_, i) {
                final row = rows[i];
                final isIncome = row.type == 'INCOME';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(row.description.isEmpty ? row.category : row.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w500)),
                            Text(
                              '${AppDateUtils.formatDate(row.date, 'MMM d, yyyy')} · ${row.category}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        isIncome
                            ? '+KSh ${row.amount.toInt()}'
                            : 'KSh ${row.amount.toInt()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isIncome
                                  ? const Color(0xFF34D399)
                                  : scheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (_importing)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 12),
              Text('Importing…',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          )
        else ...[
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: rows.isEmpty ? null : _confirm,
              style: FilledButton.styleFrom(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(
                  'Import ${rows.length} transaction${rows.length == 1 ? '' : 's'}'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: widget.onDismiss,
              style: OutlinedButton.styleFrom(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _doneStep(BuildContext context, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Import complete',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          'Successfully imported $count transaction${count == 1 ? '' : 's'}.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: const Color(0xFF34D399)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: widget.onDismiss,
            style: FilledButton.styleFrom(
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}

// ── Delete confirmation — red Delete confirm button (FinanceScreen parity) ──

class DeleteTransactionDialog extends StatelessWidget {
  const DeleteTransactionDialog({
    super.key,
    required this.merchant,
    required this.formattedAmount,
    required this.onDelete,
    required void Function() onCancel,
  }) : _onCancel = onCancel;

  final String merchant;
  final String formattedAmount;
  final VoidCallback onDelete;
  final VoidCallback _onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LifeOsAlertDialog(
      title: const Text('Delete transaction?'),
      content: Text('Remove "$merchant" ($formattedAmount)? This cannot be undone.'),
      actions: [
        TextButton(onPressed: _onCancel, child: const Text('Cancel')),
        FilledButton(
          onPressed: onDelete,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
