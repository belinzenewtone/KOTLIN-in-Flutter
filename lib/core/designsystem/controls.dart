/// 1:1 port of core/ui/designsystem/{SegmentedControl,SearchField,LifeOSSwitch,
/// CalendarEventChip,BudgetProgressIndicator}.kt.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart' show hapticsController;
import '../../ui/theme/colors.dart';
import '../../ui/theme/theme.dart';
import 'metric_card.dart';
import 'tokens.dart';

class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Material(
                color: selectedIndex == i
                    ? scheme.primaryContainer.withValues(alpha: 0.92)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
                child: InkWell(
                  onTap: () => onSelected(i),
                  borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Text(
                      items[i],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: selectedIndex == i
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// SearchField — outlined rounded search input with clear button.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.value,
    required this.onValueChange,
    this.placeholder = 'Search',
    this.autofocus = false,
  });

  /// Current text; the parent owns state (Compose parity).
  final String value;
  final ValueChanged<String> onValueChange;
  final String placeholder;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      onChanged: onValueChange,
      autofocus: autofocus,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(color: scheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.48)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.48)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
          borderSide: BorderSide(color: scheme.primary),
        ),
        hintText: placeholder,
        hintStyle:
            Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.search_outlined,
            size: 22, color: scheme.onSurfaceVariant.withValues(alpha: 0.85)),
        suffixIcon: value.isNotEmpty
            ? IconButton(
                onPressed: () => onValueChange(''),
                icon: const Icon(Icons.close_outlined, size: 20))
            : null,
      ),
    );
  }
}

/// LifeOSSwitch — Telegram-style toggle pinned to static brand blue track.
class LifeOsSwitch extends StatelessWidget {
  const LifeOsSwitch({super.key, required this.value, this.onChanged, this.enabled = true});

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // Static Primary keeps the same vivid blue in dark mode.
    const activeColor = kPrimary;
    // 35% instead of 20% — makes the inactive track clearly legible in dark mode
    // while still reading as "off" vs the vivid primary active track.
    final inactive =
        Theme.of(context).extension<LifeOsColors>()?.onSurface.withValues(alpha: 0.30) ??
            kTextOnSurfaceVariant.withValues(alpha: 0.30);
    return Switch(
      value: value,
      onChanged: enabled
          ? (v) {
              if (hapticsController.value) HapticFeedback.selectionClick();
              onChanged?.call(v);
            }
          : null,
      activeTrackColor: activeColor,
      inactiveTrackColor: inactive,
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      thumbColor: const WidgetStatePropertyAll(Colors.white),
    );
  }
}

/// CalendarEventChip — "Title • time" pill.
class CalendarEventChip extends StatelessWidget {
  const CalendarEventChip({super.key, required this.title, required this.timeLabel});

  final String title;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: (Theme.of(context).extension<LifeOsColors>() ?? LifeOsColors.light).surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(title, style: Theme.of(context).textTheme.bodyMedium)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text('•', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          Text(timeLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.primary)),
        ],
      ),
    );
  }
}

/// BudgetProgressIndicator — spent/budget bar with over/near-limit states.
class BudgetProgressIndicator extends StatelessWidget {
  const BudgetProgressIndicator({
    super.key,
    required this.spentAmount,
    required this.budgetAmount,
  });

  final double spentAmount;
  final double budgetAmount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ratio = budgetAmount <= 0 ? 0.0 : (spentAmount / budgetAmount).clamp(0.0, 1.0);

    final Color barColor;
    if (ratio >= 1.0) {
      barColor = LifeOsColors.expense;   // rose — over budget
    } else if (ratio >= 0.8) {
      barColor = LifeOsColors.warning;   // amber — near limit
    } else {
      barColor = LifeOsColors.income;    // green — healthy
    }

    String? statusLabel;
    if (ratio >= 1.0) {
      statusLabel = 'Over by ${formatCurrency(spentAmount - budgetAmount)}';
    } else if (ratio >= 0.8) {
      statusLabel = 'Near limit · ${(ratio * 100).toInt()}%';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${formatCurrency(spentAmount)} of ${formatCurrency(budgetAmount)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: (Theme.of(context).extension<LifeOsColors>() ?? LifeOsColors.light).surfaceVariant,
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
        if (statusLabel != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(statusLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: barColor)),
        ],
      ],
    );
  }
}
