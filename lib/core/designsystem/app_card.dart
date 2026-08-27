/// 1:1 port of core/ui/designsystem/AppCard.kt.
library;

import 'package:flutter/material.dart';

/// Surface hierarchy: surfaceContainerLowest < surface < surfaceContainerLow.
/// Flat cards sit on surfaceContainerLowest so they lift off the background in
/// both themes. Elevated cards step up to surfaceContainerLow — tonal fill
/// conveys elevation; no border needed. Glass cards keep a translucent border.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.glass = false,
    this.elevated = false,
    this.contentPadding = const EdgeInsets.all(20),
    required this.child,
  });

  final bool glass;
  final bool elevated;
  final EdgeInsetsGeometry contentPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // 12dp card radius (revamp v2 — kRadius12 in theme.dart).
    final shape = BorderRadius.circular(12);

    final Color baseColor;
    if (glass) {
      baseColor = scheme.surface.withValues(alpha: 0.84);
    } else if (elevated) {
      baseColor = scheme.surface;
    } else {
      // surfaceContainerLowest is exposed via LifeOsColors extension.
      baseColor = scheme.surfaceContainerLowest;
    }

    final Color borderColor = glass
        ? scheme.outlineVariant.withValues(alpha: 0.70)
        : scheme.outlineVariant.withValues(alpha: 0.54);

    final double elevation = glass ? 8 : (elevated ? 4 : 2);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: shape,
        border: Border.all(color: borderColor, width: 0.85),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.11 * (elevation / 8).clamp(0.25, 1.0)),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: glass
          ? Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: shape,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.04),
                          Colors.white.withValues(alpha: 0.01),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(padding: contentPadding, child: child),
              ],
            )
          : Padding(padding: contentPadding, child: child),
    );
  }
}
