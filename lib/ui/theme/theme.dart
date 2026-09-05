/// 1:1 port of ui/theme/Theme.kt + ui/theme/AppThemeMode.kt.
///
/// The full Material role set lives in [LifeOsColors] (a ThemeExtension) so every
/// token used by the Compose design system has an exact Dart counterpart,
/// including `background`/`onBackground`/`surfaceContainer*`.
///
/// Mode switches animate over 250 ms — mirrors Compose's animateColorAsState
/// via Flutter's AnimatedTheme, which lerps the full ThemeData (including
/// ColorScheme AND LifeOsColors) so there is no flash between layers.
library;

import 'package:flutter/material.dart';

enum AppThemeMode { system, light, dark }

// ─── Light scheme (RFINAL lifeosPaperThemeLight) ─────────────────────────
// Values transcribed verbatim from Theme.kt LightColorScheme.

// ─── Dark scheme (RFINAL lifeosPaperTheme) ───────────────────────────────
// Values transcribed verbatim from Theme.kt DarkColorScheme.

/// Every color role the app references, resolved per-brightness.
@immutable
class LifeOsColors extends ThemeExtension<LifeOsColors> {
  const LifeOsColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.tertiary,
    required this.tertiaryContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.brightness,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color secondaryContainer;
  final Color tertiary;
  final Color tertiaryContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Brightness brightness;

  // Semantic accents (AppDesignTokens.colors.success / warning).
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);

  static const light = LifeOsColors(
    primary: Color(0xFF0369A1),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFBAE6FD),
    onPrimaryContainer: Color(0xFF082F49),
    secondary: Color(0xFF64748B),
    secondaryContainer: Color(0xFFE2E8F0),
    tertiary: Color(0xFF0F766E),
    tertiaryContainer: Color(0xFFCCFBF1),
    background: Color(0xFFE8EDF3),
    onBackground: Color(0xFF0F172A),
    surface: Color(0xFFF8FAFC),
    onSurface: Color(0xFF0F172A),
    surfaceVariant: Color(0xFFEEF2F7),
    onSurfaceVariant: Color(0xFF475569),
    outline: Color(0xFFCBD5E1),
    outlineVariant: Color(0xFFE2E8F0),
    error: Color(0xFFDC2626),
    onError: Colors.white,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF7F1D1D),
    inverseSurface: Color(0xFF1E293B),
    inverseOnSurface: Color(0xFFF8FAFC),
    inversePrimary: Color(0xFF7DD3FC),
    surfaceContainerLowest: Color(0xFFF8FAFC),
    surfaceContainerLow: Color(0xFFF1F5F9),
    surfaceContainer: Color(0xFFE2E8F0),
    surfaceContainerHigh: Color(0xFFCBD5E1),
    surfaceContainerHighest: Color(0xFF94A3B8),
    brightness: Brightness.light,
  );

  static const dark = LifeOsColors(
    primary: Color(0xFF57B9FF),
    onPrimary: Color(0xFF0A0A0B),
    primaryContainer: Color(0xFF0F2A40),
    onPrimaryContainer: Color(0xFFBFE3FF),
    secondary: Color(0xFFA1A1AA),
    secondaryContainer: Color(0xFF26272B),
    tertiary: Color(0xFF5EEAD4),
    tertiaryContainer: Color(0xFF0F3A33),
    background: Color(0xFF0A0A0B),
    onBackground: Color(0xFFF4F4F5),
    surface: Color(0xFF0A0A0B),
    onSurface: Color(0xFFF4F4F5),
    surfaceVariant: Color(0xFF161618),
    onSurfaceVariant: Color(0xFFA1A1AA),
    outline: Color(0xFF2E2E33),
    outlineVariant: Color(0xFF222226),
    error: Color(0xFFF87171),
    onError: Color(0xFF0A0A0B),
    errorContainer: Color(0xFF3A1214),
    onErrorContainer: Color(0xFFFECACA),
    inverseSurface: Color(0xFFF4F4F5),
    inverseOnSurface: Color(0xFF0A0A0B),
    inversePrimary: Color(0xFF57B9FF),
    surfaceContainerLowest: Color(0xFF0A0A0B),
    surfaceContainerLow: Color(0xFF111113),
    surfaceContainer: Color(0xFF161618),
    surfaceContainerHigh: Color(0xFF1A1A1D),
    surfaceContainerHighest: Color(0xFF1D1D20),
    brightness: Brightness.dark,
  );

  @override
  LifeOsColors copyWith({Brightness? brightness}) => this;

  @override
  LifeOsColors lerp(LifeOsColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return LifeOsColors(
      primary: c(primary, other.primary),
      onPrimary: c(onPrimary, other.onPrimary),
      primaryContainer: c(primaryContainer, other.primaryContainer),
      onPrimaryContainer: c(onPrimaryContainer, other.onPrimaryContainer),
      secondary: c(secondary, other.secondary),
      secondaryContainer: c(secondaryContainer, other.secondaryContainer),
      tertiary: c(tertiary, other.tertiary),
      tertiaryContainer: c(tertiaryContainer, other.tertiaryContainer),
      background: c(background, other.background),
      onBackground: c(onBackground, other.onBackground),
      surface: c(surface, other.surface),
      onSurface: c(onSurface, other.onSurface),
      surfaceVariant: c(surfaceVariant, other.surfaceVariant),
      onSurfaceVariant: c(onSurfaceVariant, other.onSurfaceVariant),
      outline: c(outline, other.outline),
      outlineVariant: c(outlineVariant, other.outlineVariant),
      error: c(error, other.error),
      onError: c(onError, other.onError),
      errorContainer: c(errorContainer, other.errorContainer),
      onErrorContainer: c(onErrorContainer, other.onErrorContainer),
      inverseSurface: c(inverseSurface, other.inverseSurface),
      inverseOnSurface: c(inverseOnSurface, other.inverseOnSurface),
      inversePrimary: c(inversePrimary, other.inversePrimary),
      surfaceContainerLowest: c(surfaceContainerLowest, other.surfaceContainerLowest),
      surfaceContainerLow: c(surfaceContainerLow, other.surfaceContainerLow),
      surfaceContainer: c(surfaceContainer, other.surfaceContainer),
      surfaceContainerHigh: c(surfaceContainerHigh, other.surfaceContainerHigh),
      surfaceContainerHighest: c(surfaceContainerHighest, other.surfaceContainerHighest),
      brightness: t < 0.5 ? brightness : other.brightness,
    );
  }
}

// ─── Bolder typography to match RFINAL Paper theme ──────────────────────
const TextTheme kLifeOsTypography = TextTheme(
  displayLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 36, height: 42 / 36),
  headlineLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 30, height: 36 / 30, letterSpacing: -0.5),
  headlineMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, height: 30 / 24, letterSpacing: -0.4),
  headlineSmall: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, height: 26 / 20, letterSpacing: -0.3),
  titleLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, height: 24 / 18, letterSpacing: -0.2),
  titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, height: 22 / 16),
  titleSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, height: 20 / 14),
  bodyLarge: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, height: 24 / 16),
  bodyMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, height: 20 / 14),
  bodySmall: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, height: 16 / 12),
  labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 20 / 14),
  labelMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, height: 16 / 12),
  labelSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 11, height: 16 / 11),
);

// ─── 6dp shapes to match RFINAL roundness ───────────────────────────────
BorderRadius kRadius6 = BorderRadius.circular(12);

MaterialApp buildLifeOsApp({
  required AppThemeMode themeMode,
  required RouterConfig<Object> routerConfig,
  String title = 'BELTECH',
}) {
  return MaterialApp.router(
    routerConfig: routerConfig,
    title: title,
    debugShowCheckedModeBanner: false,
    theme: _themeData(Brightness.light),
    darkTheme: _themeData(Brightness.dark),
    themeMode: switch (themeMode) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    },
    // AnimatedTheme is a StatefulWidget that correctly:
    //   • Caches child so the subtree is NOT rebuilt on every animation frame.
    //   • Lerps the FULL ThemeData via ThemeData.lerp() — which includes both
    //     ColorScheme AND every ThemeExtension (i.e., LifeOsColors.lerp()).
    //   This prevents the two-layer glitch where scaffold jumps to light colours
    //   while extension colours are still lerping from dark.
    builder: (context, child) => AnimatedTheme(
      data: Theme.of(context),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

ThemeData _themeData(Brightness brightness) {
  final colors = brightness == Brightness.light ? LifeOsColors.light : LifeOsColors.dark;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.secondary,
      onSecondary: colors.onPrimary,
      secondaryContainer: colors.secondaryContainer,
      onSecondaryContainer: colors.onSurface,
      tertiary: colors.tertiary,
      onTertiary: colors.onPrimary,
      tertiaryContainer: colors.tertiaryContainer,
      onTertiaryContainer: colors.onSurface,
      error: colors.error,
      onError: colors.onError,
      errorContainer: colors.errorContainer,
      onErrorContainer: colors.onErrorContainer,
      surface: colors.surface,
      onSurface: colors.onSurface,
      surfaceContainerHighest: colors.surfaceContainerHighest,
      surfaceContainerHigh: colors.surfaceContainerHigh,
      surfaceContainer: colors.surfaceContainer,
      surfaceContainerLow: colors.surfaceContainerLow,
      surfaceContainerLowest: colors.surfaceContainerLowest,
      outline: colors.outline,
      outlineVariant: colors.outlineVariant,
      inverseSurface: colors.inverseSurface,
      onInverseSurface: colors.inverseOnSurface,
      inversePrimary: colors.inversePrimary,
      shadow: Colors.black,
      scrim: Colors.black,
    ),
    textTheme: kLifeOsTypography,
    scaffoldBackgroundColor: colors.background,
    splashFactory: InkRipple.splashFactory,
    fontFamily: 'Roboto',
    extensions: <ThemeExtension<dynamic>>{colors},
  );
}

// _AnimatedScheme deleted — see AnimatedTheme builder in buildLifeOsApp().
// Bug that was here: the StatelessWidget builder captured `this.child` instead
// of using TweenAnimationBuilder's stable child param, so the entire app tree
// rebuilt on every animation frame (freeze). It also only lerped LifeOsColors
// while ColorScheme jumped instantly (light-mode glitch).

/// Convenience accessor mirroring `AppDesignTokens.colors`.
extension LifeOsColorsX on BuildContext {
  LifeOsColors get appColors => Theme.of(this).extension<LifeOsColors>() ?? LifeOsColors.light;
}
