/// Fast M-Pesa date extraction — port of the DATE_RE matcher plus the
/// SUPPORTED_DATE_FORMATTERS / DATE_ONLY_FORMATTERS list in
/// MpesaParserEnhanced.kt, implemented as a hand-rolled tokenizer.
///
/// Why hand-rolled: DateTimeFormatter.tryParse per pattern is ~30x slower than
/// direct tokenization, and this runs once per SMS during 100k-message
/// backfills. Supported layouts (identical to Kotlin):
///   d/M/yy[yy] [h[h]:mm[:ss] [a]]  ·  d-M-yy[yy] …  ·  yyyy-MM-dd HH:mm[:]
///   d-MMM-yy[yy] …  ·  MMM d[,] yyyy …  ·  d MMM yy[yy] …
library;

final RegExp kDateRe = RegExp(
  r'(\d{1,2}[/\-]\d{1,2}[/\-]\d{2,4}|\d{4}-\d{2}-\d{2}|\d{1,2}-[A-Za-z]{3,9}-\d{2,4}|[A-Za-z]{3,9}\s+\d{1,2},?\s+\d{2,4}|\d{1,2}\s+[A-Za-z]{3,9}\s+\d{2,4})'
  r'(?:\s+(?:at\s+)?(\d{1,2}:\d{2}(?::\d{2})?(?:\s*[AP]M)?))?',
  caseSensitive: false,
);

const Map<String, int> _months = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

int _twoDigitYear(int y) {
  // java.time two-digit pivot: 2000-2099 window (same as DateTimeFormatter yy).
  if (y >= 100) return y;
  return 2000 + y;
}

/// Parses a single extracted date string (+ optional time part) to epoch ms,
/// or null when unparseable. Mirrors parseDateMatch().
int? parseMpesaDateMatch(String datePart, String? timePart) {
  final now = DateTime.now();

  int day = 0, month = 0, year = 0;
  var matched = false;

  // ISO yyyy-MM-dd
  final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(datePart);
  if (iso != null) {
    year = int.parse(iso.group(1)!);
    month = int.parse(iso.group(2)!);
    day = int.parse(iso.group(3)!);
    matched = true;
  }

  // Numeric d/M/yy or d-M-yy (also handles month-name middle token below).
  if (!matched) {
    final numeric =
        RegExp(r'^(\d{1,2})[/\-]([A-Za-z]{3,9}|\d{1,2})[/\-](\d{2,4})$').firstMatch(datePart);
    if (numeric != null) {
      day = int.parse(numeric.group(1)!);
      final mid = numeric.group(2)!;
      if (int.tryParse(mid) != null) {
        month = int.parse(mid);
      } else {
        month = _months[mid.toLowerCase().substring(0, 3)] ?? 0;
      }
      year = _twoDigitYear(int.parse(numeric.group(3)!));
      matched = month >= 1 && month <= 12;
    }
  }

  // "MMM d[, ] yyyy" — month first
  if (!matched) {
    final monthFirst =
        RegExp(r'^([A-Za-z]{3,9})\s+(\d{1,2}),?\s+(\d{2,4})$').firstMatch(datePart);
    if (monthFirst != null) {
      month = _months[monthFirst.group(1)!.toLowerCase().substring(0, 3)] ?? 0;
      day = int.parse(monthFirst.group(2)!);
      year = _twoDigitYear(int.parse(monthFirst.group(3)!));
      matched = month >= 1 && month <= 12;
    }
  }

  // "d MMM yyyy" — month last
  if (!matched) {
    final monthLast =
        RegExp(r'^(\d{1,2})\s+([A-Za-z]{3,9})\s+(\d{2,4})$').firstMatch(datePart);
    if (monthLast != null) {
      day = int.parse(monthLast.group(1)!);
      month = _months[monthLast.group(2)!.toLowerCase().substring(0, 3)] ?? 0;
      year = _twoDigitYear(int.parse(monthLast.group(3)!));
      matched = month >= 1 && month <= 12;
    }
  }

  if (!matched || year < 2000 || year > 2100) return null;

  int hour = 0, minute = 0, second = 0;
  var hasTime = false;

  if (timePart != null) {
    final tm = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?(?:\s*([AP])M)?$', caseSensitive: false)
        .firstMatch(timePart.trim());
    if (tm != null) {
      hour = int.parse(tm.group(1)!);
      minute = int.parse(tm.group(2)!);
      second = int.tryParse(tm.group(3) ?? '') ?? 0;
      final ampm = tm.group(4)?.toUpperCase();
      if (ampm == 'P' && hour < 12) hour += 12;
      if (ampm == 'A' && hour == 12) hour = 0;
      hasTime = true;
    }
  }

  try {
    final local = hasTime
        ? DateTime(year, month, day, hour, minute, second)
        // Date-only: keep current time-of-day so transactions without an
        // explicit timestamp don't show 12:00 AM (Kotlin LocalTime.now() parity).
        : DateTime(year, month, day, now.hour, now.minute, now.second);
    // Dart's DateTime.millisecondsSinceEpoch on a local DateTime already
    // returns UTC epoch ms — no manual timezone correction needed.
    // (Kotlin: LocalDateTime.atZone(systemDefault).toInstant().toEpochMilli()
    //  does the same single conversion.)
    return local.millisecondsSinceEpoch;
  } catch (_) {
    return null;
  }
}

/// Extracts the transaction date from an SMS body. Tries ALL matches so a
/// "due on" date earlier in the message cannot shadow the real transaction
/// date. Falls back to [fallbackMs]; rejects dates >24h ahead of it.
int extractMpesaDateMs(String body, int fallbackMs) {
  for (final m in kDateRe.allMatches(body)) {
    final parsed =
        parseMpesaDateMatch(m.group(1)!, m.group(2)?.trim());
    if (parsed != null) {
      // Future-date guard (>24h ahead of receive time → use receive time).
      if (parsed > fallbackMs + 86400000) return fallbackMs;
      return parsed;
    }
  }
  return fallbackMs;
}
