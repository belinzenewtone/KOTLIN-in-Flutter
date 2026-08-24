/// EventsScreen — 1:1 port of features/calendar/presentation/EventsScreen.kt.
///
/// Upcoming events list with CalendarEventChip + CalendarEventCard pairs,
/// search, an ExtendedFAB "Add event", the full add/edit wizard (EVENT tab),
/// delete confirmation, error/success banners and yearly-repeat-aware next
/// occurrence sorting.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/banners.dart';
import '../../../core/designsystem/controls.dart';
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/designsystem/tokens.dart';
import '../../../core/utils/date_utils.dart';
import '../../dashboard/data/providers.dart';
import '../data/calendar_repository.dart';
import 'calendar_add_screen.dart';
import 'calendar_screen.dart' show eventTypeColor, importanceColor;

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  CalendarRepository? _repo;
  String _query = '';
  CalendarEventData? _editingEvent;
  CalendarEventData? _deleteTarget;
  bool _showAddScreen = false;
  String? _error;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    () async {
      final db = await ref.read(lifeOsDatabaseProvider.future);
      final userId = await ref.read(userIdProvider.future);
      if (!mounted) return;
      setState(() => _repo = CalendarRepository(db, userId));
    }();
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
    final isEdit = _editingEvent != null;
    await repo.saveEvent(
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
    if (!mounted) return;
    setState(() {
      _showAddScreen = false;
      _successMessage = isEdit ? 'Event updated' : 'Event created';
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _successMessage = null);
    });
  }

  Future<void> _deleteEvent(CalendarEventData ev) async {
    await _repo?.deleteEvent(ev.id);
    if (!mounted) return;
    setState(() => _deleteTarget = null);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          PageScaffold(
            title: 'Events',
            subtitle: 'Upcoming',
            onBack: () => context.pop(),
            contentPadding: const EdgeInsets.only(
                bottom: AppSpacing.bottomSafeWithFloatingNav + 72),
            topBanner: _error != null
                ? TopBanner(message: _error!, tone: TopBannerTone.error)
                : _successMessage != null
                    ? TopBanner(
                        message: _successMessage!,
                        tone: TopBannerTone.success,
                        onDismiss: () => setState(() => _successMessage = null),
                      )
                    : null,
            actions: [
              IconButton(
                onPressed: _repo == null
                    ? null
                    : () => setState(() {
                          _editingEvent = null;
                          _showAddScreen = true;
                        }),
                icon: Icon(Icons.add_outlined, size: 24, color: scheme.primary),
                tooltip: 'Add event',
              ),
            ],
            child: _repo == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<CalendarEventData>>(
                    stream: _repo!.watchEvents(),
                    builder: (context, snap) {
                      final events = snap.data ?? [];
                      final nowMs = DateTime.now().millisecondsSinceEpoch;
                      final upcoming = events
                          .where((e) => e.isUpcomingNow)
                          .toList()
                        ..sort((a, b) =>
                            a.nextOccurrenceMs(nowMs).compareTo(b.nextOccurrenceMs(nowMs)));
                      final filtered = _query.isEmpty
                          ? upcoming
                          : upcoming
                              .where((e) =>
                                  e.title.toLowerCase().contains(_query.toLowerCase()) ||
                                  e.description
                                      .toLowerCase()
                                      .contains(_query.toLowerCase()) ||
                                  eventKindLabel(e.kind)
                                      .toLowerCase()
                                      .contains(_query.toLowerCase()) ||
                                  eventTypeLabel(e.type)
                                      .toLowerCase()
                                      .contains(_query.toLowerCase()))
                              .toList();
                      return _buildBody(context, filtered);
                    },
                  ),
          ),
          // ExtendedFAB "Add event" (EventsScreen.kt parity).
          Positioned(
            right: AppSpacing.screenHorizontal,
            bottom: AppSpacing.bottomSafeWithFloatingNav + 8,
            child: FloatingActionButton.extended(
              onPressed: _repo == null
                  ? null
                  : () => setState(() {
                        _editingEvent = null;
                        _showAddScreen = true;
                      }),
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              icon: const Icon(Icons.add),
              label: const Text('Add event'),
            ),
          ),
          // Add/edit wizard (EVENT tab only).
          if (_showAddScreen)
            Positioned.fill(
              child: CalendarAddScreen(
                editingEvent: _editingEvent,
                selectedDateMs: DateTime.now().millisecondsSinceEpoch,
                allowedTabs: const [AddTab.event],
                onDismiss: () => setState(() => _showAddScreen = false),
                onSaveTask: (a, b, c, d, e, f) {},
                onSaveEvent: _saveEvent,
              ),
            ),
          // Delete confirmation dialog.
          if (_deleteTarget != null)
            Positioned.fill(
              child: _DeleteEventDialog(
                event: _deleteTarget!,
                onCancel: () => setState(() => _deleteTarget = null),
                onDelete: () => _deleteEvent(_deleteTarget!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<CalendarEventData> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchField(
          value: _query,
          onValueChange: (v) => setState(() => _query = v),
          placeholder: 'Search events...',
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: events.isEmpty
              ? const EmptyState(
                  icon: Icons.event_outlined,
                  title: 'No upcoming events',
                  description: 'Tap + to schedule your next event.')
              : ListView(
                  children: [
                    for (final e in events)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // CalendarEventChip + CalendarEventCard pair.
                            Align(
                              alignment: Alignment.centerLeft,
                              child: CalendarEventChip(
                                title: e.title,
                                timeLabel: e.allDay
                                    ? AppDateUtils.formatDate(
                                        e.date, 'EEE, MMM dd')
                                    : AppDateUtils.formatDate(
                                        e.date, 'EEE, MMM dd - h:mm a'),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _SwipeableEventCard(
                              event: e,
                              onComplete: () => _repo!.markEventCompleted(e.id),
                              onEdit: () => setState(() {
                                _editingEvent = e;
                                _showAddScreen = true;
                              }),
                              onDelete: () => setState(() => _deleteTarget = e),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
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
        child:
            Icon(Icons.check_circle_outline, size: 22, color: scheme.onSurface),
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
          return false;
        } else {
          onDelete();
          return false;
        }
      },
      child: AppCard(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
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

class _DeleteEventDialog extends StatelessWidget {
  const _DeleteEventDialog({
    required this.event,
    required this.onCancel,
    required this.onDelete,
  });

  final CalendarEventData event;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      title: const Text('Delete event?'),
      content: Text('Remove "${event.title}"? This cannot be undone.'),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        FilledButton(
          onPressed: onDelete,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
