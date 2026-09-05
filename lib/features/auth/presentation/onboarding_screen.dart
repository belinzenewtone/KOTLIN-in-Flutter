/// 1:1 port of features/auth/presentation/OnboardingScreen.kt — the 5-step
/// setup flow (Welcome → Pillars → Profile → Background → All set) with hero
/// header, error banner, CTA button, and progress dots.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/designsystem/banners.dart';
import '../../../core/designsystem/tokens.dart';
import '../../../core/platform/system_bridge.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/theme.dart';
import '../../../core/security/session_store.dart';

enum OnboardingGoal {
  productivity('PRODUCTIVITY', 'Optimize Productivity',
      'Sharper focus, smarter routines, better execution.'),
  finance('FINANCE', 'Strengthen Finance',
      'Track spending and budgets with clear control.'),
  balanced('BALANCED', 'Balance Everything',
      'Plan work, money, and time in one calm system.');

  const OnboardingGoal(this.key, this.title, this.description);
  final String key;
  final String title;
  final String description;

  static OnboardingGoal fromKey(String k) => OnboardingGoal.values.firstWhere(
        (e) => e.key == k,
        orElse: () => OnboardingGoal.productivity,
      );
}

String onboardingStepSubtitle(int step) {
  switch (step) {
    case 1:
      return 'A calm setup to personalize your planning and finance workspace.';
    case 2:
      return 'Understand the core pillars that shape your daily flow.';
    case 3:
      return 'Tell us your name and what you want to focus on.';
    case 4:
      return 'Allow the app to stay active so timers, sync, and reminders always work.';
    default:
      return 'Final checks before launching into your dashboard.';
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 1;
  String _fullName = '';
  OnboardingGoal _goal = OnboardingGoal.productivity;
  bool _saving = false;
  bool? _batteryExempt;
  String? _error;

  // Single controller for the name field — created once, never leaked.
  late final TextEditingController _nameCtrl;

  static const _kName = 'user_name';
  static const _kStep = 'onboarding_step';
  static const _kGoal = 'onboarding_primary_goal';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _restoreProgress();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _restoreProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final name = prefs.getString(_kName) ?? '';
    // Pre-check battery optimisation status so step 4 shows the right button state.
    final batteryExempt = await SystemPlatformBridge.isBatteryOptimized();
    if (!mounted) return;
    setState(() {
      _fullName = name;
      _step = (prefs.getInt(_kStep) ?? 1).clamp(1, 5);
      _goal =
          OnboardingGoal.fromKey(prefs.getString(_kGoal) ?? 'PRODUCTIVITY');
      _batteryExempt = batteryExempt;
    });
    _nameCtrl.text = name;
    _nameCtrl.selection = TextSelection.collapsed(offset: name.length);
  }

  Future<void> _persistProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kStep, _step);
    await prefs.setString(_kGoal, _goal.key);
    // Persist the name as soon as it is captured (step ≥ 3) so that returning
    // to the app mid-onboarding already has the name ready and the Profile
    // screen auto-fills it immediately after completion.
    if (_fullName.trim().isNotEmpty) {
      await prefs.setString(_kName, _fullName.trim());
    }
  }

  void _continue() {
    if (_step == 3 && _fullName.trim().isEmpty) {
      setState(() => _error = 'Please enter your name to personalize your workspace.');
      return;
    }
    setState(() {
      _error = null;
      if (_step < 5) _step += 1;
    });
    _persistProgress();
  }

  void _goBack() {
    if (_step > 1) {
      setState(() {
        _step -= 1;
        _error = null;
      });
      _persistProgress();
    }
  }

  Future<void> _complete() async {
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = _fullName.trim();
      await prefs.setString(_kName, name);
      await prefs.setString(_kGoal, _goal.key);
      // Derive a username from the full name if one has not been set yet.
      // Cap at 8 chars to match the Profile Settings limit.
      // e.g. "Belinze Newtone" → "belinze" (first word, max 8 chars)
      if ((prefs.getString('auth_username') ?? '').isEmpty && name.isNotEmpty) {
        final first = name.toLowerCase().split(RegExp(r'\s+')).first;
        final derived = first.length > 8 ? first.substring(0, 8) : first;
        await prefs.setString('auth_username', derived);
      }
      await ref.read(sessionProvider.notifier).completeOnboarding();
      if (!mounted) return;
      context.go('/${AppRoute.auth}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = Theme.of(context).extension<LifeOsColors>() ?? LifeOsColors.light;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.background, c.surfaceContainerLowest],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Compact header ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: Row(
                  children: [
                    if (_step > 1)
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          onPressed: _goBack,
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.arrow_back_outlined,
                              size: 20, color: scheme.primary),
                        ),
                      )
                    else
                      const SizedBox(width: 36),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Step $_step of 5',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      color: scheme.primary,
                                      letterSpacing: 0.6)),
                          Text('PersonalOS setup',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              if (_error != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  child: InlineBanner(
                      message: _error!, tone: InlineBannerTone.error),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              // ── Step content — fills available height; scrolls on tiny screens ─
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: ConstrainedBox(
                      // minHeight forces the step widget to be at least as tall
                      // as the viewport so spaceEvenly distributes to the edges.
                      constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - AppSpacing.sm * 2),
                      child: IntrinsicHeight(
                        child: switch (_step) {
                          1 => _welcomeStep(context),
                          2 => _pillarsStep(context),
                          3 => _profileStep(context),
                          4 => _backgroundStep(context),
                          _ => _finalStep(context),
                        },
                      ),
                    ),
                  ),
                ),
              ),
              // ── CTA + progress dots ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDesignTokens.radius.sm)),
                        ),
                        onPressed:
                            _saving ? null : (_step == 5 ? _complete : _continue),
                        child: _saving
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: scheme.onPrimary,
                                ),
                              )
                            : Text(
                                switch (_step) {
                                  1 => "Let's Begin",
                                  5 => 'Start My Journey',
                                  _ => 'Continue',
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _progressDots(scheme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressDots(ColorScheme scheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            for (var i = 0; i < 5; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 28,
                height: 4,
                decoration: BoxDecoration(
                  color: i < _step ? scheme.primary : scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── Step 1: Welcome ───────────────────────────────────────────────────────

  Widget _featureRow(BuildContext context, IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Divider(color: scheme.outlineVariant.withValues(alpha: 0.3), height: 1);
  }

  Widget _welcomeStep(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      // spaceEvenly distributes remaining height (after IntrinsicHeight
      // expands to minHeight) equally above, between, and below the two blocks.
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Hero block ─────────────────────────────────────────────────
        Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.65)),
              ),
              alignment: Alignment.center,
              child: Image.asset('assets/logo/logo_personalos.png',
                  // 68dp matches Kotlin OnboardingScreen.kt Modifier.size(68.dp)
                  width: 68, height: 68, fit: BoxFit.contain),
            ),
            const SizedBox(height: 20),
            Text('Welcome to PersonalOS',
                textAlign: TextAlign.center,
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
                'Your sanctuary for productivity, finance,\nand mindful planning.',
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
        // ── Feature block ───────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("What's included",
                style: tt.labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 0.4)),
            const SizedBox(height: 16),
            _featureRow(context, Icons.speed_outlined,
                'Productivity — tasks, routines, and focused planning'),
            const SizedBox(height: 14),
            _featureRow(context, Icons.pie_chart_outline_outlined,
                'Finance — budgets, spending, and trends at a glance'),
            const SizedBox(height: 14),
            _featureRow(context, Icons.calendar_month_outlined,
                'Calendar — events, birthdays, and smart reminders'),
          ],
        ),
      ],
    );
  }

  // ── Step 2/4/5 shared pillar row (compact — no card, fits on one screen) ─

  Widget _pillarCard(
      BuildContext context, IconData icon, String title, String description) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(description,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillarsStep(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ─────────────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('One place for everything.',
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
                'PersonalOS keeps your planning and money flows aligned in one calm surface.',
                style: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
        // ── Pillar cards ────────────────────────────────────────────────
        Column(
          children: [
            _pillarCard(context, Icons.speed_outlined, 'Productivity',
                'Prioritize what matters and keep focused execution daily.'),
            _pillarCard(context, Icons.calendar_month_outlined, 'Planning & Calendar',
                'Events, reminders, birthdays, and countdowns — all in one view.'),
            _pillarCard(context, Icons.pie_chart_outline_outlined, 'Finance',
                'Track spending, watch budgets, and review trends with confidence.'),
          ],
        ),
      ],
    );
  }

  // ── Step 3: Profile setup ────────────────────────────────────────────────

  Widget _profileStep(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ─────────────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tell us about yourself.',
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('This personalizes your workspace from day one.',
                style: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
        // ── Name field ─────────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your name',
                style: tt.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            TextField(
              // Uses the stable controller initialised in initState — no new
              // controller is created on rebuild (perf-audit HIGH-5 fix).
              controller: _nameCtrl,
              onChanged: (v) => _fullName = v,
              maxLines: 1,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: scheme.surfaceContainerLowest,
                hintText: 'Full name',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDesignTokens.radius.sm),
                  borderSide: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.48)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDesignTokens.radius.sm),
                  borderSide: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.48)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDesignTokens.radius.sm),
                  borderSide: BorderSide(
                      color: scheme.primary.withValues(alpha: 0.38)),
                ),
              ),
            ),
          ],
        ),
        // ── Goal cards ─────────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your primary focus',
                style: tt.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            for (final goal in OnboardingGoal.values) ...[
              _goalCard(context, goal),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ),
      ],
    );
  }

  Widget _goalCard(BuildContext context, OnboardingGoal goal) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _goal == goal;
    final goalIcon = switch (goal) {
      OnboardingGoal.productivity => Icons.rocket_launch_outlined,
      OnboardingGoal.finance => Icons.pie_chart_outline_outlined,
      OnboardingGoal.balanced => Icons.tune,
    };

    return GestureDetector(
      onTap: () => setState(() {
        _goal = goal;
        _error = null;
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
          border: Border.all(
            width: selected ? 1.5 : 0.5,
            color: selected
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.35),
          ),
          color: selected
              ? scheme.primary.withValues(alpha: 0.07)
              : scheme.surfaceContainerLow,
        ),
        child: Row(
          children: [
            Icon(goalIcon, size: 24, color: scheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(goal.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(goal.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_outline, size: 24, color: scheme.primary),
          ],
        ),
      ),
    );
  }

  // ── Step 4: Background permission ────────────────────────────────────────

  Widget _backgroundStep(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final exempt = _batteryExempt ?? false; // platform check lands w/ channels
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ─────────────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Keep running in the background',
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
                'Without this, Android may pause the app — stopping timers, delaying reminders, and missing M-Pesa messages.',
                style: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
        // ── Benefits ────────────────────────────────────────────────────
        Column(
          children: [
            _pillarCard(context, Icons.sync_outlined, 'Real-time SMS sync',
                'Catch incoming M-Pesa messages the moment they arrive.'),
            _pillarCard(context, Icons.speed_outlined, 'Uninterrupted timers',
                'Task timers keep ticking even when you switch apps.'),
            _pillarCard(context, Icons.shield_outlined, 'Reliable reminders',
                'Notifications fire on time regardless of battery mode.'),
          ],
        ),
        // ── Action ──────────────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (exempt)
              Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 20, color: scheme.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Background activity allowed',
                      style: tt.bodyMedium?.copyWith(
                          color: scheme.primary, fontWeight: FontWeight.w600)),
                ],
              )
            else ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDesignTokens.radius.sm)),
                  ),
                  onPressed: () async {
                    final granted =
                        await SystemPlatformBridge.requestBatteryOptimization();
                    if (mounted) setState(() => _batteryExempt = granted);
                  },
                  child: const Text('Allow Background Activity'),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => setState(() => _batteryExempt = false),
                child: Text('Skip for now',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── Step 5: All set ──────────────────────────────────────────────────────

  Widget _finalStep(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Celebration header ──────────────────────────────────────────
        Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.check_circle_outline,
                  size: 48, color: scheme.primary),
            ),
            const SizedBox(height: 20),
            Text("You're all set.",
                textAlign: TextAlign.center,
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Welcome to your new digital sanctuary.',
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
        // ── Summary cards ────────────────────────────────────────────────
        Column(
          children: [
            _pillarCard(context, Icons.auto_awesome_outlined, 'Personalized Insights',
                'Actionable summaries tuned to your real usage.'),
            _pillarCard(context, Icons.speed_outlined, 'Unified Workflow',
                'Tasks, calendar, and finance in a single rhythm.'),
            _pillarCard(context, Icons.shield_outlined, 'Private & Secure',
                'Your data stays controlled, with transparent protection.'),
          ],
        ),
      ],
    );
  }
}
