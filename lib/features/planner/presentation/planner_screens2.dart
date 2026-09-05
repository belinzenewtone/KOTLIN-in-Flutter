/// Income / Recurring / Bills sub-screens (continued planner suite).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database.dart';
import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/banners.dart';
import '../../../core/designsystem/controls.dart';
import '../../../core/designsystem/metric_card.dart';
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../navigation/routes.dart';
import '../data/planner_repository.dart';
import 'planner_screens.dart';

// ── Income ───────────────────────────────────────────────────────────────────

class IncomeScreen extends ConsumerStatefulWidget {
  const IncomeScreen({super.key});

  @override
  ConsumerState<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends ConsumerState<IncomeScreen> {
  PlannerRepository? _repo;

  @override
  void initState() {
    super.initState();
    () async {
      final repo = await ref.read(plannerRepositoryProvider.future);
      if (!mounted) return;
      setState(() => _repo = repo);
    }();
  }

  static const _kFrequencies = ['DAILY', 'WEEKLY', 'MONTHLY'];

  Future<void> _showAddIncomeDialog() async {
    final sourceC = TextEditingController();
    final amountC = TextEditingController();
    final noteC = TextEditingController();
    String? sourceError;
    bool isRecurring = false;
    String frequency = 'MONTHLY';
    DateTime? selectedDate;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          title: const Text('Add Income'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: sourceC,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Source',
                    border: const OutlineInputBorder(),
                    errorText: sourceError,
                  ),
                  onChanged: (_) {
                    if (sourceError != null) {
                      setDialogState(() => sourceError = null);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: 'KSh ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // ── Date picker ─────────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(
                    selectedDate == null
                        ? 'Pick date (optional)'
                        : AppDateUtils.formatDate(
                            selectedDate!.millisecondsSinceEpoch,
                            'MMM dd, yyyy'),
                  ),
                ),
                const SizedBox(height: 12),
                // ── Note ────────────────────────────────────────────────
                TextField(
                  controller: noteC,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // ── Recurring toggle ─────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Text('Recurring',
                          style: Theme.of(ctx).textTheme.bodyMedium),
                    ),
                    LifeOsSwitch(
                      value: isRecurring,
                      onChanged: (v) => setDialogState(() => isRecurring = v),
                    ),
                  ],
                ),
                if (isRecurring) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: frequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: _kFrequencies
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => frequency = v);
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (sourceC.text.trim().isEmpty) {
                  setDialogState(() => sourceError = 'Source is required');
                  return;
                }
                final amount = double.tryParse(amountC.text.trim()) ?? 0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('Enter a valid amount greater than 0')));
                  return;
                }
                await _repo!.addIncome(
                  amount,
                  sourceC.text.trim(),
                  note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
                  isRecurring: isRecurring,
                  frequency: isRecurring ? frequency : null,
                  date: selectedDate?.millisecondsSinceEpoch,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditIncomeDialog(Income inc) async {
    final sourceC = TextEditingController(text: inc.source);
    final amountC = TextEditingController(text: inc.amount.toStringAsFixed(0));
    final noteC = TextEditingController(text: inc.note);
    bool isRecurring = inc.isRecurring;
    String frequency = inc.frequency ?? 'MONTHLY';
    DateTime selectedDate = DateTime.fromMillisecondsSinceEpoch(inc.date);

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          title: const Text('Edit Income'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: sourceC,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Source',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: 'KSh ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(AppDateUtils.formatDate(
                      selectedDate.millisecondsSinceEpoch, 'MMM dd, yyyy')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteC,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: Text('Recurring',
                      style: Theme.of(ctx).textTheme.bodyMedium)),
                  LifeOsSwitch(
                    value: isRecurring,
                    onChanged: (v) => setDialogState(() => isRecurring = v),
                  ),
                ]),
                if (isRecurring) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: frequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency', border: OutlineInputBorder()),
                    items: _kFrequencies
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => frequency = v);
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (sourceC.text.trim().isEmpty) return;
                final amount = double.tryParse(amountC.text.trim()) ?? 0;
                if (amount <= 0) return;
                await _repo!.updateIncome(
                  inc.id,
                  amount: amount,
                  source: sourceC.text.trim(),
                  note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
                  isRecurring: isRecurring,
                  frequency: isRecurring ? frequency : null,
                  date: selectedDate.millisecondsSinceEpoch,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    sourceC.dispose(); amountC.dispose(); noteC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_repo == null) return const CircularProgressIndicator();
    return StreamBuilder<List<Income>>(
      stream: _repo!.watchIncomes(),
      builder: (context, snap) {
        final incomes = snap.data ?? [];
        final total = incomes.fold<double>(0, (s, i) => s + i.amount);
        return PageScaffold(
          title: 'Income',
          subtitle: '${incomes.length} entries tracked',
          onBack: () => context.pop(),
          actions: [
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                onPressed: _showAddIncomeDialog,
                icon: const Icon(Icons.add_outlined),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Summary card ─────────────────────────────────────────────
              _IncomeSummaryCard(total: total),
              const SizedBox(height: 12),
              // ── Income rows ──────────────────────────────────────────────
              if (incomes.isEmpty)
                const EmptyState(
                  title: 'No income logged',
                  description: 'Add your salary, side income, or any money in.',
                )
              else
                for (final inc in incomes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _IncomeCard(
                      income: inc,
                      onEdit: () => _showEditIncomeDialog(inc),
                      onDelete: () async => _repo!.deleteIncome(inc.id),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _IncomeCard extends StatelessWidget {
  const _IncomeCard({
    required this.income,
    required this.onDelete,
    required this.onEdit,
  });
  final Income income;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(income.source, style: tt.titleSmall),
                    Text(
                      AppDateUtils.formatDate(income.date, 'MMM dd, yyyy'),
                      style: tt.labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(
                formatCurrency(income.amount),
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, size: 18, color: scheme.primary),
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: scheme.error),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          if (income.note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              income.note,
              style: tt.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          if (income.isRecurring && income.frequency != null) ...[
            const SizedBox(height: 4),
            Text(
              '↻ ${income.frequency}',
              style: tt.labelSmall?.copyWith(color: scheme.primary),
            ),
          ],
        ],
      ),
    );
  }
}

class _IncomeSummaryCard extends StatelessWidget {
  const _IncomeSummaryCard({required this.total});
  final double total;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Monthly income',
            style: tt.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            formatCurrency(total),
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF34D399),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recurring ────────────────────────────────────────────────────────────────

const _kRecurringTypes = ['EXPENSE', 'INCOME'];
const _kRecurringCadences = ['DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY'];
const _kRecurringCategories = [
  'FOOD', 'TRANSPORT', 'UTILITIES', 'ENTERTAINMENT', 'SHOPPING',
  'HEALTH', 'EDUCATION', 'HOUSING', 'AIRTIME', 'SAVINGS',
  'PERSONAL CARE', 'SUBSCRIPTIONS', 'FULIZA', 'OTHER',
];

class RecurringScreen extends ConsumerStatefulWidget {
  const RecurringScreen({super.key});

  @override
  ConsumerState<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends ConsumerState<RecurringScreen> {
  PlannerRepository? _repo;

  @override
  void initState() {
    super.initState();
    () async {
      final repo = await ref.read(plannerRepositoryProvider.future);
      if (!mounted) return;
      setState(() => _repo = repo);
    }();
  }

  Future<void> _showAddRecurringDialog() async {
    final titleC = TextEditingController();
    final amountC = TextEditingController();
    String selectedType = 'EXPENSE';
    String selectedCadence = 'MONTHLY';
    String selectedCategory = 'UTILITIES';
    DateTime? nextRunDate;
    String? titleError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          title: const Text('Add Recurring Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleC,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: const OutlineInputBorder(),
                    errorText: titleError,
                  ),
                  onChanged: (_) {
                    if (titleError != null) {
                      setDialogState(() => titleError = null);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _kRecurringTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedType = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCadence,
                  decoration: const InputDecoration(
                    labelText: 'Cadence',
                    border: OutlineInputBorder(),
                  ),
                  items: _kRecurringCadences
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedCadence = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _kRecurringCategories
                      .map((c) => DropdownMenuItem(
                          value: c, child: Text(_titleCaseRec(c))))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedCategory = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (optional)',
                    prefixText: 'KSh ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // ── Next run date picker ────────────────────────────────
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setDialogState(() => nextRunDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(
                    nextRunDate == null
                        ? 'Next run date (optional)'
                        : AppDateUtils.formatDate(
                            nextRunDate!.millisecondsSinceEpoch, 'MMM dd, yyyy'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleC.text.trim().isEmpty) {
                  setDialogState(() => titleError = 'Title is required');
                  return;
                }
                final amount = amountC.text.trim().isEmpty
                    ? null
                    : double.tryParse(amountC.text.trim());
                await _repo!.addRecurring(
                  title: titleC.text.trim(),
                  type: selectedType,
                  cadence: selectedCadence,
                  amount: amount,
                  category: selectedCategory,
                  nextRunAt: nextRunDate?.millisecondsSinceEpoch,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditRecurringDialog(RecurringRule rule) async {
    final titleC = TextEditingController(text: rule.title);
    final amountC = TextEditingController(
        text: rule.amount != null ? rule.amount!.toStringAsFixed(0) : '');
    String selectedType = rule.type;
    String selectedCadence = rule.cadence;
    String selectedCategory = rule.category.isNotEmpty ? rule.category : 'RECURRING';
    DateTime? nextRunDate = rule.nextRunAt > 0
        ? DateTime.fromMillisecondsSinceEpoch(rule.nextRunAt)
        : null;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          title: const Text('Edit Recurring Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleC,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                      labelText: 'Type', border: OutlineInputBorder()),
                  items: _kRecurringTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedType = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCadence,
                  decoration: const InputDecoration(
                      labelText: 'Cadence', border: OutlineInputBorder()),
                  items: _kRecurringCadences
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedCadence = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                      labelText: 'Category', border: OutlineInputBorder()),
                  items: _kRecurringCategories
                      .map((c) => DropdownMenuItem(
                          value: c, child: Text(_titleCaseRec(c))))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedCategory = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountC,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (optional)',
                    prefixText: 'KSh ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: nextRunDate ??
                          DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) setDialogState(() => nextRunDate = picked);
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(nextRunDate == null
                      ? 'Next run date'
                      : AppDateUtils.formatDate(
                          nextRunDate!.millisecondsSinceEpoch, 'MMM dd, yyyy')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (titleC.text.trim().isEmpty) return;
                final amount = amountC.text.trim().isEmpty
                    ? null
                    : double.tryParse(amountC.text.trim());
                await _repo!.updateRecurring(
                  id: rule.id,
                  title: titleC.text.trim(),
                  type: selectedType,
                  cadence: selectedCadence,
                  amount: amount,
                  category: selectedCategory,
                  nextRunAt: nextRunDate?.millisecondsSinceEpoch,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    titleC.dispose();
    amountC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_repo == null) return const CircularProgressIndicator();
    return StreamBuilder<List<RecurringRule>>(
      stream: _repo!.watchRecurring(),
      builder: (context, snap) {
        final rules = snap.data ?? [];
        return PageScaffold(
          title: 'Recurring',
          headerEyebrow: 'Automation',
          subtitle: '${rules.length} rules active',
          onBack: () => context.pop(),
          actions: [
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                onPressed: _showAddRecurringDialog,
                icon: const Icon(Icons.add_outlined),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
          child: rules.isEmpty
              ? const EmptyState(
                  title: 'No recurring rules',
                  description:
                      'Create a rule and the app generates its entries automatically.',
                )
              : Column(
                  children: [
                    for (final r in rules)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _RecurringCard(
                          rule: r,
                          onToggle: () async => _repo!.toggleRecurring(r),
                          onDelete: () async => _repo!.deleteRecurring(r.id),
                          onEdit: () => _showEditRecurringDialog(r),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _RecurringCard extends StatelessWidget {
  const _RecurringCard({
    required this.rule,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });
  final RecurringRule rule;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final nextRun = AppDateUtils.formatDate(rule.nextRunAt, 'MMM dd, yyyy');
    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(rule.title, style: tt.titleSmall),
                    Text(
                      '${rule.type} · ${rule.cadence}'
                      '${rule.category.isNotEmpty && rule.category != 'RECURRING' ? ' · ${_titleCaseRec(rule.category)}' : ''}',
                      style: tt.labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              LifeOsSwitch(
                value: rule.enabled,
                onChanged: (_) => onToggle(),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, size: 18, color: scheme.primary),
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: scheme.error),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          if (rule.amount != null) ...[
            const SizedBox(height: 4),
            Text(
              formatCurrency(rule.amount!),
              style: tt.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600, color: scheme.onSurface),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Next run: $nextRun',
            style: tt.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

String _titleCaseRec(String s) => s
    .split(' ')
    .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
    .join(' ');

// ── Bills ─────────────────────────────────────────────────────────────────────

const _kBillCycles = ['MONTHLY', 'WEEKLY', 'QUARTERLY', 'YEARLY'];

class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> {
  PlannerRepository? _repo;

  @override
  void initState() {
    super.initState();
    () async {
      final repo = await ref.read(plannerRepositoryProvider.future);
      if (!mounted) return;
      setState(() => _repo = repo);
    }();
  }

  Future<void> _showEditBillDialog(Bill bill) async {
    final titleC = TextEditingController(text: bill.title);
    final amountC = TextEditingController(text: bill.amount.toStringAsFixed(0));
    final notesC = TextEditingController(text: bill.notes);
    String selectedCycle = bill.cycle;
    DateTime selectedDueDate =
        DateTime.fromMillisecondsSinceEpoch(bill.nextDueDate);
    String? titleError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          title: const Text('Edit Bill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleC,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: const OutlineInputBorder(),
                    errorText: titleError,
                  ),
                  onChanged: (_) {
                    if (titleError != null) {
                      setDialogState(() => titleError = null);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountC,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: 'KSh ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCycle,
                  decoration: const InputDecoration(
                    labelText: 'Cycle',
                    border: OutlineInputBorder(),
                  ),
                  items: _kBillCycles
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedCycle = v);
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDueDate,
                      firstDate: DateTime.now()
                          .subtract(const Duration(days: 30)),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDueDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(AppDateUtils.formatDate(
                      selectedDueDate.millisecondsSinceEpoch,
                      'MMM dd, yyyy')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesC,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleC.text.trim().isEmpty) {
                  setDialogState(() => titleError = 'Title is required');
                  return;
                }
                final amount = double.tryParse(amountC.text.trim());
                if (amount == null || amount <= 0) return;
                await _repo!.updateBill(
                  id: bill.id,
                  title: titleC.text.trim(),
                  amount: amount,
                  cycle: selectedCycle,
                  nextDueDate: selectedDueDate.millisecondsSinceEpoch,
                  notes: notesC.text.trim(),
                );
                // Reschedule the OS reminder for the updated due date.
                unawaited(NotificationService.scheduleBillReminder(
                  billId: bill.id,
                  billTitle: titleC.text.trim(),
                  dueDateMillis: selectedDueDate.millisecondsSinceEpoch,
                  amount: amount,
                ));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddBillDialog() async {
    final titleC = TextEditingController();
    final amountC = TextEditingController();
    final notesC = TextEditingController();
    String selectedCycle = 'MONTHLY';
    DateTime? selectedDueDate;
    String? titleError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          title: const Text('Add Bill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleC,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: const OutlineInputBorder(),
                    errorText: titleError,
                  ),
                  onChanged: (_) {
                    if (titleError != null) {
                      setDialogState(() => titleError = null);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: 'KSh ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCycle,
                  decoration: const InputDecoration(
                    labelText: 'Cycle',
                    border: OutlineInputBorder(),
                  ),
                  items: _kBillCycles
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedCycle = v);
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDueDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(
                    selectedDueDate == null
                        ? 'Pick due date'
                        : AppDateUtils.formatDate(
                            selectedDueDate!.millisecondsSinceEpoch,
                            'MMM dd, yyyy'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesC,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleC.text.trim().isEmpty) {
                  setDialogState(() => titleError = 'Title is required');
                  return;
                }
                final amount = double.tryParse(amountC.text.trim()) ?? 0;
                if (amount <= 0) return;
                final dueDate = selectedDueDate ?? DateTime.now();
                await _repo!.addBill(
                  title: titleC.text.trim(),
                  amount: amount,
                  cycle: selectedCycle,
                  nextDueDate: dueDate.millisecondsSinceEpoch,
                  notes: notesC.text.trim(),
                );
                // Schedule a 1-day-before reminder for the bill.
                unawaited(NotificationService.scheduleBillReminder(
                  billId: dueDate.millisecondsSinceEpoch, // unique per due date
                  billTitle: titleC.text.trim(),
                  dueDateMillis: dueDate.millisecondsSinceEpoch,
                  amount: amount,
                ));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_repo == null) return const CircularProgressIndicator();
    return StreamBuilder<List<Bill>>(
      stream: _repo!.watchBills(),
      builder: (context, snap) {
        final bills = snap.data ?? [];
        return PageScaffold(
          title: 'Bills',
          headerEyebrow: 'Recurring Obligations',
          subtitle: '${bills.length} bills tracked',
          onBack: () => context.pop(),
          actions: [
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                onPressed: _showAddBillDialog,
                icon: const Icon(Icons.add_outlined),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
          child: bills.isEmpty
              ? const EmptyState(
                  title: 'No bills tracked',
                  description: 'Add a payment to track when it\'s due.',
                )
              : Column(
                  children: [
                    for (final b in bills)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _BillCard(
                          bill: b,
                          onMarkPaid: () async => _repo!.markBillPaid(b),
                          onTogglePaid: () async => _repo!.toggleBillPaid(b),
                          onToggleActive: () async => _repo!.toggleActiveBill(b),
                          onDelete: () async => _repo!.deleteBill(b.id),
                          onEdit: () => _showEditBillDialog(b),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

// ── BillCard ─────────────────────────────────────────────────────────────────

class _BillCard extends StatelessWidget {
  const _BillCard({
    required this.bill,
    required this.onMarkPaid,
    required this.onTogglePaid,
    required this.onToggleActive,
    required this.onDelete,
    required this.onEdit,
  });

  final Bill bill;
  final VoidCallback onMarkPaid;
  final VoidCallback onTogglePaid;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now().millisecondsSinceEpoch;
    final isOverdue = bill.nextDueDate < now && !bill.paidStatus;

    final cardBody = InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(6),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Row 1: title + paid switch + delete ────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(bill.title, style: tt.titleSmall),
            ),
            LifeOsSwitch(
              value: bill.isActive,
              onChanged: (_) => onToggleActive(),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, size: 18, color: scheme.error),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // ── Row 2: amount+cycle label, due-date chip, paid chip ────────────
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${formatCurrency(bill.amount)} · ${bill.cycle}',
              style: tt.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            _SmallChip(
              label: 'Due ${AppDateUtils.formatDate(bill.nextDueDate, 'MMM dd')}',
              borderColor: isOverdue ? scheme.error : scheme.outlineVariant,
              textColor: isOverdue ? scheme.error : scheme.onSurfaceVariant,
            ),
            _SmallChip(
              label: bill.paidStatus ? 'Paid' : 'Unpaid',
              backgroundColor: bill.paidStatus
                  ? const Color(0xFF34D399).withValues(alpha: 0.18)
                  : const Color(0xFFF59E0B).withValues(alpha: 0.18),
              borderColor: bill.paidStatus
                  ? const Color(0xFF34D399)
                  : const Color(0xFFF59E0B),
              textColor: bill.paidStatus
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFD97706),
            ),
          ],
        ),
        // ── Notes ──────────────────────────────────────────────────────────
        if (bill.notes.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            bill.notes,
            style: tt.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
        // ── Mark Paid / Mark Unpaid ────────────────────────────────────────
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onTogglePaid,
            child: Text(
              bill.paidStatus ? 'Mark Unpaid' : 'Mark Paid',
              style: tt.labelMedium?.copyWith(
                color: bill.paidStatus ? scheme.onSurfaceVariant : scheme.primary,
              ),
            ),
          ),
        ),
      ],
    ),
    );

    // Overdue unpaid bills get an errorContainer background — AppCard does not
    // expose a color override so we use a styled Container for that case.
    if (isOverdue) {
      return Container(
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: scheme.error.withValues(alpha: 0.45),
            width: 0.85,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: cardBody,
      );
    }

    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: cardBody,
    );
  }
}

/// Minimal inline chip styled with RoundedCornerShape(6).
class _SmallChip extends StatelessWidget {
  const _SmallChip({
    required this.label,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  });

  final String label;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor ?? scheme.outlineVariant,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor ?? scheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
