/// 1:1 port of core/ui/designsystem/{PageScaffold,HeroSurface}.kt.
library;

import 'package:flutter/material.dart';

import '../../ui/theme/theme.dart';
import 'tokens.dart';

enum PageHeaderVariant { hero, compact }

/// Page scaffold with HERO or COMPACT header and an optional floating
/// top-banner overlay drawn above content with zero layout impact.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.headerEyebrow,
    this.headerVariant = PageHeaderVariant.hero,
    this.topBanner,
    this.onBack,
    this.actions = const [],
    this.scrollable = true,
    this.contentPadding = const EdgeInsets.only(bottom: AppSpacing.bottomSafe),
    required this.child,
  });

  final String title;
  final String? subtitle;
  final String? headerEyebrow;
  final PageHeaderVariant headerVariant;
  final Widget? topBanner;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final bool scrollable;
  final EdgeInsetsGeometry contentPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (headerVariant == PageHeaderVariant.hero)
          HeroSurface(
            eyebrow: headerEyebrow,
            title: title,
            subtitle: subtitle,
            leading: onBack != null ? _BackButton(onBack: onBack!) : null,
            action: actions,
          )
        else
          CompactHeader(
            title: title,
            subtitle: subtitle,
            onBack: onBack,
            actions: actions,
          ),
        // When not scrollable (e.g. AssistantScreen's ListView), wrap in Expanded
        // so the child fills the remaining constrained height correctly.
        if (!scrollable) Expanded(child: child) else child,
      ],
    );

    return Container(
      color: Theme.of(context).extension<LifeOsColors>()?.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: scrollable
                  ? SingleChildScrollView(
                      // Bouncing physics gives a smooth, fluid over-scroll feel
                      // on Android that matches native app quality.
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.only(
                        left: AppSpacing.screenHorizontal,
                        right: AppSpacing.screenHorizontal,
                      ).add(contentPadding),
                      child: body,
                    )
                  : Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.screenHorizontal,
                        right: AppSpacing.screenHorizontal,
                      ).add(contentPadding),
                      child: body,
                    ),
            ),
          ),
          // Floating banner overlay — drawn on top of content, zero layout impact
          if (topBanner != null)
            Positioned(
              top: 0,
              left: AppSpacing.screenHorizontal,
              right: AppSpacing.screenHorizontal,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: topBanner!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onBack,
      icon: const Icon(Icons.arrow_back_outlined, size: 20),
      tooltip: 'Go back',
      style: IconButton.styleFrom(
        fixedSize: const Size(36, 36),
        minimumSize: const Size(36, 36),
        maximumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
      ),
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}

class CompactHeader extends StatelessWidget {
  const CompactHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                if (onBack != null)
                  Padding(padding: const EdgeInsets.only(right: 4), child: _BackButton(onBack: onBack!)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: scheme.onSurface)),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...actions.map((w) => Padding(padding: const EdgeInsets.only(left: 6), child: w)),
        ],
      ),
    );
  }
}

/// Hero surface — top gradient wash, eyebrow/title/subtitle + trailing action.
class HeroSurface extends StatelessWidget {
  const HeroSurface({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.leading,
    this.action = const [],
    this.footer,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> action;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LifeOsColors>();
    final c = colors ?? LifeOsColors.light;
    final shape = BorderRadius.vertical(
      top: Radius.zero,
      bottom: Radius.circular(16),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.primary.withValues(alpha: 0.08), Colors.transparent],
        ),
      ),
      child: Padding(
        // Revamped padding: top 4 / bottom 10 (was 6/14) — slimmer header.
        padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) Padding(padding: const EdgeInsets.only(top: 2), child: leading!),
                if (leading != null) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (eyebrow != null)
                        Text(
                          eyebrow!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.none,
                            decorationColor: Colors.transparent,
                          ),
                        ),
                      // Gap tightened 4 → 2dp when eyebrow present; 4 → 2dp title→subtitle.
                      if (eyebrow != null) const SizedBox(height: 2),
                      if (eyebrow == null) const SizedBox(height: 2),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        // headlineSmall (20sp/w700) — was headlineMedium (24sp).
                        // Saves ~4sp of height while keeping the heading hierarchy clear.
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: c.onBackground),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: c.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
                if (action.isNotEmpty) ...action,
              ],
            ),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}

/// HeroStatChip — label/value pill used under hero headers.
class HeroStatChip extends StatelessWidget {
  const HeroStatChip({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<LifeOsColors>() ?? LifeOsColors.light;
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c.onSurfaceVariant)),
          const SizedBox(width: 6),
          Text(value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.onSurface)),
        ],
      ),
    );
  }
}
