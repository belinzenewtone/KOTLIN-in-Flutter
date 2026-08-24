/// Calendar feature repository — Drift watch/CRUD for events + tasks
/// (ports CalendarViewModel + TasksViewModel data layer).
library;

import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../../../core/utils/date_utils.dart' show AppDateUtils;

/// Event kind — mirrors EventKind.kt.
enum EventKind { event, birthday, anniversary, countdown }

EventKind eventKindFrom(String s) => switch (s.toUpperCase()) {
      'BIRTHDAY' => EventKind.birthday,
      'ANNIVERSARY' => EventKind.anniversary,
      'COUNTDOWN' => EventKind.countdown,
      _ => EventKind.event,
    };

String eventKindName(EventKind k) => switch (k) {
      EventKind.event => 'EVENT',
      EventKind.birthday => 'BIRTHDAY',
      EventKind.anniversary => 'ANNIVERSARY',
      EventKind.countdown => 'COUNTDOWN',
    };

String eventKindLabel(EventKind k) => switch (k) {
      EventKind.event => 'Event',
      EventKind.birthday => 'Birthday',
      EventKind.anniversary => 'Anniversary',
      EventKind.countdown => 'Countdown',
    };

/// Repeat rule — mirrors RepeatRule.kt.
enum RepeatRule { never, daily, monFri, weekly, monthly, yearly }

RepeatRule repeatRuleFrom(String s) => switch (s.toUpperCase()) {
      'DAILY' => RepeatRule.daily,
      'MON_FRI' => RepeatRule.monFri,
      'WEEKLY' => RepeatRule.weekly,
      'MONTHLY' => RepeatRule.monthly,
      'YEARLY' => RepeatRule.yearly,
      _ => RepeatRule.never,
    };

String repeatRuleName(RepeatRule r) => switch (r) {
      RepeatRule.never => 'NEVER',
      RepeatRule.daily => 'DAILY',
      RepeatRule.monFri => 'MON_FRI',
      RepeatRule.weekly => 'WEEKLY',
      RepeatRule.monthly => 'MONTHLY',
      RepeatRule.yearly => 'YEARLY',
    };

String repeatRuleLabel(RepeatRule r) => switch (r) {
      RepeatRule.never => 'Never',
      RepeatRule.daily => 'Daily',
      RepeatRule.monFri => 'Mon – Fri',
      RepeatRule.weekly => 'Weekly',
      RepeatRule.monthly => 'Monthly',
      RepeatRule.yearly => 'Yearly',
    };

/// Event type — mirrors EventType.kt.
enum EventType { work, personal, health, finance, other }

EventType eventTypeFrom(String s) => switch (s.toUpperCase()) {
      'WORK' => EventType.work,
      'HEALTH' => EventType.health,
      'FINANCE' => EventType.finance,
      'OTHER' => EventType.other,
      _ => EventType.personal,
    };

String eventTypeName(EventType t) => switch (t) {
      EventType.work => 'WORK',
      EventType.personal => 'PERSONAL',
      EventType.health => 'HEALTH',
      EventType.finance => 'FINANCE',
      EventType.other => 'OTHER',
    };

String eventTypeLabel(EventType t) => switch (t) {
      EventType.work => 'Work',
      EventType.personal => 'Personal',
      EventType.health => 'Health',
      EventType.finance => 'Finance',
      EventType.other => 'Other',
    };

/// Event importance — mirrors EventImportance.kt.
enum EventImportance { neutral, important, urgent }

EventImportance importanceFrom(String s) => switch (s.toUpperCase()) {
      'IMPORTANT' => EventImportance.important,
      'URGENT' => EventImportance.urgent,
      _ => EventImportance.neutral,
    };

String importanceName(EventImportance i) => switch (i) {
      EventImportance.neutral => 'NEUTRAL',
      EventImportance.important => 'IMPORTANT',
      EventImportance.urgent => 'URGENT',
    };

String importanceLabel(EventImportance i) => switch (i) {
      EventImportance.neutral => 'Neutral',
      EventImportance.important => 'Important',
      EventImportance.urgent => 'Urgent',
    };

/// Task priority — mirrors Task.kt TaskPriority (URGENT / IMPORTANT / NEUTRAL).
enum TaskPriority { urgent, important, neutral }

TaskPriority taskPriorityFrom(String s) => switch (s.toUpperCase()) {
      'URGENT' => TaskPriority.urgent,
      'IMPORTANT' => TaskPriority.important,
      _ => TaskPriority.neutral,
    };

String taskPriorityName(TaskPriority p) => switch (p) {
      TaskPriority.urgent => 'URGENT',
      TaskPriority.important => 'IMPORTANT',
      TaskPriority.neutral => 'NEUTRAL',
    };

String taskPriorityLabel(TaskPriority p) => switch (p) {
      TaskPriority.urgent => 'Urgent',
      TaskPriority.important => 'Important',
      TaskPriority.neutral => 'Neutral',
    };

List<int> parseOffsets(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  return raw
      .split(',')
      .map((e) => int.tryParse(e.trim()))
      .whereType<int>()
      .toList();
}

String encodeOffsets(List<int> offsets) => offsets.join(',');

class CalendarEventData {
  const CalendarEventData({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.endDate,
    required this.type,
    required this.importance,
    required this.status,
    required this.hasReminder,
    required this.kind,
    required this.allDay,
    required this.repeatRule,
    required this.reminderOffsets,
    required this.alarmEnabled,
    required this.guests,
    required this.timeZoneId,
    required this.reminderTimeOfDayMinutes,
  });
  final int id;
  final String title;
  final String description;
  final int date;
  final int? endDate;
  final EventType type;
  final EventImportance importance;
  final String status;
  final bool hasReminder;
  final EventKind kind;
  final bool allDay;
  final RepeatRule repeatRule;
  final List<int> reminderOffsets;
  final bool alarmEnabled;
  final String guests;
  final String timeZoneId;
  final int reminderTimeOfDayMinutes;

  /// Next upcoming timestamp, advancing yearly repeats past [nowMs]
  /// (port of EventsScreen.nextOccurrenceMs).
  int nextOccurrenceMs(int nowMs) {
    if (repeatRule != RepeatRule.yearly || date >= nowMs) return date;
    final original = DateTime.fromMillisecondsSinceEpoch(date);
    final now = DateTime.fromMillisecondsSinceEpoch(nowMs);
    var next = DateTime(now.year, original.month, original.day, original.hour,
        original.minute, original.second);
    if (next.millisecondsSinceEpoch < nowMs) {
      next = DateTime(next.year + 1, original.month, original.day,
          original.hour, original.minute, original.second);
    }
    return next.millisecondsSinceEpoch;
  }

  bool get isUpcomingNow {
    final now = DateTime.now().millisecondsSinceEpoch;
    return date >= now || (endDate != null && endDate! >= now);
  }
}

class TaskData {
  const TaskData({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.deadline,
    required this.createdAt,
    required this.reminderOffsets,
    required this.alarmEnabled,
  });
  final int id;
  final String title;
  final String description;
  final TaskPriority priority;
  final String status;
  final int? deadline;
  final int createdAt;
  final List<int> reminderOffsets;
  final bool alarmEnabled;

  bool get isCompleted => status == 'COMPLETED';

  /// Mirrors Task.subtitle(): description > deadline > "No deadline".
  String subtitle() {
    if (description.isNotEmpty) return description;
    if (deadline != null) {
      return 'Due ${AppDateUtils.formatDate(deadline!, 'MMM dd, h:mm a')}';
    }
    return 'No deadline';
  }
}

class TaskTimeEntryData {
  const TaskTimeEntryData({
    required this.id,
    required this.taskId,
    required this.startedAt,
    this.endedAt,
    required this.durationMinutes,
  });
  final int id;
  final int taskId;
  final int startedAt;
  final int? endedAt;
  final int durationMinutes;
}

class CalendarRepository {
  CalendarRepository(this._db, this._userId);

  final LifeOsDatabase _db;
  String _userId;

  set userId(String v) => _userId = v;

  // ── Events ────────────────────────────────────────────────────────────────

  Stream<List<CalendarEventData>> watchEvents() {
    final stmt = _db.select(_db.events)
      ..where((e) => e.userId.equals(_userId) & e.deletedAt.isNull())
      ..orderBy([(e) => OrderingTerm.asc(e.date)]);
    return stmt.watch().map((rows) => rows.map(_eventFromRow).toList());
  }

  CalendarEventData _eventFromRow(Event row) => CalendarEventData(
        id: row.id,
        title: row.title,
        description: row.description,
        date: row.date,
        endDate: row.endDate,
        type: eventTypeFrom(row.type),
        importance: importanceFrom(row.importance),
        status: row.status,
        hasReminder: row.hasReminder,
        kind: eventKindFrom(row.kind),
        allDay: row.allDay,
        repeatRule: repeatRuleFrom(row.repeatRule),
        reminderOffsets: parseOffsets(row.reminderOffsets),
        alarmEnabled: row.alarmEnabled,
        guests: row.guests,
        timeZoneId: row.timeZoneId,
        reminderTimeOfDayMinutes: row.reminderTimeOfDayMinutes,
      );

  Future<int> saveEvent({
    required String title,
    required String description,
    required EventType type,
    required EventImportance importance,
    required int date,
    int? endDate,
    required bool allDay,
    required RepeatRule repeatRule,
    required List<int> reminderOffsets,
    required bool alarmEnabled,
    required String guests,
    required String timeZoneId,
    required EventKind kind,
    required int reminderTimeOfDayMinutes,
    int? editingId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = editingId ?? await _nextId('events');
    final companion = EventsCompanion(
      id: Value(id),
      userId: Value(_userId),
      title: Value(title),
      description: Value(description),
      date: Value(date),
      endDate: Value(endDate),
      type: Value(eventTypeName(type)),
      importance: Value(importanceName(importance)),
      status: const Value('PENDING'),
      hasReminder: Value(reminderOffsets.isNotEmpty),
      reminderMinutesBefore: Value(reminderOffsets.isEmpty ? 15 : reminderOffsets.first),
      kind: Value(eventKindName(kind)),
      allDay: Value(allDay),
      repeatRule: Value(repeatRuleName(repeatRule)),
      reminderOffsets: Value(encodeOffsets(reminderOffsets)),
      alarmEnabled: Value(alarmEnabled),
      guests: Value(guests),
      timeZoneId: Value(timeZoneId),
      reminderTimeOfDayMinutes: Value(reminderTimeOfDayMinutes),
      updatedAt: Value(now),
      syncState: Value('LOCAL'),
      recordSource: Value('MANUAL_ENTRY'),
      revision: const Value(0),
      createdAt: Value(editingId == null ? now : now),
    );
    if (editingId == null) {
      await _db.into(_db.events).insert(companion);
    } else {
      await (_db.update(_db.events)..where((e) => e.id.equals(editingId) & e.userId.equals(_userId)))
          .write(companion);
    }
    return id;
  }

  Future<void> markEventCompleted(int id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.events)
          ..where((e) => e.userId.equals(_userId) & e.id.equals(id)))
        .write(EventsCompanion(status: const Value('COMPLETED'), updatedAt: Value(now)));
  }

  Future<void> deleteEvent(int id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.events)
          ..where((e) => e.userId.equals(_userId) & e.id.equals(id)))
        .write(EventsCompanion(deletedAt: Value(now), revision: const Value(1)));
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────

  Stream<List<TaskData>> watchTasks() {
    final stmt = _db.select(_db.tasks)
      ..where((t) => t.userId.equals(_userId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.deadline)]);
    return stmt.watch().map((rows) => rows.map(_taskFromRow).toList());
  }

  TaskData _taskFromRow(Task row) => TaskData(
        id: row.id,
        title: row.title,
        description: row.description,
        priority: taskPriorityFrom(row.priority),
        status: row.status,
        deadline: row.deadline,
        createdAt: row.createdAt,
        reminderOffsets: parseOffsets(row.reminderOffsets),
        alarmEnabled: row.alarmEnabled,
      );

  Future<int> saveTask({
    required String title,
    required String description,
    required TaskPriority priority,
    int? deadline,
    required List<int> reminderOffsets,
    required bool alarmEnabled,
    int? editingId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = editingId ?? await _nextId('tasks');
    final companion = TasksCompanion(
      id: Value(id),
      userId: Value(_userId),
      title: Value(title),
      description: Value(description),
      priority: Value(taskPriorityName(priority)),
      status: const Value('PENDING'),
      deadline: Value(deadline),
      reminderOffsets: Value(encodeOffsets(reminderOffsets)),
      alarmEnabled: Value(alarmEnabled),
      updatedAt: Value(now),
      syncState: Value('LOCAL'),
      recordSource: Value('MANUAL_ENTRY'),
      revision: const Value(0),
      createdAt: Value(now),
    );
    if (editingId == null) {
      await _db.into(_db.tasks).insert(companion);
    } else {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(editingId) & t.userId.equals(_userId)))
          .write(companion);
    }
    return id;
  }

  Future<void> completeTask(int id, {required bool completed}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.tasks)
          ..where((t) => t.userId.equals(_userId) & t.id.equals(id)))
        .write(TasksCompanion(
      status: Value(completed ? 'COMPLETED' : 'PENDING'),
      completedAt: Value(completed ? now : null),
      updatedAt: Value(now),
    ));
  }

  Future<void> deleteTask(int id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.tasks)
          ..where((t) => t.userId.equals(_userId) & t.id.equals(id)))
        .write(TasksCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  }

  Future<TaskData?> taskById(int id) async {
    final row = await (_db.select(_db.tasks)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return row == null ? null : _taskFromRow(row);
  }

  Future<CalendarEventData?> eventById(int id) async {
    final row = await (_db.select(_db.events)
          ..where((e) => e.id.equals(id) & e.userId.equals(_userId) & e.deletedAt.isNull()))
        .getSingleOrNull();
    return row == null ? null : _eventFromRow(row);
  }

  // ── Task time entries (timers) ────────────────────────────────────────────

  Stream<List<TaskTimeEntryData>> watchTimeEntries(int taskId) {
    final stmt = _db.select(_db.taskTimeEntries)
      ..where((t) => t.userId.equals(_userId) & t.taskId.equals(taskId))
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    return stmt.watch().map((rows) => rows
        .map((r) => TaskTimeEntryData(
              id: r.id,
              taskId: r.taskId,
              startedAt: r.startedAt,
              endedAt: r.endedAt,
              durationMinutes: r.durationMinutes,
            ))
        .toList());
  }

  Future<int> totalLoggedMinutes(int taskId) async {
    final row = await _db.customSelect(
      'SELECT COALESCE(SUM(duration_minutes),0) AS total FROM task_time_entries '
      'WHERE user_id=? AND task_id=?',
      variables: [Variable.withString(_userId), Variable.withInt(taskId)],
      readsFrom: {_db.taskTimeEntries},
    ).getSingle();
    return (row.data['total'] as num?)?.toInt() ?? 0;
  }

  /// Starts a timer for [taskId]; returns the new entry id.
  Future<int> startTimer(int taskId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await _nextId('task_time_entries');
    await _db.into(_db.taskTimeEntries).insert(TaskTimeEntriesCompanion.insert(
          id: id,
          userId: _userId,
          taskId: taskId,
          startedAt: now,
          durationMinutes: 0,
          createdAt: now,
        ));
    return id;
  }

  /// Stops the active timer for [taskId], persisting elapsed minutes.
  Future<void> stopTimer(int taskId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final open = await (_db.select(_db.taskTimeEntries)
          ..where((t) =>
              t.userId.equals(_userId) &
              t.taskId.equals(taskId) &
              t.endedAt.isNull()))
        .get();
    for (final row in open) {
      final elapsedMin = ((now - row.startedAt) / 60000).floor().clamp(0, 24 * 60);
      await (_db.update(_db.taskTimeEntries)
            ..where((t) => t.userId.equals(_userId) & t.id.equals(row.id)))
          .write(TaskTimeEntriesCompanion(
        endedAt: Value(now),
        durationMinutes: Value(elapsedMin),
      ));
    }
  }

  /// Returns true when [taskId] has an open (running) timer.
  Future<bool> hasActiveTimer(int taskId) async {
    final row = await _db.customSelect(
      'SELECT COUNT(*) AS n FROM task_time_entries '
      'WHERE user_id=? AND task_id=? AND ended_at IS NULL',
      variables: [Variable.withString(_userId), Variable.withInt(taskId)],
      readsFrom: {_db.taskTimeEntries},
    ).getSingle();
    return ((row.data['n'] as num?)?.toInt() ?? 0) > 0;
  }

  Future<int> _nextId(String table) async {
    final row = await _db.customSelect(
      'SELECT COALESCE(MAX(id),0)+1 AS n FROM $table WHERE user_id = ?',
      variables: [Variable.withString(_userId)],
    ).getSingle();
    return row.data['n'] as int;
  }
}
