/// 1:1 port of core/utils/DateUtils.kt — window boundaries, formatting,
/// relative time. Currency uses Kotlin's exact "KSh <grouped-int>" shape
/// (decimals truncated via toLong()).
library;

import 'package:intl/intl.dart';

int currentTimeMillis() => DateTime.now().millisecondsSinceEpoch;

final class AppDateUtils {
  static DateTime _local(int ms) => DateTime.fromMillisecondsSinceEpoch(ms);

  static int get nowMillis => DateTime.now().millisecondsSinceEpoch;

  static int hoursAgoMillis(int hours) =>
      DateTime.now().millisecondsSinceEpoch - hours * 3600000;

  static int daysAgoMillis(int days) =>
      DateTime.now().millisecondsSinceEpoch - days * 86400000;

  /// Start of today (00:00 local).
  static int get todayStartMillis {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day).millisecondsSinceEpoch;
  }

  /// End of today (23:59:59.999 local) — mirrors atEndOfDay in Kotlin.
  static int get todayEndMillis {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day + 1).millisecondsSinceEpoch - 1;
  }

  /// Monday of this week (previousOrSame MONDAY), start of day.
  static int get weekStartMillis {
    final n = DateTime.now();
    final d = DateTime(n.year, n.month, n.day);
    final offset = d.weekday - DateTime.monday; // Mon=1 → 0
    final monday = d.subtract(Duration(days: offset));
    return monday.millisecondsSinceEpoch;
  }

  /// Sunday of this week (nextOrSame SUNDAY), end of day.
  static int get weekEndMillis {
    final n = DateTime.now();
    final d = DateTime(n.year, n.month, n.day);
    final offset = DateTime.sunday - d.weekday;
    final sunday = d.add(Duration(days: offset >= 0 ? offset : offset + 7));
    return sunday.millisecondsSinceEpoch +
        const Duration(days: 1).inMilliseconds -
        1;
  }

  static int monthStartOf(int year, int month) =>
      DateTime(year, month, 1).millisecondsSinceEpoch;

  static int get monthStartMillis {
    final n = DateTime.now();
    return DateTime(n.year, n.month, 1).millisecondsSinceEpoch;
  }

  static int get monthEndMillis {
    final n = DateTime.now();
    return DateTime(n.year, n.month + 1, 1).millisecondsSinceEpoch - 1;
  }

  static int get yearStartMillis =>
      DateTime(DateTime.now().year, 1, 1).millisecondsSinceEpoch;

  static int get yearEndMillis =>
      DateTime(DateTime.now().year + 1, 1, 1).millisecondsSinceEpoch - 1;

  /// Pattern formatting supporting the app's used patterns:
  /// "MMM dd, yyyy" · "h:mm a" · "EEEE, MMM dd" · "MMM dd" · "d/M/yyyy".
  static String formatDate(int epochMillis, [String pattern = 'MMM dd, yyyy']) {
    final dt = _local(epochMillis);
    // Translate Java patterns to intl where identical; custom map otherwise.
    const passthrough = {'MMM dd, yyyy', 'h:mm a', 'MMM dd', 'd/M/yyyy', 'MMMM yyyy'};
    final p = passthrough.contains(pattern) ? pattern : null;
    if (p != null) {
      try {
        return DateFormat(p, 'en_US').format(dt);
      } catch (_) {/* fall through */}
    }
    // Hand-rolled fallbacks for composite patterns.
    switch (pattern) {
      case 'EEEE, MMM dd':
        const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${weekdays[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}';
      default:
        return DateFormat('MMM dd, yyyy').format(dt);
    }
  }

  static String formatTime(int epochMillis) => formatDate(epochMillis, 'h:mm a');

  /// "KSh 12,345" — grouped integer part only (Kotlin formatNumber parity).
  static String formatCurrency(double amount) => 'KSh ${_formatNumber(amount)}';

  static String _formatNumber(double value) {
    final long = value.truncate();
    final str = long.toString();
    final sb = StringBuffer();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      final ch = str[i];
      if (ch == '-') {
        sb.write('-');
        continue;
      }
      if (count > 0 && count % 3 == 0) sb.write(',');
      sb.write(ch);
      count++;
    }
    return sb.toString().split('').reversed.join();
  }

  static String formatRelativeTime(int epochMillis, {int? referenceTimeMillis}) {
    final ref = referenceTimeMillis ?? DateTime.now().millisecondsSinceEpoch;
    final delta = (ref - epochMillis).clamp(0, 1 << 62);
    final minutes = delta ~/ 60000;
    final hours = delta ~/ 3600000;
    final days = delta ~/ 86400000;

    if (minutes < 1) return 'just now';
    if (minutes < 60) return '$minutes min ago';
    if (hours < 24) return '$hours hr ago';
    if (days < 7) return days == 1 ? '1 day ago' : '$days days ago';
    return formatDate(epochMillis, 'MMM dd');
  }

  /// Parses "dd/MM/yyyy" to epoch millis at start-of-day; null when invalid.
  static int? parseDdMmYyyy(String text) {
    final m = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(text.trim());
    if (m == null) return null;
    final d = int.tryParse(m.group(1)!),
        mo = int.tryParse(m.group(2)!),
        y = int.tryParse(m.group(3)!);
    if (d == null || mo == null || y == null || mo < 1 || mo > 12) return null;
    try {
      return DateTime(y, mo, d).millisecondsSinceEpoch;
    } catch (_) {
      return null;
    }
  }
}
