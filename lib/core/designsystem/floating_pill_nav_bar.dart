/// 1:1 port of core/ui/designsystem/FloatingPillNavBar.kt.
library;

import 'package:flutter/material.dart';

import '../../navigation/routes.dart';
import '../../ui/theme/theme.dart';
import 'tokens.dart';

/// Floating pill bottom bar — 58dp, surfaceContainerHigh base, gradient sheen,
/// outline-variant hairline border, animated icon/label colors (120ms).
class LifeOsBottomBar extends StatelessWidget {
  const LifeOsBottomBar({
    super.key,
    required this.currentRoute,
    required this.onTabSelected,
  });

  /// The active route path without query args, e.g. "home".
  final String? currentRoute;
  final ValueChanged<String> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<LifeOsColors>() ?? LifeOsColors.light;
    final scheme = Theme.of(context).colorScheme;
    final navBarShape = BorderRadius.circular(12);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppDesignTokens.floatingNavBarBottomOffset),
          child: Container(
            height: AppDesignTokens.floatingNavBarHeight,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh.withValues(alpha: 0.94),
              borderRadius: navBarShape,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.surfaceContainerHighest.withValues(alpha: 0.96 * 0.94),
                  scheme.surfaceContainerHigh.withValues(alpha: 0.90 * 0.94),
                ],
              ),
              border: GradientBoxBorder(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    c.outlineVariant.withValues(alpha: 0.76),
                    c.outlineVariant.withValues(alpha: 0.38),
                  ],
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: c.onBackground.withValues(alpha: 0.14),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final item in primaryTabs)
                  Expanded(
                    child: _BottomNavItem(
                      label: item.label,
                      selected:
                          currentRoute != null && isPrimaryTabSelected(item, {currentRoute!}),
                      selectedIcon: item.selectedIcon,
                      unselectedIcon: item.unselectedIcon,
                      onTap: () {
                        if (currentRoute == item.route) return;
                        onTabSelected(item.route);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.selected,
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final targetIcon =
        selected ? scheme.primary : scheme.onSurfaceVariant.withValues(alpha: 0.7);
    final targetText = selected ? scheme.primary : scheme.onSurfaceVariant;
    const duration = Duration(milliseconds: 120);

    // Animate icon + text color over 120ms like animateColorAsState.
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: targetIcon),
      duration: duration,
      builder: (context, iconColor, _) => TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: targetText),
        duration: duration,
        builder: (context, textColor, _) => Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(selected ? selectedIcon : unselectedIcon,
                      size: 24, color: iconColor ?? targetIcon),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: textColor ?? targetText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// GradientBoxBorder — Flutter lacks a gradient Border out of the box.
class GradientBoxBorder extends BoxBorder {
  const GradientBoxBorder({required this.gradient, this.width = 1});

  final Gradient gradient;
  final double width;

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  BorderSide get top => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(Canvas canvas, Rect rect,
      {BorderRadius? borderRadius, BoxShape shape = BoxShape.rectangle, TextDirection? textDirection}) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = gradient.createShader(rect);
    final rrect = (borderRadius ?? BorderRadius.circular(12)).toRRect(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  void paintInterior(Canvas canvas, Rect rect, Paint paint, {TextDirection? textDirection}) {}

  ShapeBorder get shape => const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)));

  @override
  GradientBoxBorder scale(double t) =>
      GradientBoxBorder(gradient: gradient, width: width * t);
}
