/// Dashboard domain model — port of features/dashboard/domain/model.
library;

class UpcomingEvent {
  const UpcomingEvent({required this.id, required this.title, required this.date});
  final int id;
  final String title;
  final int date;
}

class RecentTransaction {
  const RecentTransaction({
    required this.id,
    required this.amount,
    required this.merchant,
    required this.category,
    required this.transactionType,
    required this.date,
  });
  final int id;
  final double amount;
  final String merchant;
  final String category;
  final String transactionType;
  final int date;
}

class DailySpending {
  const DailySpending({required this.dayLabel, required this.total});
  final String dayLabel;
  final double total;
}

class DashboardInsight {
  const DashboardInsight({required this.title, this.body});
  final String title;
  final String? body;
}

class DashboardData {
  const DashboardData({
    required this.greeting,
    required this.todaySpending,
    required this.weekSpending,
    required this.monthSpending,
    required this.upcomingEvents,
    required this.pendingTaskCount,
    required this.completedTodayCount,
    required this.recentTransactions,
    required this.weeklySpendingData,
    required this.insights,
  });

  final String greeting;
  final double todaySpending;
  final double weekSpending;
  final double monthSpending;
  final List<UpcomingEvent> upcomingEvents;
  final int pendingTaskCount;
  final int completedTodayCount;
  final List<RecentTransaction> recentTransactions;
  final List<DailySpending> weeklySpendingData;
  final List<DashboardInsight> insights;

  /// buildGreeting() parity: hour-based salutation + display name.
  /// Username is capped at 8 chars (matches the Profile Settings limit);
  /// profile first name is shown as-is when no username is set.
  static String buildGreeting(String profileName, String username) {
    final hour = DateTime.now().hour;
    final timeGreeting =
        hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    String firstName;
    if (username.trim().isNotEmpty) {
      // Username: honour the 8-char limit set everywhere else in the app.
      final u = username.trim();
      firstName = u.length > 8 ? u.substring(0, 8) : u;
    } else {
      // No username — use the first word of the profile name (no hard cap).
      firstName = profileName.trim().split(' ').firstOrNull ?? '';
    }
    if (firstName.isNotEmpty) return '$timeGreeting, $firstName';
    return timeGreeting;
  }

  /// Weekly spending buckets Mon..Sun from week-window transactions.
  static List<DailySpending> buildWeeklySpending(
      List<RecentTransaction> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - DateTime.monday));

    const spendTypes = {
      'SENT', 'AIRTIME', 'PAYBILL', 'BUY_GOODS', 'WITHDRAW', 'PAID', 'WITHDRAWN'
    };
    final buckets = List<double>.filled(7, 0.0);
    for (final tx in transactions) {
      final type = tx.transactionType.toUpperCase();
      if (!spendTypes.contains(type)) continue;
      final d = DateTime.fromMillisecondsSinceEpoch(tx.date);
      final day = DateTime(d.year, d.month, d.day);
      final idx = day.difference(monday).inDays;
      if (idx >= 0 && idx < 7) buckets[idx] += tx.amount;
    }

    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return [
      for (var i = 0; i < 7; i++) DailySpending(dayLabel: labels[i], total: buckets[i]),
    ];
  }
}
