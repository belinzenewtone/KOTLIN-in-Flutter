/// 1:1 port of core/ui/designsystem/AppDesignTokens.kt + ui/theme/Spacing.kt.
library;

import 'package:flutter/material.dart';

import '../../ui/theme/theme.dart';

/// AppSpacing — verbatim from Spacing.kt.
abstract final class AppSpacing {
  static const double screenHorizontal = 8;
  static const double screenTop = 12;
  static const double section = 20;
  static const double bottomSafe = 108;
  static const double bottomSafeWithFab = 144;
  static const double bottomSafeWithFloatingNav = 220;
  static const double fabBottomOffset = 104;

  // Granular tokens for component consistency
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

enum AppSemanticTone { info, success, warning, error }

@immutable
class AppSemanticColors {
  const AppSemanticColors({required this.container, required this.onContainer, required this.icon});
  final Color container;
  final Color onContainer;
  final Color icon;
}

@immutable
class AppColorRoles {
  const AppColorRoles({
    required this.primary,
    required this.primaryContainer,
    required this.surface,
    required this.surfaceContainerLow,
    required this.surfaceContainerLowest,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outlineVariant,
    required this.success,
    required this.warning,
    required this.error,
    required this.income,
    required this.expense,
    required this.violet,
  });

  final Color primary;
  final Color primaryContainer;
  final Color surface;
  final Color surfaceContainerLow;
  final Color surfaceContainerLowest;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outlineVariant;
  final Color success;
  final Color warning;
  final Color error;
  /// Semantic green for income / credit transactions.
  final Color income;
  /// Semantic rose for expense / debit transactions.
  final Color expense;
  /// Violet accent for goals, aurora, secondary highlights.
  final Color violet;

  static AppSemanticTone toneOf(String s) {
    switch (s.toUpperCase()) {
      case 'SUCCESS':
        return AppSemanticTone.success;
      case 'WARNING':
        return AppSemanticTone.warning;
      case 'ERROR':
        return AppSemanticTone.error;
      default:
        return AppSemanticTone.info;
    }
  }
}

@immutable
class AppTypographyScale {
  const AppTypographyScale({
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.label,
    required this.mono,
  });
  final double display;
  final double headline;
  final double title;
  final double body;
  final double label;
  final double mono;
}

@immutable
class AppSpacingScale {
  const AppSpacingScale({required this.xs, required this.sm, required this.md, required this.lg, required this.xl});
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
}

@immutable
class AppRadiusScale {
  const AppRadiusScale({required this.sm, required this.pill});
  final double sm;
  final double pill;
}

@immutable
class AppElevationSpec {
  const AppElevationSpec({required this.card, required this.floating});
  final double card;
  final double floating;
}

@immutable
class AppMotionSpec {
  const AppMotionSpec({required this.fastMs, required this.standardMs, required this.slowMs});
  final int fastMs;
  final int standardMs;
  final int slowMs;
}

/// AppDesignTokens — verbatim scale values from AppDesignTokens.kt.
abstract final class AppDesignTokens {
  /// Resolved color roles from the animated theme extension.
  static AppColorRoles colors(BuildContext context) {
    final c = Theme.of(context).extension<LifeOsColors>() ?? LifeOsColors.light;
    return AppColorRoles(
      primary: c.primary,
      primaryContainer: c.primaryContainer,
      surface: c.surface,
      surfaceContainerLow: c.surfaceContainerLow,
      surfaceContainerLowest: c.surfaceContainerLowest,
      onSurface: c.onSurface,
      onSurfaceVariant: c.onSurfaceVariant,
      outlineVariant: c.outlineVariant,
      success: LifeOsColors.success,
      warning: LifeOsColors.warning,
      error: c.error,
      income: LifeOsColors.income,
      expense: LifeOsColors.expense,
      violet: LifeOsColors.violet,
    );
  }

  static const typography = AppTypographyScale(display: 48, headline: 28, title: 18, body: 15, label: 12, mono: 14);

  static const spacing = AppSpacingScale(xs: 4, sm: 8, md: 12, lg: 16, xl: 24);

  /// sm = 12dp card radius (upgraded from 6dp); pill = 28dp for tab/badge pills.
  static const radius = AppRadiusScale(sm: 12, pill: 28);

  static const double floatingNavBarHeight = 58;
  static const double floatingNavBarBottomOffset = 4;
  static const double assistantInputHairlineGap = 8;

  static const elevation = AppElevationSpec(card: 2, floating: 8);

  static const motion = AppMotionSpec(fastMs: 100, standardMs: 180, slowMs: 260);

  static AppSemanticColors semanticColors(BuildContext context, AppSemanticTone tone) {
    final scheme = Theme.of(context).colorScheme;
    final roles = colors(context);
    return switch (tone) {
      AppSemanticTone.info => AppSemanticColors(
          container: scheme.primaryContainer.withValues(alpha: 0.56),
          onContainer: scheme.onSurface,
          icon: scheme.primary,
        ),
      AppSemanticTone.success => AppSemanticColors(
          container: scheme.secondaryContainer.withValues(alpha: 0.50),
          onContainer: scheme.onSurface,
          icon: roles.success,
        ),
      AppSemanticTone.warning => AppSemanticColors(
          container: scheme.tertiaryContainer.withValues(alpha: 0.58),
          onContainer: scheme.onSurface,
          icon: roles.warning,
        ),
      AppSemanticTone.error => AppSemanticColors(
          container: scheme.errorContainer.withValues(alpha: 0.62),
          onContainer: scheme.onSurface,
          icon: scheme.error,
        ),
    };
  }

  // MetricCardDefaults
  static const double metricCardWidth = 160;
  static const double metricCardCornerRadius = 20;
  static const EdgeInsets metricCardContentPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  // HeroSurfaceDefaults
  static const EdgeInsets heroSurfacePadding =
      EdgeInsets.only(left: 20, right: 20, top: 32);

  // ListItemDefaults
  static const double listItemHeight = 56;
  static const EdgeInsets listItemContentPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const double listItemLeadingSpacing = 16;
  static const double listItemTrailingSpacing = 12;

  // BottomNavDefaults
  static const double pillHorizontalPadding = 12;
  static const double pillVerticalPadding = 6;
  static const double iconSize = 24;
  static const double labelSize = 11;
}
