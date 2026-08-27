/// Dashboard repository — reactive Drift port of DashboardRepositoryImpl.
///
/// Combines watch-streams for today/week/month spend, upcoming events,
/// pending/completed tasks, week-window transactions and month income into a
/// single [DashboardData] stream (Drift re-emits on table changes, matching
/// Kotlin's SQLDelight Flow combine chain).
library;

import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/database/database.dart';
import '../domain/dashboard_data.dart';

class DashboardRepository {
  DashboardRepository(this._db, this._userId);

  final LifeOsDatabase _db;
  String _userId;

  set userId(String v) => _userId = v;

  static const String _spendTypes =
      "('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','PAID','WITHDRAWN')";

  Stream<DashboardData> watchDashboard() {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final todayStart = DateTime(nowMs).hour == -1
        ? 0
        : _startOfDay(DateTime.now()).millisecondsSinceEpoch;
    final todayEnd = todayStart + 86400000 - 1;
    final now = DateTime.now();
    final monday =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final weekStart = monday.millisecondsSinceEpoch;
    final monthStart = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
    final monthEnd = DateTime(now.year, now.month + 1, 1).millisecondsSinceEpoch - 1;

    final todaySpend$ = (_db.customSelect(
      'SELECT COALESCE(SUM(amount),0.0) AS s FROM transactions '
      'WHERE user_id = ? AND deleted_at IS NULL AND date BETWEEN ? AND ? '
      'AND UPPER(transaction_type) IN $_spendTypes',
      variables: [Variable.withString(_userId), Variable.withInt(todayStart), Variable.withInt(todayEnd)],
      readsFrom: {_db.transactions},
    ).watchSingle())
        .map((r) => (r.data['s'] as num).toDouble());

    final weekSpend$ = (_db.customSelect(
      'SELECT COALESCE(SUM(amount),0.0) AS s FROM transactions '
      'WHERE user_id = ? AND deleted_at IS NULL AND date BETWEEN ? AND ? '
      'AND UPPER(transaction_type) IN $_spendTypes',
      variables: [Variable.withString(_userId), Variable.withInt(weekStart), Variable.withInt(todayEnd)],
      readsFrom: {_db.transactions},
    ).watchSingle())
        .map((r) => (r.data['s'] as num).toDouble());

    final monthSpend$ = (_db.customSelect(
      'SELECT COALESCE(SUM(amount),0.0) AS s FROM transactions '
      'WHERE user_id = ? AND deleted_at IS NULL AND date BETWEEN ? AND ? '
      'AND UPPER(transaction_type) IN $_spendTypes',
      variables: [Variable.withString(_userId), Variable.withInt(monthStart), Variable.withInt(monthEnd)],
      readsFrom: {_db.transactions},
    ).watchSingle())
        .map((r) => (r.data['s'] as num).toDouble());

    final monthIncome$ = (_db.customSelect(
      'SELECT COALESCE(SUM(amount),0.0) AS s FROM incomes '
      'WHERE user_id = ? AND deleted_at IS NULL AND date BETWEEN ? AND ?',
      variables: [Variable.withString(_userId), Variable.withInt(monthStart), Variable.withInt(monthEnd)],
      readsFrom: {_db.incomes},
    ).watchSingle())
        .map((r) => (r.data['s'] as num).toDouble());

    final events$ = (_db.customSelect(
      "SELECT id, title, date FROM events "
      "WHERE user_id = ? AND status = 'PENDING' AND date >= ? ORDER BY date ASC LIMIT 5",
      variables: [Variable.withString(_userId), Variable.withInt(nowMs)],
      readsFrom: {_db.events},
    ).watch())
        .map((rows) => rows
            .map((r) => UpcomingEvent(
                  id: r.data['id'] as int,
                  title: r.data['title'] as String,
                  date: r.data['date'] as int,
                ))
            .toList());

    final pendingTasks$ = (_db.customSelect(
      "SELECT COUNT(*) AS c FROM tasks WHERE user_id = ? AND status != 'COMPLETED' AND deleted_at IS NULL",
      variables: [Variable.withString(_userId)],
      readsFrom: {_db.tasks},
    ).watchSingle())
        .map((r) => (r.data['c'] as int));

    final recentTx$ = (_db.select(_db.transactions)
          ..where((t) => t.userId.equals(_userId) & t.deletedAt.isNull())
          ..where((t) => t.date.isBetweenValues(weekStart, todayEnd))
          ..orderBy([(u) => OrderingTerm.desc(u.date)]))
        .watch()
        .map((rows) => rows
            .map((r) => RecentTransaction(
                  id: r.id,
                  amount: r.amount,
                  merchant: r.merchant,
                  category: r.category,
                  transactionType: r.transactionType,
                  date: r.date,
                ))
            .toList());

    return Rx.combineLatest7<double, double, double, double, List<UpcomingEvent>, int,
        List<RecentTransaction>, _Core>(
      todaySpend$, weekSpend$, monthSpend$, monthIncome$, events$, pendingTasks$, recentTx$,
      (today, week, month, income, events, pending, txs) => _Core(
        todaySpending: today,
        weekSpending: week,
        monthSpending: month,
        monthIncome: income,
        events: events,
        pending: pending,
        txs: txs,
      ),
    )
    // Collapse rapid bursts (e.g. during a large SMS import that writes
    // thousands of rows in quick succession) into a single downstream event.
    // 250 ms is imperceptible to the user but prevents the asyncMap from
    // queuing hundreds of concurrent DB calls that can transiently error.
    .debounceTime(const Duration(milliseconds: 250))
    .asyncMap((core) async {
      final completedToday = await _db.customSelect(
        "SELECT COUNT(*) AS c FROM tasks WHERE user_id = ? AND status = 'COMPLETED' "
        'AND completed_at BETWEEN ? AND ?',
        variables: [
          Variable.withString(_userId),
          Variable.withInt(todayStart),
          Variable.withInt(todayEnd)
        ],
        readsFrom: {_db.tasks},
      ).getSingle();

      return DashboardData(
        greeting:
            DashboardData.buildGreeting(await _profileName(), await _username()),
        todaySpending: core.todaySpending,
        weekSpending: core.weekSpending,
        monthSpending: core.monthSpending,
        upcomingEvents: core.events,
        pendingTaskCount: core.pending,
        completedTodayCount: completedToday.data['c'] as int,
        recentTransactions: core.txs.take(5).toList(),
        weeklySpendingData: DashboardData.buildWeeklySpending(core.txs),
        insights: const [],
      );
    });
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<String> _profileName() async {
    // user_name lives in SharedPreferences; injected via setter to keep this
    // class DB-only. Defaults to '' until profile pass wires it up.
    return _profileNameOverride ?? '';
  }

  Future<String> _username() async => _usernameOverride ?? '';

  String? _profileNameOverride;
  String? _usernameOverride;

  void setProfile({String? name, String? username}) {
    _profileNameOverride = name;
    _usernameOverride = username;
  }
}

class _Core {
  const _Core({
    required this.todaySpending,
    required this.weekSpending,
    required this.monthSpending,
    required this.monthIncome,
    required this.events,
    required this.pending,
    required this.txs,
  });

  final double todaySpending;
  final double weekSpending;
  final double monthSpending;
  final double monthIncome;
  final List<UpcomingEvent> events;
  final int pending;
  final List<RecentTransaction> txs;
}
