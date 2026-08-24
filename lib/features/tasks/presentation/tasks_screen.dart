/// TasksScreen — 1:1 port of features/tasks/presentation/TasksScreen.kt.
///
/// Standalone full-screen tasks list: search, "N open • N completed" subtitle,
/// pending tasks grouped by priority (Urgent / Important / Neutral) with
/// swipe-to-complete/delete, task timer buttons (task_time_entries), a
/// Completed section (tap to undo), a FAB that opens the CalendarAddScreen
/// wizard (TASK tab only), edit dialogs, delete confirmation, snackbar
/// messages and the `tasks?itemId=` deep link (opens the edit dialog).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/designsystem/banners.dart';
import '../../../core/designsystem/controls.dart';
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/designsystem/task_row.dart';
import '../../../core/designsystem/tokens.dart';
import '../../dashboard/data/providers.dart';
import '../../calendar/data/calendar_repository.dart';
import '../../calendar/presentation/calendar_add_screen.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key, this.initialTaskId});

  /// Non-null when navigated from a search result — opens that task's edit
  /// dialog immediately (TasksScreen.kt deep-link parity).
  final int? initialTaskId;

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  CalendarRepository? _repo;
  String _query = '';
  TaskData? _editingTask;
  TaskData? _deleteTarget;
  bool _showAddScreen = false;
  final _snackbarKey = GlobalKey<ScaffoldMessengerState>();
  String? _successMessage;
  Timer? _successTimer;

  // Timer state.
  final Set<int> _runningTaskIds = {};
  int _activeTimerTaskId = -1;
  DateTime? _activeTimerStartedAt;
  Timer? _ticker;
  int _elapsedSeconds = 0;
  final Map<int, int> _totalLogged = {};

  @override
  void initState() {
    super.initState();
    () async {
      final db = await ref.read(lifeOsDatabaseProvider.future);
      final userId = await ref.read(userIdProvider.future);
      if (!mounted) return;
      setState(() => _repo = CalendarRepository(db, userId));
      await _handleDeepLink();
    }();
  }

  @override
  void dispose() {
    _successTimer?.cancel();
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _handleDeepLink() async {
    final id = widget.initialTaskId;
    if (id == null) return;
    final repo = _repo;
    if (repo == null) return;
    final task = await repo.taskById(id);
    if (task == null || !mounted) return;
    setState(() {
      _editingTask = task;
      _showAddScreen = true;
    });
  }

  void _showMessage(String message) {
    _successTimer?.cancel();
    setState(() => _successMessage = message);
    _successTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _successMessage = null);
    });
  }

  // ── Timer actions ─────────────────────────────────────────────────────────

  Future<void> _startTimer(int taskId) async {
    final repo = _repo;
    if (repo == null) return;
    await repo.startTimer(taskId);
    if (!mounted) return;
    setState(() {
      _activeTimerTaskId = taskId;
      _runningTaskIds.add(taskId);
      _activeTimerStartedAt = DateTime.now();
      _elapsedSeconds = 0;
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _activeTimerStartedAt == null) return;
      setState(() {
        _elapsedSeconds =
            DateTime.now().difference(_activeTimerStartedAt!).inSeconds;
      });
    });
  }

  Future<void> _stopTimer(int taskId) async {
    final repo = _repo;
    if (repo == null) return;
    await repo.stopTimer(taskId);
    if (!mounted) return;
    setState(() {
      _runningTaskIds.remove(taskId);
      if (_activeTimerTaskId == taskId) _activeTimerTaskId = -1;
      _activeTimerStartedAt = null;
      _elapsedSeconds = 0;
    });
    _ticker?.cancel();
    // Refresh the logged total for the task.
    final total = await repo.totalLoggedMinutes(taskId);
    if (!mounted) return;
    setState(() => _totalLogged[taskId] = total);
  }

  Future<void> _loadLoggedMinutes(List<TaskData> tasks) async {
    final repo = _repo;
    if (repo == null) return;
    final map = <int, int>{};
    for (final t in tasks) {
      map[t.id] = await repo.totalLoggedMinutes(t.id);
    }
    if (!mounted) return;
    setState(() => _totalLogged.addAll(map));
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

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
    final isEdit = _editingTask != null;
    await repo.saveTask(
      title: title,
      description: desc,
      priority: priority,
      deadline: deadline,
      reminderOffsets: reminderOffsets,
      alarmEnabled: alarmEnabled,
      editingId: _editingTask?.id,
    );
    if (!mounted) return;
    setState(() => _showAddScreen = false);
    _showMessage(isEdit ? 'Task updated' : 'Task created');
  }

  Future<void> _completeTask(TaskData task) async {
    await _repo?.completeTask(task.id, completed: !task.isCompleted);
  }

  Future<void> _deleteTask(TaskData task) async {
    await _repo?.deleteTask(task.id);
    if (!mounted) return;
    setState(() => _deleteTarget = null);
    _showMessage('Task deleted');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ScaffoldMessenger(
      key: _snackbarKey,
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: Stack(
          children: [
            PageScaffold(
              title: 'Tasks',
              onBack: () => context.pop(),
              contentPadding: const EdgeInsets.only(
                  bottom: AppSpacing.bottomSafeWithFloatingNav + 72),
              topBanner: _successMessage == null
                  ? null
                  : TopBanner(
                      message: _successMessage!,
                      tone: TopBannerTone.success,
                      onDismiss: () => setState(() => _successMessage = null),
                    ),
              child: _repo == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<List<TaskData>>(
                      stream: _repo!.watchTasks(),
                      builder: (context, snap) {
                        final tasks = snap.data ?? [];
                        unawaited(_loadLoggedMinutes(tasks));
                        return _buildBody(context, tasks);
                      },
                    ),
            ),
            // FAB (TasksScreen.kt parity — bottom-end, above floating bar).
            Positioned(
              right: AppSpacing.screenHorizontal,
              bottom: AppSpacing.bottomSafeWithFloatingNav + 8,
              child: FloatingActionButton(
                onPressed: () => setState(() {
                  _editingTask = null;
                  _showAddScreen = true;
                }),
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onSurface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.add),
              ),
            ),
            // Add/edit wizard (TASK tab only).
            if (_showAddScreen)
              Positioned.fill(
                child: CalendarAddScreen(
                  editingTask: _editingTask,
                  selectedDateMs: DateTime.now().millisecondsSinceEpoch,
                  allowedTabs: const [AddTab.task],
                  onDismiss: () => setState(() => _showAddScreen = false),
                  onSaveTask: _saveTask,
                  onSaveEvent: (a, b, c, d, e, f, g, h, i, j, k, l, m, n) {},
                ),
              ),
            // Delete confirmation dialog (TasksScreen.kt parity).
            if (_deleteTarget != null)
              Positioned.fill(
                child: _DeleteTaskDialog(
                  task: _deleteTarget!,
                  onCancel: () => setState(() => _deleteTarget = null),
                  onDelete: () => _deleteTask(_deleteTarget!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<TaskData> tasks) {
    final scheme = Theme.of(context).colorScheme;
    final query = _query.trim();
    final filtered = query.isEmpty
        ? tasks
        : tasks
            .where((t) =>
                t.title.toLowerCase().contains(query.toLowerCase()) ||
                t.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
    final pending = filtered.where((t) => !t.isCompleted).toList();
    final completed = filtered.where((t) => t.isCompleted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${pending.length} open • ${completed.length} completed',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),
        SearchField(
          value: _query,
          onValueChange: (v) => setState(() => _query = v),
          placeholder: 'Search tasks',
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ListView(
            children: [
              if (pending.isEmpty)
                const EmptyState(
                    title: 'No open tasks',
                    description: 'Create a task to start your daily focus list.')
              else ...[
                // Group by priority: URGENT, IMPORTANT, NEUTRAL.
                for (final p in [
                  TaskPriority.urgent,
                  TaskPriority.important,
                  TaskPriority.neutral,
                ])
                  _prioritySection(context, p, pending),
              ],
              if (completed.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Completed',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                for (final t in completed.take(20))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TaskRow(
                      title: t.title,
                      subtitle: t.subtitle(),
                      isCompleted: true,
                      onToggleComplete: () => _completeTask(t),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _prioritySection(
      BuildContext context, TaskPriority priority, List<TaskData> pending) {
    final scheme = Theme.of(context).colorScheme;
    final group = pending.where((t) => t.priority == priority).toList();
    if (group.isEmpty) return const SizedBox.shrink();

    final (label, color) = switch (priority) {
      TaskPriority.urgent => ('Urgent', scheme.error),
      TaskPriority.important => ('Important', const Color(0xFFF59E0B)),
      TaskPriority.neutral => ('Neutral', scheme.onSurfaceVariant),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 4),
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: color)),
        ),
        for (final t in group)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SwipeableTaskRow(
              task: t,
              isTimerRunning: _runningTaskIds.contains(t.id),
              elapsedSeconds:
                  _activeTimerTaskId == t.id ? _elapsedSeconds : 0,
              totalLoggedMinutes: _totalLogged[t.id] ?? 0,
              onToggleComplete: () => _completeTask(t),
              onEdit: () => setState(() {
                _editingTask = t;
                _showAddScreen = true;
              }),
              onDelete: () => setState(() => _deleteTarget = t),
              onStartTimer: () => _startTimer(t.id),
              onStopTimer: () => _stopTimer(t.id),
            ),
          ),
      ],
    );
  }

  // ── Delete confirmation dialog ────────────────────────────────────────────
}

class _DeleteTaskDialog extends StatelessWidget {
  const _DeleteTaskDialog({
    required this.task,
    required this.onCancel,
    required this.onDelete,
  });

  final TaskData task;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      title: const Text('Delete task?'),
      content: Text('Remove "${task.title}"? This cannot be undone.'),
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

// ── Swipeable task row (PrioritySection.kt) ─────────────────────────────────

class _SwipeableTaskRow extends StatelessWidget {
  const _SwipeableTaskRow({
    required this.task,
    required this.isTimerRunning,
    required this.elapsedSeconds,
    required this.totalLoggedMinutes,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    required this.onStartTimer,
    required this.onStopTimer,
  });

  final TaskData task;
  final bool isTimerRunning;
  final int elapsedSeconds;
  final int totalLoggedMinutes;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStartTimer;
  final VoidCallback onStopTimer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey('task-${task.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child:
            Icon(Icons.check_circle_outline, color: scheme.onSurface),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child:
            Icon(Icons.delete_outline, color: scheme.onSurface),
      ),
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.4,
        DismissDirection.endToStart: 0.4,
      },
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          if (!task.isCompleted) onToggleComplete();
          return false;
        } else {
          onDelete();
          return false;
        }
      },
      child: TaskRow(
        title: task.title,
        subtitle: task.subtitle(),
        isCompleted: false,
        priority: taskPriorityName(task.priority),
        onToggleComplete: onToggleComplete,
        onClick: onEdit,
        trailingContent: _TaskTimerButton(
          isRunning: isTimerRunning,
          elapsedSeconds: elapsedSeconds,
          totalLoggedMinutes: totalLoggedMinutes,
          onStart: onStartTimer,
          onStop: onStopTimer,
        ),
      ),
    );
  }
}

// ── Task timer button (TaskTimerButton.kt) ──────────────────────────────────

class _TaskTimerButton extends StatelessWidget {
  const _TaskTimerButton({
    required this.isRunning,
    required this.elapsedSeconds,
    required this.totalLoggedMinutes,
    required this.onStart,
    required this.onStop,
  });

  final bool isRunning;
  final int elapsedSeconds;
  final int totalLoggedMinutes;
  final VoidCallback onStart;
  final VoidCallback onStop;

  String get _elapsedLabel {
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds % 3600) ~/ 60;
    final s = elapsedSeconds % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '$m:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final tint = isRunning
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (totalLoggedMinutes > 0 || isRunning)
          Text(
            isRunning ? _elapsedLabel : '${totalLoggedMinutes}m logged',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: tint),
          ),
        IconButton(
          onPressed: isRunning ? onStop : onStart,
          icon: Icon(
            isRunning ? Icons.stop_outlined : Icons.timer_outlined,
            color: tint,
            size: 20,
          ),
          tooltip: isRunning ? 'Stop timer' : 'Start timer',
        ),
      ],
    );
  }
}
