/// Finance repository — Drift port of FinanceRepositoryImpl + BuildFinanceSummary.
library;

import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../domain/finance_models.dart';

class FinanceRepository {
  FinanceRepository(this._db, this._userId);

  final LifeOsDatabase _db;
  String _userId;

  set userId(String v) => _userId = v;

  static const String _spendTypes =
      "('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','PAID','WITHDRAWN')";

  int _windowStart(FinanceTransactionFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case FinanceTransactionFilter.last23Hours:
        return now.millisecondsSinceEpoch - 23 * 3600000;
      case FinanceTransactionFilter.last1Month:
        return DateTime(now.year, now.month - 1, now.day).millisecondsSinceEpoch;
      case FinanceTransactionFilter.last3Months:
        return DateTime(now.year, now.month - 3, now.day).millisecondsSinceEpoch;
      case FinanceTransactionFilter.last6Months:
        return DateTime(now.year, now.month - 6, now.day).millisecondsSinceEpoch;
    }
  }

  /// Paged transaction window (FinanceViewModel.pagedTransactions parity).
  Future<List<FinanceTransaction>> pageTransactions({
    FinanceTransactionFilter filter = FinanceTransactionFilter.last1Month,
    required int start,
    required int pageSize,
    String query = '',
  }) async {
    final from = _windowStart(filter);
    final like = '%$query%';

    final rows = await (_db.select(_db.transactions)
          ..where((t) => t.userId.equals(_userId) & t.deletedAt.isNull())
          ..where((t) => t.date.isBiggerOrEqualValue(from))
          ..where((t) => query.isEmpty
              ? const CustomExpression<bool>('1=1')
              : t.merchant.like(like) |
                  t.category.like(like) |
                  t.mpesaCode.like(like) |
                  t.transactionType.like(like))
          ..orderBy([(u) => OrderingTerm.desc(u.date)])
          ..limit(pageSize, offset: start))
        .get();
    return rows.map(_toTx).toList();
  }

  FinanceTransaction _toTx(Transaction r) => FinanceTransaction(
        id: r.id,
        amount: r.amount,
        merchant: r.merchant,
        category: r.category,
        date: r.date,
        source: r.source,
        transactionType: r.transactionType,
        mpesaCode: r.mpesaCode,
        rawSms: r.rawSms,
        createdAt: r.createdAt,
        description: r.description,
        notes: r.notes,
        fee: r.fee,
        balanceAfter: r.balanceAfter,
        status: r.status,
      );

  /// Spending summary for the hero card + breakdown section.
  Future<FinanceSpendingSummary> summary() async {
    final now = DateTime.now();
    final todayStart =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final weekStart = monday.millisecondsSinceEpoch;
    final monthStart = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;

    Future<double> sum(int? fromMs) async {
      if (fromMs == null) return 0;
      final row = await _db.customSelect(
        'SELECT COALESCE(SUM(amount),0.0) AS s FROM transactions '
        'WHERE user_id = ? AND deleted_at IS NULL AND date >= ? '
        'AND UPPER(transaction_type) IN $_spendTypes',
        variables: [Variable.withString(_userId), Variable.withInt(fromMs)],
        readsFrom: {_db.transactions},
      ).getSingle();
      return (row.data['s'] as num).toDouble();
    }

    final todayTotal = await sum(todayStart);
    final weekTotal = await sum(weekStart);
    final monthTotal = await sum(monthStart);

    final breakdownRows = await _db.customSelect(
      'SELECT category, SUM(amount) AS total FROM transactions '
      'WHERE user_id = ? AND deleted_at IS NULL AND date >= ? '
      'AND UPPER(transaction_type) IN $_spendTypes '
      'GROUP BY category ORDER BY total DESC',
      variables: [Variable.withString(_userId), Variable.withInt(monthStart)],
      readsFrom: {_db.transactions},
    ).get();

    final merchantsRows = await _db.customSelect(
      'SELECT merchant, SUM(amount) AS total FROM transactions '
      'WHERE user_id = ? AND deleted_at IS NULL AND date >= ? '
      'AND UPPER(transaction_type) IN $_spendTypes '
      'GROUP BY merchant ORDER BY total DESC LIMIT 5',
      variables: [Variable.withString(_userId), Variable.withInt(monthStart)],
      readsFrom: {_db.transactions},
    ).get();

    final uncategorizedRow = await _db.customSelect(
      "SELECT COUNT(*) AS c FROM transactions WHERE user_id = ? "
      "AND deleted_at IS NULL AND date >= ? AND UPPER(category) IN ('OTHER','UNCATEGORIZED','UNKNOWN','')",
      variables: [Variable.withString(_userId), Variable.withInt(monthStart)],
      readsFrom: {_db.transactions},
    ).getSingle();

    final feeRow = await _db.customSelect(
      'SELECT COALESCE(SUM(fee),0.0) AS s FROM transactions '
      'WHERE user_id = ? AND deleted_at IS NULL AND date >= ?',
      variables: [Variable.withString(_userId), Variable.withInt(monthStart)],
      readsFrom: {_db.transactions},
    ).getSingle();

    final budgetRow = await _db.customSelect(
      'SELECT COALESCE(SUM(limit_amount),0.0) AS s FROM budgets '
      'WHERE user_id = ? AND deleted_at IS NULL',
      variables: [Variable.withString(_userId)],
      readsFrom: {_db.budgets},
    ).getSingle();

    return FinanceSpendingSummary(
      todayTotal: todayTotal,
      weekTotal: weekTotal,
      monthTotal: monthTotal,
      categoryBreakdown: [
        // Nullable casts + defaults, matching the safer pattern used elsewhere
        // (insights/misc): a stray NULL from a future migration yields a blank
        // row instead of crashing the whole Finance summary.
        for (final r in breakdownRows)
          FinanceCategoryBreakdown(
            category: r.data['category'] as String? ?? '',
            total: (r.data['total'] as num?)?.toDouble() ?? 0,
          ),
      ],
      topMerchant: merchantsRows.isEmpty
          ? null
          : merchantsRows.first.data['merchant'] as String?,
      topMerchants: [
        for (final r in merchantsRows)
          (
            r.data['merchant'] as String? ?? '',
            (r.data['total'] as num?)?.toDouble() ?? 0
          )
      ],
      uncategorizedCount: uncategorizedRow.data['c'] as int,
      monthFeesTotal: (feeRow.data['s'] as num).toDouble(),
      totalMonthBudget: (budgetRow.data['s'] as num).toDouble(),
    );
  }

  Future<int> addManual({
    required double amount,
    required String merchant,
    required String category,
    String? notes,
    double fee = 0,
    int? dateOverrideMs,
    String? typeOverride,
  }) async {
    final id = await _nextId();
    final now = DateTime.now().millisecondsSinceEpoch;
    final txType = typeOverride ??
        (amount < 0 ? 'SENT' : 'RECEIVED');
    await _db.into(_db.transactions).insert(TransactionsCompanion.insert(
          id: id,
          userId: _userId,
          amount: amount,
          merchant: merchant,
          category: category,
          date: dateOverrideMs ?? now,
          source: 'MANUAL',
          transactionType: txType,
          createdAt: now,
          updatedAt: now,
          syncState: 'LOCAL',
          recordSource: 'MANUAL_ENTRY',
          revision: 0,
          notes: Value(notes),
          fee: Value(fee),
          rawSms: const Value(null),
        ));
    return id;
  }

  Future<int> _nextId() async {
    final row = await _db.customSelect(
      'SELECT COALESCE(MAX(id),0)+1 AS n FROM transactions WHERE user_id = ?',
      variables: [Variable.withString(_userId)],
    ).getSingle();
    return row.data['n'] as int;
  }

  Future<void> delete(int id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.transactions)
          ..where((t) => t.userId.equals(_userId) & t.id.equals(id)))
        .write(TransactionsCompanion(
      deletedAt: Value(now),
      updatedAt: Value(now),
      revision: const Value(1),
    ));
  }

  Future<void> recategorize(FinanceTransaction tx, String category) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.transactions)
          ..where((t) => t.userId.equals(_userId) & t.id.equals(tx.id)))
        .write(TransactionsCompanion(
      category: Value(category),
      updatedAt: Value(now),
      revision: const Value(1),
    ));
  }

  Future<void> updateTransaction({
    required int id,
    required double amount,
    required String merchant,
    required String category,
    String? notes,
    required double fee,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.transactions)
          ..where((t) => t.userId.equals(_userId) & t.id.equals(id)))
        .write(TransactionsCompanion(
      amount: Value(amount),
      merchant: Value(merchant),
      category: Value(category),
      notes: Value(notes),
      fee: Value(fee),
      updatedAt: Value(now),
      revision: const Value(1),
    ));
  }

  /// Fuliza outstanding = draws minus repayments (fuliza_events).
  Future<double?> fulizaOutstanding() async {
    try {
      final row = await _db.customSelect("""
        SELECT COALESCE(SUM(CASE WHEN event_type='DRAW' THEN amount_kes ELSE -amount_kes END),0.0) AS s
        FROM fuliza_events WHERE user_id = ?
      """, variables: [Variable.withString(_userId)], readsFrom: {_db.fulizaEvents}).getSingle();
      final v = (row.data['s'] as num).toDouble();
      return v > 0 ? v : 0.0;
    } catch (_) {
      return null;
    }
  }

  /// True when there are any FULIZA-type transactions (triggers limit dialog).
  Future<bool> hasFulizaActivity() async {
    try {
      final row = await _db.customSelect(
        "SELECT COUNT(*) AS n FROM transactions WHERE user_id=? AND deleted_at IS NULL "
        "AND (UPPER(transaction_type) LIKE '%FULIZA%' OR UPPER(category) LIKE '%FULIZA%')",
        variables: [Variable.withString(_userId)],
        readsFrom: {_db.transactions},
      ).getSingle();
      return ((row.data['n'] as int?) ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }
}
