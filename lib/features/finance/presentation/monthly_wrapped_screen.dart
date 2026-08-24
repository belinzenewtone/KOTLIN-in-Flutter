/// 1:1 port of features/finance/presentation/MonthlyWrappedScreen.kt.
library;

import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database.dart';
import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/utils/date_utils.dart';
import '../../../navigation/routes.dart';
import '../../dashboard/data/providers.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class _MonthlyData {
  const _MonthlyData({
    required this.totalSpent,
    required this.prevMonthSpent,
    required this.monthIncome,
    required this.categoryBreakdown,
    this.topMerchant,
    required this.topMerchantTotal,
    this.biggestTxMerchant,
    required this.biggestTxAmount,
    this.mostVisitedMerchant,
    required this.mostVisitedCount,
    required this.activeDays,
    required this.daysInMonth,
    required this.totalFees,
    required this.fulizaUsed,
    required this.txCount,
  });

  final double totalSpent;
  final double prevMonthSpent;
  final double monthIncome;
  final List<(String category, double amount)> categoryBreakdown;
  final String? topMerchant;
  final double topMerchantTotal;
  final String? biggestTxMerchant;
  final double biggestTxAmount;
  final String? mostVisitedMerchant;
  final int mostVisitedCount;
  final int activeDays;
  final int daysInMonth;
  final double totalFees;
  final double fulizaUsed;
  final int txCount;
}

// ── Widget ────────────────────────────────────────────────────────────────────

class MonthlyWrappedScreen extends ConsumerStatefulWidget {
  const MonthlyWrappedScreen({super.key, this.year, this.month});

  final int? year;
  final int? month;

  @override
  ConsumerState<MonthlyWrappedScreen> createState() =>
      _MonthlyWrappedScreenState();
}

class _MonthlyWrappedScreenState extends ConsumerState<MonthlyWrappedScreen> {
  late int _year;
  late int _month;
  _MonthlyData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = widget.year ?? now.year;
    _month = widget.month ?? now.month;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final db = await ref.read(lifeOsDatabaseProvider.future);
      final userId = await ref.read(userIdProvider.future);
      final data = await _queryMonth(db, userId, _year, _month);
      if (mounted) setState(() => _data = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static Future<_MonthlyData> _queryMonth(
    LifeOsDatabase db,
    String userId,
    int year,
    int month,
  ) async {
    final monthStart =
        DateTime(year, month, 1).millisecondsSinceEpoch;
    final monthEnd =
        DateTime(year, month + 1, 1).millisecondsSinceEpoch;

    // Previous month boundaries
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;
    final prevStart =
        DateTime(prevYear, prevMonth, 1).millisecondsSinceEpoch;
    final prevEnd =
        DateTime(prevYear, prevMonth + 1, 1).millisecondsSinceEpoch;

    // Total spent this month
    final totalRow = await db.customSelect(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total, COUNT(*) AS cnt
      FROM transactions
      WHERE user_id = ? AND deleted_at IS NULL
        AND date >= ? AND date < ?
        AND UPPER(transaction_type) IN
          ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','PAID','WITHDRAWN')
      ''',
      variables: [
        Variable.withString(userId),
        Variable.withInt(monthStart),
        Variable.withInt(monthEnd),
      ],
    ).getSingle();
    final totalSpent = (totalRow.data['total'] as num?)?.toDouble() ?? 0.0;
    final txCount = (totalRow.data['cnt'] as num?)?.toInt() ?? 0;

    // Previous month total
    final prevRow = await db.customSelect(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE user_id = ? AND deleted_at IS NULL
        AND date >= ? AND date < ?
        AND UPPER(transaction_type) IN
          ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','PAID','WITHDRAWN')
      ''',
      variables: [
        Variable.withString(userId),
        Variable.withInt(prevStart),
        Variable.withInt(prevEnd),
      ],
    ).getSingle();
    final prevMonthSpent =
        (prevRow.data['total'] as num?)?.toDouble() ?? 0.0;

    // Category breakdown — top 5 desc
    final catRows = await db.customSelect(
      '''
      SELECT COALESCE(category, 'Uncategorised') AS cat,
             SUM(amount) AS total
      FROM transactions
      WHERE user_id = ? AND deleted_at IS NULL
        AND date >= ? AND date < ?
        AND UPPER(transaction_type) IN
          ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','PAID','WITHDRAWN')
      GROUP BY cat
      ORDER BY total DESC
      LIMIT 5
      ''',
      variables: [
        Variable.withString(userId),
        Variable.withInt(monthStart),
        Variable.withInt(monthEnd),
      ],
    ).get();
    final categoryBreakdown = catRows
        .map((r) => (
              r.data['cat'] as String? ?? 'Uncategorised',
              (r.data['total'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList();

    // Month income
    final incomeRow = await db.customSelect(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE user_id = ? AND deleted_at IS NULL
        AND date >= ? AND date < ?
        AND UPPER(transaction_type) IN ('RECEIVED','DEPOSIT')
      ''',
      variables: [
        Variable.withString(userId),
        Variable.withInt(monthStart),
        Variable.withInt(monthEnd),
      ],
    ).getSingle();
    final monthIncome = (incomeRow.data['total'] as num?)?.toDouble() ?? 0.0;

    // Top merchant (by total spend)
    final topMerchantRow = await db.customSelect(
      '''
      SELECT COALESCE(merchant, '') AS merchant,
             SUM(amount) AS total
      FROM transactions
      WHERE user_id = ? AND deleted_at IS NULL
        AND date >= ? AND date < ?
        AND UPPER(transaction_type) IN
          ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','PAID','WITHDRAWN')
        AND merchant IS NOT NULL AND merchant != ''
      GROUP BY merchant
      ORDER BY total DESC
      LIMIT 1
      ''',
      variables: [
        Variable.withString(userId),
        Variable.withInt(monthStart),
        Variable.withInt(monthEnd),
      ],
    ).getSingleOrNull();
    final topMerchant = topMerchantRow?.data['merchant'] as String?;
    final topMerchantTotal =
        (topMerchantRow?.data['total'] as num?)?.toDouble() ?? 0.0;

    // Most visited merchant (by transaction count)
    final mostVisitedRow = await db.customSelect(
      '''
      SELECT COALESCE(merchant, '') AS merchant, COUNT(*) AS n
      FROM transactions
      WHERE user_id = ? AND deleted_at IS NULL
        AND date >= ? AND date < ?
        AND merchant IS NOT NULL AND merchant != ''
      GROUP BY merchant
      ORDER BY n DESC
      LIMIT 1
      ''',
      variables: [
        Variable.withString(userId),
        Variable.withInt(monthStart),
        Variable.withInt(monthEnd),
      ],
    ).getSingleOrNull();
    final mostVisitedMerchant =
        mostVisitedRow?.data['merchant'] as String?;
    final mostVisitedCount =
        (mostVisitedRow?.data['n'] as num?)?.toInt() ?? 0;

    // Biggest single transaction
    final biggestRow = await db.customSelect(
      '''
      SELECT COALESCE(merchant, '') AS merchant, amount
      FROM transactions
      WHERE user_id = ? AND deleted_at IS NULL
        AND date >= ? AND date < ?
        AND UPPER(transaction_type) IN
          ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','PAID','WITHDRAWN')
      ORDER BY amount DESC
      LIMIT 1
      ''',
      variables: [
        Variable.withString(userId),
        Variable.withInt(monthStart),
        Variable.withInt(monthEnd),
      ],
    ).getSingleOrNull();
    final biggestTxMerchant = biggestRow?.data['merchant'] as String?;
    final biggestTxAmount =
        (biggestRow?.data['amount'] as num?)?.toDouble() ?? 0.0;

    // Active days — distinct calendar dates with transactions
    final activeDaysRow = await db.customSelect(
      '''
      SELECT COUNT(DISTINCT date(date / 1000, 'unixepoch')) AS days
      FROM transactions
      WHERE user_id = ? AND deleted_at IS NULL
        AND date >= ? AND date < ?
        AND UPPER(transaction_type) IN
          ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','PAID','WITHDRAWN')
      ''',
      variables: [
        Variable.withString(userId),
        Variable.withInt(monthStart),
        Variable.withInt(monthEnd),
      ],
    ).getSingle();
    final activeDays =
        (activeDaysRow.data['days'] as num?)?.toInt() ?? 0;

    // Total fees — AIRTIME / WITHDRAW transaction types or Fuliza category
    final feesRow = await db.customSelect(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE user_id = ? AND deleted_at IS NULL
        AND date >= ? AND date < ?
        AND (
          UPPER(transaction_type) IN ('AIRTIME', 'WITHDRAW')
          OR LOWER(COALESCE(category, '')) = 'fuliza'
        )
      ''',
      variables: [
        Variable.withString(userId),
        Variable.withInt(monthStart),
        Variable.withInt(monthEnd),
      ],
    ).getSingle();
    final totalFees =
        (feesRow.data['total'] as num?)?.toDouble() ?? 0.0;

    // Fuliza used this month — sum from fuliza_events draws (column may vary)
    double fulizaUsed = 0.0;
    try {
      final fulizaRow = await db.customSelect(
        "SELECT COALESCE(SUM(amount_kes), 0) AS total FROM fuliza_events WHERE user_id=? AND event_type='DRAW' AND created_at>=? AND created_at<?",
        variables: [
          Variable.withString(userId),
          Variable.withInt(monthStart),
          Variable.withInt(monthEnd),
        ],
        readsFrom: {db.fulizaEvents},
      ).getSingleOrNull();
      fulizaUsed = (fulizaRow?.data['total'] as num?)?.toDouble() ?? 0.0;
    } catch (_) {
      fulizaUsed = 0.0;
    }

    return _MonthlyData(
      totalSpent: totalSpent,
      prevMonthSpent: prevMonthSpent,
      monthIncome: monthIncome,
      categoryBreakdown: categoryBreakdown,
      topMerchant: topMerchant?.isEmpty ?? true ? null : topMerchant,
      topMerchantTotal: topMerchantTotal,
      biggestTxMerchant:
          biggestTxMerchant?.isEmpty ?? true ? null : biggestTxMerchant,
      biggestTxAmount: biggestTxAmount,
      mostVisitedMerchant:
          mostVisitedMerchant?.isEmpty ?? true ? null : mostVisitedMerchant,
      mostVisitedCount: mostVisitedCount,
      activeDays: activeDays,
      daysInMonth: DateTime(year, month + 1, 0).day,
      totalFees: totalFees,
      fulizaUsed: fulizaUsed,
      txCount: txCount,
    );
  }

  void _previousMonth() {
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year -= 1;
      } else {
        _month -= 1;
      }
      _data = null;
    });
    _load();
  }

  void _nextMonth() {
    final now = DateTime.now();
    final isCurrentMonth = _year == now.year && _month == now.month;
    if (isCurrentMonth) return;
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year += 1;
      } else {
        _month += 1;
      }
      _data = null;
    });
    _load();
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _year == now.year && _month == now.month;
  }

  String get _monthLabel =>
      DateFormat('MMMM yyyy').format(DateTime(_year, _month));

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Monthly Wrapped',
      headerVariant: PageHeaderVariant.compact,
      onBack: () => context.pop(),
      child: _loading && _data == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          : _WrappedBody(
              year: _year,
              month: _month,
              monthLabel: _monthLabel,
              isCurrentMonth: _isCurrentMonth,
              data: _data,
              onPrevious: _previousMonth,
              onNext: _nextMonth,
            ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _WrappedBody extends StatelessWidget {
  const _WrappedBody({
    required this.year,
    required this.month,
    required this.monthLabel,
    required this.isCurrentMonth,
    required this.data,
    required this.onPrevious,
    required this.onNext,
  });

  final int year;
  final int month;
  final String monthLabel;
  final bool isCurrentMonth;
  final _MonthlyData? data;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final d = data;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),

        // ── Month navigator ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevious,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  monthLabel,
                  style: text.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  d != null ? '${d.txCount} transactions' : '—',
                  style: text.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: isCurrentMonth ? null : onNext,
            ),
          ],
        ),

        if (d == null) ...[
          const SizedBox(height: 60),
          Center(
            child: Text(
              'No data for this month',
              style: text.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ] else ...[
          const SizedBox(height: 16),

          // ── Total Spent card ───────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Spent',
                  style: text.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  AppDateUtils.formatCurrency(d.totalSpent),
                  style: text.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                _MomRow(
                  current: d.totalSpent,
                  previous: d.prevMonthSpent,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Top Categories ─────────────────────────────────────────────────
          if (d.categoryBreakdown.isNotEmpty) ...[
            Text('Top Categories', style: text.titleSmall),
            const SizedBox(height: 8),
            ...d.categoryBreakdown.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final (cat, amount) = entry.value;
              final progress =
                  d.totalSpent > 0 ? (amount / d.totalSpent).clamp(0.0, 1.0) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CategoryRow(
                  rank: rank,
                  category: cat,
                  amount: amount,
                  progress: progress,
                ),
              );
            }),
            const SizedBox(height: 4),
          ],

          // ── Month Highlights ───────────────────────────────────────────────
          if (d.biggestTxMerchant != null || d.mostVisitedMerchant != null) ...[
            Text('Month Highlights', style: text.titleSmall),
            const SizedBox(height: 8),
            AppCard(
              contentPadding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (d.biggestTxMerchant != null)
                    _highlightRow(context, 'BIGGEST TRANSACTION',
                        d.biggestTxMerchant!, AppDateUtils.formatCurrency(d.biggestTxAmount), scheme),
                  if (d.biggestTxMerchant != null && d.mostVisitedMerchant != null)
                    Divider(height: 20, color: scheme.outlineVariant.withValues(alpha: 0.3)),
                  if (d.mostVisitedMerchant != null)
                    _highlightRow(context, 'MOST VISITED',
                        d.mostVisitedMerchant!, '${d.mostVisitedCount}x transactions', scheme),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── 2-col row: Top Merchant / Biggest Spend ────────────────────────
          Row(
            children: [
              Expanded(
                child: AppCard(
                  contentPadding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top merchant',
                        style: text.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        d.topMerchant ?? '—',
                        style: text.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold,
                                color: scheme.primary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (d.topMerchantTotal > 0)
                        Text(AppDateUtils.formatCurrency(d.topMerchantTotal),
                            style: text.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppCard(
                  contentPadding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biggest spend',
                        style: text.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppDateUtils.formatCurrency(d.biggestTxAmount),
                        style: text.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold,
                                color: scheme.primary),
                      ),
                      if (d.biggestTxMerchant != null)
                        Text(d.biggestTxMerchant!,
                            style: text.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── 2-col row: Active Days / Fees Paid ────────────────────────────
          Row(
            children: [
              Expanded(
                child: AppCard(
                  contentPadding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active days',
                        style: text.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.activeDays} of ${d.daysInMonth} days',
                        style: text.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppCard(
                  contentPadding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fees paid',
                        style: text.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppDateUtils.formatCurrency(d.totalFees),
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      Text('M-Pesa charges',
                          style: text.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Spent over income alert (if applicable) ───────────────────────
          if (d.monthIncome > 0 && d.totalSpent > d.monthIncome) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: scheme.error.withValues(alpha: 0.65)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Spent over income',
                        style: text.labelSmall?.copyWith(
                            color: scheme.error,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      AppDateUtils.formatCurrency(
                          d.totalSpent - d.monthIncome),
                      style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.error),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Income ${AppDateUtils.formatCurrency(d.monthIncome)} · Spend ${AppDateUtils.formatCurrency(d.totalSpent)}',
                      style: text.labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ── Fuliza card (conditional) ──────────────────────────────────────
          if (d.fulizaUsed > 0) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: scheme.error, width: 3),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FULIZA USED',
                      style: text.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppDateUtils.formatCurrency(d.fulizaUsed),
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ── Verdict card ───────────────────────────────────────────────────
          _VerdictCard(
            totalSpent: d.totalSpent,
            prevMonthSpent: d.prevMonthSpent,
          ),

          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _highlightRow(BuildContext context, String label, String title,
      String value, ColorScheme scheme) {
    final text = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: text.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(title,
                  style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: scheme.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(value,
            style: text.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold, color: scheme.primary)),
      ],
    );
  }
}

// ── MoM row ───────────────────────────────────────────────────────────────────

class _MomRow extends StatelessWidget {
  const _MomRow({required this.current, required this.previous});

  final double current;
  final double previous;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final isIncrease = previous <= 0 || current >= previous;
    final pct = previous > 0
        ? ((current - previous) / previous * 100).abs().toStringAsFixed(1)
        : null;

    final color = isIncrease ? scheme.error : scheme.primary;
    final icon = isIncrease ? Icons.trending_up : Icons.trending_down;
    final label = pct != null
        ? '$pct% vs last month'
        : 'No data for last month';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: text.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

// ── Category row ──────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.rank,
    required this.category,
    required this.amount,
    required this.progress,
  });

  final int rank;
  final String category;
  final double amount;
  final double progress;

  static Color _badgeColor(int rank, ColorScheme scheme) {
    switch (rank) {
      case 1:
        return const Color(0xFFF59E0B);
      case 2:
        return const Color(0xFF9CA3AF);
      case 3:
        return const Color(0xFFB45309);
      default:
        return scheme.primaryContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final badgeColor = _badgeColor(rank, scheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category,
                style: text.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppDateUtils.formatCurrency(amount),
              style: text.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor:
                  AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Verdict card ──────────────────────────────────────────────────────────────

class _VerdictCard extends StatelessWidget {
  const _VerdictCard({
    required this.totalSpent,
    required this.prevMonthSpent,
  });

  final double totalSpent;
  final double prevMonthSpent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final spentLess = prevMonthSpent > 0 && totalSpent < prevMonthSpent;
    final verdictText = spentLess
        ? 'Spent less than last month 🎉'
        : 'Spent more than last month';
    final verdictColor =
        spentLess ? scheme.primary : const Color(0xFFF59E0B);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: verdictColor, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          verdictText,
          style: text.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: verdictColor,
          ),
        ),
      ),
    );
  }
}
