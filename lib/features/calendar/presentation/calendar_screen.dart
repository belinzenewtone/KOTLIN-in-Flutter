/// 1:1 port of features/calendar/presentation/CalendarScreen.kt +
/// CalendarMonthComponents.kt + CalendarEventComponents.kt.
///
/// 3-tab pill bar (Calendar / Tasks / Events); Monday-first month grid with
/// kind-coloured dots, Today jump, swipe navigation; grouped day agenda with
/// edit/complete/delete; tasks tab with Pending/Doing/Done counts and search;
/// events tab with count and search. Full add/edit wizard via
/// CalendarAddScreen (5 tabs, repeat/reminders/timezone sub-pages).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/banners.dart';
import '../../../core/designsystem/controls.dart';
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/designsystem/task_row.dart';
import '../../../core/designsystem/tokens.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../ui/theme/colors.dart';
import '../../../ui/theme/theme.dart';
import '../../dashboard/data/providers.dart';
import '../data/calendar_repository.dart';
import 'calendar_add_screen.dart';

enum CalendarTab { calendar, tasks, events }

// calendarRepositoryProvider intentionally removed — it was unused; the screen
// manages CalendarRepository via an inline async in initState.

// ── Kind colours (EventKind.dotColor parity) ────────────────────────────────

Color kindDotColor(EventKind kind) => switch (kind) {
      EventKind.event => const Color(0xFF57B9FF),
      EventKind.birthday => const Color(0xFFEF4444),
      EventKind.anniversary => const Color(0xFFF59E0B),
      EventKind.countdown => const Color(0xFF8B5CF6),
    };

Color eventTypeColor(EventType type) => switch (type) {
      EventType.work => const Color(0xFF57B9FF),
      EventType.health => const Color(0xFF34D399),
      EventType.finance => const Color(0xFFF59E0B),
      EventType.personal => kPrimary,
      EventType.other => const Color(0xFF94A3B8),
    };

Color importanceColor(EventImportance importance) => switch (importance) {
      EventImportance.urgent => const Color(0xFFF87171),
      EventImportance.important => const Color(0xFFF59E0B),
      EventImportance.neutral => const Color(0xFF57B9FF),
    };

// ── Screen ───────────────────────────────────────────────────────────────────

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key, this.initialEventId, this.initialEventDate});

  /// Non-null when navigated from a search result — opens the event's month
  /// and its edit dialog (CalendarScreen.kt deep-link parity).
  final int? initialEventId;
  final int? initialEventDate;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarRepository? _repo;
  CalendarTab _tab = CalendarTab.calendar;
  DateTime _selectedDay = DateTime.now();
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  CalendarEventData? _editingEvent;
  TaskData? _editingTask;
  bool _showAddScreen = false;
  String _dayQuery = '';

  // Cached streams — created once when _repo is ready, never recreated on
  // rebuild. This prevents StreamBuilder from resubscribing on every setState
  // (which causes a flash-to-empty for one frame).
  Stream<List<CalendarEventData>>? _eventsStream;
  Stream<List<TaskData>>? _tasksStream;

  @override
  void initState() {
    super.initState();
    () async {
      final db = await ref.read(lifeOsDatabaseProvider.future);
      final userId = await ref.read(userIdProvider.future);
      if (!mounted) return;
      final repo = CalendarRepository(db, userId);
      setState(() {
        _repo = repo;
        _eventsStream = repo.watchEvents();
        _tasksStream = repo.watchTasks();
      });
      _handleDeepLink();
    }();
  }

  Future<void> _handleDeepLink() async {
    final id = widget.initialEventId;
    final date = widget.initialEventDate;
    if (id == null || date == null) return;
    final repo = _repo;
    if (repo == null) return;
    final ev = await repo.eventById(id);
    if (ev == null || !mounted) return;
    setState(() {
      _tab = CalendarTab.calendar;
      _selectedDay = DateTime.fromMillisecondsSinceEpoch(date);
      _currentMonth = DateTime(_selectedDay.year, _selectedDay.month);
      _editingEvent = ev;
      _showAddScreen = true;
    });
  }

  void _openAdd() {
    setState(() {
      _editingEvent = null;
      _editingTask = null;
      _showAddScreen = true;
    });
  }

  void _openEditEvent(CalendarEventData ev) {
    setState(() {
      _editingEvent = ev;
      _editingTask = null;
      _showAddScreen = true;
    });
  }

  void _openEditTask(TaskData task) {
    setState(() {
      _editingTask = task;
      _editingEvent = null;
      _showAddScreen = true;
    });
  }

  Future<void> _saveEvent(
    String title,
    String desc,
    EventType type,
    EventImportance importance,
    int date,
    int? endDate,
    bool allDay,
    RepeatRule repeatRule,
    List<int> reminderOffsets,
    bool alarmEnabled,
    String guests,
    String timeZoneId,
    EventKind kind,
    int reminderTimeOfDayMinutes,
  ) async {
    final repo = _repo;
    if (repo == null) return;
    final id = await repo.saveEvent(
      title: title,
      description: desc,
      type: type,
      importance: importance,
      date: date,
      endDate: endDate,
      allDay: allDay,
      repeatRule: repeatRule,
      reminderOffsets: reminderOffsets,
      alarmEnabled: alarmEnabled,
      guests: guests,
      timeZoneId: timeZoneId,
      kind: kind,
      reminderTimeOfDayMinutes: reminderTimeOfDayMinutes,
      editingId: _editingEvent?.id,
    );
    // Schedule OS notifications for each reminder offset.
    if (reminderOffsets.isNotEmpty) {
      await NotificationService.scheduleEventReminders(
        eventId: id,
        title: title,
        eventMillis: date,
        offsets: reminderOffsets,
        allDay: allDay,
        reminderTimeOfDayMinutes: reminderTimeOfDayMinutes,
      );
    } else {
      await NotificationService.cancelEventReminders(id);
    }
    if (mounted) setState(() => _showAddScreen = false);
  }

  Future<void> _saveTask(
    String title,
    String desc,
    TaskPriority priority,
    int? deadline,
    List<int> reminderOffsets,
    bool alarmEnabled,
  ) async {
    final repo = _repo;
    if (repo == null) return;
    final id = await repo.saveTask(
      title: title,
      description: desc,
      priority: priority,
      deadline: deadline,
      reminderOffsets: reminderOffsets,
      alarmEnabled: alarmEnabled,
      editingId: _editingTask?.id,
    );
    // Schedule OS task reminders when a deadline is set.
    if (reminderOffsets.isNotEmpty && deadline != null) {
      await NotificationService.scheduleTaskReminders(
        taskId: id,
        title: title,
        deadlineMillis: deadline,
        offsets: reminderOffsets,
      );
    } else {
      await NotificationService.cancelTaskReminders(id);
    }
    if (mounted) setState(() => _showAddScreen = false);
  }

  Future<void> _confirmDeleteEvent(CalendarEventData ev) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: const Text('Delete event?'),
        content: Text('Remove "${ev.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && mounted) await _repo!.deleteEvent(ev.id);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final scaffold = PageScaffold(
      title: 'Calendar',
      subtitle: AppDateUtils.formatDate(AppDateUtils.nowMillis, 'MMMM yyyy'),
      scrollable: false,
      contentPadding:
          const EdgeInsets.only(bottom: AppSpacing.bottomSafeWithFloatingNav),
      actions: [
        IconButton(
          onPressed: _repo == null ? null : () => _openAdd(),
          icon: Icon(Icons.add_outlined, size: 24, color: scheme.primary),
          tooltip: 'Add',
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tabBar(context),
          const SizedBox(height: AppSpacing.md),
          if (_repo == null)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: switch (_tab) {
                CalendarTab.calendar => _calendarTab(),
                CalendarTab.tasks => _tasksTab(),
                CalendarTab.events => _eventsTab(),
              },
            ),
        ],
      ),
    );

    // Full-page add/edit wizard must cover the entire screen including the
    // PageScaffold header (CalendarAddScreenOverlay parity), so it is placed
    // at the top-level Stack rather than inside the body area.
    if (_showAddScreen) {
      return Stack(
        children: [
          scaffold,
          CalendarAddScreen(
            editingEvent: _editingEvent,
            editingTask: _editingTask,
            selectedDateMs: _selectedDay.millisecondsSinceEpoch,
            defaultTab: switch (_tab) {
              CalendarTab.tasks => AddTab.task,
              CalendarTab.events => AddTab.event,
              _ => null,
            },
            onDismiss: () => setState(() => _showAddScreen = false),
            onSaveTask: _saveTask,
            onSaveEvent: _saveEvent,
          ),
        ],
      );
    }
    return scaffold;
  }

  // ── Pill tab bar (TabBar.kt) ─────────────────────────────────────────────

  Widget _tabBar(BuildContext context) {
    final c = Theme.of(context).extension<LifeOsColors>() ?? LifeOsColors.light;
    final labels = ['Calendar', 'Tasks', 'Events'];
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = CalendarTab.values[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: _tab.index == i
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _tab.index == i
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: _tab.index == i
                          ? Theme.of(context).colorScheme.onPrimary
                          : c.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Calendar tab (CalendarTabContent.kt) ─────────────────────────────────

  Widget _calendarTab() {
    return StreamBuilder<List<CalendarEventData>>(
      stream: _eventsStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final events = snap.data ?? [];
        final selectedEvents =
            events.where((e) => _isSameDay(e.date, _selectedDay)).toList();
        final filtered = _dayQuery.isEmpty
            ? selectedEvents
            : selectedEvents
                .where((e) =>
                    e.title.toLowerCase().contains(_dayQuery.toLowerCase()) ||
                    e.description
                        .toLowerCase()
                        .contains(_dayQuery.toLowerCase()))
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _monthCard(context, events),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppDateUtils.formatDate(
                  _selectedDay.millisecondsSinceEpoch, 'EEEE, MMM dd'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            SearchField(
              value: _dayQuery,
              onValueChange: (v) => setState(() => _dayQuery = v),
              placeholder: 'Search across all categories',
            ),
            const SizedBox(height: AppSpacing.md),
            if (filtered.isEmpty)
              const EmptyState(
                  title: 'Nothing for the day',
                  description:
                      'Tap + to add an event, birthday, countdown and more.')
            else
              _dayView(filtered),
          ],
        );
      },
    );
  }

  bool _isSameDay(int ms, DateTime day) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return d.year == day.year && d.month == day.month && d.day == day.day;
  }

  // ── Month card (CalendarMonthCard.kt) ────────────────────────────────────

  Widget _monthCard(BuildContext context, List<CalendarEventData> events) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isViewingCurrentMonth =
        _currentMonth.year == now.year && _currentMonth.month == now.month;
    final monthLabel = AppDateUtils.formatDate(
        _currentMonth.millisecondsSinceEpoch, 'MMMM yyyy');

    // Distinct kind-colour dots per day (toDayColorMap parity).
    final dayColorMap = <int, List<Color>>{};
    for (final e in events) {
      final d = DateTime.fromMillisecondsSinceEpoch(e.date);
      if (d.year == _currentMonth.year && d.month == _currentMonth.month) {
        final color = kindDotColor(e.kind);
        final list = dayColorMap.putIfAbsent(d.day, () => []);
        if (!list.contains(color)) list.add(color);
      }
    }

    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday - 1;
    final rows = ((firstWeekday + daysInMonth) / 7).ceil();

    return AppCard(
      contentPadding: const EdgeInsets.all(12),
      child: GestureDetector(
        // Swipe left → next month, swipe right → previous month.
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v < -72) {
            setState(() => _currentMonth = DateTime(
                _currentMonth.year, _currentMonth.month + 1, 1));
          } else if (v > 72) {
            setState(() => _currentMonth = DateTime(
                _currentMonth.year, _currentMonth.month - 1, 1));
          }
        },
        child: Column(
          children: [
            // Month header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => setState(() => _currentMonth = DateTime(
                      _currentMonth.year, _currentMonth.month - 1, 1)),
                  icon: const Icon(Icons.chevron_left),
                ),
                Column(
                  children: [
                    Text(monthLabel,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    if (!isViewingCurrentMonth)
                      TextButton(
                        onPressed: () => setState(() {
                          final today = DateTime.now();
                          _currentMonth = DateTime(today.year, today.month);
                          _selectedDay = today;
                        }),
                        child: Text('Today',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: scheme.primary)),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () => setState(() => _currentMonth = DateTime(
                      _currentMonth.year, _currentMonth.month + 1, 1)),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Day-of-week header (Mon–Sun)
            Row(
              children: [
                for (final wd in ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'])
                  Expanded(
                    child: Center(
                      child: Text(wd,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Day grid — square cells, today/selected filled primary
            for (var row = 0; row < rows; row++)
              Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(
                      child: Builder(builder: (_) {
                        final dayIdx = row * 7 + col - firstWeekday + 1;
                        if (dayIdx < 1 || dayIdx > daysInMonth) {
                          return const AspectRatio(aspectRatio: 1, child: SizedBox());
                        }
                        final isSelected = _selectedDay.year == _currentMonth.year &&
                            _selectedDay.month == _currentMonth.month &&
                            _selectedDay.day == dayIdx;
                        final isToday = now.year == _currentMonth.year &&
                            now.month == _currentMonth.month &&
                            now.day == dayIdx;
                        final dotColors = dayColorMap[dayIdx] ?? const [];

                        return GestureDetector(
                          onTap: () => setState(() => _selectedDay = DateTime(
                              _currentMonth.year, _currentMonth.month, dayIdx)),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected || isToday
                                    ? scheme.primary
                                    : Colors.transparent,
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$dayIdx',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isSelected || isToday
                                              ? scheme.onPrimary
                                              : scheme.onSurface,
                                          fontWeight: isToday || isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                  ),
                                  if (dotColors.isNotEmpty)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        for (final c in dotColors.take(3))
                                          Container(
                                            width: 4,
                                            height: 4,
                                            margin:
                                                const EdgeInsets.symmetric(horizontal: 1),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected || isToday
                                                  ? scheme.onPrimary
                                                  : c,
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ── Grouped day view (DayViewContent.kt) ─────────────────────────────────

  Widget _dayView(List<CalendarEventData> events) {
    const kindOrder = [
      EventKind.event,
      EventKind.birthday,
      EventKind.anniversary,
      EventKind.countdown,
    ];
    final grouped = <EventKind, List<CalendarEventData>>{};
    // Sort the filtered-by-day slice (typically 0–10 items) in place-on-copy.
    final sorted = List.of(events)..sort((a, b) => a.date.compareTo(b.date));
    for (final e in sorted) {
      grouped.putIfAbsent(e.kind, () => []).add(e);
    }
    final presentKinds =
        kindOrder.where((k) => grouped.containsKey(k)).toList();

    final children = <Widget>[];
    for (var i = 0; i < presentKinds.length; i++) {
      final kind = presentKinds[i];
      final kindEvents = grouped[kind]!;
      final sectionColor = kindDotColor(kind);
      final sectionLabel = switch (kind) {
        EventKind.event => 'Events',
        EventKind.birthday => 'Birthdays',
        EventKind.anniversary => 'Anniversaries',
        EventKind.countdown => 'Countdowns',
      };
      if (i > 0) children.add(const SizedBox(height: 8));
      if (i > 0) {
        children.add(Divider(
            height: 1,
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.2)));
        children.add(const SizedBox(height: 8));
      }
      children.add(Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(sectionLabel,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: sectionColor)),
      ));
      children.add(Column(
        children: [
          for (final e in kindEvents)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SwipeableEventCard(
                event: e,
                onComplete: () => _repo!.markEventCompleted(e.id),
                onEdit: () => _openEditEvent(e),
                onDelete: () => _confirmDeleteEvent(e),
              ),
            ),
        ],
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  // ── Tasks tab (TasksTabContent.kt) ───────────────────────────────────────

  Widget _tasksTab() {
    return StreamBuilder<List<TaskData>>(
      stream: _tasksStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final tasks = snap.data ?? [];
        final pendingCount = tasks.where((t) => !t.isCompleted).length;
        final doneCount = tasks.where((t) => t.isCompleted).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$pendingCount Pending · 0 Doing · $doneCount Done',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            SearchField(
              value: _dayQuery,
              onValueChange: (v) => setState(() => _dayQuery = v),
              placeholder: 'Search tasks...',
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: tasks.isEmpty
                  ? const EmptyState(
                      icon: Icons.check_circle_outline,
                      title: 'No tasks here',
                      description: 'Use + below to create your first task.')
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskRow(
                          title: tasks[i].title,
                          subtitle: tasks[i].subtitle(),
                          isCompleted: tasks[i].isCompleted,
                          priority: taskPriorityName(tasks[i].priority),
                          onToggleComplete: () => _repo!
                              .completeTask(tasks[i].id, completed: !tasks[i].isCompleted),
                          trailingContent: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _openEditTask(tasks[i]),
                                icon: Icon(Icons.edit_outlined,
                                    size: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 32, minHeight: 32),
                                tooltip: 'Edit task',
                              ),
                              IconButton(
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      title: const Text('Delete task?'),
                                      content: Text(
                                          '"${tasks[i].title}" will be removed.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancel')),
                                        FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .onError,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6)),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await _repo!.deleteTask(tasks[i].id);
                                    await NotificationService
                                        .cancelTaskReminders(tasks[i].id);
                                  }
                                },
                                icon: Icon(Icons.delete_outline,
                                    size: 18,
                                    color:
                                        Theme.of(context).colorScheme.error),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 32, minHeight: 32),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  // ── Events tab (EventsTabContent.kt) ─────────────────────────────────────

  Widget _eventsTab() {
    return StreamBuilder<List<CalendarEventData>>(
      stream: _eventsStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final all = snap.data ?? [];
        final filtered = _dayQuery.isEmpty
            ? all
            : all
                .where((e) =>
                    e.title.toLowerCase().contains(_dayQuery.toLowerCase()) ||
                    e.description
                        .toLowerCase()
                        .contains(_dayQuery.toLowerCase()))
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${filtered.length} event${filtered.length == 1 ? '' : 's'}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            SearchField(
              value: _dayQuery,
              onValueChange: (v) => setState(() => _dayQuery = v),
              placeholder: 'Search events...',
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyState(
                      icon: Icons.calendar_month_outlined,
                      title: 'Events Area',
                      description: 'No events yet. Tap + to create one.')
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _SwipeableEventCard(
                          event: filtered[i],
                          onComplete: () =>
                              _repo!.markEventCompleted(filtered[i].id),
                          onEdit: () => _openEditEvent(filtered[i]),
                          onDelete: () => _confirmDeleteEvent(filtered[i]),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ── Swipeable event card (CalendarEventCard.kt) ─────────────────────────────

class _SwipeableEventCard extends StatelessWidget {
  const _SwipeableEventCard({
    required this.event,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final CalendarEventData event;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final completed = event.status == 'COMPLETED';
    final typeColor = eventTypeColor(event.type);

    return Dismissible(
      key: ValueKey('event-${event.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF34D399).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.check_circle_outline,
            size: 22, color: scheme.onSurface),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF87171).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(6),
        ),
        child:
            Icon(Icons.delete_outline, size: 22, color: scheme.onSurface),
      ),
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.4,
        DismissDirection.endToStart: 0.4,
      },
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          if (!completed) onComplete();
          return false; // snap back; card recomposes with strikethrough
        } else {
          onDelete();
          return false; // let the confirm dialog handle removal
        }
      },
      child: AppCard(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // 3dp type-colour bar (outline when completed)
            Container(
              width: 3,
              height: 40,
              decoration: BoxDecoration(
                color: completed ? scheme.outline : typeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: completed
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                          fontWeight: FontWeight.w600,
                          decoration:
                              completed ? TextDecoration.lineThrough : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // Badges: kind (if not EVENT), type, importance
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (event.kind != EventKind.event)
                        _EventBadge(
                            text: eventKindLabel(event.kind),
                            color: scheme.tertiary),
                      _EventBadge(
                          text: eventTypeLabel(event.type), color: typeColor),
                      _EventBadge(
                          text: importanceLabel(event.importance),
                          color: importanceColor(event.importance)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppDateUtils.formatDate(event.date, 'MMM dd, yyyy h:mm a')}'
                    '${event.endDate != null ? ' → ${AppDateUtils.formatDate(event.endDate!, 'MMM dd, yyyy h:mm a')}' : ''}',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined,
                  size: 18, color: scheme.onSurfaceVariant),
              tooltip: 'Edit event',
            ),
          ],
        ),
      ),
    );
  }
}

class _EventBadge extends StatelessWidget {
  const _EventBadge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: color, fontWeight: FontWeight.w500)),
    );
  }
}
