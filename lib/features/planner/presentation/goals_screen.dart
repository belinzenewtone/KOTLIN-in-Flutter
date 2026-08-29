/// GoalsScreen — target tracker with progress editing (GoalsScreen.kt port).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database.dart';
import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/banners.dart';
import '../../../core/designsystem/dialogs.dart';
import '../../../core/designsystem/metric_card.dart';
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/designsystem/tokens.dart' show AppSpacing;
import '../../../ui/theme/theme.dart' show LifeOsColors;
import '../../../core/utils/date_utils.dart';
import '../../../navigation/routes.dart';
import '../data/planner_repository.dart';
import 'planner_screens.dart' show plannerRepositoryProvider;

const _kGoalCategories = [
  'SAVINGS',
  'HEALTH',
  'EDUCATION',
  'CAREER',
  'PERSONAL',
  'FINANCIAL',
  'OTHER',
];

// ── Screen ───────────────────────────────────────────────────────────────────

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  PlannerRepository? _repo;

  @override
  void initState() {
    super.initState();
    () async {
      final repo = await ref.read(plannerRepositoryProvider.future);
      if (!mounted) return;
      setState(() => _repo = repo);
    }();
  }

  // ── Add goal dialog ──────────────────────────────────────────────────────

  Future<void> _showAddGoalDialog() async {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    final targetC = TextEditingController();
    final unitC = TextEditingController(text: 'KES');
    DateTime? deadlineDate;
    String selectedCategory = 'SAVINGS';
    String? titleError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => LifeOsAlertDialog(
          scrollable: true,
          title: const Text('Add Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleC,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: const OutlineInputBorder(),
                    errorText: titleError,
                  ),
                  onChanged: (_) {
                    if (titleError != null) setDialogState(() => titleError = null);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descC,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: targetC,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Target',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: unitC,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _kGoalCategories
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(_goalTitleCase(c))))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedCategory = v);
                  },
                ),
                const SizedBox(height: 12),
                // Date picker button — replaces manual dd/MM/yyyy text entry.
                OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: deadlineDate ??
                          now.add(const Duration(days: 30)),
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) {
                      setDialogState(() => deadlineDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(deadlineDate == null
                      ? 'Set deadline (optional)'
                      : AppDateUtils.formatDate(
                          deadlineDate!.millisecondsSinceEpoch, 'MMM dd, yyyy')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            if (deadlineDate != null)
              TextButton(
                onPressed: () => setDialogState(() => deadlineDate = null),
                child: const Text('Clear date'),
              ),
            FilledButton(
              onPressed: () async {
                if (titleC.text.trim().isEmpty) {
                  setDialogState(() => titleError = 'Title is required');
                  return;
                }
                final target = double.tryParse(targetC.text.trim()) ?? 0;
                await _repo!.addGoal(
                  title: titleC.text.trim(),
                  description: descC.text.trim(),
                  targetValue: target,
                  unit: unitC.text.trim().isEmpty ? 'KES' : unitC.text.trim(),
                  category: selectedCategory,
                  deadline: deadlineDate?.millisecondsSinceEpoch,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit goal dialog ─────────────────────────────────────────────────────

  Future<void> _showEditGoalDialog(Goal g) async {
    final titleC = TextEditingController(text: g.title);
    final descC = TextEditingController(text: g.description);
    final targetC = TextEditingController(
        text: g.targetValue > 0 ? g.targetValue.toStringAsFixed(0) : '');
    final unitC = TextEditingController(text: g.unit);
    DateTime? deadlineDate = g.deadline != null
        ? DateTime.fromMillisecondsSinceEpoch(g.deadline!)
        : null;
    String selectedCategory = g.category.isNotEmpty ? g.category : 'SAVINGS';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => LifeOsAlertDialog(
          scrollable: true,
          title: const Text('Edit Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleC,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descC,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: targetC,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Target', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: unitC,
                      decoration: const InputDecoration(
                          labelText: 'Unit', border: OutlineInputBorder()),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                      labelText: 'Category', border: OutlineInputBorder()),
                  items: _kGoalCategories
                      .map((c) => DropdownMenuItem(
                          value: c, child: Text(_goalTitleCase(c))))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedCategory = v);
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: deadlineDate ??
                          now.add(const Duration(days: 30)),
                      firstDate: now.subtract(const Duration(days: 1)),
                      lastDate: now.add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) {
                      setDialogState(() => deadlineDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(deadlineDate == null
                      ? 'Set deadline (optional)'
                      : AppDateUtils.formatDate(
                          deadlineDate!.millisecondsSinceEpoch, 'MMM dd, yyyy')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            if (deadlineDate != null)
              TextButton(
                onPressed: () => setDialogState(() => deadlineDate = null),
                child: const Text('Clear date'),
              ),
            FilledButton(
              onPressed: () async {
                if (titleC.text.trim().isEmpty) return;
                final target = double.tryParse(targetC.text.trim()) ?? 0;
                await _repo!.updateGoal(
                  id: g.id,
                  title: titleC.text.trim(),
                  description: descC.text.trim(),
                  targetValue: target,
                  unit: unitC.text.trim().isEmpty ? 'KES' : unitC.text.trim(),
                  category: selectedCategory,
                  deadline: deadlineDate?.millisecondsSinceEpoch,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    titleC.dispose();
    descC.dispose();
    targetC.dispose();
    unitC.dispose();
  }

  // ── Log progress dialog ──────────────────────────────────────────────────

  Future<void> _showLogProgressDialog(Goal g) async {
    final progressC = TextEditingController(
      text: g.currentValue > 0 ? g.currentValue.toStringAsFixed(2) : '',
    );

    await showDialog<void>(
      context: context,
      builder: (ctx) => LifeOsAlertDialog(
        title: Text('Update Progress — ${g.title}'),
        content: TextField(
          controller: progressC,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'New value (${g.unit})',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final val = double.tryParse(progressC.text.trim());
              if (val == null) return;
              await _repo!.updateGoalProgress(g, val);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_repo == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return PageScaffold(
      title: 'Goals',
      headerEyebrow: 'Personal Growth',
      subtitle: 'What you are working toward',
      onBack: () => context.pop(),
      actions: [
        IconButton(
          onPressed: _showAddGoalDialog,
          icon: Icon(Icons.add_outlined, size: 24, color: scheme.primary),
          tooltip: 'Add goal',
        ),
      ],
      contentPadding:
          const EdgeInsets.only(bottom: AppSpacing.bottomSafeWithFloatingNav),
      child: StreamBuilder<List<Goal>>(
            stream: _repo!.watchGoals(),
            builder: (context, snap) {
              final goals = snap.data ?? [];
              if (goals.isEmpty) {
                return const EmptyState(
                  title: 'No goals yet',
                  description:
                      'Set a savings or milestone target to track progress.',
                );
              }
              return Column(
                children: [
                  for (final g in goals)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _GoalCard(
                        goal: g,
                        onMarkComplete: () async {
                          await _repo!.updateGoalProgress(g, g.targetValue);
                        },
                        onLogProgress: () => _showLogProgressDialog(g),
                        onEdit: () => _showEditGoalDialog(g),
                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => LifeOsAlertDialog(
                              title: const Text('Delete goal?'),
                              content: Text(
                                  'Remove "${g.title}"? This cannot be undone.'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancel')),
                                FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    style: FilledButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .error),
                                    child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await _repo!.deleteGoal(g.id);
                          }
                        },
                      ),
                    ),
                ],
              );
            },
          ),
    );
  }
}

// ── GoalCard ─────────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.onMarkComplete,
    required this.onLogProgress,
    required this.onDelete,
    required this.onEdit,
  });

  final Goal goal;
  final VoidCallback onMarkComplete;
  final VoidCallback onLogProgress;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  static const _categoryIcons = {
    'SAVINGS': Icons.savings_outlined,
    'HEALTH': Icons.favorite_outline,
    'EDUCATION': Icons.school_outlined,
    'CAREER': Icons.work_outline,
    'PERSONAL': Icons.person_outline,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ratio = goal.targetValue <= 0
        ? 0.0
        : (goal.currentValue / goal.targetValue).clamp(0.0, 1.0);
    final isComplete =
        goal.currentValue >= goal.targetValue && goal.targetValue > 0;
    final progressColor =
        isComplete ? LifeOsColors.income : scheme.primary;
    final categoryIcon =
        _categoryIcons[goal.category] ?? Icons.flag_outlined;

    // Determine deadline urgency.
    final now = DateTime.now().millisecondsSinceEpoch;
    final daysLeft = goal.deadline != null
        ? ((goal.deadline! - now) / 86400000).ceil()
        : null;
    final deadlineColor = daysLeft == null
        ? scheme.onSecondaryContainer
        : daysLeft < 0
            ? scheme.error
            : daysLeft <= 7
                ? const Color(0xFFF59E0B)
                : scheme.onSecondaryContainer;

    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header row ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(categoryIcon, size: 20, color: progressColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(goal.title,
                        style: tt.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (goal.description.isNotEmpty)
                      Text(goal.description,
                          style: tt.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              // Edit / delete compact icons
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, size: 16, color: scheme.primary),
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, size: 16, color: scheme.error),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Progress bar ──────────────────────────────────────────
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: ratio),
            duration: const Duration(milliseconds: 600),
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // ── Progress text + chips ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_rawNum(goal.currentValue)} / ${_rawNum(goal.targetValue)} ${goal.unit}  ·  ${(ratio * 100).toStringAsFixed(0)}%',
                  style: tt.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              if (isComplete)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: LifeOsColors.income.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('✓ Done',
                      style: tt.labelSmall?.copyWith(
                          color: LifeOsColors.income,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          // Deadline chip + category chip
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _GoalChip(
                label: _goalTitleCase(goal.category),
                color: scheme.primaryContainer,
                textColor: scheme.onPrimaryContainer,
              ),
              if (goal.deadline != null)
                _GoalChip(
                  label: daysLeft != null && daysLeft < 0
                      ? '⏰ Overdue'
                      : daysLeft == 0
                          ? '⏰ Today'
                          : '⏰ ${AppDateUtils.formatDate(goal.deadline!, 'MMM dd, yyyy')}',
                  color: deadlineColor.withValues(alpha: 0.14),
                  textColor: deadlineColor,
                ),
            ],
          ),
          // ── Actions ───────────────────────────────────────────────
          const SizedBox(height: 4),
          Divider(
              height: 1,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.10)),
          const SizedBox(height: 4),
          Row(
            children: [
              TextButton(
                onPressed: onLogProgress,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 32),
                  foregroundColor: scheme.primary,
                ),
                child: const Text('Log Progress'),
              ),
              const Spacer(),
              if (!isComplete)
                TextButton(
                  onPressed: onMarkComplete,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: const Size(0, 32),
                    foregroundColor: LifeOsColors.income,
                  ),
                  child: const Text('Mark Complete'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.label,
    required this.color,
    required this.textColor,
  });
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: textColor),
      ),
    );
  }
}

String _rawNum(double v) {
  if (v == v.truncateToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(2);
}

String _goalTitleCase(String s) => s
    .split(' ')
    .map((w) => w.isEmpty
        ? ''
        : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
    .join(' ');
