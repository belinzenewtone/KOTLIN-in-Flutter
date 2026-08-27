/// LifeOS design system v2 — revamped colour & typography tokens.
///
/// Primary: indigo #6366F1 (Droo Finance inspiration).
/// Typography: Plus Jakarta Sans 800/700 (display/headline) · Inter (body/title)
///             via Google Fonts. JetBrains Mono for all KSh amounts → kMonoStyle.
/// Card radius: 12dp (kRadius12). Small components keep kRadius6 (6dp).
/// Theme animation: 400ms easeInOut (intentional revamp delta; Kotlin parity was 250ms).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode { system, light, dark }

/// Every colour role the app references, resolved per-brightness.
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

  // ── Semantic statics ──────────────────────────────────────────────────────
  /// Positive income / credit transactions.
  static const income  = Color(0xFF22C55E);
  /// Expense / debit transactions.
  static const expense = Color(0xFFF43F5E);
  /// Secondary accent: violet (goals, aurora gradient, secondary highlights).
  static const violet  = Color(0xFF8B5CF6);
  /// Success confirmation (kept at AppDesignTokens.colors.success).
  static const success = Color(0xFF16A34A);
  /// Warning / caution (kept at AppDesignTokens.colors.warning).
  static const warning = Color(0xFFD97706);

  // ── Light scheme ──────────────────────────────────────────────────────────
  static const light = LifeOsColors(
    primary:              Color(0xFF4F46E5), // indigo-600
    onPrimary:            Color(0xFFFFFFFF),
    primaryContainer:     Color(0xFFE0E7FF), // indigo-100
    onPrimaryContainer:   Color(0xFF312E81), // indigo-900
    secondary:            Color(0xFF7C3AED), // violet-600
    secondaryContainer:   Color(0xFFEDE9FE), // violet-100
    tertiary:             Color(0xFF0D9488), // teal-600
    tertiaryContainer:    Color(0xFFCCFBF1), // teal-100
    background:           Color(0xFFF2F2F8), // near-white, slight indigo hue
    onBackground:         Color(0xFF0D0D18),
    surface:              Color(0xFFFFFFFF),
    onSurface:            Color(0xFF0D0D18),
    surfaceVariant:       Color(0xFFEDEDF7),
    onSurfaceVariant:     Color(0xFF44445A),
    outline:              Color(0xFFDCDCEE),
    outlineVariant:       Color(0xFFEDEDF7),
    error:                Color(0xFFE11D48), // rose-600
    onError:              Color(0xFFFFFFFF),
    errorContainer:       Color(0xFFFFE4E6), // rose-100
    onErrorContainer:     Color(0xFF9F1239), // rose-800
    inverseSurface:       Color(0xFF1A1A28),
    inverseOnSurface:     Color(0xFFF2F2F8),
    inversePrimary:       Color(0xFFA5B4FC), // indigo-300
    surfaceContainerLowest:  Color(0xFFFFFFFF),
    surfaceContainerLow:     Color(0xFFF6F6FC),
    surfaceContainer:        Color(0xFFEDEDF7),
    surfaceContainerHigh:    Color(0xFFE4E4F0),
    surfaceContainerHighest: Color(0xFFD8D8EC),
    brightness: Brightness.light,
  );

  // ── Dark scheme ───────────────────────────────────────────────────────────
  static const dark = LifeOsColors(
    primary:              Color(0xFF6366F1), // indigo-500
    onPrimary:            Color(0xFFFFFFFF),
    primaryContainer:     Color(0xFF1E1E3F), // deep indigo
    onPrimaryContainer:   Color(0xFFC7D2FE), // indigo-200
    secondary:            Color(0xFF8B5CF6), // violet-500
    secondaryContainer:   Color(0xFF1A1033), // deep violet
    tertiary:             Color(0xFF14B8A6), // teal-500
    tertiaryContainer:    Color(0xFF0D2E2B), // deep teal
    background:           Color(0xFF08080C), // near-black, indigo bias
    onBackground:         Color(0xFFE8E8F2),
    surface:              Color(0xFF0F0F18), // dark surface
    onSurface:            Color(0xFFE8E8F2),
    surfaceVariant:       Color(0xFF14141E), // raised surface
    onSurfaceVariant:     Color(0xFFA0A0B8),
    outline:              Color(0xFF464658), // raised from #252530 — visible border in dark mode
    outlineVariant:       Color(0xFF2C2C3E), // raised from #1C1C28 — subtle but legible border
    error:                Color(0xFFF43F5E), // rose-500
    onError:              Color(0xFFFFFFFF),
    errorContainer:       Color(0xFF2D0A12), // deep rose
    onErrorContainer:     Color(0xFFFCA5A5), // rose-300
    inverseSurface:       Color(0xFFE8E8F2),
    inverseOnSurface:     Color(0xFF08080C),
    inversePrimary:       Color(0xFF6366F1),
    surfaceContainerLowest:  Color(0xFF05050A),
    surfaceContainerLow:     Color(0xFF0F0F18),
    surfaceContainer:        Color(0xFF14141E),
    surfaceContainerHigh:    Color(0xFF1A1A28),
    surfaceContainerHighest: Color(0xFF20202F),
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

// ── Typography ────────────────────────────────────────────────────────────────
// Display/headline → Plus Jakarta Sans 800/700 (via GoogleFonts).
// Title/body/label  → Inter, applied via fontFamily in ThemeData.
// Amounts           → kMonoStyle() — JetBrains Mono + tabular-nums, called at the use site.

TextTheme _buildTextTheme() => TextTheme(
  displayLarge:
      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 36, height: 1.167),
  headlineLarge:
      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 30, height: 1.2, letterSpacing: -0.5),
  headlineMedium:
      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 24, height: 1.25, letterSpacing: -0.4),
  headlineSmall:
      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 20, height: 1.3, letterSpacing: -0.3),
  titleLarge:  const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, height: 1.333, letterSpacing: -0.2),
  titleMedium: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, height: 1.375),
  titleSmall:  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, height: 1.429),
  bodyLarge:   const TextStyle(fontWeight: FontWeight.w400, fontSize: 16, height: 1.5),
  bodyMedium:  const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, height: 1.429),
  bodySmall:   const TextStyle(fontWeight: FontWeight.w400, fontSize: 12, height: 1.333),
  labelLarge:  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 1.429),
  labelMedium: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, height: 1.333),
  labelSmall:  const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, height: 1.455),
);

/// Typography set for the theme. Display + headline use Plus Jakarta Sans;
/// title / body / label roles inherit Inter from ThemeData.fontFamily.
final TextTheme kLifeOsTypography = _buildTextTheme();

/// JetBrains Mono with tabular-nums — **required** for every KSh amount,
/// balance, or digit column in the app.
///
/// Results are cached by (fontSize, fontWeight) key so we never call
/// GoogleFonts.jetBrainsMono() more than once per unique combination.
/// Without this cache, every build of every transaction row / metric card
/// creates a fresh TextStyle object which causes noticeable jank on lists.
final _monoStyleCache = <int, TextStyle>{};

TextStyle kMonoStyle({double fontSize = 14, FontWeight fontWeight = FontWeight.w500}) {
  // Pack both values into a single int key — fontSize multiplied by 10 to
  // preserve one decimal place, weight index shifted into the high bits.
  final key = (fontSize * 10).round() | (fontWeight.value << 4);
  return _monoStyleCache.putIfAbsent(
    key,
    () => GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
  );
}

// ── Radii ─────────────────────────────────────────────────────────────────────
/// 6dp — kept for small components: chips, badges, tags.
// ignore: non_constant_identifier_names
final BorderRadius kRadius6 = BorderRadius.circular(6);

/// 12dp — standard card radius for AppCard, GlassCard, MetricCard, dialogs.
// ignore: non_constant_identifier_names
final BorderRadius kRadius12 = BorderRadius.circular(12);

// ── App builder ───────────────────────────────────────────────────────────────
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
      AppThemeMode.light  => ThemeMode.light,
      AppThemeMode.dark   => ThemeMode.dark,
    },
    // AnimatedTheme lerps the full ThemeData (ColorScheme + LifeOsColors.lerp)
    // over 400ms — intentional revamp delta; Kotlin parity was 250ms.
    builder: (context, child) => AnimatedTheme(
      data: Theme.of(context),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

// Cached Inter font-family name — avoids calling GoogleFonts.inter() on every
// ThemeData rebuild (triggered by root ValueListenableBuilder on themeController).
final String _interFontFamily = GoogleFonts.inter().fontFamily ?? 'Inter';

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
    // Inter as the base body/title font; Plus Jakarta Sans overrides
    // display and headline roles directly in kLifeOsTypography.
    // Cache the fontFamily string — GoogleFonts.inter() creates a TextStyle
    // object each call; we only need the family name once.
    fontFamily: _interFontFamily,
    extensions: <ThemeExtension<dynamic>>{colors},
    // ── Global input field defaults ───────────────────────────────────────────
    // Fixes invisible text fields in dark mode. All TextFields that don't set
    // explicit borders/fill inherit these; fields with explicit decorations keep
    // their own values (enabledBorder beats theme.border via applyDefaults()).
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      // Never float the label above the field — instead it sits inside like a
      // hint, giving the clean "Add Transaction" style across the whole app.
      floatingLabelBehavior: FloatingLabelBehavior.never,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
      hintStyle: TextStyle(
        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
        fontSize: 14,
      ),
    ),
    // ── Global Switch defaults ────────────────────────────────────────────────
    // Fixes nearly-invisible Switch widgets in dark mode. Raw Switch() calls
    // and LifeOsSwitch both benefit since LifeOsSwitch sets inactiveTrackColor
    // explicitly; raw Switch() inherits these defaults.
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colors.primary;
        return colors.onSurface.withValues(alpha: 0.28);
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
  );
}

/// Convenience accessor — `context.appColors.primary` etc.
extension LifeOsColorsX on BuildContext {
  LifeOsColors get appColors => Theme.of(this).extension<LifeOsColors>() ?? LifeOsColors.light;
}
