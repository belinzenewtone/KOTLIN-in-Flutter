/// Planner suite repositories — Budget / Income / Recurring / Bills / Goals
/// CRUD over Drift (ports of those feature repositories).
library;

import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

class PlannerRepository {
  PlannerRepository(this._db, this._userId);

  final LifeOsDatabase _db;
  String _userId;

  set userId(String v) => _userId = v;

  Future<int> _nextId(String table) async {
    final row = await _db.customSelect(
      'SELECT COALESCE(MAX(id),0)+1 AS n FROM $table WHERE user_id = ?',
      variables: [Variable.withString(_userId)],
    ).getSingle();
    return row.data['n'] as int;
  }

  int get _now => DateTime.now().millisecondsSinceEpoch;

  // ── Budgets ───────────────────────────────────────────────────────────────

  Future<void> addBudget(
    String category,
    double limitAmount, {
    String period = 'MONTHLY',
    double? alertThreshold,
  }) async {
    final id = await _nextId('budgets');
    await _db.into(_db.budgets).insert(BudgetsCompanion.insert(
          id: id,
          userId: _userId,
          category: category.trim().toUpperCase(),
          limitAmount: limitAmount,
          period: period,
          alertThreshold: Value(alertThreshold),
          createdAt: _now,
          updatedAt: _now,
          syncState: 'LOCAL',
          recordSource: 'MANUAL_ENTRY',
          revision: 0,
        ));
  }

  Future<void> updateBudget(
    int id, {
    required String category,
    required double limitAmount,
    required String period,
    double? alertThreshold,
  }) async {
    await (_db.update(_db.budgets)
          ..where((b) => b.userId.equals(_userId) & b.id.equals(id)))
        .write(BudgetsCompanion(
      category: Value(category.trim().toUpperCase()),
      limitAmount: Value(limitAmount),
      period: Value(period),
      alertThreshold: Value(alertThreshold),
      updatedAt: Value(_now),
      syncState: const Value('LOCAL'),
    ));
  }

  Future<void> toggleActiveBudget(int id, bool active) async {
    await (_db.update(_db.budgets)
          ..where((b) => b.userId.equals(_userId) & b.id.equals(id)))
        .write(BudgetsCompanion(
      isActive: Value(active),
      updatedAt: Value(_now),
    ));
  }

  Future<void> deleteBudget(int id) async {
    await (_db.update(_db.budgets)
          ..where((b) => b.userId.equals(_userId) & b.id.equals(id)))
        .write(BudgetsCompanion(deletedAt: Value(_now), updatedAt: Value(_now)));
  }

  Stream<List<Budget>> watchBudgets() {
    final q = _db.select(_db.budgets)
      ..where((b) => b.userId.equals(_userId) & b.deletedAt.isNull())
      ..orderBy([(b) => OrderingTerm.desc(b.limitAmount)]);
    return q.watch();
  }

  /// Spent per category this month (BudgetProgressIndicator inputs).
  Future<Map<String, double>> monthSpendByCategory() =>
      _spendByCategoryQuery().get().then(_mapSpendRows);

  /// Reactive stream — re-emits whenever the transactions table changes.
  Stream<Map<String, double>> watchMonthSpendByCategory() =>
      _spendByCategoryQuery().watch().map(_mapSpendRows);

  Selectable<QueryRow> _spendByCategoryQuery() {
    final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1)
        .millisecondsSinceEpoch;
    return _db.customSelect(
      'SELECT category, SUM(amount) AS total FROM transactions '
      "WHERE user_id = ? AND deleted_at IS NULL AND date >= ? AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','PAID','WITHDRAWN') "
      'GROUP BY category',
      variables: [Variable.withString(_userId), Variable.withInt(monthStart)],
      readsFrom: {_db.transactions},
    );
  }

  Map<String, double> _mapSpendRows(List<QueryRow> rows) => {
        for (final r in rows)
          r.data['category'] as String: (r.data['total'] as num).toDouble(),
      };

  // ── Income ────────────────────────────────────────────────────────────────

  Future<void> addIncome(
    double amount,
    String source, {
    String? note,
    bool isRecurring = false,
    String? frequency,
    int? date,
  }) async {
    final id = await _nextId('incomes');
    await _db.into(_db.incomes).insert(IncomesCompanion.insert(
          id: id,
          userId: _userId,
          amount: amount,
          source: source,
          date: date ?? _now,
          note: note ?? '',
          isRecurring: isRecurring,
          frequency: Value(frequency),
          createdAt: _now,
          updatedAt: _now,
          syncState: 'LOCAL',
          recordSource: 'MANUAL_ENTRY',
          revision: 0,
        ));
  }

  Future<void> toggleBillPaid(Bill bill) async {
    await (_db.update(_db.bills)
          ..where((b) => b.userId.equals(_userId) & b.id.equals(bill.id)))
        .write(BillsCompanion(
      paidStatus: Value(!bill.paidStatus),
      lastPaidAt: bill.paidStatus ? const Value(null) : Value(_now),
    ));
  }

  Future<void> updateIncome(
    int id, {
    required double amount,
    required String source,
    String? note,
    required bool isRecurring,
    String? frequency,
    required int date,
  }) async {
    await (_db.update(_db.incomes)
          ..where((i) => i.userId.equals(_userId) & i.id.equals(id)))
        .write(IncomesCompanion(
      amount: Value(amount),
      source: Value(source),
      note: Value(note ?? ''),
      isRecurring: Value(isRecurring),
      frequency: Value(frequency),
      date: Value(date),
      updatedAt: Value(_now),
    ));
  }

  Future<void> deleteIncome(int id) async {
    await (_db.update(_db.incomes)
          ..where((i) => i.userId.equals(_userId) & i.id.equals(id)))
        .write(IncomesCompanion(deletedAt: Value(_now), updatedAt: Value(_now)));
  }

  Stream<List<Income>> watchIncomes() {
    final q = _db.select(_db.incomes)
      ..where((i) => i.userId.equals(_userId) & i.deletedAt.isNull())
      ..orderBy([(i) => OrderingTerm.desc(i.date)]);
    return q.watch();
  }

  // ── Recurring rules ───────────────────────────────────────────────────────

  Future<void> addRecurring({
    required String title,
    required String type,
    required String cadence,
    double? amount,
    String category = 'RECURRING',
    int? nextRunAt,
  }) async {
    final id = await _nextId('recurring_rules');
    const day = 86400000;
    final defaultNextRun = switch (cadence.toUpperCase()) {
      'WEEKLY' => _now + 7 * day,
      'MONTHLY' => _now + 30 * day,
      'QUARTERLY' => _now + 90 * day,
      _ => _now + 30 * day,
    };
    await _db.into(_db.recurringRules).insert(RecurringRulesCompanion.insert(
          id: id,
          userId: _userId,
          title: title,
          type: type,
          cadence: cadence.toUpperCase(),
          nextRunAt: nextRunAt ?? defaultNextRun,
          enabled: true,
          amount: Value(amount),
          category: Value(category),
          createdAt: _now,
          updatedAt: _now,
          syncState: 'LOCAL',
          recordSource: 'MANUAL_ENTRY',
          revision: 0,
        ));
  }

  Future<void> toggleRecurring(RecurringRule rule) async {
    await (_db.update(_db.recurringRules)
          ..where((r) => r.userId.equals(_userId) & r.id.equals(rule.id)))
        .write(RecurringRulesCompanion(enabled: Value(!rule.enabled), updatedAt: Value(_now)));
  }

  Future<void> updateRecurring({
    required int id,
    required String title,
    required String type,
    required String cadence,
    double? amount,
    required String category,
    int? nextRunAt,
  }) async {
    await (_db.update(_db.recurringRules)
          ..where((r) => r.userId.equals(_userId) & r.id.equals(id)))
        .write(RecurringRulesCompanion(
      title: Value(title),
      type: Value(type),
      cadence: Value(cadence),
      amount: Value(amount),
      category: Value(category),
      nextRunAt: Value(nextRunAt ?? _now),
      updatedAt: Value(_now),
    ));
  }

  Future<void> deleteRecurring(int id) async {
    await (_db.update(_db.recurringRules)
          ..where((r) => r.userId.equals(_userId) & r.id.equals(id)))
        .write(RecurringRulesCompanion(deletedAt: Value(_now), updatedAt: Value(_now)));
  }

  Stream<List<RecurringRule>> watchRecurring() {
    final q = _db.select(_db.recurringRules)
      ..where((r) => r.userId.equals(_userId) & r.deletedAt.isNull())
      ..orderBy([(r) => OrderingTerm.asc(r.nextRunAt)]);
    return q.watch();
  }

  // ── Bills ────────────────────────────────────────────────────────────────

  Future<void> addBill({
    required String title,
    required double amount,
    required String cycle,
    required int nextDueDate,
    String notes = '',
  }) async {
    final id = await _nextId('bills');
    await _db.into(_db.bills).insert(BillsCompanion.insert(
          id: id,
          userId: _userId,
          title: title,
          amount: amount,
          cycle: cycle,
          nextDueDate: nextDueDate,
          notes: notes,
          isActive: true,
          createdAt: _now,
          updatedAt: _now,
          syncState: 'LOCAL',
        ));
  }

  Future<void> markBillPaid(Bill bill) async {
    await (_db.update(_db.bills)
          ..where((b) => b.userId.equals(_userId) & b.id.equals(bill.id)))
        .write(BillsCompanion(paidStatus: const Value(true), lastPaidAt: Value(_now)));
  }

  Future<void> toggleActiveBill(Bill bill) async {
    await (_db.update(_db.bills)
          ..where((b) => b.userId.equals(_userId) & b.id.equals(bill.id)))
        .write(BillsCompanion(
      isActive: Value(!bill.isActive),
      updatedAt: Value(_now),
    ));
  }

  Future<void> updateBill({
    required int id,
    required String title,
    required double amount,
    required String cycle,
    required int nextDueDate,
    required String notes,
  }) async {
    await (_db.update(_db.bills)
          ..where((b) => b.userId.equals(_userId) & b.id.equals(id)))
        .write(BillsCompanion(
      title: Value(title),
      amount: Value(amount),
      cycle: Value(cycle),
      nextDueDate: Value(nextDueDate),
      notes: Value(notes),
      updatedAt: Value(_now),
    ));
  }

  Future<void> deleteBill(int id) async {
    await (_db.update(_db.bills)
          ..where((b) => b.userId.equals(_userId) & b.id.equals(id)))
        .write(BillsCompanion(deletedAt: Value(_now)));
  }

  Stream<List<Bill>> watchBills() {
    final q = _db.select(_db.bills)
      ..where((b) => b.userId.equals(_userId) & b.deletedAt.isNull())
      ..orderBy([(b) => OrderingTerm.asc(b.nextDueDate)]);
    return q.watch();
  }

  // ── Goals ────────────────────────────────────────────────────────────────

  Future<void> addGoal({
    required String title,
    required String description,
    required double targetValue,
    required String unit,
    required String category,
    int? deadline,
  }) async {
    final id = await _nextId('goals');
    await _db.into(_db.goals).insert(GoalsCompanion.insert(
          id: id,
          userId: _userId,
          title: title,
          description: description,
          targetValue: targetValue,
          currentValue: 0,
          unit: unit,
          category: category,
          status: 'ACTIVE',
          createdAt: _now,
          updatedAt: _now,
          syncState: 'LOCAL',
          revision: 0,
          deadline: Value(deadline),
        ));
  }

  Future<void> updateGoalProgress(Goal g, double newValue) async {
    final status = newValue >= g.targetValue ? 'COMPLETED' : 'ACTIVE';
    await (_db.update(_db.goals)
          ..where((x) => x.userId.equals(_userId) & x.id.equals(g.id)))
        .write(GoalsCompanion(currentValue: Value(newValue), status: Value(status), updatedAt: Value(_now)));
  }

  Future<void> updateGoal({
    required int id,
    required String title,
    required String description,
    required double targetValue,
    required String unit,
    required String category,
    int? deadline,
  }) async {
    await (_db.update(_db.goals)
          ..where((g) => g.userId.equals(_userId) & g.id.equals(id)))
        .write(GoalsCompanion(
      title: Value(title),
      description: Value(description),
      targetValue: Value(targetValue),
      unit: Value(unit),
      category: Value(category),
      deadline: Value(deadline),
      updatedAt: Value(_now),
    ));
  }

  Future<void> deleteGoal(int id) async {
    await (_db.update(_db.goals)
          ..where((g) => g.userId.equals(_userId) & g.id.equals(id)))
        .write(GoalsCompanion(deletedAt: Value(_now), updatedAt: Value(_now)));
  }

  Stream<List<Goal>> watchGoals() {
    final q = _db.select(_db.goals)
      ..where((g) => g.userId.equals(_userId) & g.deletedAt.isNull())
      ..orderBy([(g) => OrderingTerm.desc(g.createdAt)]);
    return q.watch();
  }
}
