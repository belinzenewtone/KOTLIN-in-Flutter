/// 1:1 port of ui/components/GlassCard.kt — glass morphism card.
library;

import 'package:flutter/material.dart';

/// Reusable Glass Morphism card component.
///
/// Uses the theme surface color as a base so the card is always readable in
/// both light and dark mode. A subtle white-alpha gradient adds the glass sheen.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    this.cornerRadius = 20,
    this.glassAlpha = 0.04,
    this.elevation = 4,
    required this.child,
  });

  final double cornerRadius;
  final double glassAlpha;
  final double elevation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLightSurface = scheme.surface.computeLuminance() > 0.5;
    final sheenColor = isLightSurface ? Colors.white : scheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(cornerRadius),
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cornerRadius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    sheenColor.withValues(alpha: glassAlpha * (isLightSurface ? 1.0 : 0.55)),
                    sheenColor.withValues(alpha: glassAlpha * (isLightSurface ? 0.2 : 0.12)),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

/// Variant with accent-colored glow for highlighted cards.
class AccentGlassCard extends StatelessWidget {
  const AccentGlassCard({
    super.key,
    this.accentColor = kPrimaryAccentFallback,
    this.cornerRadius = 20,
    required this.child,
  });

  static const Color kPrimaryAccentFallback = Color(0xFF0369A1);

  final Color accentColor;
  final double cornerRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(cornerRadius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accentColor.withValues(alpha: 0.07),
            accentColor.withValues(alpha: 0.01),
            Colors.transparent,
          ],
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.115), width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
