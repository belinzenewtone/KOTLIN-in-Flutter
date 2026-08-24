/// NotificationService — schedules and fires local notifications via
/// flutter_local_notifications. Covers:
///   • Calendar event / task reminders (zonedSchedule)
///   • Daily digest (repeating daily at configured time)
///   • Budget threshold alerts (immediate show)
///   • Bill due-date reminders (zonedSchedule)
library;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // ── Android channel ──────────────────────────────────────────────────────
  static const _channelId = 'lifeos_reminders';
  static const _channelName = 'LifeOS Reminders';
  static const _channelDesc = 'Event, task, bill, and budget reminders';

  // ── Stable notification ID ranges ────────────────────────────────────────
  // Event reminders  : eventId * 10 + offsetIndex  (IDs ≈ 10 – 990 000)
  // Task reminders   : taskId  * 10 + offsetIndex + 1_000_000
  // Bill reminders   : billId  + 2_000_000
  // Budget alerts    : budgetId + 3_000_000
  // Daily digest     : 9_999_999
  static const _dailyDigestId = 9999999;

  // ── Initialise ───────────────────────────────────────────────────────────

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    // Use the system local timezone; falls back to UTC on emulators.
    try {
      tz.setLocalLocation(tz.getLocation(
          DateTime.now().timeZoneName.isNotEmpty
              ? DateTime.now().timeZoneName
              : 'UTC'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      enableVibration: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  // ── Internal helpers ─────────────────────────────────────────────────────

  static AndroidNotificationDetails get _androidDetails =>
      const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
      );

  static AndroidNotificationDetails get _androidLowDetails =>
      const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

  static Future<bool> _notifEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('notif_enabled') ?? true;
  }

  // ── Event reminders ──────────────────────────────────────────────────────

  /// Schedule OS notifications for each reminder offset of a calendar event.
  ///
  /// [eventId]     — Drift row id
  /// [title]       — event title shown in the notification
  /// [eventMillis] — epoch millis when the event starts (or occurs for all-day)
  /// [offsets]     — minutes-before-event list (e.g. [15, 60, 1440])
  /// [allDay]      — when true, fire at [reminderTimeOfDayMinutes] on the day
  /// [reminderTimeOfDayMinutes] — minutes since midnight for all-day reminders
  static Future<void> scheduleEventReminders({
    required int eventId,
    required String title,
    required int eventMillis,
    required List<int> offsets,
    bool allDay = false,
    int reminderTimeOfDayMinutes = 480, // 08:00
  }) async {
    if (!await _notifEnabled()) return;
    await init();
    // Cancel any previously scheduled reminders for this event.
    await cancelEventReminders(eventId);

    final now = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < offsets.length; i++) {
      final offsetMin = offsets[i];
      final int fireMillis;
      if (allDay) {
        final eventDay = DateTime.fromMillisecondsSinceEpoch(eventMillis);
        final dayStart = DateTime(eventDay.year, eventDay.month, eventDay.day)
            .millisecondsSinceEpoch;
        fireMillis = dayStart -
            offsetMin * 60000 +
            reminderTimeOfDayMinutes * 60000;
      } else {
        fireMillis = eventMillis - offsetMin * 60000;
      }
      if (fireMillis <= now) continue; // past — skip

      final scheduled = tz.TZDateTime.fromMillisecondsSinceEpoch(
          tz.local, fireMillis);
      final body = _offsetLabel(offsetMin, allDay);
      await _plugin.zonedSchedule(
        eventId * 10 + i,
        title,
        body,
        scheduled,
        NotificationDetails(android: _androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  /// Schedule OS notifications for each reminder offset of a task.
  static Future<void> scheduleTaskReminders({
    required int taskId,
    required String title,
    required int? deadlineMillis,
    required List<int> offsets,
  }) async {
    if (!await _notifEnabled()) return;
    await init();
    await cancelTaskReminders(taskId);
    if (deadlineMillis == null || offsets.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < offsets.length; i++) {
      final fireMillis = deadlineMillis - offsets[i] * 60000;
      if (fireMillis <= now) continue;
      final scheduled = tz.TZDateTime.fromMillisecondsSinceEpoch(
          tz.local, fireMillis);
      await _plugin.zonedSchedule(
        taskId * 10 + i + 1000000,
        title,
        _offsetLabel(offsets[i], false),
        scheduled,
        NotificationDetails(android: _androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  // ── Bill reminders ───────────────────────────────────────────────────────

  /// Schedule a bill-due notification 1 day before [dueDateMillis].
  static Future<void> scheduleBillReminder({
    required int billId,
    required String billTitle,
    required int dueDateMillis,
    required double amount,
  }) async {
    if (!await _notifEnabled()) return;
    await init();
    await cancelBillReminder(billId);
    final fireMillis = dueDateMillis - const Duration(days: 1).inMilliseconds;
    if (fireMillis <= DateTime.now().millisecondsSinceEpoch) return;
    final scheduled = tz.TZDateTime.fromMillisecondsSinceEpoch(
        tz.local, fireMillis);
    await _plugin.zonedSchedule(
      billId + 2000000,
      'Bill due tomorrow',
      '$billTitle — KSh ${amount.toInt()}',
      scheduled,
      NotificationDetails(android: _androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ── Budget alerts ────────────────────────────────────────────────────────

  /// Fire an immediate notification when spending crosses a budget threshold.
  static Future<void> maybeSendBudgetAlert({
    required int budgetId,
    required String category,
    required double spent,
    required double limit,
  }) async {
    if (!await _notifEnabled()) return;
    final p = await SharedPreferences.getInstance();
    if (!(p.getBool('budget_alerts') ?? true)) return;
    await init();

    final ratio = limit <= 0 ? 0.0 : spent / limit;
    final high = (p.getDouble('threshold_high') ?? 90) / 100;
    final med = (p.getDouble('threshold_medium') ?? 70) / 100;
    final low = (p.getDouble('threshold_low') ?? 50) / 100;

    String? body;
    if (ratio >= 1.0) {
      body = 'Over budget! Spent KSh ${spent.toInt()} of KSh ${limit.toInt()}';
    } else if (ratio >= high) {
      body = '${(ratio * 100).toInt()}% of budget used — close to limit';
    } else if (ratio >= med) {
      body = '${(ratio * 100).toInt()}% of budget used this month';
    } else if (ratio >= low) {
      body = '${(ratio * 100).toInt()}% of budget used — staying on track';
    }
    if (body == null) return;

    await _plugin.show(
      budgetId + 3000000,
      '$category budget alert',
      body,
      NotificationDetails(android: _androidDetails),
    );
  }

  // ── Daily digest ─────────────────────────────────────────────────────────

  static Future<void> scheduleDailyDigest({
    required int hour,
    required int minute,
  }) async {
    final p = await SharedPreferences.getInstance();
    if (!(p.getBool('notif_enabled') ?? true)) return;
    if (!(p.getBool('daily_digest') ?? false)) {
      await cancelDailyDigest();
      return;
    }
    await init();
    await cancelDailyDigest();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      _dailyDigestId,
      'Good morning! Your day at a glance',
      'Open LifeOS to see your tasks, events, and finances.',
      scheduled,
      NotificationDetails(android: _androidLowDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ── Cancellation ─────────────────────────────────────────────────────────

  static Future<void> cancelEventReminders(int eventId) async {
    for (var i = 0; i < 10; i++) {
      await _plugin.cancel(eventId * 10 + i);
    }
  }

  static Future<void> cancelTaskReminders(int taskId) async {
    for (var i = 0; i < 10; i++) {
      await _plugin.cancel(taskId * 10 + i + 1000000);
    }
  }

  static Future<void> cancelBillReminder(int billId) async {
    await _plugin.cancel(billId + 2000000);
  }

  static Future<void> cancelDailyDigest() async {
    await _plugin.cancel(_dailyDigestId);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _offsetLabel(int minutes, bool allDay) {
    if (minutes == 0) return 'Now';
    if (allDay) {
      final days = minutes ~/ (60 * 24);
      if (days > 0) return 'In $days day${days == 1 ? '' : 's'}';
    }
    if (minutes < 60) return 'In $minutes min';
    if (minutes < 60 * 24) {
      final h = minutes ~/ 60;
      return 'In $h hour${h == 1 ? '' : 's'}';
    }
    final d = minutes ~/ (60 * 24);
    return 'In $d day${d == 1 ? '' : 's'}';
  }
}
