/// 1:1 port of features/home/presentation/HomeScreen.kt + HomeMenuCard.kt +
/// WeeklyResetCard.kt.
///
/// Aurora backdrop (three radial washes), TopAppBar "Today" + date, greeting,
/// Today/Week/Month metric row, 4-item quick-launch menu card, and the weekly
/// reset card. Shimmer skeleton while loading.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/designsystem/banners.dart';
import '../../../core/designsystem/metric_card.dart';
import '../../../core/designsystem/tokens.dart' show AppSpacing;
import '../../../navigation/routes.dart';
import '../../dashboard/data/providers.dart';

// ── HomeUiState (HomeContracts.kt) ──────────────────────────────────────────

class HomeUiState {
  const HomeUiState({
    required this.greeting,
    required this.dateLabel,
    required this.todaySpending,
    required this.weekSpending,
    required this.monthSpending,
    required this.pendingTaskCount,
    required this.completedTodayCount,
    required this.nextEventTitle,
    required this.nextEventTimeLabel,
    required this.isLoading,
    this.errorMessage,
    this.hasWeeklyRitual = true,
  });

  final String greeting;
  final String dateLabel;
  final double todaySpending;
  final double weekSpending;
  final double monthSpending;
  final int pendingTaskCount;
  final int completedTodayCount;
  final String? nextEventTitle;
  final String? nextEventTimeLabel;
  final bool isLoading;
  final String? errorMessage;

  /// HOME_RITUALS feature flag is on by default (Kotlin parity).
  final bool hasWeeklyRitual;

  /// buildWeeklyRitual() priority text.
  String get ritualSummary {
    if (pendingTaskCount > 0) {
      return 'Clear $pendingTaskCount pending task${pendingTaskCount == 1 ? '' : 's'} '
          'before the week closes.';
    }
    return 'Capture one win and one risk from this week while the context is still fresh.';
  }
}

// Non-autoDispose: keeps the stream and its cached value alive for the whole
// app session. GoRouter rebuilds the ShellRoute child on every tab switch, so
// autoDispose would destroy and recreate the stream each time — causing a
// visible shimmer skeleton flash on every return to the Home tab.
final homeUiStreamProvider = StreamProvider<HomeUiState>(
    (ref) => watchHomeUiState(ref));

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(homeUiStreamProvider);
    const initial = HomeUiState(
      greeting: '',
      dateLabel: '',
      todaySpending: 0,
      weekSpending: 0,
      monthSpending: 0,
      pendingTaskCount: 0,
      completedTodayCount: 0,
      nextEventTitle: null,
      nextEventTimeLabel: null,
      isLoading: true,
    );
    // If the stream has an error and no cached value, show an error surface
    // rather than a permanent shimmer or an empty black screen.
    if (snap.hasError && snap.value == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_outlined,
                  size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text('Could not load home data.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(homeUiStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    final state = snap.value ?? initial;

    return Scaffold(
      // Explicit background prevents a one-frame black flash before the aurora
      // canvas and content widgets paint themselves in.
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(child: _AuroraBackdrop()),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── TopAppBar ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8, top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Today',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            Text(state.dateLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
                          ],
                        ),
                      ),
                      // 44dp logo with 6dp clip — DashboardComponents.kt parity.
                      GestureDetector(
                        onTap: () => context.go('/${AppRoute.profile}'),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            'assets/logo/logo_personalos.png',
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: ShimmerLoadingState(rows: 3))
                      : RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(homeUiStreamProvider);
                            // Wait one frame so the new stream emits before
                            // the indicator spinner stops.
                            await Future<void>.delayed(
                                const Duration(milliseconds: 300));
                          },
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 8,
                                bottom: AppSpacing.bottomSafeWithFloatingNav),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (state.errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: TopBanner(
                                        message: state.errorMessage!,
                                        tone: TopBannerTone.error),
                                  ),
                                // Greeting section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(state.greeting,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge
                                            ?.copyWith(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text(
                                        'Review priorities, schedule, and your spend trend.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant)),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                // Spending metrics row
                                Row(
                                  children: [
                                    Expanded(
                                      child: MetricCard(
                                          title: 'Today',
                                          amount: state.todaySpending),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: MetricCard(
                                          title: 'Week',
                                          amount: state.weekSpending),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: MetricCard(
                                          title: 'Month',
                                          amount: state.monthSpending),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                HomeMenuCard(
                                  pendingTaskCount: state.pendingTaskCount,
                                  nextEventTitle: state.nextEventTitle,
                                  nextEventTimeLabel: state.nextEventTimeLabel,
                                  onOpenRoute: (r) => context.push('/$r'),
                                ),
                                if (state.hasWeeklyRitual) ...[
                                  const SizedBox(height: 14),
                                  WeeklyResetCard(
                                    pendingTaskCount: state.pendingTaskCount,
                                    onOpenReview: () =>
                                        context.push('/${AppRoute.review}'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Three radial aurora washes with a 12-second slow-breathe opacity animation.
/// Indigo primary wash top-left, violet secondary mid-right, teal accent low.
class _AuroraBackdrop extends StatefulWidget {
  const _AuroraBackdrop();

  @override
  State<_AuroraBackdrop> createState() => _AuroraBackdropState();
}

class _AuroraBackdropState extends State<_AuroraBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    // Subtle breathe: 78% → 100% opacity on the full aurora layer.
    _opacity = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (_, __) => Opacity(
          opacity: _opacity.value,
          child: const CustomPaint(
            size: Size.infinite,
            painter: _AuroraPainter(),
          ),
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  const _AuroraPainter();

  // Cached Paint objects (with shaders) keyed to the Size they were built for.
  // ignore: prefer_final_fields
  static Size? _cachedSize;
  static Paint? _p1, _p2, _p3;

  static void _buildPaints(Size size) {
    if (_cachedSize == size) return;
    _cachedSize = size;
    final maxDim = size.shortestSide;

    Paint makePaint(Offset center, double radius, List<Color> colors) =>
        Paint()
          ..shader = RadialGradient(colors: colors).createShader(
            Rect.fromCircle(center: center, radius: radius),
          );

    // Indigo primary wash — top-left anchor.
    _p1 = makePaint(
      Offset(size.width * 0.25, size.height * 0.08),
      maxDim * 0.58,
      [const Color(0x226366F1), const Color(0x0C6366F1), Colors.transparent],
    );
    // Violet secondary wash — mid-right.
    _p2 = makePaint(
      Offset(size.width * 0.78, size.height * 0.40),
      maxDim * 0.50,
      [const Color(0x1C8B5CF6), const Color(0x088B5CF6), Colors.transparent],
    );
    // Teal accent — bottom-centre.
    _p3 = makePaint(
      Offset(size.width * 0.5, size.height * 0.80),
      maxDim * 0.44,
      [const Color(0x1014B8A6), const Color(0x0514B8A6), Colors.transparent],
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _buildPaints(size);
    final maxDim = size.shortestSide;
    canvas.drawCircle(
        Offset(size.width * 0.25, size.height * 0.08), maxDim * 0.58, _p1!);
    canvas.drawCircle(
        Offset(size.width * 0.78, size.height * 0.40), maxDim * 0.50, _p2!);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.80), maxDim * 0.44, _p3!);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── HomeMenuCard ─────────────────────────────────────────────────────────────

class HomeMenuCard extends StatelessWidget {
  const HomeMenuCard({
    super.key,
    required this.pendingTaskCount,
    required this.nextEventTitle,
    required this.nextEventTimeLabel,
    required this.onOpenRoute,
  });

  final int pendingTaskCount;
  final String? nextEventTitle;
  final String? nextEventTimeLabel;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = scheme.surfaceContainerLow;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Kotlin rows are stacked same-color cards — no dividers.
          _row(context, Icons.task_alt_outlined, 'Tasks',
              value:
                  pendingTaskCount == 0 ? 'All done' : '$pendingTaskCount pending',
              onTap: () => onOpenRoute(AppRoute.tasks)),
          _row(context, Icons.calendar_month_outlined, 'Next Event',
              value: nextEventTimeLabel ?? 'No event',
              subtitle: nextEventTitle,
              onTap: () => onOpenRoute(AppRoute.events)),
          _row(context, Icons.auto_graph_outlined, 'Analytics',
              value: 'Trends', onTap: () => onOpenRoute(AppRoute.insights)),
          _row(context, Icons.search_outlined, 'Search',
              value: 'Find anything', onTap: () => onOpenRoute(AppRoute.search)),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String title, {
    required String value,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: scheme.primary, semanticLabel: title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── WeeklyResetCard ─────────────────────────────────────────────────────────

class WeeklyResetCard extends StatelessWidget {
  const WeeklyResetCard({
    super.key,
    required this.pendingTaskCount,
    required this.onOpenReview,
  });

  final int pendingTaskCount;
  final VoidCallback onOpenReview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const summary =
        'Capture one win and one risk from this week while the context is still fresh.';
    final taskSummary =
        'Clear $pendingTaskCount pending task${pendingTaskCount == 1 ? '' : 's'} before the week closes.';
    final body = pendingTaskCount > 0 ? taskSummary : summary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: scheme.primaryContainer.withValues(alpha: 0.40),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Weekly reset',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(body,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onOpenReview,
            icon: const Icon(Icons.sync_outlined, size: 14),
            label: const Text('Open Weekly Review'),
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}
