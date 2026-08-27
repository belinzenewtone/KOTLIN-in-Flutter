/// 1:1 port of core/ui/designsystem/{TopBanner,InlineBanner,EmptyAndErrorState,
/// ImportHealthPanel}.kt.
library;

import 'package:flutter/material.dart';

import '../../ui/theme/theme.dart';
import 'app_card.dart';
import 'tokens.dart';

enum TopBannerTone { error, warning, success, info }

typedef ImportHealthUiModel = ({
  int importedCount,
  int pendingReviewCount,
  int duplicateCount,
  int parseFailureCount,
  String? lastImportSummary,
});

/// TopBanner — high-priority floating banner with tinted icon badge.
class TopBanner extends StatelessWidget {
  const TopBanner({
    super.key,
    required this.message,
    this.tone = TopBannerTone.info,
    this.title,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  final String message;
  final TopBannerTone tone;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final semanticTone = switch (tone) {
      TopBannerTone.info => AppSemanticTone.info,
      TopBannerTone.success => AppSemanticTone.success,
      TopBannerTone.warning => AppSemanticTone.warning,
      TopBannerTone.error => AppSemanticTone.error,
    };
    final semanticColors = AppDesignTokens.semanticColors(context, semanticTone);
    final icon = switch (tone) {
      TopBannerTone.error => Icons.error_outline,
      TopBannerTone.warning => Icons.warning_outlined,
      TopBannerTone.success => Icons.check_circle_outline,
      TopBannerTone.info => Icons.info_outline,
    };
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
        border: Border.all(color: semanticColors.icon.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(color: semanticColors.icon.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: semanticColors.icon.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: semanticColors.icon),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(title!,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                Text(message,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w500)),
                if (actionLabel != null && onAction != null)
                  InkWell(
                    onTap: onAction,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(actionLabel!,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: semanticColors.icon)),
                    ),
                  ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(Icons.close_outlined, size: 14, color: scheme.onSurfaceVariant),
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}

enum InlineBannerTone { info, success, warning, error }

class InlineBanner extends StatelessWidget {
  const InlineBanner({super.key, required this.message, this.tone = InlineBannerTone.info});

  final String message;
  final InlineBannerTone tone;

  @override
  Widget build(BuildContext context) {
    final semanticTone = switch (tone) {
      InlineBannerTone.info => AppSemanticTone.info,
      InlineBannerTone.success => AppSemanticTone.success,
      InlineBannerTone.warning => AppSemanticTone.warning,
      InlineBannerTone.error => AppSemanticTone.error,
    };
    final semanticColors = AppDesignTokens.semanticColors(context, semanticTone);
    final icon = switch (tone) {
      InlineBannerTone.info => Icons.info_outline,
      InlineBannerTone.success => Icons.check_circle_outline,
      InlineBannerTone.warning => Icons.warning_outlined,
      InlineBannerTone.error => Icons.error_outline,
    };

    return Container(
      decoration: BoxDecoration(
        color: semanticColors.container,
        borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: semanticColors.icon),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(message,
                style:
                    Theme.of(context).textTheme.bodyMedium?.copyWith(color: semanticColors.onContainer)),
          ),
        ],
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label = 'Loading...'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: AppSpacing.sm),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

/// Shimmer skeleton mimicking a list of transaction/card rows.
///
/// The shimmer band sweeps from left to right using a LinearGradient whose
/// Alignment begin/end are animated. `offset` ranges [-2, 2] in Alignment
/// space (−1 = left edge, 1 = right edge) so the highlight travels from
/// off-screen-left through the widget to off-screen-right.
class ShimmerLoadingState extends StatefulWidget {
  const ShimmerLoadingState({super.key, this.rows = 4});

  final int rows;

  @override
  State<ShimmerLoadingState> createState() => _ShimmerLoadingStateState();
}

class _ShimmerLoadingStateState extends State<ShimmerLoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<LifeOsColors>() ?? LifeOsColors.light;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // offset sweeps −2 → 2 so the highlight band travels from off-screen-
        // left to off-screen-right; easeInOut gives a smooth ramp on each side.
        final offset = Curves.easeInOut.transform(_controller.value) * 4.0 - 2.0;
        return Column(
          children: [
            for (var i = 0; i < widget.rows; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _ShimmerRow(
                shimmerOffset: offset,
                base: c.surfaceContainerLow,
                // surfaceContainerHighest gives a noticeably brighter sweep
                // band compared to surfaceContainerHigh — more legible on both
                // light and dark themes without over-saturating the skeleton.
                highlight: c.surfaceContainerHighest,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  const _ShimmerRow({
    required this.shimmerOffset,
    required this.base,
    required this.highlight,
  });

  /// Alignment-space position of the highlight centre (−2 to 2).
  /// −1 = widget left edge, 1 = widget right edge.
  final double shimmerOffset;
  final Color base;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    // The band is 2 alignment-units wide (1 unit each side of the offset),
    // which at the widget's own width corresponds to the full width — the
    // gradient is a single smooth fade-in → highlight → fade-out stripe.
    final g = LinearGradient(
      begin: Alignment(shimmerOffset - 1.0, 0),
      end: Alignment(shimmerOffset + 1.0, 0),
      colors: [base, highlight, base],
      stops: const [0.0, 0.5, 1.0],
    );

    Widget box({double? w, double? h, double? fraction}) => FractionallySizedBox(
          widthFactor: fraction,
          child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: g,
            ),
          ),
        );

    return SizedBox(
      height: 72,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), gradient: g),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                box(fraction: 0.55, h: 14),
                const SizedBox(height: 6),
                box(fraction: 0.35, h: 10),
              ],
            ),
          ),
          box(w: 60, h: 14),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.description, this.icon});

  final String title;
  final String description;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final centered = icon != null;
    return Column(
      mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        Text(description,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.description,
    required this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String title;
  final String description;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: scheme.error)),
        const SizedBox(height: 6),
        Text(description,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 10),
        FilledButton(onPressed: onRetry, child: Text(retryLabel)),
      ],
    );
  }
}

/// ImportHealthPanel — imported/pending/duplicates/parse-issues summary.
class ImportHealthPanel extends StatelessWidget {
  const ImportHealthPanel({
    super.key,
    required this.model,
    this.onReview,
  });

  final ImportHealthUiModel model;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      contentPadding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Import Health', style: Theme.of(context).textTheme.titleMedium),
              TextButton(onPressed: onReview, child: const Text('Review')),
            ],
          ),
          Text(
            '${model.importedCount} imported | '
            '${model.pendingReviewCount} pending | '
            '${model.duplicateCount} duplicates | '
            '${model.parseFailureCount} parse issues',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (model.lastImportSummary != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(model.lastImportSummary!,
                style:
                    Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
