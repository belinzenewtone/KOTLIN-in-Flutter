/// 1:1 port of core/ui/designsystem/{TaskRow,AssistantActionCard,
/// StyledSnackbarHost}.kt.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart' show hapticsController;
import '../../ui/theme/colors.dart';
import '../../ui/theme/theme.dart';
import 'app_card.dart';
import 'tokens.dart';

Color _priorityDotColor(String priority) {
  switch (priority.toUpperCase()) {
    case 'URGENT':
    case 'HIGH':
      return kErrorColor;
    case 'IMPORTANT':
    case 'MEDIUM':
      return kWarningColor;
    default:
      return kInfoColor;
  }
}

class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.priority = '',
    this.onToggleComplete,
    this.onClick,
    this.trailingContent,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;

  /// Pass the TaskPriority name, or '' to hide the stripe.
  final String priority;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onClick;
  final Widget? trailingContent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onClick,
      child: AppCard(
        contentPadding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Priority stripe — left border, only when active + non-completed
            if (priority.isNotEmpty && !isCompleted) ...[
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: _priorityDotColor(priority),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(2)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            // Completion toggle circle
            InkWell(
              onTap: () {
                if (hapticsController.value) HapticFeedback.mediumImpact();
                onToggleComplete?.call();
              },
              customBorder: const CircleBorder(),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? scheme.primary : (Theme.of(context).extension<LifeOsColors>() ?? LifeOsColors.light).surfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (trailingContent != null) trailingContent!,
          ],
        ),
      ),
    );
  }
}
