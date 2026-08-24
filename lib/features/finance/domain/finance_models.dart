/// Finance domain models — ports of FinanceTransaction.kt +
/// FinanceAnalyticsModels.kt.
library;

class FinanceTransaction {
  const FinanceTransaction({
    this.id = 0,
    required this.amount,
    required this.merchant,
    required this.category,
    required this.date,
    this.source = 'MPESA',
    this.transactionType = 'SENT',
    this.mpesaCode,
    this.rawSms,
    this.createdAt = 0,
    this.description,
    this.notes,
    this.fee = 0.0,
    this.balanceAfter,
    this.status = 'completed',
  });

  final int id;
  final double amount;
  final String merchant;
  final String category;
  final int date;
  final String source;
  final String transactionType;
  final String? mpesaCode;
  final String? rawSms;
  final int createdAt;
  final String? description;
  final String? notes;
  final double fee;
  final double? balanceAfter;
  final String status;

  bool get isIncome => amount < 0 || transactionType == 'RECEIVED';
}

enum FinanceTransactionFilter {
  last23Hours('23 hrs'),
  last1Month('1 month'),
  last3Months('3 months'),
  last6Months('6 months');

  const FinanceTransactionFilter(this.label);
  final String label;
}

class FinanceCategoryBreakdown {
  const FinanceCategoryBreakdown({
    required this.category,
    required this.total,
    this.percentage = 0,
  });
  final String category;
  final double total;
  final double percentage;
}

class FinanceSpendingSummary {
  const FinanceSpendingSummary({
    this.todayTotal = 0,
    this.weekTotal = 0,
    this.monthTotal = 0,
    this.lastMonthTotal = 0,
    this.transactionCount = 0,
    this.categoryBreakdown = const [],
    this.topMerchant,
    this.topMerchants = const [],
    this.monthFeesTotal = 0,
    this.uncategorizedCount = 0,
    this.totalMonthBudget = 0,
  });

  final double todayTotal;
  final double weekTotal;
  final double monthTotal;
  final double lastMonthTotal;
  final int transactionCount;
  final List<FinanceCategoryBreakdown> categoryBreakdown;
  final String? topMerchant;
  final List<(String, double)> topMerchants;
  final double monthFeesTotal;
  final int uncategorizedCount;
  final double totalMonthBudget;

  static const empty = FinanceSpendingSummary();
}

class SpendingForecast {
  const SpendingForecast({
    required this.projectedMonthEndSpend,
    required this.dailyBurnRate,
    required this.daysRemaining,
  });
  final double projectedMonthEndSpend;
  final double dailyBurnRate;
  final int daysRemaining;
}
