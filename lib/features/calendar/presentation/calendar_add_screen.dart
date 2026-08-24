/// CalendarAddScreen — full multi-page add/edit wizard.
///
/// 1:1 port of androidMain/.../calendar/presentation/CalendarAddScreen.kt.
/// Five tabs (Event / Task / Birthday / Anniversary / Countdown), each with its
/// own form; sub-pages for Repeat, Reminders and Time zone. Supports edit mode
/// for both events and tasks, and an `allowedTabs` restriction per entry point
/// (Tasks screen → TASK only; Events screen → EVENT only; Calendar tab → all).
library;

import 'package:flutter/material.dart';

import '../../../core/designsystem/controls.dart';
import '../../../core/designsystem/tokens.dart';
import '../../../core/utils/date_utils.dart';
import '../data/calendar_repository.dart';

// â”€â”€ Tab types (AddTab.kt) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

enum AddTab {
  task('Task'),
  event('Event'),
  birthday('Birthday'),
  anniversary('Anniversary'),
  countdown('Countdown');

  const AddTab(this.label);
  final String label;
}

enum _AddPage { form, repeat, reminders, timezone }

// â”€â”€ Reminder presets (CalendarAddScreen.kt) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ReminderPreset {
  const _ReminderPreset(this.label, this.minutes);
  final String label;
  final int minutes;
}

const List<_ReminderPreset> _eventReminderPresets = [
  _ReminderPreset('When event starts', 0),
  _ReminderPreset('5 minutes before', 5),
  _ReminderPreset('10 minutes before', 10),
  _ReminderPreset('15 minutes before', 15),
  _ReminderPreset('30 minutes before', 30),
  _ReminderPreset('1 hour before', 60),
  _ReminderPreset('1 day before', 60 * 24),
  _ReminderPreset('2 days before', 60 * 24 * 2),
  _ReminderPreset('1 week before', 60 * 24 * 7),
];

const List<_ReminderPreset> _dayBasedReminderPresets = [
  _ReminderPreset('On that day', 0),
  _ReminderPreset('1 day before the event', 60 * 24),
  _ReminderPreset('2 days before the event', 60 * 24 * 2),
  _ReminderPreset('3 days before the event', 60 * 24 * 3),
  _ReminderPreset('7 days before the event', 60 * 24 * 7),
];

const List<String> _customUnits = ['minute', 'hour', 'day'];

int _customMinutes(int value, String unit) => switch (unit) {
      'hour' => value * 60,
      'day' => value * 60 * 24,
      _ => value,
    };

String _formatOffset(int minutes) {
  if (minutes % (60 * 24) == 0) {
    final d = minutes ~/ (60 * 24);
    return '$d day${d > 1 ? 's' : ''} before';
  }
  if (minutes % 60 == 0) {
    final h = minutes ~/ 60;
    return '$h hour${h > 1 ? 's' : ''} before';
  }
  return '$minutes minute${minutes > 1 ? 's' : ''} before';
}

int _defaultEventDateTime(DateTime selectedDate) =>
    DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 9)
        .millisecondsSinceEpoch;

int _defaultTaskDeadline(DateTime selectedDate) =>
    _defaultEventDateTime(selectedDate);

// â”€â”€ Save payloads â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

typedef SaveTaskFn = void Function(
  String title,
  String desc,
  TaskPriority priority,
  int? deadline,
  List<int> reminderOffsets,
  bool alarmEnabled,
);

typedef SaveEventFn = void Function(
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
);

class CalendarAddScreen extends StatefulWidget {
  const CalendarAddScreen({
    super.key,
    this.editingEvent,
    this.editingTask,
    this.selectedDateMs,
    this.allowedTabs,
    this.defaultTab,
    required this.onDismiss,
    required this.onSaveTask,
    required this.onSaveEvent,
  });

  final CalendarEventData? editingEvent;
  final TaskData? editingTask;
  final int? selectedDateMs;
  final List<AddTab>? allowedTabs;
  final AddTab? defaultTab;
  final VoidCallback onDismiss;
  final SaveTaskFn onSaveTask;
  final SaveEventFn onSaveEvent;

  @override
  State<CalendarAddScreen> createState() => _CalendarAddScreenState();
}

class _CalendarAddScreenState extends State<CalendarAddScreen> {
  late DateTime _selectedDate;
  late AddTab _tab;
  _AddPage _page = _AddPage.form;

  // Event form state.
  late String _eventTitle;
  late String _eventDesc;
  late EventType _eventType;
  late EventImportance _eventImportance;
  late bool _allDay;
  late int _startDateTime;
  int? _endDateTime;
  late RepeatRule _repeatRule;
  late List<int> _reminderOffsets;
  late bool _alarmEnabled;
  late String _guests;
  late String _timeZoneId;
  late bool _eventReminderEnabled;
  late int _eventReminderTimeHour;
  late int _eventReminderTimeMinute;

  // Task form state.
  late String _taskTitle;
  late String _taskDesc;
  late TaskPriority _taskPriority;
  int? _taskDeadline;
  late List<int> _taskReminderOffsets;
  late bool _taskAlarmEnabled;
  late bool _taskReminderEnabled;

  // Birthday / Anniversary state.
  late String _bdayName;
  late int _bdayDate;
  bool _bdayShowYear = false;
  late List<int> _bdayReminderOffsets;
  late bool _bdayAlarm;
  late bool _bdayReminderEnabled;
  late int _bdayReminderTimeHour;
  late int _bdayReminderTimeMinute;

  // Countdown state.
  String _countdownName = '';
  late int _countdownDate;
  late RepeatRule _countdownRepeat;
  bool _countdownRemindDaysBefore = false;
  late int _countdownAlarmHour;
  late int _countdownAlarmMinute;

  @override
  void initState() {
    super.initState();
    final ev = widget.editingEvent;
    final tk = widget.editingTask;
    _selectedDate = widget.selectedDateMs == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(widget.selectedDateMs!);

    _tab = switch (widget) {
      final w when w.editingTask != null => AddTab.task,
      final w when w.editingEvent?.kind == EventKind.birthday => AddTab.birthday,
      final w when w.editingEvent?.kind == EventKind.anniversary => AddTab.anniversary,
      final w when w.editingEvent?.kind == EventKind.countdown => AddTab.countdown,
      _ => widget.defaultTab ?? widget.allowedTabs?.first ?? AddTab.event,
    };

    _eventTitle = ev?.title ?? '';
    _eventDesc = ev?.description ?? '';
    _eventType = ev?.type ?? EventType.personal;
    _eventImportance = ev?.importance ?? EventImportance.neutral;
    _allDay = ev?.allDay ?? false;
    _startDateTime = ev?.date ?? _defaultEventDateTime(_selectedDate);
    _endDateTime = ev?.endDate;
    _repeatRule = ev?.repeatRule ?? RepeatRule.never;
    _reminderOffsets = List.of(ev?.reminderOffsets ?? const []);
    _alarmEnabled = ev?.alarmEnabled ?? false;
    _guests = ev?.guests ?? '';
    _timeZoneId = ev?.timeZoneId.isNotEmpty == true
        ? ev!.timeZoneId
        : DateTime.now().timeZoneName;
    _eventReminderEnabled = (ev?.reminderOffsets.isNotEmpty ?? false);
    _eventReminderTimeHour = ((ev?.reminderTimeOfDayMinutes ?? 480) ~/ 60).clamp(0, 23);
    _eventReminderTimeMinute = (ev?.reminderTimeOfDayMinutes ?? 480) % 60;

    _taskTitle = tk?.title ?? '';
    _taskDesc = tk?.description ?? '';
    _taskPriority = tk?.priority ?? TaskPriority.neutral;
    _taskDeadline = tk?.deadline ?? _defaultTaskDeadline(_selectedDate);
    _taskReminderOffsets = List.of(tk?.reminderOffsets ?? const []);
    _taskAlarmEnabled = tk?.alarmEnabled ?? false;
    _taskReminderEnabled = (tk?.reminderOffsets.isNotEmpty ?? false);

    _bdayName = ev?.title ?? '';
    _bdayDate = ev?.date ?? _defaultEventDateTime(_selectedDate);
    _bdayReminderOffsets = List.of(ev?.reminderOffsets ?? const []);
    _bdayAlarm = ev?.alarmEnabled ?? false;
    _bdayReminderEnabled = (ev?.reminderOffsets.isNotEmpty ?? false);
    _bdayReminderTimeHour = ((ev?.reminderTimeOfDayMinutes ?? 480) ~/ 60).clamp(0, 23);
    _bdayReminderTimeMinute = (ev?.reminderTimeOfDayMinutes ?? 480) % 60;

    _countdownDate = _defaultEventDateTime(_selectedDate);
    _countdownRepeat = RepeatRule.never;
    _countdownAlarmHour = 8;
    _countdownAlarmMinute = 0;
  }

  void _onTabSelected(AddTab tab) {
    setState(() {
      _tab = tab;
      _page = _AddPage.form;
    });
  }

  /// Public setState wrapper so child form widgets (which hold a reference to
  /// this State) can trigger rebuilds.
  void update(VoidCallback fn) => setState(fn);

  void _save() {
    switch (_tab) {
      case AddTab.task:
        if (_taskTitle.trim().isNotEmpty) {
          widget.onSaveTask(_taskTitle, _taskDesc, _taskPriority, _taskDeadline,
              _taskReminderOffsets, _taskAlarmEnabled);
        }
      case AddTab.event:
        if (_eventTitle.trim().isNotEmpty) {
          widget.onSaveEvent(
            _eventTitle,
            _eventDesc,
            _eventType,
            _eventImportance,
            _startDateTime,
            _endDateTime,
            _allDay,
            _repeatRule,
            _reminderOffsets,
            _alarmEnabled,
            _guests,
            _timeZoneId,
            EventKind.event,
            _eventReminderTimeHour * 60 + _eventReminderTimeMinute,
          );
        }
      case AddTab.birthday:
        _saveBirthday(EventKind.birthday);
      case AddTab.anniversary:
        _saveBirthday(EventKind.anniversary);
      case AddTab.countdown:
        if (_countdownName.trim().isNotEmpty) {
          final alarmOffset = _countdownAlarmHour * 60 + _countdownAlarmMinute;
          final offsets = _countdownRemindDaysBefore
              ? [60 * 24 * 3, alarmOffset]
              : [alarmOffset];
          widget.onSaveEvent(
            _countdownName,
            '',
            EventType.personal,
            EventImportance.neutral,
            _countdownDate,
            null,
            true,
            _countdownRepeat,
            offsets,
            false,
            '',
            '',
            EventKind.countdown,
            _eventReminderTimeHour * 60 + _eventReminderTimeMinute,
          );
        }
    }
  }

  void _saveBirthday(EventKind kind) {
    if (_bdayName.trim().isNotEmpty) {
      widget.onSaveEvent(
        _bdayName,
        '',
        EventType.personal,
        EventImportance.neutral,
        _bdayDate,
        null,
        true,
        RepeatRule.yearly,
        _bdayReminderOffsets,
        _bdayAlarm,
        '',
        '',
        kind,
        _bdayReminderTimeHour * 60 + _bdayReminderTimeMinute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.fastOutSlowIn,
          switchOutCurve: Curves.fastOutSlowIn,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0.25, 0),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(opacity: animation, child: SlideTransition(position: slide, child: child));
          },
          child: switch (_page) {
            _AddPage.form => _FormPage(
                key: ValueKey('form-${_tab.name}'),
                tab: _tab,
                allowedTabs: widget.allowedTabs,
                isEdit: widget.editingEvent != null || widget.editingTask != null,
                onTabSelected: _onTabSelected,
                onDismiss: widget.onDismiss,
                onSave: _save,
                state: this,
              ),
            _AddPage.repeat => _RepeatPickerPage(
                key: const ValueKey('repeat'),
                selected: _tab == AddTab.countdown ? _countdownRepeat : _repeatRule,
                onSelect: (rule) => setState(() {
                  if (_tab == AddTab.countdown) {
                    _countdownRepeat = rule;
                  } else {
                    _repeatRule = rule;
                  }
                  _page = _AddPage.form;
                }),
                onBack: () => setState(() => _page = _AddPage.form),
              ),
            _AddPage.reminders => _RemindersPickerPage(
                key: const ValueKey('reminders'),
                isDayBased: _tab == AddTab.birthday ||
                    _tab == AddTab.anniversary ||
                    (_tab == AddTab.event && _allDay),
                presets: _tab == AddTab.birthday || _tab == AddTab.anniversary ||
                        (_tab == AddTab.event && _allDay)
                    ? _dayBasedReminderPresets
                    : _eventReminderPresets,
                selectedOffsets: _offsetsForTab(),
                reminderEnabled: _reminderEnabledForTab(),
                reminderTimeHour: _reminderHourForTab(),
                reminderTimeMinute: _reminderMinuteForTab(),
                onReminderEnabledChange: (v) => setState(() {
                  switch (_tab) {
                    case AddTab.birthday || AddTab.anniversary:
                      _bdayReminderEnabled = v;
                    case AddTab.task:
                      _taskReminderEnabled = v;
                    default:
                      _eventReminderEnabled = v;
                  }
                }),
                onReminderTimeChange: (h, m) => setState(() {
                  if (_tab == AddTab.birthday || _tab == AddTab.anniversary) {
                    _bdayReminderTimeHour = h;
                    _bdayReminderTimeMinute = m;
                  } else {
                    _eventReminderTimeHour = h;
                    _eventReminderTimeMinute = m;
                  }
                }),
                onToggle: (minutes) => setState(() {
                  final list = _offsetsForTab();
                  if (list.contains(minutes)) {
                    list.remove(minutes);
                  } else {
                    list.add(minutes);
                  }
                  _setOffsetsForTab(list);
                }),
                onBack: () => setState(() => _page = _AddPage.form),
              ),
            _AddPage.timezone => _TimezonePickerPage(
                key: const ValueKey('timezone'),
                selected: _timeZoneId,
                onSelect: (tz) => setState(() {
                  _timeZoneId = tz;
                  _page = _AddPage.form;
                }),
                onBack: () => setState(() => _page = _AddPage.form),
              ),
          },
        ),
      ),
    );
  }

  // Reminder helpers — the offsets/enabled/hour/minute resolved per tab.

  List<int> _offsetsForTab() => switch (_tab) {
        AddTab.birthday || AddTab.anniversary => _bdayReminderOffsets,
        AddTab.task => _taskReminderOffsets,
        _ => _reminderOffsets,
      };

  void _setOffsetsForTab(List<int> list) {
    switch (_tab) {
      case AddTab.birthday || AddTab.anniversary:
        _bdayReminderOffsets = list;
      case AddTab.task:
        _taskReminderOffsets = list;
      default:
        _reminderOffsets = list;
    }
  }

  bool _reminderEnabledForTab() => switch (_tab) {
        AddTab.birthday || AddTab.anniversary => _bdayReminderEnabled,
        AddTab.task => _taskReminderEnabled,
        _ => _eventReminderEnabled,
      };

  int _reminderHourForTab() => _tab == AddTab.birthday || _tab == AddTab.anniversary
      ? _bdayReminderTimeHour
      : _eventReminderTimeHour;

  int _reminderMinuteForTab() => _tab == AddTab.birthday || _tab == AddTab.anniversary
      ? _bdayReminderTimeMinute
      : _eventReminderTimeMinute;
}

// â”€â”€ Form page (FormPage.kt) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FormPage extends StatelessWidget {
  const _FormPage({
    super.key,
    required this.tab,
    required this.allowedTabs,
    required this.isEdit,
    required this.onTabSelected,
    required this.onDismiss,
    required this.onSave,
    required this.state,
  });

  final AddTab tab;
  final List<AddTab>? allowedTabs;
  final bool isEdit;
  final ValueChanged<AddTab> onTabSelected;
  final VoidCallback onDismiss;
  final VoidCallback onSave;
  final _CalendarAddScreenState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visibleTabs = allowedTabs ?? AddTab.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: onDismiss,
                icon: Icon(Icons.arrow_back_outlined, color: scheme.onSurface),
                tooltip: 'Close',
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    isEdit ? 'Edit ${tab.label}' : 'New ${tab.label}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: scheme.onSurface),
                  ),
                ),
              ),
              TextButton(
                onPressed: onSave,
                child: Text('Save',
                    style: TextStyle(
                        color: scheme.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        // Type tabs
        if (visibleTabs.length > 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                for (final t in visibleTabs) ...[
                  if (t != visibleTabs.first) const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onTabSelected(t),
                    child: Container(
                      decoration: BoxDecoration(
                        color: t == tab ? scheme.primary : scheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        t.label,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: t == tab
                                  ? scheme.onPrimary
                                  : scheme.onSurfaceVariant,
                              fontWeight: t == tab
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.4)),
        const SizedBox(height: 4),
        // Form content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                switch (tab) {
                  AddTab.task => _TaskFormContent(state: state),
                  AddTab.event => _EventFormContent(state: state),
                  AddTab.birthday || AddTab.anniversary =>
                    _BirthdayFormContent(
                        state: state, isAnniversary: tab == AddTab.anniversary),
                  AddTab.countdown => _CountdownFormContent(state: state),
                },
                // Ensures the last field scrolls clear of the floating nav bar.
                const SizedBox(height: 220),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Task form (TaskFormContent.kt) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _TaskFormContent extends StatelessWidget {
  const _TaskFormContent({required this.state});
  final _CalendarAddScreenState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormTextField(
            value: s._taskTitle,
            onChanged: (v) => s.update(() => s._taskTitle = v),
            label: 'Task title'),
        const SizedBox(height: 12),
        _FormTextField(
            value: s._taskDesc,
            onChanged: (v) => s.update(() => s._taskDesc = v),
            label: 'Description (optional)',
            maxLines: 3),
        const SizedBox(height: 12),
        const _FormSectionLabel('Priority'),
        Row(
          children: [
            for (final p in TaskPriority.values) ...[
              if (p != TaskPriority.values.first) const SizedBox(width: 8),
              Expanded(
                child: _PriorityButton(
                  label: taskPriorityLabel(p),
                  color: _priorityColor(context, p),
                  selected: p == s._taskPriority,
                  onTap: () => s.update(() => s._taskPriority = p),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        const _FormSectionLabel('Deadline'),
        _FormPickerRow(
          icon: Icons.calendar_month_outlined,
          label: 'Date',
          value: AppDateUtils.formatDate(s._taskDeadline ?? 0, 'MMM dd, yyyy'),
          onClick: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.fromMillisecondsSinceEpoch(s._taskDeadline ?? 0),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              final cur = DateTime.fromMillisecondsSinceEpoch(s._taskDeadline ?? 0);
              s.update(() => s._taskDeadline = DateTime(
                      picked.year, picked.month, picked.day,
                      cur.hour, cur.minute).millisecondsSinceEpoch);
            }
          },
        ),
        _FormPickerRow(
          icon: Icons.access_time_outlined,
          label: 'Time',
          value: AppDateUtils.formatTime(s._taskDeadline ?? 0),
          onClick: () async {
            final cur = DateTime.fromMillisecondsSinceEpoch(s._taskDeadline ?? 0);
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: cur.hour, minute: cur.minute),
            );
            if (picked != null) {
              s.update(() => s._taskDeadline = DateTime(
                      cur.year, cur.month, cur.day,
                      picked.hour, picked.minute).millisecondsSinceEpoch);
            }
          },
        ),
        _FormNavRow(
          icon: Icons.notifications_outlined,
          label: 'Reminders',
          value: _remindersValue(s._taskReminderOffsets),
          onClick: () => s.update(() => s._page = _AddPage.reminders),
        ),
        _FormToggleRow(
          icon: Icons.notifications_active_outlined,
          label: 'Alarm reminders',
          checked: s._taskAlarmEnabled,
          onChanged: (v) => s.update(() => s._taskAlarmEnabled = v),
        ),
      ],
    );
  }
}

// â”€â”€ Event form (EventFormContent.kt) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _EventFormContent extends StatelessWidget {
  const _EventFormContent({required this.state});
  final _CalendarAddScreenState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormTextField(
            value: s._eventTitle,
            onChanged: (v) => s.update(() => s._eventTitle = v),
            label: 'Event title'),
        const SizedBox(height: 12),
        _FormToggleRow(
          label: 'All day',
          checked: s._allDay,
          onChanged: (v) => s.update(() => s._allDay = v),
        ),
        const SizedBox(height: 12),
        const _FormSectionLabel('When'),
        _FormCard(
          child: Column(
            children: [
              _FormPickerRow(
                icon: Icons.calendar_month_outlined,
                label: 'From',
                value: s._allDay
                    ? AppDateUtils.formatDate(s._startDateTime, 'EEE, MMM dd')
                    : '${AppDateUtils.formatDate(s._startDateTime, 'EEE, MMM dd')}  ${AppDateUtils.formatTime(s._startDateTime)}',
                onClick: () async {
                  final cur = DateTime.fromMillisecondsSinceEpoch(s._startDateTime);
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: cur,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    s.update(() => s._startDateTime = DateTime(
                            picked.year, picked.month, picked.day,
                            cur.hour, cur.minute).millisecondsSinceEpoch);
                  }
                },
              ),
              if (!s._allDay) ...[
                const _RowDivider(),
                _FormPickerRow(
                  icon: Icons.access_time_outlined,
                  label: 'Start time',
                  value: AppDateUtils.formatTime(s._startDateTime),
                  onClick: () async {
                    final cur = DateTime.fromMillisecondsSinceEpoch(s._startDateTime);
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: cur.hour, minute: cur.minute),
                    );
                    if (picked != null) {
                      s.update(() => s._startDateTime = DateTime(
                              cur.year, cur.month, cur.day,
                              picked.hour, picked.minute).millisecondsSinceEpoch);
                    }
                  },
                ),
              ],
              const _RowDivider(),
              _FormPickerRow(
                icon: Icons.calendar_month_outlined,
                label: 'To',
                value: s._endDateTime == null
                    ? 'Set end date'
                    : s._allDay
                        ? AppDateUtils.formatDate(s._endDateTime!, 'EEE, MMM dd')
                        : '${AppDateUtils.formatDate(s._endDateTime!, 'EEE, MMM dd')}  ${AppDateUtils.formatTime(s._endDateTime!)}',
                onClick: () async {
                  final base = s._endDateTime ?? s._startDateTime;
                  final cur = DateTime.fromMillisecondsSinceEpoch(base);
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: cur,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    final ref = s._endDateTime == null
                        ? DateTime.fromMillisecondsSinceEpoch(s._startDateTime)
                            .copyWith(hour: 23, minute: 59)
                        : DateTime.fromMillisecondsSinceEpoch(s._endDateTime!);
                    s.update(() => s._endDateTime = DateTime(
                            picked.year, picked.month, picked.day,
                            ref.hour, ref.minute).millisecondsSinceEpoch);
                  }
                },
              ),
              if (!s._allDay && s._endDateTime != null) ...[
                const _RowDivider(),
                _FormPickerRow(
                  icon: Icons.access_time_outlined,
                  label: 'End time',
                  value: AppDateUtils.formatTime(s._endDateTime!),
                  onClick: () async {
                    final cur = DateTime.fromMillisecondsSinceEpoch(s._endDateTime!);
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: cur.hour, minute: cur.minute),
                    );
                    if (picked != null) {
                      s.update(() => s._endDateTime = DateTime(
                              cur.year, cur.month, cur.day,
                              picked.hour, picked.minute).millisecondsSinceEpoch);
                    }
                  },
                ),
              ],
              if (s._endDateTime != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: TextButton(
                      onPressed: () => s.update(() => s._endDateTime = null),
                      child: Text('Clear end date',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: const Color(0xFFF87171))),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _FormNavRow(
          icon: Icons.repeat_outlined,
          label: 'Repeat',
          value: repeatRuleLabel(s._repeatRule),
          onClick: () => s.update(() => s._page = _AddPage.repeat),
        ),
        _FormNavRow(
          icon: Icons.notifications_outlined,
          label: 'Reminders',
          value: _remindersValue(s._reminderOffsets),
          onClick: () => s.update(() => s._page = _AddPage.reminders),
        ),
        _FormToggleRow(
          icon: Icons.notifications_active_outlined,
          label: 'Alarm reminders',
          checked: s._alarmEnabled,
          onChanged: (v) => s.update(() => s._alarmEnabled = v),
        ),
        _GuestsSection(guests: s._guests, onGuestsChange: (v) => s.update(() => s._guests = v)),
        if (!s._allDay) ...[
          const SizedBox(height: 12),
          _FormCard(
            child: _FormPickerRow(
              icon: Icons.public_outlined,
              label: 'Time zone',
              value: s._timeZoneId,
              onClick: () => s.update(() => s._page = _AddPage.timezone),
            ),
          ),
        ],
        const SizedBox(height: 12),
        const _FormSectionLabel('Category'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final t in EventType.values) ...[
                if (t != EventType.values.first) const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => s.update(() => s._eventType = t),
                  child: Container(
                    decoration: BoxDecoration(
                      color: t == s._eventType
                          ? scheme.primary
                          : scheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    child: Text(
                      eventTypeLabel(t),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: t == s._eventType
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _FormSectionLabel('Priority'),
        Row(
          children: [
            for (final imp in EventImportance.values) ...[
              if (imp != EventImportance.values.first) const SizedBox(width: 8),
              Expanded(
                child: _PriorityButton(
                  label: importanceLabel(imp),
                  color: _importanceColor(context, imp),
                  selected: imp == s._eventImportance,
                  onTap: () => s.update(() => s._eventImportance = imp),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        _FormTextField(
            value: s._eventDesc,
            onChanged: (v) => s.update(() => s._eventDesc = v),
            label: 'Description (optional)',
            maxLines: 4),
      ],
    );
  }
}

// â”€â”€ Birthday / Anniversary form (BirthdayFormContent.kt) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _BirthdayFormContent extends StatelessWidget {
  const _BirthdayFormContent({required this.state, required this.isAnniversary});
  final _CalendarAddScreenState state;
  final bool isAnniversary;

  @override
  Widget build(BuildContext context) {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormTextField(
            value: s._bdayName,
            onChanged: (v) => s.update(() => s._bdayName = v),
            label: isAnniversary ? 'Anniversary name' : "Person's name"),
        const SizedBox(height: 12),
        _FormSectionLabel(isAnniversary ? 'Date' : 'Birthday'),
        _FormCard(
          child: _FormPickerRow(
            icon: Icons.calendar_month_outlined,
            label: s._bdayShowYear || isAnniversary ? 'Date' : 'Month and day',
            value: AppDateUtils.formatDate(s._bdayDate,
                s._bdayShowYear || isAnniversary ? 'MMMM dd, yyyy' : 'MMMM dd'),
            onClick: () async {
              final cur = DateTime.fromMillisecondsSinceEpoch(s._bdayDate);
              final picked = await showDatePicker(
                context: context,
                initialDate: cur,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                s.update(() => s._bdayDate = DateTime(
                        picked.year, picked.month, picked.day,
                        cur.hour, cur.minute).millisecondsSinceEpoch);
              }
            },
          ),
        ),
        if (!isAnniversary)
          _FormToggleRow(
            label: 'Add year',
            checked: s._bdayShowYear,
            onChanged: (v) => s.update(() => s._bdayShowYear = v),
          ),
        _FormNavRow(
          icon: Icons.notifications_outlined,
          label: 'Reminders',
          value: _remindersValue(s._bdayReminderOffsets),
          onClick: () => s.update(() => s._page = _AddPage.reminders),
        ),
        _FormToggleRow(
          icon: Icons.notifications_active_outlined,
          label: 'Alarm reminders',
          checked: s._bdayAlarm,
          onChanged: (v) => s.update(() => s._bdayAlarm = v),
        ),
      ],
    );
  }
}

// â”€â”€ Countdown form (CountdownFormContent.kt) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CountdownFormContent extends StatelessWidget {
  const _CountdownFormContent({required this.state});
  final _CalendarAddScreenState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormTextField(
            value: s._countdownName,
            onChanged: (v) => s.update(() => s._countdownName = v),
            label: 'Event name'),
        const SizedBox(height: 12),
        const _FormSectionLabel('When'),
        _FormPickerRow(
          icon: Icons.calendar_month_outlined,
          label: 'Date',
          value: AppDateUtils.formatDate(s._countdownDate, 'EEE, MMM dd, yyyy'),
          onClick: () async {
            final cur = DateTime.fromMillisecondsSinceEpoch(s._countdownDate);
            final picked = await showDatePicker(
              context: context,
              initialDate: cur,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              s.update(() => s._countdownDate = DateTime(
                      picked.year, picked.month, picked.day,
                      cur.hour, cur.minute).millisecondsSinceEpoch);
            }
          },
        ),
        _FormNavRow(
          icon: Icons.repeat_outlined,
          label: 'Repeat',
          value: repeatRuleLabel(s._countdownRepeat),
          onClick: () => s.update(() => s._page = _AddPage.repeat),
        ),
        const SizedBox(height: 12),
        const _FormSectionLabel('Remind me at'),
        _FormPickerRow(
          icon: Icons.access_time_outlined,
          label: 'Time',
          value: '${s._countdownAlarmHour.toString().padLeft(2, '0')}:${s._countdownAlarmMinute.toString().padLeft(2, '0')}',
          onClick: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                  hour: s._countdownAlarmHour, minute: s._countdownAlarmMinute),
            );
            if (picked != null) {
              s.update(() {
                s._countdownAlarmHour = picked.hour;
                s._countdownAlarmMinute = picked.minute;
              });
            }
          },
        ),
        _FormToggleRow(
          label: 'Remind 3 days before',
          checked: s._countdownRemindDaysBefore,
          onChanged: (v) => s.update(() => s._countdownRemindDaysBefore = v),
        ),
      ],
    );
  }
}

// â”€â”€ Repeat picker sub-page (RepeatPickerPage.kt) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _RepeatPickerPage extends StatelessWidget {
  const _RepeatPickerPage({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onBack,
  });

  final RepeatRule selected;
  final ValueChanged<RepeatRule> onSelect;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SubPageTopBar(title: 'Repeat', onBack: onBack),
        Expanded(
          child: ListView(
            children: [
              for (final rule in RepeatRule.values)
                _SelectRow(
                  label: repeatRuleLabel(rule),
                  selected: rule == selected,
                  onTap: () => onSelect(rule),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Reminders picker sub-page (RemindersPickerPage.kt) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _RemindersPickerPage extends StatefulWidget {
  const _RemindersPickerPage({
    super.key,
    required this.presets,
    required this.isDayBased,
    required this.selectedOffsets,
    required this.reminderEnabled,
    required this.reminderTimeHour,
    required this.reminderTimeMinute,
    required this.onReminderEnabledChange,
    required this.onReminderTimeChange,
    required this.onToggle,
    required this.onBack,
  });

  final List<_ReminderPreset> presets;
  final bool isDayBased;
  final List<int> selectedOffsets;
  final bool reminderEnabled;
  final int reminderTimeHour;
  final int reminderTimeMinute;
  final ValueChanged<bool> onReminderEnabledChange;
  final void Function(int h, int m) onReminderTimeChange;
  final ValueChanged<int> onToggle;
  final VoidCallback onBack;

  @override
  State<_RemindersPickerPage> createState() => _RemindersPickerPageState();
}

class _RemindersPickerPageState extends State<_RemindersPickerPage> {
  String get _timeLabel =>
      '${widget.reminderTimeHour.toString().padLeft(2, '0')}:${widget.reminderTimeMinute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final presetMinutes = widget.presets.map((p) => p.minutes).toSet();
    final customOffsets = widget.selectedOffsets
        .where((o) => !presetMinutes.contains(o))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SubPageTopBar(title: 'Reminders', onBack: widget.onBack),
        // Master toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reminder',
                  style: Theme.of(context).textTheme.bodyMedium),
              LifeOsSwitch(
                value: widget.reminderEnabled,
                onChanged: widget.onReminderEnabledChange,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.4)),
        Expanded(
          child: ListView(
            children: [
              // Time-of-day row for day-based events.
              if (widget.isDayBased)
                _SelectRow(
                  label: 'Reminder time',
                  trailing: Text(_timeLabel,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.primary)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: widget.reminderTimeHour,
                          minute: widget.reminderTimeMinute),
                    );
                    if (picked != null) {
                      widget.onReminderTimeChange(picked.hour, picked.minute);
                    }
                  },
                ),
              // Preset rows.
              for (final preset in widget.presets)
                _SelectRow(
                  label: widget.isDayBased
                      ? '${preset.label} at $_timeLabel'
                      : preset.label,
                  selected: widget.selectedOffsets.contains(preset.minutes),
                  onTap: () => widget.onToggle(preset.minutes),
                ),
              // Selected custom offsets not matching a preset.
              for (final offset in customOffsets)
                _SelectRow(
                  label: _formatOffset(offset),
                  selected: true,
                  onTap: () => widget.onToggle(offset),
                ),
              // Custom row.
              _SelectRow(
                label: 'Custom',
                labelColor: scheme.primary,
                trailing: Icon(Icons.chevron_right,
                    size: 18, color: scheme.primary),
                onTap: _openCustomDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openCustomDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => _CustomReminderDialog(
        onConfirm: (minutes) {
          widget.onToggle(minutes);
          Navigator.pop(ctx);
        },
        onDismiss: () => Navigator.pop(ctx),
      ),
    );
  }
}

// â”€â”€ Custom reminder dialog (CustomReminderDialog.kt) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CustomReminderDialog extends StatefulWidget {
  const _CustomReminderDialog({required this.onConfirm, required this.onDismiss});
  final ValueChanged<int> onConfirm;
  final VoidCallback onDismiss;

  @override
  State<_CustomReminderDialog> createState() => _CustomReminderDialogState();
}

class _CustomReminderDialogState extends State<_CustomReminderDialog> {
  int _unitIndex = 0;
  int _valueIndex = 0;

  String get _unit => _customUnits[_unitIndex];

  List<String> get _valueItems => switch (_unit) {
        'hour' => [for (var i = 1; i <= 23; i++) '$i'],
        'day' => [for (var i = 1; i <= 30; i++) '$i'],
        _ => [for (var i = 1; i <= 59; i++) '$i'],
      };

  int get _currentValue => int.tryParse(_valueItems[_valueIndex]) ?? 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      title: Text('Custom reminder',
          style: Theme.of(context).textTheme.titleMedium),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: _WheelPicker(
              items: _valueItems,
              selectedIndex: _valueIndex,
              onSelectedIndexChange: (i) => setState(() => _valueIndex = i),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 104,
            child: _WheelPicker(
              items: [
                for (final u in _customUnits)
                  u + (_currentValue > 1 ? 's' : ''),
              ],
              selectedIndex: _unitIndex,
              onSelectedIndexChange: (i) => setState(() {
                _unitIndex = i;
                _valueIndex = 0;
              }),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: widget.onDismiss,
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () => widget.onConfirm(_customMinutes(_currentValue, _unit)),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

// â”€â”€ Wheel picker (WheelPicker.kt) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _WheelPicker extends StatefulWidget {
  const _WheelPicker({
    required this.items,
    required this.selectedIndex,
    required this.onSelectedIndexChange,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelectedIndexChange;

  @override
  State<_WheelPicker> createState() => _WheelPickerState();
}

class _WheelPickerState extends State<_WheelPicker> {
  static const double _itemHeight = 48;
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(
      initialScrollOffset: widget.selectedIndex * _itemHeight,
    );
  }

  @override
  void didUpdateWidget(_WheelPicker old) {
    super.didUpdateWidget(old);
    if (widget.selectedIndex != old.selectedIndex &&
        _controller.hasClients) {
      _controller.animateTo(
        widget.selectedIndex * _itemHeight,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: _itemHeight * 3,
      child: Stack(
        children: [
          NotificationListener<ScrollEndNotification>(
            onNotification: (n) {
              final idx = (_controller.offset / _itemHeight)
                  .round()
                  .clamp(0, widget.items.length - 1);
              if (idx != widget.selectedIndex) {
                widget.onSelectedIndexChange(idx);
              }
              return false;
            },
            child: ListWheelScrollView(
              controller: _controller,
              itemExtent: _itemHeight,
              physics: const FixedExtentScrollPhysics(),
              children: [
                for (var i = 0; i < widget.items.length; i++)
                  Center(
                    child: Text(
                      widget.items[i],
                      textAlign: TextAlign.center,
                      style: i == widget.selectedIndex
                          ? Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.bold)
                          : Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ),
          // Lines above and below the center row.
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 1,
              margin: EdgeInsets.only(top: _itemHeight),
              color: scheme.outlineVariant,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 1,
              margin: EdgeInsets.only(top: _itemHeight * 2),
              color: scheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Guests section (GuestsSection.kt) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GuestsSection extends StatefulWidget {
  const _GuestsSection({required this.guests, required this.onGuestsChange});
  final String guests;
  final ValueChanged<String> onGuestsChange;

  @override
  State<_GuestsSection> createState() => _GuestsSectionState();
}

class _GuestsSectionState extends State<_GuestsSection> {
  late final TextEditingController _input = TextEditingController();

  List<String> get _guestList => widget.guests
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final guests = _guestList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const _FormSectionLabel('Guests'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                onSubmitted: _addGuest,
                decoration: InputDecoration(
                  labelText: 'Add guest (name or email)',
                  isDense: true,
                  prefixIcon: Icon(Icons.people_outlined,
                      size: 20, color: scheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addGuest(_input.text),
              style: IconButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.add, size: 20),
              tooltip: 'Add guest',
            ),
          ],
        ),
        if (guests.isNotEmpty) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final guest in guests) ...[
                  if (guest != guests.first) const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 12, right: 4, top: 6, bottom: 6),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(guest,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: scheme.primary)),
                        InkWell(
                          onTap: () => _removeGuest(guest),
                          borderRadius: BorderRadius.circular(9),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Icon(Icons.close,
                                size: 12, color: scheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _addGuest(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;
    widget.onGuestsChange([..._guestList, trimmed].join(','));
    _input.clear();
  }

  void _removeGuest(String guest) {
    widget.onGuestsChange(_guestList.where((g) => g != guest).join(','));
  }
}

// â”€â”€ Timezone picker sub-page (TimezonePickerPage.kt) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _TimezonePickerPage extends StatefulWidget {
  const _TimezonePickerPage({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onBack,
  });

  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onBack;

  @override
  State<_TimezonePickerPage> createState() => _TimezonePickerPageState();
}

class _TimezonePickerPageState extends State<_TimezonePickerPage> {
  String _query = '';
  late final List<String> _allZones = _knownTimeZones();

  List<String> get _filtered => _query.isEmpty
      ? _allZones
      : _allZones.where((z) => z.toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SubPageTopBar(title: 'Time zone', onBack: widget.onBack),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search time zones',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final tz in _filtered)
                _SelectRow(
                  label: tz,
                  labelColor: tz == widget.selected ? scheme.primary : null,
                  selected: tz == widget.selected,
                  onTap: () => widget.onSelect(tz),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static List<String> _knownTimeZones() {
    // Deterministic IANA-style list (Kotlin TimeZone.getAvailableIDs parity).
    const base = [
      'Africa/Abidjan', 'Africa/Accra', 'Africa/Addis_Ababa', 'Africa/Algiers',
      'Africa/Cairo', 'Africa/Casablanca', 'Africa/Johannesburg', 'Africa/Kampala',
      'Africa/Khartoum', 'Africa/Kigali', 'Africa/Lagos', 'Africa/Nairobi',
      'Africa/Tripoli', 'Africa/Tunis', 'America/Anchorage', 'America/Argentina/Buenos_Aires',
      'America/Bogota', 'America/Caracas', 'America/Chicago', 'America/Denver',
      'America/Halifax', 'America/Lima', 'America/Los_Angeles', 'America/Mexico_City',
      'America/New_York', 'America/Phoenix', 'America/Sao_Paulo', 'America/Toronto',
      'America/Vancouver', 'Asia/Bangkok', 'Asia/Beirut', 'Asia/Dhaka', 'Asia/Dubai',
      'Asia/Hong_Kong', 'Asia/Istanbul', 'Asia/Jakarta', 'Asia/Jerusalem',
      'Asia/Karachi', 'Asia/Kathmandu', 'Asia/Kolkata', 'Asia/Kuala_Lumpur',
      'Asia/Manila', 'Asia/Riyadh', 'Asia/Seoul', 'Asia/Shanghai', 'Asia/Singapore',
      'Asia/Taipei', 'Asia/Tokyo', 'Australia/Adelaide', 'Australia/Brisbane',
      'Australia/Melbourne', 'Australia/Perth', 'Australia/Sydney',
      'Europe/Amsterdam', 'Europe/Athens', 'Europe/Berlin', 'Europe/Brussels',
      'Europe/Bucharest', 'Europe/Dublin', 'Europe/Helsinki', 'Europe/Lisbon',
      'Europe/London', 'Europe/Madrid', 'Europe/Moscow', 'Europe/Oslo',
      'Europe/Paris', 'Europe/Prague', 'Europe/Rome', 'Europe/Stockholm',
      'Europe/Vienna', 'Europe/Warsaw', 'Europe/Zurich', 'Pacific/Auckland',
      'Pacific/Honolulu', 'Pacific/Port_Moresby',
    ];
    return base;
  }
}

// â”€â”€ Reusable components (CalendarAddScreen.kt bottom half) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SubPageTopBar extends StatelessWidget {
  const _SubPageTopBar({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              IconButton(
                  onPressed: onBack,
                  icon: Icon(Icons.arrow_back_outlined,
                      color: scheme.onSurface)),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ],
    );
  }
}

class _FormSectionLabel extends StatelessWidget {
  const _FormSectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}

class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.value,
    required this.onChanged,
    required this.label,
    this.maxLines = 1,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: scheme.primary),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
      ),
      child: child,
    );
  }
}

class _FormPickerRow extends StatelessWidget {
  const _FormPickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onClick,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  Text(value,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormNavRow extends StatelessWidget {
  const _FormNavRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onClick,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
        child: InkWell(
          onTap: onClick,
          borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    size: 18, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormToggleRow extends StatelessWidget {
  const _FormToggleRow({
    required this.label,
    required this.checked,
    required this.onChanged,
    this.icon,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(label,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              LifeOsSwitch(value: checked, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48),
      child: Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
    );
  }
}

class _SelectRow extends StatelessWidget {
  const _SelectRow({
    required this.label,
    this.selected = false,
    this.onTap,
    this.trailing,
    this.labelColor,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: labelColor ?? scheme.onSurface),
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (selected)
                  Icon(Icons.check, size: 20, color: scheme.primary),
              ],
            ),
          ),
          Divider(
              height: 1,
              indent: 20,
              color: scheme.outlineVariant.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}

class _PriorityButton extends StatelessWidget {
  const _PriorityButton({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : color,
              ),
        ),
      ),
    );
  }
}

Color _priorityColor(BuildContext context, TaskPriority p) => switch (p) {
      TaskPriority.urgent => const Color(0xFFF87171),
      TaskPriority.important => const Color(0xFFF59E0B),
      TaskPriority.neutral => const Color(0xFF57B9FF),
    };

Color _importanceColor(BuildContext context, EventImportance imp) => switch (imp) {
      EventImportance.urgent => const Color(0xFFF87171),
      EventImportance.important => const Color(0xFFF59E0B),
      EventImportance.neutral => const Color(0xFF57B9FF),
    };

String _remindersValue(List<int> offsets) {
  if (offsets.isEmpty) return 'None';
  return '${offsets.length} reminder${offsets.length > 1 ? 's' : ''}';
}
