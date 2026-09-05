/// Planner hub + Budget sub-screen (PlannerScreen.kt, BudgetScreen.kt ports).
///
/// The hub mirrors the Kotlin "Finance Tools" surface: hero header with
/// navigation cards to Budget / Income / Recurring / Bills / Goals / Loans /
/// Monthly Wrapped / Search / Export. Settings is excluded — it lives in Profile.
/// Each sub-screen is a PageScaffold list with AlertDialog add flows backed by
/// [PlannerRepository].
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
import '../../../core/designsystem/tokens.dart';
import '../../../navigation/routes.dart';
import '../../dashboard/data/providers.dart';
import '../data/planner_repository.dart';

final plannerRepositoryProvider = FutureProvider<PlannerRepository>(
    (ref) async {
  final db = await ref.watch(lifeOsDatabaseProvider.future);
  final userId = await ref.watch(userIdProvider.future);
  return PlannerRepository(db, userId);
});

// ── Budget categories — 14 items (Kotlin parity), stored UPPERCASE ────────────

const _kBudgetCategories = [
  'FOOD', 'TRANSPORT', 'UTILITIES', 'ENTERTAINMENT', 'SHOPPING',
  'HEALTH', 'EDUCATION', 'HOUSING', 'AIRTIME', 'SAVINGS',
  'PERSONAL CARE', 'SUBSCRIPTIONS', 'FULIZA', 'OTHER',
];

const _kPeriods = ['DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'];

String _titleCase(String s) => s
    .split(' ')
    .map((w) => w.isEmpty
        ? ''
        : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
    .join(' ');

// 3-tier status color: error ≥100%, warning ≥80%, success else
Color _statusColor(BuildContext ctx, double ratio) {
  final s = Theme.of(ctx).colorScheme;
  if (ratio >= 1.0) return s.error;
  if (ratio >= 0.8) return const Color(0xFFFBBF24);
  return const Color(0xFF34D399);
}

// ── Hub ───────────────────────────────────────────────────────────────────────

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const tools = [
      (
        'Budgets',
        'Set spending limits by category and track progress',
        Icons.account_balance_outlined,
        AppRoute.budget
      ),
      (
        'Income',
        'Log and review income sources',
        Icons.monetization_on_outlined,
        AppRoute.income
      ),
      (
        'Recurring',
        'Subscriptions, salaries, and scheduled payments',
        Icons.loop_outlined,
        AppRoute.recurring
      ),
      (
        'Loans & Fuliza',
        'Track outstanding Fuliza draws and repayment history',
        Icons.account_balance_wallet_outlined,
        AppRoute.loans
      ),
      (
        'Bills',
        'Track recurring bills and subscriptions with due dates',
        Icons.receipt_outlined,
        AppRoute.bills
      ),
      (
        'Search Finance',
        'Search transactions, budgets, and recurring entries',
        Icons.search_outlined,
        AppRoute.search
      ),
      (
        'Export',
        'Export your data as CSV or share a report',
        Icons.file_download_outlined,
        AppRoute.export
      ),
      (
        'Monthly Wrapped',
        'Your month in review — spending totals, top categories, and highlights',
        Icons.auto_awesome_outlined,
        AppRoute.monthlyWrapped
      ),
    ];

    return PageScaffold(
      headerEyebrow: 'Finance Tools',
      title: 'Finance Hub',
      subtitle: 'Manage budgets, income, recurring items, loans, and exports',
      contentPadding:
          const EdgeInsets.only(bottom: AppSpacing.bottomSafeWithFloatingNav),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (title, subtitle, icon, route) in tools)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                contentPadding: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: () => context.push('/$route'),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      Icon(icon, size: 22, color: scheme.primary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(title,
                                style: Theme.of(context).textTheme.titleSmall),
                            Text(subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          size: 18, color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Budget screen ─────────────────────────────────────────────────────────────

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  PlannerRepository? _repo;
  Map<String, double> _spend = {};
  String? _successMessage;
  String? _errorMessage;
  StreamSubscription<Map<String, double>>? _spendSub;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _spendSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = await ref.read(plannerRepositoryProvider.future);
    if (!mounted) return;
    setState(() => _repo = repo);
    // Subscribe to live spend so budget bars update as transactions change.
    _spendSub = repo.watchMonthSpendByCategory().listen((spend) {
      if (mounted) setState(() => _spend = spend);
    });
  }

  /// Unified add / edit dialog.
  Future<void> _showBudgetDialog({Budget? editing}) async {
    // initialise dialog state from existing budget when editing
    String selCategory =
        editing?.category ?? _kBudgetCategories.first;
    String selPeriod = editing?.period ?? 'MONTHLY';
    final limitC = TextEditingController(
        text: editing != null
            ? editing.limitAmount.toStringAsFixed(0)
            : '');
    final thresholdC = TextEditingController(
        text: editing != null && editing.alertThreshold != null
            ? (editing.alertThreshold! * 100).toStringAsFixed(0)
            : '');
    String? limitError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          final amount = double.tryParse(limitC.text.trim()) ?? 0.0;
          final periodLabel = switch (selPeriod) {
            'DAILY' => 'Daily',
            'WEEKLY' => 'Weekly',
            'YEARLY' => 'Yearly',
            _ => 'Monthly',
          };
          final String? hint = amount > 0
              ? switch (selPeriod) {
                  'MONTHLY' =>
                    'Daily equivalent: KSh ${(amount / 30).toStringAsFixed(0)}',
                  'WEEKLY' =>
                    'Monthly equivalent: KSh ${(amount * 4.33).toStringAsFixed(0)}',
                  'DAILY' =>
                    'Monthly equivalent: KSh ${(amount * 30).toStringAsFixed(0)}',
                  'YEARLY' =>
                    'Monthly equivalent: KSh ${(amount / 12).toStringAsFixed(0)}',
                  _ => null,
                }
              : null;

          return AlertDialog(
            backgroundColor:
                Theme.of(ctx).colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            title: Text(editing != null ? 'Edit Budget' : 'Set Budget'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Category ──────────────────────────────────────────
                  DropdownButtonFormField<String>(
                    value: selCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    items: _kBudgetCategories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(_titleCase(c)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setSt(() => selCategory = v);
                    },
                  ),
                  const SizedBox(height: 14),
                  // ── Period chips ──────────────────────────────────────
                  Text('Period',
                      style: Theme.of(ctx)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                              color: Theme.of(ctx)
                                  .colorScheme
                                  .onSurfaceVariant)),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final p in _kPeriods)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () => setSt(() => selPeriod = p),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: selPeriod == p
                                      ? Theme.of(ctx).colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selPeriod == p
                                        ? Theme.of(ctx)
                                            .colorScheme
                                            .primary
                                        : Theme.of(ctx)
                                            .colorScheme
                                            .outline,
                                  ),
                                ),
                                child: Text(
                                  _titleCase(p),
                                  style: Theme.of(ctx)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: selPeriod == p
                                            ? Theme.of(ctx)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(ctx)
                                                .colorScheme
                                                .onSurface,
                                        fontWeight: selPeriod == p
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // ── Limit amount ──────────────────────────────────────
                  TextField(
                    controller: limitC,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: '$periodLabel Limit (KES)',
                      prefixText: 'KSh ',
                      border: const OutlineInputBorder(),
                      errorText: limitError,
                    ),
                    onChanged: (v) {
                      setSt(() => limitError = null);
                    },
                  ),
                  if (hint != null) ...[
                    const SizedBox(height: 4),
                    Text(hint,
                        style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                            color: Theme.of(ctx)
                                .colorScheme
                                .onSurfaceVariant)),
                  ],
                  const SizedBox(height: 14),
                  // ── Alert threshold ───────────────────────────────────
                  TextField(
                    controller: thresholdC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Alert Threshold',
                      hintText: '80',
                      suffixText: '%',
                      border: OutlineInputBorder(),
                      helperText:
                          'Alert when spending reaches this % of limit',
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
                  final limit =
                      double.tryParse(limitC.text.trim()) ?? 0.0;
                  if (limit <= 0) {
                    setSt(() => limitError = 'Enter a valid amount');
                    return;
                  }
                  final tRaw =
                      double.tryParse(thresholdC.text.trim());
                  final threshold = tRaw != null
                      ? (tRaw / 100.0).clamp(0.0, 1.0)
                      : null;

                  try {
                    if (editing != null) {
                      await _repo!.updateBudget(
                        editing.id,
                        category: selCategory,
                        limitAmount: limit,
                        period: selPeriod,
                        alertThreshold: threshold,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        setState(
                            () => _successMessage = 'Budget updated');
                      }
                    } else {
                      await _repo!.addBudget(
                        selCategory,
                        limit,
                        period: selPeriod,
                        alertThreshold: threshold,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        setState(() => _successMessage = 'Budget saved');
                      }
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      setSt(() => limitError = e.toString());
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child:
                    Text(editing != null ? 'Update' : 'Set Budget'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_repo == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    return PageScaffold(
      headerEyebrow: 'Spending Guardrails',
      title: 'Budgets',
      onBack: () => context.pop(),
      topBanner: _successMessage != null
          ? TopBanner(
              message: _successMessage!,
              tone: TopBannerTone.success,
              onDismiss: () => setState(() => _successMessage = null),
            )
          : _errorMessage != null
              ? TopBanner(
                  message: _errorMessage!,
                  tone: TopBannerTone.error,
                  onDismiss: () => setState(() => _errorMessage = null),
                )
              : null,
      actions: [
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            onPressed: () => _showBudgetDialog(),
            icon: const Icon(Icons.add_outlined),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
      child: StreamBuilder<List<Budget>>(
        stream: _repo!.watchBudgets(),
        builder: (context, snap) {
          final budgets = snap.data ?? [];
          if (budgets.isEmpty) {
            return const EmptyState(
              title: 'No budgets yet',
              description:
                  'Tap + to set a monthly limit for any spending category.',
              icon: Icons.account_balance_outlined,
            );
          }

          final activeBudgets =
              budgets.where((b) => b.isActive).toList();
          final totalBudgeted =
              activeBudgets.fold<double>(0, (s, b) => s + b.limitAmount);
          final totalSpent = activeBudgets.fold<double>(
              0, (s, b) => s + (_spend[b.category] ?? 0));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BudgetMonthSummaryCard(
                totalBudgeted: totalBudgeted,
                totalSpent: totalSpent,
                activeCount: activeBudgets.length,
              ),
              const SizedBox(height: 12),
              for (final b in budgets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BudgetItemCard(
                    budget: b,
                    spent: _spend[b.category] ?? 0.0,
                    onEdit: () => _showBudgetDialog(editing: b),
                    onDelete: () async {
                      await _repo!.deleteBudget(b.id);
                      if (mounted) {
                        setState(
                            () => _successMessage = 'Budget deleted');
                      }
                    },
                    onToggleActive: (v) async {
                      await _repo!.toggleActiveBudget(b.id, v);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── BudgetMonthSummaryCard ────────────────────────────────────────────────────

class _BudgetMonthSummaryCard extends StatelessWidget {
  const _BudgetMonthSummaryCard({
    required this.totalBudgeted,
    required this.totalSpent,
    required this.activeCount,
  });

  final double totalBudgeted;
  final double totalSpent;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final rawRatio =
        totalBudgeted > 0 ? totalSpent / totalBudgeted : 0.0;
    final barRatio = rawRatio.clamp(0.0, 1.0);
    final statusColor = _statusColor(context, rawRatio);
    final pct = (rawRatio * 100).toStringAsFixed(1);
    final statusLabel = rawRatio >= 1.0
        ? 'Over by ${formatCurrency(totalSpent - totalBudgeted)}'
        : rawRatio >= 0.8
            ? 'Near limit'
            : 'On track';

    return AppCard(
      elevated: true,
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('This Month',
                  style: tt.labelMedium
                      ?.copyWith(color: scheme.onSurfaceVariant)),
              Text(
                '$activeCount ${activeCount == 1 ? 'category' : 'categories'} tracked',
                style: tt.labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(formatCurrency(totalSpent),
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text('of ${formatCurrency(totalBudgeted)}',
                        style: tt.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$pct%',
                      style: tt.titleSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600)),
                  Text(statusLabel,
                      style: tt.labelSmall
                          ?.copyWith(color: statusColor)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Animated progress bar — 600ms tween (Kotlin parity)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: barRatio),
            duration: const Duration(milliseconds: 600),
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 10,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── BudgetItemCard ────────────────────────────────────────────────────────────

class _BudgetItemCard extends StatelessWidget {
  const _BudgetItemCard({
    required this.budget,
    required this.spent,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  final Budget budget;
  final double spent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleActive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ratio =
        budget.limitAmount > 0 ? spent / budget.limitAmount : 0.0;
    final barRatio = ratio.clamp(0.0, 1.0);
    final statusColor = _statusColor(context, ratio);
    final pct = (ratio * 100).toStringAsFixed(1);
    final remaining =
        (budget.limitAmount - spent).clamp(0.0, double.infinity);
    final periodLabel = _titleCase(budget.period);
    final statusText = ratio >= 1.0
        ? 'Over'
        : ratio >= 0.8
            ? 'Near limit'
            : 'On track';

    return Opacity(
      opacity: budget.isActive ? 1.0 : 0.55,
      child: AppCard(
        contentPadding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header: dot + name/period + status badge + toggle ──────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status dot (10dp)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 8),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_titleCase(budget.category),
                          style: tt.titleSmall),
                      Text(
                        '$periodLabel · ${formatCurrency(budget.limitAmount)}',
                        style: tt.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                // Status badge chip
                Container(
                  margin: const EdgeInsets.only(left: 6, top: 2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: tt.labelSmall?.copyWith(
                        color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ),
                // Active toggle — use the shared LifeOsSwitch (brand track +
                // haptics + M3 fix), not a raw Switch with deprecated
                // activeColor (which reintroduced the purple-track bug).
                Transform.scale(
                  scale: 0.8,
                  child: LifeOsSwitch(
                    value: budget.isActive,
                    onChanged: onToggleActive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ── Animated progress bar (500ms Kotlin parity) ────────────
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: barRatio),
              duration: const Duration(milliseconds: 500),
              builder: (context, v, _) => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: v,
                  minHeight: 8,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // ── Amounts row ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatCurrency(spent)} spent / $pct% of limit',
                  style: tt.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                Text(
                  '${formatCurrency(remaining)} left',
                  style: tt.labelSmall?.copyWith(
                    color: ratio >= 1.0
                        ? scheme.error
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(
                height: 1,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.12)),
            // ── Edit / Delete action row ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_outlined,
                        size: 16, color: scheme.primary),
                    label: Text('Edit',
                        style: TextStyle(color: scheme.primary)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outlined,
                        size: 16, color: scheme.error),
                    label: Text('Delete',
                        style: TextStyle(color: scheme.error)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
