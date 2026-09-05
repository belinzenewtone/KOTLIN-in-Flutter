/// GoalsScreen — target tracker with progress editing (GoalsScreen.kt port).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database.dart';
import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/banners.dart';
import '../../../core/designsystem/metric_card.dart';
import '../../../core/designsystem/page_scaffold.dart';
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
    final deadlineC = TextEditingController();
    String selectedCategory = 'SAVINGS';
    String? titleError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    if (titleError != null) {
                      setDialogState(() => titleError = null);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descC,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
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
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedCategory = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: deadlineC,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: 'Deadline',
                    hintText: 'dd/MM/yyyy — optional',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleC.text.trim().isEmpty) {
                  setDialogState(() => titleError = 'Title is required');
                  return;
                }
                final target = double.tryParse(targetC.text.trim()) ?? 0;
                if (target <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('Enter a target greater than 0')));
                  return;
                }
                final deadline = deadlineC.text.trim().isEmpty
                    ? null
                    : AppDateUtils.parseDdMmYyyy(deadlineC.text.trim());
                await _repo!.addGoal(
                  title: titleC.text.trim(),
                  description: descC.text.trim(),
                  targetValue: target,
                  unit: unitC.text.trim().isEmpty ? 'KES' : unitC.text.trim(),
                  category: selectedCategory,
                  deadline: deadline,
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
    final deadlineC = TextEditingController(
        text: g.deadline != null
            ? AppDateUtils.formatDate(g.deadline!, 'dd/MM/yyyy')
            : '');
    String selectedCategory = g.category.isNotEmpty ? g.category : 'SAVINGS';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        labelText: 'Target',
                        border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: unitC,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder()),
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
                TextField(
                  controller: deadlineC,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: 'Deadline (dd/mm/yyyy, optional)',
                    border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (titleC.text.trim().isEmpty) return;
                final target = double.tryParse(targetC.text.trim()) ?? 0;
                final deadline = deadlineC.text.trim().isEmpty
                    ? null
                    : AppDateUtils.parseDdMmYyyy(deadlineC.text.trim());
                await _repo!.updateGoal(
                  id: g.id,
                  title: titleC.text.trim(),
                  description: descC.text.trim(),
                  targetValue: target,
                  unit: unitC.text.trim().isEmpty ? 'KES' : unitC.text.trim(),
                  category: selectedCategory,
                  deadline: deadline,
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
    deadlineC.dispose();
  }

  // ── Log progress dialog ──────────────────────────────────────────────────

  Future<void> _showLogProgressDialog(Goal g) async {
    final progressC = TextEditingController(
      text: g.currentValue > 0 ? g.currentValue.toStringAsFixed(2) : '',
    );

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    return Stack(
      children: [
        PageScaffold(
          title: 'Goals',
          headerEyebrow: 'Personal Growth',
          subtitle: 'What you are working toward',
          onBack: () => context.pop(),
          // extra bottom padding so cards don't hide behind the FAB
          contentPadding: const EdgeInsets.only(bottom: 228 + 16),
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
                          await _repo!.deleteGoal(g.id);
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        // ExtendedFAB — bottom=228 end=8 (matches Kotlin Modifier.align + padding)
        Positioned(
          bottom: 228,
          right: 8,
          child: FloatingActionButton.extended(
            heroTag: 'goals_fab',
            onPressed: _showAddGoalDialog,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            icon: const Icon(Icons.add),
            label: const Text('Add Goal'),
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ratio = goal.targetValue <= 0
        ? 0.0
        : (goal.currentValue / goal.targetValue).clamp(0.0, 1.0);
    final isComplete = goal.currentValue >= goal.targetValue && goal.targetValue > 0;

    return AppCard(
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row + edit + delete
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(goal.title, style: tt.titleSmall),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, size: 18, color: scheme.primary),
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: scheme.error),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          // Category + deadline chips
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (goal.category.isNotEmpty)
                _GoalChip(
                  label: _goalTitleCase(goal.category),
                  color: scheme.primaryContainer,
                  textColor: scheme.onPrimaryContainer,
                ),
              if (goal.deadline != null)
                _GoalChip(
                  label: '⏰ ${AppDateUtils.formatDate(goal.deadline!, 'MMM dd, yyyy')}',
                  color: isComplete
                      ? const Color(0xFF34D399).withValues(alpha: 0.18)
                      : scheme.secondaryContainer,
                  textColor: isComplete
                      ? const Color(0xFF16A34A)
                      : scheme.onSecondaryContainer,
                ),
            ],
          ),
          // Description
          if (goal.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              goal.description,
              style: tt.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 10),
          // Progress bar — height 6, rounded corners 6
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? const Color(0xFF34D399) : scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Progress label — raw values, not currency-formatted
          Text(
            '${_rawNum(goal.currentValue)} / ${_rawNum(goal.targetValue)} ${goal.unit}',
            style: tt.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: onLogProgress,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('Log Progress'),
              ),
              if (!isComplete)
                TextButton(
                  onPressed: onMarkComplete,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: const Size(0, 32),
                    foregroundColor: scheme.primary,
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
        borderRadius: BorderRadius.circular(12),
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
