/// 1:1 port of ServiceNoticeFilter.kt.
library;

class ServiceNoticeFilter {
  /// Failed/error SMS: insufficient funds, wrong PIN, etc.
  static bool isFailedTransaction(String body) {
    final lower = body.toLowerCase();
    return lower.startsWith('failed.') ||
        lower.startsWith('failed ') ||
        lower.contains('you have entered the wrong pin') ||
        lower.contains('the number you are trying to pay has not joined') ||
        (lower.contains('insufficient funds') && lower.contains('failed'));
  }

  /// Generic success-confirmation SMS with no economic intent.
  static bool isAmbiguousSuccessReceipt(String body) {
    final lower = body.toLowerCase();
    final hasSuccessSignal = lower.contains('completed successfully') ||
        lower.contains('transaction successful') ||
        lower.contains('confirmed successfully');
    if (!hasSuccessSignal) return false;
    const intentKeywords = [
      'received', 'sent', 'paid', 'withdrawn', 'airtime',
      'fuliza', 'reversal', 'reversed', 'deposited', 'bought',
    ];
    for (final kw in intentKeywords) {
      if (lower.contains(kw)) return false;
    }
    return true;
  }
}
