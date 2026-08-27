/// App-level providers: database singleton, dashboard repository + Home stream.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/database.dart';
import '../../../core/utils/date_utils.dart';
import 'dashboard_repository.dart';
import '../../home/presentation/home_screen.dart';

/// Opens (and keeps) the WAL-tuned LifeOS database.
final lifeOsDatabaseProvider = FutureProvider<LifeOsDatabase>(
    (ref) => LifeOsDatabase.open());

/// Active user id — local-only auth (Kotlin AuthSessionStore parity).
final userIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_user_id') ?? 'local-user';
});

final dashboardRepositoryProvider = FutureProvider<DashboardRepository>(
    (ref) async {
  final db = await ref.watch(lifeOsDatabaseProvider.future);
  final userId = await ref.watch(userIdProvider.future);
  final repo = DashboardRepository(db, userId);
  final prefs = await SharedPreferences.getInstance();
  repo.setProfile(
    name: prefs.getString('user_name'),
    username: prefs.getString('auth_username'),
  );
  return repo;
});

/// Maps DashboardData → HomeUiState (HomeContracts.toHomeUiState).
///
/// If the inner Drift stream throws a transient error (e.g. DB contention
/// during a large SMS import burst), the generator catches it, waits 2 s, and
/// re-subscribes — instead of propagating a fatal error to the StreamProvider
/// that would show "could not load home data" until the user taps Retry.
Stream<HomeUiState> watchHomeUiState(Ref ref) async* {
  final repo = await ref.watch(dashboardRepositoryProvider.future);
  while (true) {
    try {
      await for (final d in repo.watchDashboard()) {
        yield HomeUiState(
          greeting: d.greeting,
          dateLabel:
              AppDateUtils.formatDate(AppDateUtils.nowMillis, 'EEEE, MMM dd'),
          todaySpending: d.todaySpending,
          weekSpending: d.weekSpending,
          monthSpending: d.monthSpending,
          pendingTaskCount: d.pendingTaskCount,
          completedTodayCount: d.completedTodayCount,
          nextEventTitle: d.upcomingEvents.isEmpty ? null : d.upcomingEvents.first.title,
          nextEventTimeLabel:
              d.upcomingEvents.isEmpty ? null : AppDateUtils.formatTime(d.upcomingEvents.first.date),
          isLoading: false,
          hasWeeklyRitual: true,
        );
      }
      return; // stream ended normally
    } catch (_) {
      // Transient error — 2 s backoff then restart.
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }
}
