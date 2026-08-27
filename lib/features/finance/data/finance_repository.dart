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
  ///
  /// All 8 DB queries run in parallel via Future.wait() — reduces the load
  /// time from (sum of query times) to (slowest single query).
  ///
  /// The uncategorized count uses the same broad filter and "no date limit"
  /// logic as CategorizePage, and counts distinct merchant groups rather than
  /// individual rows — so the banner number matches what you see when you open
  /// the Categorize page.
  Future<FinanceSpendingSummary> summary() async {
    final now = DateTime.now();
    final todayStart =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final weekStart = monday.millisecondsSinceEpoch;
    final monthStart = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;

    // Broad uncategorized filter — mirrors _CategorizeState._uncatFilter in
    // misc_screens.dart so the banner count stays in sync.
    const uncatFilter =
        "(category IS NULL OR category='' OR LOWER(category) IN "
        "('uncategorized','other','others','unknown','other category'))";

    Future<double> sumQuery(int fromMs) async {
      final row = await _db.customSelect(
        'SELECT COALESCE(SUM(amount),0.0) AS s FROM transactions '
        'WHERE user_id = ? AND deleted_at IS NULL AND date >= ? '
        'AND UPPER(transaction_type) IN $_spendTypes',
        variables: [Variable.withString(_userId), Variable.withInt(fromMs)],
        readsFrom: {_db.transactions},
      ).getSingle();
      return (row.data['s'] as num).toDouble();
    }

    // Run all 8 independent queries concurrently.
    final results = await Future.wait([
      /* 0 */ sumQuery(todayStart),
      /* 1 */ sumQuery(weekStart),
      /* 2 */ sumQuery(monthStart),
      /* 3 */ _db.customSelect(
        'SELECT category, SUM(amount) AS total FROM transactions '
        'WHERE user_id = ? AND deleted_at IS NULL AND date >= ? '
        'AND UPPER(transaction_type) IN $_spendTypes '
        'GROUP BY category ORDER BY total DESC',
        variables: [Variable.withString(_userId), Variable.withInt(monthStart)],
        readsFrom: {_db.transactions},
      ).get(),
      /* 4 */ _db.customSelect(
        'SELECT merchant, SUM(amount) AS total FROM transactions '
        'WHERE user_id = ? AND deleted_at IS NULL AND date >= ? '
        'AND UPPER(transaction_type) IN $_spendTypes '
        'GROUP BY merchant ORDER BY total DESC LIMIT 5',
        variables: [Variable.withString(_userId), Variable.withInt(monthStart)],
        readsFrom: {_db.transactions},
      ).get(),
      /* 5 — count distinct merchant groups (matches CategorizePage) */
      _db.customSelect(
        'SELECT COUNT(*) AS c FROM ('
        '  SELECT COALESCE(merchant,\'Unknown\') FROM transactions'
        '  WHERE user_id = ? AND deleted_at IS NULL AND $uncatFilter'
        '  GROUP BY merchant'
        ')',
        variables: [Variable.withString(_userId)],
        readsFrom: {_db.transactions},
      ).getSingle(),
      /* 6 */ _db.customSelect(
        'SELECT COALESCE(SUM(fee),0.0) AS s FROM transactions '
        'WHERE user_id = ? AND deleted_at IS NULL AND date >= ?',
        variables: [Variable.withString(_userId), Variable.withInt(monthStart)],
        readsFrom: {_db.transactions},
      ).getSingle(),
      /* 7 */ _db.customSelect(
        'SELECT COALESCE(SUM(limit_amount),0.0) AS s FROM budgets '
        'WHERE user_id = ? AND deleted_at IS NULL',
        variables: [Variable.withString(_userId)],
        readsFrom: {_db.budgets},
      ).getSingle(),
    ]);

    final todayTotal    = results[0] as double;
    final weekTotal     = results[1] as double;
    final monthTotal    = results[2] as double;
    final breakdownRows = results[3] as List<QueryRow>;
    final merchantsRows = results[4] as List<QueryRow>;
    final uncatRow      = results[5] as QueryRow;
    final feeRow        = results[6] as QueryRow;
    final budgetRow     = results[7] as QueryRow;

    return FinanceSpendingSummary(
      todayTotal: todayTotal,
      weekTotal: weekTotal,
      monthTotal: monthTotal,
      categoryBreakdown: [
        for (final r in breakdownRows)
          FinanceCategoryBreakdown(
            category: r.data['category'] as String,
            total: (r.data['total'] as num).toDouble(),
          ),
      ],
      topMerchant: merchantsRows.isEmpty
          ? null
          : merchantsRows.first.data['merchant'] as String,
      topMerchants: [
        for (final r in merchantsRows)
          (
            r.data['merchant'] as String,
            (r.data['total'] as num).toDouble()
          )
      ],
      uncategorizedCount: uncatRow.data['c'] as int,
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
