/// InsightsScreen — 1:1 port of features/insights/presentation/InsightsScreen.kt.
///
/// Two tabs: Analytics (vs Last Month comparison, Spend/Income/Net/Average
/// summary cards, Spending by Category with weekly bars, Transaction Fees) and
/// Insights (Monthly Trend bars, Average Monthly / Total Tracked, Spending
/// Insights rows, History breakdown with expandable top categories, Payday
/// Pulse, Spend Anatomy).
library;

import 'package:drift/drift.dart' show QueryRow, Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/banners.dart';
import '../../../core/designsystem/metric_card.dart' show formatCurrency;
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/designsystem/tokens.dart';
import '../../../core/utils/date_utils.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/colors.dart';
import '../../dashboard/data/providers.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int _tab = 0; // 0 = Analytics, 1 = Insights
  bool _expandCategories = false;
  int _analyticsFilter = 1; // 0 = This week, 1 = This month
  final _expandedMonths = <String>{};

  // Cache the future so setState (filter toggle, expand cards) never restarts
  // the DB query. Only refreshed when the user taps the refresh button.
  late Future<_InsightsData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _load();
  }

  void _refresh() => setState(() => _dataFuture = _load());

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PageScaffold(
      title: 'Analytics',
      subtitle: 'Productivity and finance trends in one place',
      onBack: () => context.pop(),
      scrollable: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          tooltip: 'Refresh',
          onPressed: _refresh,
        ),
      ],
      child: FutureBuilder<_InsightsData>(
        future: _dataFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 40,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 12),
                  Text('Could not load analytics.',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _refresh, child: const Text('Retry')),
                ],
              ),
            );
          }
          final d = snap.data;
          if (d == null) {
            return const EmptyState(
                title: 'No data yet',
                description: 'Import transactions to see insights.');
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tab bar (Analytics / Insights)
              Row(
                children: [
                  for (var i = 0; i < 2; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tab = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _tab == i
                                ? scheme.primary
                                : scheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            i == 0 ? 'Analytics' : 'Insights',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: _tab == i
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: _tab == i
                                      ? scheme.onPrimary
                                      : scheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  // Key changes only when the tab changes — not on filter/expand.
                  child: KeyedSubtree(
                    key: ValueKey(_tab),
                    child: _tab == 0
                        ? _AnalyticsListView(
                            key: ValueKey(_analyticsFilter),
                            children: _analyticsContent(context, d),
                          )
                        : ListView(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.bottomSafe),
                            children: _insightsContent(context, d),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Analytics tab ─────────────────────────────────────────────────────────

  List<Widget> _analyticsContent(BuildContext context, _InsightsData d) {
    final scheme = Theme.of(context).colorScheme;
    final isWeek = _analyticsFilter == 0;
    final spend = isWeek ? d.weekSpend : d.monthSpend;
    final income = isWeek ? d.weekIncome : d.monthIncome;
    final net = income - spend;
    final activeCats = isWeek ? d.weekCategories : d.categories;
    final avg = (spend > 0 && activeCats.isNotEmpty) ? spend / activeCats.length : 0.0;

    // Comparison card — week or month depending on the filter.
    final prevSpend = isWeek ? d.prevWeekSpend : d.prevMonthSpend;
    final delta = spend - prevSpend;
    final up = delta > 0;
    final curColor = up ? scheme.error : scheme.primary;
    final mx = [spend, prevSpend, 1.0].reduce((a, b) => a > b ? a : b);
    final periodLabel = isWeek ? 'This week' : 'This month';
    final prevLabel = isWeek ? 'Last week' : 'Last month';
    final compTitle = isWeek ? 'vs Last Week' : 'vs Last Month';

    return [
      // Filter chips: This week / This month
      Row(
        children: [
          _filterChip(context, 'This week', 0),
          const SizedBox(width: 8),
          _filterChip(context, 'This month', 1),
        ],
      ),
      const SizedBox(height: 12),
      // Comparison card — adapts with the filter toggle.
      AppCard(
        contentPadding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(compTitle,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _comparisonRow(context, prevLabel, prevSpend / mx, prevSpend, scheme.outline, scheme.onSurfaceVariant),
            const SizedBox(height: 8),
            _comparisonRow(context, periodLabel, spend / mx, spend, curColor, curColor, bold: true),
            if (prevSpend > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: curColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(up ? Icons.trending_up : Icons.trending_down,
                        size: 12, color: curColor),
                    const SizedBox(width: 4),
                    Text(
                      up
                          ? 'Spent ${formatCurrency(delta)} more than $prevLabel'
                          : 'Saved ${formatCurrency(-delta)} vs $prevLabel',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: curColor),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      // Summary cards: 2×2 grid
      Row(
        children: [
          Expanded(child: _summaryCardRow(context, 'Spend', spend, scheme.error)),
          const SizedBox(width: 8),
          Expanded(child: _summaryCardRow(context, 'Income', income, kSuccessColor)),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: _summaryCardRow(context, 'Net', net, net >= 0 ? kSuccessColor : scheme.error)),
          const SizedBox(width: 8),
          Expanded(child: _summaryCardRow(context, 'Average', avg, scheme.primary)),
        ],
      ),
      const SizedBox(height: 12),
      // Spending by Category — shows week or month categories based on the filter.
      if (activeCats.isNotEmpty) ...[
        _categorySpendHeader(context, activeCats.length),
        for (final c in (_expandCategories ? activeCats : activeCats.take(3)))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _categorySpendCard(context, c),
          ),
      ],
      // Transaction Fees
      if (d.feesTotal > 0) ...[
        const SizedBox(height: 12),
        AppCard(
          contentPadding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      size: 15, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text('Transaction Fees',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              Text(formatCurrency(d.feesTotal),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Avg fee: ${formatCurrency(d.feesTotal / (d.feeTxCount > 0 ? d.feeTxCount : 1))} · ${d.feeTxCount} tx',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ],
    ];
  }

  Widget _comparisonRow(BuildContext context, String label, double ratio,
      double amount, Color barColor, Color textColor,
      {bool bold = false}) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 84,
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              color: scheme.outlineVariant,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ratio.clamp(0.0, 1.0),
                child: Container(color: barColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 76,
          child: Text(
            formatCurrency(amount),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCardRow(BuildContext context, String label, double value, Color color) {
    return AppCard(
      contentPadding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(formatCurrency(value),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, int index) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _analyticsFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _analyticsFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Widget _categorySpendHeader(BuildContext context, int count) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Spending by Category',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600)),
          if (count > 3)
            IconButton(
              onPressed: () => setState(() => _expandCategories = !_expandCategories),
              icon: Icon(
                _expandCategories ? Icons.expand_less : Icons.expand_more,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _categorySpendCard(BuildContext context, _CategorySpend c) {
    final scheme = Theme.of(context).colorScheme;
    final globalMax = c.weeklyAmounts.isEmpty
        ? 1.0
        : c.weeklyAmounts.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);
    return AppCard(
      contentPadding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(c.color)),
                  ),
                  const SizedBox(width: 8),
                  Text(_cap(c.category),
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatCurrency(c.total),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text('${c.pctOfTotal.toStringAsFixed(1)}%',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (c.topMerchant != null)
                Text('Top: ${c.topMerchant}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant))
              else
                const SizedBox(width: 1),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final v in c.weeklyAmounts)
                    Container(
                      width: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      height: v > 0
                          ? (v / globalMax * 28).clamp(3.0, 28.0)
                          : 1.0,
                      decoration: BoxDecoration(
                        color: v > 0
                            ? Color(c.color)
                            : Color(c.color).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Insights tab ──────────────────────────────────────────────────────────

  List<Widget> _insightsContent(BuildContext context, _InsightsData d) {
    final scheme = Theme.of(context).colorScheme;
    if (d.monthBars.isEmpty) {
      return [
        const EmptyState(
            title: 'No spending history yet',
            description: 'Add transactions to unlock patterns.'),
      ];
    }
    final good = kSuccessColor;
    final bad = scheme.error;
    final maxExpense = d.monthBars
        .map((m) => m.expense)
        .fold<double>(1.0, (a, b) => a > b ? a : b);

    final children = <Widget>[
      // Monthly Trend
      AppCard(
        contentPadding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Trend',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final m in d.monthBars)
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.push(
                          '/${AppRoute.monthlyWrapped}/${m.year}/${m.month}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              width: 24,
                              height: m.txCount > 0
                                  ? (90 * (m.expense / maxExpense))
                                      .clamp(3.0, 90.0)
                                  : 4.0,
                              decoration: BoxDecoration(
                                color: m.txCount > 0
                                    ? (m.expense <= d.avgExpense ? good : bad)
                                    : scheme.outlineVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(m.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                        color: m.monthOffset == 0
                                            ? scheme.primary
                                            : scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _legendDot(context, good, 'Below avg'),
                    const SizedBox(width: 12),
                    _legendDot(context, bad, 'Above avg'),
                  ],
                ),
                Text('Tap → Wrapped',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: scheme.outline)),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      // Average Monthly / Total Tracked
      Row(
        children: [
          Expanded(
            child: AppCard(
              contentPadding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Average Monthly',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(formatCurrency(d.avgExpense),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.primary)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppCard(
              contentPadding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Tracked',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(formatCurrency(d.totalTracked),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      // Spending Insights
      AppCard(
        contentPadding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: scheme.primary),
                const SizedBox(width: 8),
                Text('Spending Insights',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            if (d.highestMonth != null)
              _insightRow(context, 'Highest Month',
                  '${d.highestMonth!.fullLabel} · ${formatCurrency(d.highestMonth!.expense)}',
                  bad,
                  () => context.push(
                      '/${AppRoute.monthlyWrapped}/${d.highestMonth!.year}/${d.highestMonth!.month}')),
            if (d.lowestMonth != null)
              _insightRow(context, 'Lowest Month',
                  '${d.lowestMonth!.fullLabel} · ${formatCurrency(d.lowestMonth!.expense)}',
                  good,
                  () => context.push(
                      '/${AppRoute.monthlyWrapped}/${d.lowestMonth!.year}/${d.lowestMonth!.month}')),
            if (d.topCategory != null)
              _insightRow(context, 'Top Category',
                  '${_cap(d.topCategory!)} · ${d.topCategoryPct.toStringAsFixed(1)}%',
                  categoryColorFor(d.topCategory),
                  () {}),
            _insightRow(context, 'Trend', _cap(d.trend),
                d.trend == 'increasing'
                    ? bad
                    : d.trend == 'decreasing'
                        ? good
                        : scheme.onSurfaceVariant,
                () {}),
          ],
        ),
      ),
      // History breakdown
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text('History',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
      for (final m in d.breakdown) _historyCard(context, m),
      // spacing after last card consumed by individual card padding
      // Payday Pulse
      if (d.paydayPulse != null) ...[
        const SizedBox(height: 12),
        _paydayPulseCard(context, d.paydayPulse!),
      ],
      // Spend Anatomy
      if (d.sizeBreakdown.totalCount > 0) ...[
        const SizedBox(height: 12),
        _spendAnatomyCard(context, d.sizeBreakdown),
      ],
    ];
    return children;
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _insightRow(BuildContext context, String label, String detail,
      Color color, VoidCallback onClick) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child:
                  Icon(Icons.chevron_right, size: 14, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  Text(detail, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: scheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _historyCard(BuildContext context, _MonthBreakdown m) {
    final scheme = Theme.of(context).colorScheme;
    final key = '${m.month.year}-${m.month.month}';
    final expanded = _expandedMonths.contains(key);
    final dCol = m.delta == null || m.delta == 0
        ? scheme.outlineVariant
        : m.delta! > 0
            ? scheme.error
            : kSuccessColor;
    final rowIcon = m.delta == null || m.delta == 0
        ? Icons.remove
        : m.delta! > 0
            ? Icons.trending_up
            : Icons.trending_down;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        contentPadding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row (tappable) ─────────────────────────────────────
            InkWell(
              onTap: () => setState(() {
                if (expanded) {
                  _expandedMonths.remove(key);
                } else {
                  _expandedMonths.add(key);
                }
              }),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: dCol.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(rowIcon, size: 16, color: dCol),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(m.month.fullLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            if (m.delta != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: dCol.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${m.delta! > 0 ? '+' : ''}${m.delta!.toStringAsFixed(1)}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          color: dCol,
                                          fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                            const Spacer(),
                            Text(formatCurrency(m.month.expense),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: scheme.primary)),
                          ],
                        ),
                        Text('${m.month.txCount} transactions',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: scheme.outlineVariant,
                  ),
                ],
              ),
            ),
            // ── Expanded: top categories ──────────────────────────────────
            if (expanded && m.topCategories.isNotEmpty) ...[
              const SizedBox(height: 10),
              Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.35)),
              const SizedBox(height: 10),
              Text('Top Categories',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              for (final entry in m.topCategories.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _miniCategoryRow(
                      context, entry.key, entry.value, m.month.expense),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniCategoryRow(BuildContext context, String category, double amount,
      double monthTotal) {
    final scheme = Theme.of(context).colorScheme;
    final pct = monthTotal > 0 ? amount / monthTotal : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurface)),
            Text(formatCurrency(amount),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 4,
            color: scheme.outlineVariant.withValues(alpha: 0.25),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct.clamp(0.0, 1.0),
              child: Container(
                  color: categoryColorFor(category)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _paydayPulseCard(BuildContext context, _PaydayPulse p) {
    final scheme = Theme.of(context).colorScheme;
    final postHigher = p.postPaydayAvgPerDay > p.otherDaysAvgPerDay;
    final diffPct = p.otherDaysAvgPerDay > 0
        ? ((p.postPaydayAvgPerDay - p.otherDaysAvgPerDay).abs() /
                p.otherDaysAvgPerDay) *
            100
        : 0.0;
    final pulseCol = postHigher ? scheme.error : kSuccessColor;
    final maxVal = [p.postPaydayAvgPerDay, p.otherDaysAvgPerDay, 1.0]
        .reduce((a, b) => a > b ? a : b);
    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.account_balance_wallet_outlined,
                    size: 14, color: const Color(0xFFF59E0B)),
              ),
              const SizedBox(width: 8),
              Text('Payday Pulse',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('${p.incomeEventsCount} income events · avg daily spend',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            postHigher
                ? 'You spend ${diffPct.round()}% more in the 7 days after income arrives'
                : 'You spend ${diffPct.round()}% less right after income — disciplined!',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600, color: pulseCol),
          ),
          const SizedBox(height: 8),
          _pulseBar(context, 'Post-income (7 days)', p.postPaydayAvgPerDay, maxVal, pulseCol),
          const SizedBox(height: 8),
          _pulseBar(context, 'Other days', p.otherDaysAvgPerDay, maxVal, scheme.primary),
        ],
      ),
    );
  }

  Widget _pulseBar(BuildContext context, String label, double value,
      double maxVal, Color color) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
            Text('${formatCurrency(value)}/day',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 6,
            color: scheme.outlineVariant.withValues(alpha: 0.2),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (value / maxVal).clamp(0.0, 1.0),
              child: Container(color: color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _spendAnatomyCard(BuildContext context, _SizeBreakdown sb) {
    final scheme = Theme.of(context).colorScheme;
    final totalCount = sb.microCount + sb.mediumCount + sb.largeCount;
    final totalAmt = sb.microTotal + sb.mediumTotal + sb.largeTotal;
    final tiers = [
      ('Micro', '< KSh 500', sb.microCount, sb.microTotal, kSuccessColor),
      ('Medium', 'KSh 500–2k', sb.mediumCount, sb.mediumTotal, const Color(0xFFF59E0B)),
      ('Large', '> KSh 2k', sb.largeCount, sb.largeTotal, scheme.error),
    ];
    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.lightbulb_outline,
                    size: 14, color: const Color(0xFF8B5CF6)),
              ),
              const SizedBox(width: 8),
              Text('Spend Anatomy',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text('How your $totalCount transactions break down by size',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          for (final (label, range, cnt, total, col) in tiers)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: col),
                          ),
                          const SizedBox(width: 6),
                          Text('$label ($range)',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      Text(
                          '$cnt txns · ${totalAmt > 0 ? (total / totalAmt * 100).toStringAsFixed(0) : '0'}% of spend',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      height: 6,
                      color: scheme.outlineVariant.withValues(alpha: 0.2),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor:
                            totalCount > 0 ? cnt / totalCount : 0.0,
                        child: Container(color: col),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _cap(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<_InsightsData> _load() async {
    final db = await ref.read(lifeOsDatabaseProvider.future);
    final userId = await ref.read(userIdProvider.future);
    final now = DateTime.now();
    final monthStart =
        DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
    final prevMonthStart =
        DateTime(now.year, now.month - 1, 1).millisecondsSinceEpoch;
    double sum(List<QueryRow> rows) =>
        (rows.first.data['total'] as num?)?.toDouble() ?? 0;

    final spendQ = "SELECT SUM(amount) AS total FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','WITHDRAWN','PAID')";
    final incomeQ = "SELECT SUM(amount) AS total FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND UPPER(transaction_type) IN ('RECEIVED','DEPOSIT')";

    final weekStartDate = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(weekStartDate.year, weekStartDate.month, weekStartDate.day).millisecondsSinceEpoch;
    final prevWeekStartDate = weekStartDate.subtract(const Duration(days: 7));
    final prevWeekStart = DateTime(prevWeekStartDate.year, prevWeekStartDate.month, prevWeekStartDate.day).millisecondsSinceEpoch;

    // Bounded-range query for prev-week spend.
    final spendRangeQ =
        "SELECT SUM(amount) AS total FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND date<? AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','WITHDRAWN','PAID')";

    // Run all summary queries in parallel to eliminate sequential DB round-trips.
    final summaryResults = await Future.wait([
      db.customSelect(spendQ, variables: [Variable.withString(userId), Variable.withInt(monthStart)], readsFrom: {db.transactions}).get(),
      db.customSelect(spendQ, variables: [Variable.withString(userId), Variable.withInt(prevMonthStart)], readsFrom: {db.transactions}).get(),
      db.customSelect(incomeQ, variables: [Variable.withString(userId), Variable.withInt(monthStart)], readsFrom: {db.transactions}).get(),
      db.customSelect(spendQ, variables: [Variable.withString(userId), Variable.withInt(weekStart)], readsFrom: {db.transactions}).get(),
      db.customSelect(incomeQ, variables: [Variable.withString(userId), Variable.withInt(weekStart)], readsFrom: {db.transactions}).get(),
      db.customSelect(spendRangeQ, variables: [Variable.withString(userId), Variable.withInt(prevWeekStart), Variable.withInt(weekStart)], readsFrom: {db.transactions}).get(),
    ]);
    final monthSpend = sum(summaryResults[0]);
    final prevSpend = sum(summaryResults[1]);
    final monthIncome = sum(summaryResults[2]);
    final weekSpend = sum(summaryResults[3]);
    final weekIncome = sum(summaryResults[4]);
    final prevWeekSpend = sum(summaryResults[5]);

    // Category spend (this month + this week) — run in parallel.
    final catQ = "SELECT category, SUM(amount) AS total, COUNT(*) AS n FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','WITHDRAWN','PAID') GROUP BY category ORDER BY total DESC LIMIT 8";
    final catParallel = await Future.wait([
      db.customSelect(catQ, variables: [Variable.withString(userId), Variable.withInt(monthStart)], readsFrom: {db.transactions}).get(),
      db.customSelect(catQ, variables: [Variable.withString(userId), Variable.withInt(weekStart)], readsFrom: {db.transactions}).get(),
    ]);
    final catRows = catParallel[0];
    final weekCatRows = catParallel[1];
    final catTotal = catRows.fold<double>(0, (a, r) => a + ((r.data['total'] as num?)?.toDouble() ?? 0));
    // Weekly boundaries (4 weeks of the current month).
    final w1s = monthStart;
    final w2s = DateTime(now.year, now.month, 8).millisecondsSinceEpoch;
    final w3s = DateTime(now.year, now.month, 15).millisecondsSinceEpoch;
    final w4s = DateTime(now.year, now.month, 22).millisecondsSinceEpoch;
    final w4e = DateTime(now.year, now.month + 1, 1).millisecondsSinceEpoch;
    // Per-category weekly query.
    final weeklyRows = await db.customSelect(
      "SELECT category,"
      " SUM(CASE WHEN date>=? AND date<? THEN amount ELSE 0 END) AS w1,"
      " SUM(CASE WHEN date>=? AND date<? THEN amount ELSE 0 END) AS w2,"
      " SUM(CASE WHEN date>=? AND date<? THEN amount ELSE 0 END) AS w3,"
      " SUM(CASE WHEN date>=? AND date<? THEN amount ELSE 0 END) AS w4"
      " FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND date<?"
      " AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','WITHDRAWN','PAID')"
      " GROUP BY category",
      variables: [
        Variable.withInt(w1s), Variable.withInt(w2s),
        Variable.withInt(w2s), Variable.withInt(w3s),
        Variable.withInt(w3s), Variable.withInt(w4s),
        Variable.withInt(w4s), Variable.withInt(w4e),
        Variable.withString(userId),
        Variable.withInt(monthStart), Variable.withInt(w4e),
      ],
      readsFrom: {db.transactions},
    ).get();
    final weeklyMap = <String, List<double>>{
      for (final r in weeklyRows)
        (r.data['category'] as String? ?? 'Other'): [
          (r.data['w1'] as num?)?.toDouble() ?? 0,
          (r.data['w2'] as num?)?.toDouble() ?? 0,
          (r.data['w3'] as num?)?.toDouble() ?? 0,
          (r.data['w4'] as num?)?.toDouble() ?? 0,
        ]
    };
    // Top merchant per category.
    final topMerchantRows = await db.customSelect(
      "SELECT category, merchant, SUM(amount) AS t FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=?"
      " AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','WITHDRAWN','PAID')"
      " AND merchant IS NOT NULL AND merchant != '' GROUP BY category, merchant ORDER BY t DESC",
      variables: [Variable.withString(userId), Variable.withInt(monthStart)],
      readsFrom: {db.transactions},
    ).get();
    final topMerchantMap = <String, String>{};
    for (final r in topMerchantRows) {
      final cat = r.data['category'] as String? ?? 'Other';
      if (!topMerchantMap.containsKey(cat)) {
        topMerchantMap[cat] = r.data['merchant'] as String? ?? '';
      }
    }
    final categories = <_CategorySpend>[
      for (final r in catRows)
        _CategorySpend(
          category: (r.data['category'] as String? ?? 'Other'),
          total: (r.data['total'] as num?)?.toDouble() ?? 0,
          pctOfTotal: catTotal > 0 ? ((r.data['total'] as num) / catTotal * 100) : 0,
          color: categoryColorFor(r.data['category'] as String?).toARGB32(),
          topMerchant: topMerchantMap[r.data['category'] as String? ?? 'Other'],
          weeklyAmounts: weeklyMap[r.data['category'] as String? ?? 'Other'] ?? [0, 0, 0, 0],
        ),
    ];
    final weekCatTotal = weekCatRows.fold<double>(0, (a, r) => a + ((r.data['total'] as num?)?.toDouble() ?? 0));
    final weekCategories = <_CategorySpend>[
      for (final r in weekCatRows)
        _CategorySpend(
          category: (r.data['category'] as String? ?? 'Other'),
          total: (r.data['total'] as num?)?.toDouble() ?? 0,
          pctOfTotal: weekCatTotal > 0 ? ((r.data['total'] as num) / weekCatTotal * 100) : 0,
          color: categoryColorFor(r.data['category'] as String?).toARGB32(),
          topMerchant: topMerchantMap[r.data['category'] as String? ?? 'Other'],
          weeklyAmounts: [(r.data['total'] as num?)?.toDouble() ?? 0, 0, 0, 0],
        ),
    ];

    // Fees.
    final feeRows = await db.customSelect(
      "SELECT SUM(amount) AS total, COUNT(*) AS n FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND UPPER(transaction_type) IN ('AIRTIME','WITHDRAW','WITHDRAWN','FULIZA_CHARGE')",
      variables: [Variable.withString(userId), Variable.withInt(monthStart)],
      readsFrom: {db.transactions},
    ).get();
    final feesTotal = (feeRows.first.data['total'] as num?)?.toDouble() ?? 0;
    final feeTxCount = (feeRows.first.data['n'] as num?)?.toInt() ?? 0;

    // Monthly bars (last 6 months) — run all 6 queries in parallel.
    final monthBarFutures = <Future<({DateTime d, int offset, dynamic row})>>[];
    for (var i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final start = d.millisecondsSinceEpoch;
      final end = DateTime(now.year, now.month - i + 1, 1).millisecondsSinceEpoch;
      final capturedD = d;
      final capturedI = i;
      monthBarFutures.add(
        db.customSelect(
          "SELECT COALESCE(SUM(amount),0) AS total, COUNT(*) AS n FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND date<? AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','WITHDRAWN','PAID')",
          variables: [Variable.withString(userId), Variable.withInt(start), Variable.withInt(end)],
          readsFrom: {db.transactions},
        ).getSingle().then((row) => (d: capturedD, offset: capturedI, row: row)),
      );
    }
    final monthBarResults = await Future.wait(monthBarFutures);
    monthBarResults.sort((a, b) => b.offset.compareTo(a.offset));
    final monthBars = <_MonthBar>[
      for (final r in monthBarResults)
        _MonthBar(
          label: _monthShort(r.d.month),
          fullLabel: _monthFull(r.d.month),
          year: r.d.year,
          month: r.d.month,
          monthOffset: r.offset,
          expense: (r.row.data['total'] as num?)?.toDouble() ?? 0,
          txCount: (r.row.data['n'] as num?)?.toInt() ?? 0,
        ),
    ];
    final avgExpense = monthBars.isEmpty
        ? 0.0
        : monthBars.map((m) => m.expense).reduce((a, b) => a + b) / monthBars.length;
    final totalTracked = monthBars.fold<double>(0, (a, m) => a + m.expense);
    final withData = monthBars.where((m) => m.txCount > 0).toList();
    final highest = withData.isEmpty ? null : withData.reduce((a, b) => a.expense > b.expense ? a : b);
    final lowest = withData.isEmpty ? null : withData.reduce((a, b) => a.expense < b.expense ? a : b);

    // Trend: compare last month vs previous.
    final trend = monthBars.length < 2
        ? 'stable'
        : monthBars[monthBars.length - 1].expense > monthBars[monthBars.length - 2].expense
            ? 'increasing'
            : monthBars[monthBars.length - 1].expense < monthBars[monthBars.length - 2].expense
                ? 'decreasing'
                : 'stable';

    // Size breakdown (this month).
    final sizeRows = await db.customSelect(
      "SELECT amount FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','WITHDRAWN','PAID')",
      variables: [Variable.withString(userId), Variable.withInt(monthStart)],
      readsFrom: {db.transactions},
    ).get();
    var microC = 0, medC = 0, largeC = 0;
    var microT = 0.0, medT = 0.0, largeT = 0.0;
    for (final r in sizeRows) {
      final amt = (r.data['amount'] as num?)?.toDouble() ?? 0;
      if (amt < 500) {
        microC++;
        microT += amt;
      } else if (amt <= 2000) {
        medC++;
        medT += amt;
      } else {
        largeC++;
        largeT += amt;
      }
    }

    return _InsightsData(
      monthSpend: monthSpend,
      prevMonthSpend: prevSpend,
      monthIncome: monthIncome,
      weekSpend: weekSpend,
      weekIncome: weekIncome,
      prevWeekSpend: prevWeekSpend,
      weekCategories: weekCategories,
      monthNet: monthIncome - monthSpend,
      avgTransaction: catRows.isEmpty ? 0 : monthSpend / catRows.length,
      feesTotal: feesTotal,
      feeTxCount: feeTxCount,
      categories: categories,
      monthBars: monthBars,
      avgExpense: avgExpense,
      totalTracked: totalTracked,
      highestMonth: highest,
      lowestMonth: lowest,
      topCategory: categories.isEmpty ? null : categories.first.category,
      topCategoryPct: categories.isEmpty ? 0 : categories.first.pctOfTotal,
      trend: trend,
      // Per-month top-5 categories for History breakdown expansion.
      breakdown: await () async {
        final reversedWithData = withData.reversed.toList();
        final monthCatMaps = <Map<String, double>>[];
        for (final mb in reversedWithData) {
          final s = DateTime(mb.year, mb.month, 1).millisecondsSinceEpoch;
          final e = DateTime(mb.year, mb.month + 1, 1).millisecondsSinceEpoch;
          final rows = await db.customSelect(
            "SELECT category, SUM(amount) AS total FROM transactions WHERE user_id=? AND deleted_at IS NULL AND date>=? AND date<? AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','WITHDRAWN','PAID') GROUP BY category ORDER BY total DESC LIMIT 5",
            variables: [Variable.withString(userId), Variable.withInt(s), Variable.withInt(e)],
            readsFrom: {db.transactions},
          ).get();
          monthCatMaps.add({
            for (final r in rows)
              (r.data['category'] as String? ?? 'Other'): (r.data['total'] as num?)?.toDouble() ?? 0,
          });
        }
        return List.generate(reversedWithData.length, (i) {
          final originalIdx = withData.length - 1 - i;
          return _MonthBreakdown(
            month: reversedWithData[i],
            delta: (originalIdx > 0 && withData[originalIdx - 1].expense > 0)
                ? (reversedWithData[i].expense - withData[originalIdx - 1].expense) /
                    withData[originalIdx - 1].expense *
                    100
                : null,
            topCategories: monthCatMaps[i],
          );
        });
      }(),
      paydayPulse: null,
      sizeBreakdown: _SizeBreakdown(
        microCount: microC,
        mediumCount: medC,
        largeCount: largeC,
        microTotal: microT,
        mediumTotal: medT,
        largeTotal: largeT,
      ),
    );
  }

  String _monthShort(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m - 1];

  String _monthFull(int m) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ][m - 1];
}

// ── Data model ──────────────────────────────────────────────────────────────

class _InsightsData {
  const _InsightsData({
    required this.monthSpend,
    required this.prevMonthSpend,
    required this.monthIncome,
    required this.weekSpend,
    required this.weekIncome,
    required this.prevWeekSpend,
    required this.weekCategories,
    required this.monthNet,
    required this.avgTransaction,
    required this.feesTotal,
    required this.feeTxCount,
    required this.categories,
    required this.monthBars,
    required this.avgExpense,
    required this.totalTracked,
    required this.highestMonth,
    required this.lowestMonth,
    required this.topCategory,
    required this.topCategoryPct,
    required this.trend,
    required this.breakdown,
    required this.paydayPulse,
    required this.sizeBreakdown,
  });

  final double monthSpend;
  final double prevMonthSpend;
  final double monthIncome;
  final double weekSpend;
  final double weekIncome;
  final double prevWeekSpend;
  final List<_CategorySpend> weekCategories;
  final double monthNet;
  final double avgTransaction;
  final double feesTotal;
  final int feeTxCount;
  final List<_CategorySpend> categories;
  final List<_MonthBar> monthBars;
  final double avgExpense;
  final double totalTracked;
  final _MonthBar? highestMonth;
  final _MonthBar? lowestMonth;
  final String? topCategory;
  final double topCategoryPct;
  final String trend;
  final List<_MonthBreakdown> breakdown;
  final _PaydayPulse? paydayPulse;
  final _SizeBreakdown sizeBreakdown;
}

/// A ListView wrapper that gives the analytics tab its own scroll position,
/// separated from the insights tab. The [key] changes when the analytics
/// filter (week/month) toggles, which replaces this widget and resets the
/// scroll to the top — matching the Kotlin behavior.
class _AnalyticsListView extends StatelessWidget {
  const _AnalyticsListView({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.bottomSafe),
      children: children,
    );
  }
}

class _CategorySpend {
  const _CategorySpend({
    required this.category,
    required this.total,
    required this.pctOfTotal,
    required this.color,
    required this.topMerchant,
    required this.weeklyAmounts,
  });
  final String category;
  final double total;
  final double pctOfTotal;
  final int color;
  final String? topMerchant;
  final List<double> weeklyAmounts;
}

class _MonthBar {
  const _MonthBar({
    required this.label,
    required this.fullLabel,
    required this.year,
    required this.month,
    required this.monthOffset,
    required this.expense,
    required this.txCount,
  });
  final String label;
  final String fullLabel;
  final int year;
  final int month;
  final int monthOffset;
  final double expense;
  final int txCount;
}

class _MonthBreakdown {
  const _MonthBreakdown({
    required this.month,
    required this.delta,
    this.topCategories = const {},
  });
  final _MonthBar month;
  final double? delta;
  /// Top 5 categories for this month: {category: amount}.
  final Map<String, double> topCategories;
}

class _PaydayPulse {
  const _PaydayPulse({
    required this.postPaydayAvgPerDay,
    required this.otherDaysAvgPerDay,
    required this.incomeEventsCount,
  });
  final double postPaydayAvgPerDay;
  final double otherDaysAvgPerDay;
  final int incomeEventsCount;
}

class _SizeBreakdown {
  const _SizeBreakdown({
    required this.microCount,
    required this.mediumCount,
    required this.largeCount,
    required this.microTotal,
    required this.mediumTotal,
    required this.largeTotal,
  });
  final int microCount;
  final int mediumCount;
  final int largeCount;
  final double microTotal;
  final double mediumTotal;
  final double largeTotal;

  int get totalCount => microCount + mediumCount + largeCount;
}
