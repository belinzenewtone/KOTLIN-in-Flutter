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

  /// buildGreeting() parity: hour-based salutation + first name (≤12 chars).
  static String buildGreeting(String profileName, String username) {
    final hour = DateTime.now().hour;
    final timeGreeting =
        hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final displayName =
        username.trim().isNotEmpty ? username.trim() : profileName.trim();
    var firstName = displayName.split(' ').firstOrNull ?? '';
    if (firstName.length > 12) firstName = firstName.substring(0, 12);
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
