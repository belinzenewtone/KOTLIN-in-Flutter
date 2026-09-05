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
              // Inner segment nests concentrically inside the 12dp track
              // (4dp padding): 12 - 4 = 8dp.
              child: Material(
                color: selectedIndex == i
                    ? scheme.primaryContainer.withValues(alpha: 0.92)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => onSelected(i),
                  borderRadius: BorderRadius.circular(8),
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
///
/// The parent owns the text value (Compose parity), but the controller is a
/// stable field — NOT recreated on every rebuild — so the cursor no longer
/// jumps to the end / drops a character on each keystroke. External changes to
/// [value] (e.g. the clear button, or a programmatic reset) are synced in
/// didUpdateWidget without disturbing the caret while the user is typing.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.value,
    required this.onValueChange,
    this.placeholder = 'Search',
    this.autofocus = false,
  });

  final String value;
  final ValueChanged<String> onValueChange;
  final String placeholder;
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value)
        ..selection = TextSelection.collapsed(offset: widget.value.length);

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only overwrite the field when the parent value diverges from what the
    // controller already holds (an external reset), so typing is untouched.
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
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
    return TextField(
      controller: _controller,
      onChanged: widget.onValueChange,
      autofocus: widget.autofocus,
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
        hintText: widget.placeholder,
        hintStyle:
            Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.search_outlined,
            size: 22, color: scheme.onSurfaceVariant.withValues(alpha: 0.85)),
        suffixIcon: widget.value.isNotEmpty
            ? IconButton(
                onPressed: () => widget.onValueChange(''),
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
    final inactive =
        Theme.of(context).extension<LifeOsColors>()?.onSurfaceVariant.withValues(alpha: 0.20) ??
            kTextOnSurfaceVariant.withValues(alpha: 0.20);
    // Migrate from deprecated M2 activeTrackColor/inactiveTrackColor to M3
    // WidgetStateProperty — fixes the "always purple" track bug on Flutter 3.29+.
    return Switch(
      value: value,
      onChanged: enabled
          ? (v) {
              if (hapticsController.value) HapticFeedback.selectionClick();
              onChanged?.call(v);
            }
          : null,
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) return activeColor;
        return inactive;
      }),
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
      barColor = scheme.error;
    } else if (ratio >= 0.8) {
      barColor = LifeOsColors.warning;
    } else {
      barColor = LifeOsColors.success;
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
