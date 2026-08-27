/// 1:1 port of LifeOSNavHost.kt navigation graph + AppNavigationGuards.kt.
///
/// Motion contract (mirrors NavTransition config):
///  • Primary-tab swaps (Home/Finance/Calendar/AI/Profile): quick crossfade —
///    160ms in, 120ms out (FastOutSlowIn / FastOutLinear).
///  • Hierarchical push/pop: fade 220ms + horizontal slide of width/6 forward,
///    reverse on pop with /12 and /6 offsets.
///
/// Guard contract (resolveGuardNavigationTarget):
///  • !onboardingCompleted && not on auth/onboarding → Onboarding
///  • onboardingCompleted && current == Onboarding → Home
///  • isLoggedIn && current == Auth → Home
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/designsystem/floating_pill_nav_bar.dart';
import '../core/designsystem/tokens.dart' show AppDesignTokens;
import '../core/permissions/permissions_orchestrator.dart';
import '../core/security/biometric_lock.dart';
import '../core/security/session_store.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/auth/presentation/onboarding_screen.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/assistant/presentation/assistant_screen.dart';
import '../features/finance/presentation/finance_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/finance/presentation/loans_screen.dart';
import '../features/finance/presentation/monthly_wrapped_screen.dart';
import '../features/finance/presentation/merchant_detail_screen.dart';
import '../features/misc_screens.dart';
import '../features/planner/presentation/planner_screens.dart';
import '../features/planner/presentation/planner_screens2.dart';
import '../features/planner/presentation/goals_screen.dart';
import '../features/profile/presentation/profile_sub_screens.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import '../features/calendar/presentation/events_screen.dart';
import '../ui/splash/splash_screen.dart';
import 'routes.dart';

// ── Guard logic (AppNavigationGuards.kt verbatim) ──────────────────────────

bool isPublicRoute(String? route) =>
    route == '/${AppRoute.auth}' || route == '/${AppRoute.onboarding}';

String? resolveGuardNavigationTarget({
  required bool isLoggedIn,
  required bool onboardingCompleted,
  String? currentRoute,
}) {
  final shouldRouteToOnboarding = !onboardingCompleted;
  if (shouldRouteToOnboarding &&
      currentRoute != '/${AppRoute.onboarding}' &&
      currentRoute != '/${AppRoute.auth}') {
    return '/${AppRoute.onboarding}';
  }
  if (!shouldRouteToOnboarding &&
      currentRoute == '/${AppRoute.onboarding}') {
    return '/${AppRoute.home}';
  }
  if (isLoggedIn && currentRoute == '/${AppRoute.auth}') {
    return '/${AppRoute.home}';
  }
  return null;
}

final Set<String> _primaryTabRoutes =
    primaryTabs.map((t) => '/${t.route}').toSet();

bool isPrimaryTabSwap(String? fromRoute, String? toRoute) =>
    _isTabSwap(fromRoute, toRoute);

bool _isTabSwap(String? from, String? to) {
  if (from == null || to == null) return false;
  return _primaryTabRoutes.contains(from.split('?').first) &&
      _primaryTabRoutes.contains(to.split('?').first);
}

bool isPrimaryTabRoute(String? route) {
  if (route == null) return false;
  return _primaryTabRoutes.contains(route.split('?').first);
}

const Set<String> kSensitiveRoutes = {
  AppRoute.finance,
  AppRoute.planner,
  AppRoute.budget,
  AppRoute.income,
  AppRoute.recurring,
  AppRoute.loans,
  AppRoute.categorize,
  AppRoute.feeAnalytics,
  AppRoute.review,
  AppRoute.export,
  AppRoute.search,
  AppRoute.profile,
  AppRoute.assistant,
};

// ── Router ─────────────────────────────────────────────────────────────────

GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Notifies go_router whenever the session state changes so guards re-run
/// (login/logout/onboarding complete) — mirrors Kotlin's startDestination
/// recomposition after AppBootstrapViewModel resolves.
class _SessionRefreshListenable extends ChangeNotifier {
  _SessionRefreshListenable(ProviderContainer container) {
    sessionChanges.addListener(notifyListeners);
    // Re-run router guards when the async sessionStore resolves (SharedPrefs
    // ready).  Without this the router's storeReady gate never fires after the
    // initial null check and the app stays on the splash screen forever.
    container.listen(sessionStoreProvider, (_, __) => notifyListeners());
  }
}

GoRouter buildAppRouter(ProviderContainer container) {
  final refresh = _SessionRefreshListenable(container);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      // Bootstrap gate: hold at splash until prefs resolve.
      final storeReady =
          container.read(sessionStoreProvider).value != null;
      if (!storeReady) return null;

      final session = container.read(sessionProvider);
      final path = state.uri.path;

      // Start-destination resolution (AppBootstrapCoordinator parity):
      // onboarding → auth → home.
      if (path == '/') {
        if (!session.onboardingCompleted) return '/${AppRoute.onboarding}';
        if (!session.isLoggedIn) return '/${AppRoute.auth}';
        return '/${AppRoute.home}';
      }
      return resolveGuardNavigationTarget(
        isLoggedIn: session.isLoggedIn,
        onboardingCompleted: session.onboardingCompleted,
        currentRoute: path,
      );
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PersonalOsSplashScreen(),
      ),
      GoRoute(
        path: '/${AppRoute.onboarding}',
        pageBuilder: (context, state) => _fadePage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: '/${AppRoute.auth}',
        pageBuilder: (context, state) => _fadePage(state, const AuthScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(currentPath: state.uri.toString(), child: child),
        routes: [
          GoRoute(
            path: '/${AppRoute.home}',
            pageBuilder: (context, state) => _tabPage(state, const HomeScreen()),
          ),
          GoRoute(
            path: '/${AppRoute.finance}',
            pageBuilder: (context, state) {
              final txIdStr = state.uri.queryParameters['transactionId'];
              final txId = int.tryParse(txIdStr ?? '');
              return _tabPage(
                  state,
                  FinanceScreen(
                    initialTransactionId: txId,
                    onOpenHub: () => context.push('/${AppRoute.planner}'),
                    onExportPdf: () => context.push('/${AppRoute.export}'),
                  ));
            },
          ),
          GoRoute(
            path: '/${AppRoute.calendar}',
            pageBuilder: (context, state) {
              final eventIdStr = state.uri.queryParameters['eventId'];
              final eventDateStr = state.uri.queryParameters['eventDate'];
              return _tabPage(
                  state,
                  CalendarScreen(
                    initialEventId: int.tryParse(eventIdStr ?? ''),
                    initialEventDate: int.tryParse(eventDateStr ?? ''),
                  ));
            },
          ),
          GoRoute(
            path: '/${AppRoute.assistant}',
            pageBuilder: (context, state) => _tabPage(state, const AssistantScreen()),
          ),
          GoRoute(
            path: '/${AppRoute.profile}',
            pageBuilder: (context, state) => _tabPage(state, const ProfileScreen()),
          ),
          // Secondary routes — pushed above the current tab but INSIDE the shell,
          // so the floating pill bar stays visible (LifeOSNavHost parity: the bar
          // is hidden only on public flow, when locked, or when the IME is open).
          ...secondaryRoutes(),
        ],
      ),
    ],
  );
}

List<GoRoute> secondaryRoutes() {
  return [
    GoRoute(
      path: '/${AppRoute.tasks}',
      pageBuilder: (c, s) => _pushPage(
          s,
          TasksScreen(
            initialTaskId: int.tryParse(s.uri.queryParameters['itemId'] ?? ''),
          )),
    ),
    GoRoute(path: '/${AppRoute.settings}', pageBuilder: (c, s) => _pushPage(s, const SettingsScreen())),
    GoRoute(path: '/${AppRoute.export}', pageBuilder: (c, s) => _pushPage(s, const ExportScreen())),
    GoRoute(path: '/${AppRoute.insights}', pageBuilder: (c, s) => _pushPage(s, const InsightsScreen())),
    GoRoute(path: '/${AppRoute.search}', pageBuilder: (c, s) => _pushPage(s, const SearchScreen())),
    GoRoute(path: '/${AppRoute.planner}', pageBuilder: (c, s) => _pushPage(s, const PlannerScreen())),
    GoRoute(path: '/${AppRoute.review}', pageBuilder: (c, s) => _pushPage(s, const ReviewScreen())),
    GoRoute(path: '/${AppRoute.events}', pageBuilder: (c, s) => _pushPage(s, const EventsScreen())),
    GoRoute(path: '/${AppRoute.budget}', pageBuilder: (c, s) => _pushPage(s, const BudgetScreen())),
    GoRoute(path: '/${AppRoute.income}', pageBuilder: (c, s) => _pushPage(s, const IncomeScreen())),
    GoRoute(path: '/${AppRoute.recurring}', pageBuilder: (c, s) => _pushPage(s, const RecurringScreen())),
    GoRoute(path: '/${AppRoute.loans}', pageBuilder: (c, s) => _pushPage(s, const LoansScreen())),
    GoRoute(path: '/${AppRoute.bills}', pageBuilder: (c, s) => _pushPage(s, const BillsScreen())),
    GoRoute(path: '/${AppRoute.categorize}', pageBuilder: (c, s) => _pushPage(s, const CategorizePage())),
    GoRoute(path: '/${AppRoute.feeAnalytics}', pageBuilder: (c, s) => _pushPage(s, const FeeAnalyticsPage())),
    GoRoute(
        path: '/${AppRoute.statementExport}',
        pageBuilder: (c, s) => _pushPage(s, const ExportScreen(openPdfSheet: true))),
    GoRoute(path: '/${AppRoute.learning}', pageBuilder: (c, s) => _pushPage(s, const LearningPage())),
    GoRoute(path: '/${AppRoute.goals}', pageBuilder: (c, s) => _pushPage(s, const GoalsScreen())),
    GoRoute(path: '/${AppRoute.changelog}', pageBuilder: (c, s) => _pushPage(s, const ChangelogPage())),
    GoRoute(path: '/${AppRoute.smsImportHealth}', pageBuilder: (c, s) => _pushPage(s, const SmsImportHealthPage())),
    GoRoute(path: '/${AppRoute.reviewQueue}', pageBuilder: (c, s) => _pushPage(s, const ReviewQueuePage())),
    GoRoute(path: '/${AppRoute.smsQuarantine}', pageBuilder: (c, s) => _pushPage(s, const QuarantinePage())),
    GoRoute(path: '/${AppRoute.paybillRegistry}', pageBuilder: (c, s) => _pushPage(s, const PaybillRegistryPage())),
    GoRoute(path: '/${AppRoute.screenLock}', pageBuilder: (c, s) => _pushPage(s, const ScreenLockSettingsPage())),
    GoRoute(path: '/${AppRoute.notificationSettings}', pageBuilder: (c, s) => _pushPage(s, const NotificationSettingsPage())),
    GoRoute(path: '/${AppRoute.profileInfo}', pageBuilder: (c, s) => _pushPage(s, const ProfileInfoScreen())),
    GoRoute(path: '/${AppRoute.profileSecurity}', pageBuilder: (c, s) => _pushPage(s, const ProfileSecurityScreen())),
    GoRoute(path: '/${AppRoute.profilePreferences}', pageBuilder: (c, s) => _pushPage(s, const ProfilePreferencesScreen())),
    GoRoute(
      path: '/${AppRoute.merchantDetail}/:merchant',
      pageBuilder: (c, s) => _pushPage(s, MerchantDetailScreen(merchant: Uri.decodeComponent(s.pathParameters['merchant'] ?? ''))),
    ),
    GoRoute(
      path: '/${AppRoute.monthlyWrapped}/:year/:month',
      pageBuilder: (c, s) => _pushPage(s, MonthlyWrappedScreen(
        year: int.tryParse(s.pathParameters['year'] ?? ''),
        month: int.tryParse(s.pathParameters['month'] ?? ''),
      )),
    ),
    GoRoute(
      path: '/${AppRoute.monthlyWrapped}',
      pageBuilder: (c, s) => _pushPage(s, const MonthlyWrappedScreen()),
    ),
  ];
}

// ── Transition pages ────────────────────────────────────────────────────────

CustomTransitionPage<T> _page<T>({
  required Object? key,
  required Widget child,
  required bool fadeOnly,
  bool reverseSlide = false,
}) {
  return CustomTransitionPage<T>(
    key: ValueKey(key),
    child: child,
    transitionDuration: Duration(milliseconds: fadeOnly ? 160 : 220),
    reverseTransitionDuration: Duration(milliseconds: fadeOnly ? 120 : 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final inCurve = CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn);
      // outCurve unused — secondary animation handled implicitly by FadeTransition
      if (fadeOnly) {
        return FadeTransition(opacity: inCurve, child: child);
      }
      final size = MediaQuery.sizeOf(context).width;
      return FadeTransition(
        opacity: inCurve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(reverseSlide ? -size / 6 : size / 6, 0) * (1 / size),
            end: Offset.zero,
          ).animate(inCurve),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<void> _tabPage(GoRouterState state, Widget child) =>
    _page(key: state.uri.path, child: child, fadeOnly: true);

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) =>
    _page(key: state.uri.path, child: child, fadeOnly: true);

CustomTransitionPage<void> _pushPage(GoRouterState state, Widget child) =>
    _page(key: state.uri.toString(), child: child, fadeOnly: false);


// ── Main shell: content + floating pill bottom bar ────────────────────────
// Bottom bar hidden when IME open or when not on a primary tab (parity).

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.currentPath, required this.child});

  final String currentPath;
  final Widget child;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _imeVisible = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final activeRoute = widget.currentPath.split('?').first;
    // Kotlin parity (LifeOSNavHost.kt:234-238): the bar is hidden only on the
    // public flow (auth/onboarding), while locked, or when the IME is open —
    // it stays visible on pushed secondary pages too.
    final isPublic = isPublicRoute(activeRoute);
    final showBottomBar = !_imeVisible && !isPublic && session.isLoggedIn;

    return BiometricLockCoordinator(
      enabled: session.isLoggedIn && session.biometricEnabled,
      onDisable: () => ref.read(sessionProvider.notifier).setBiometricEnabled(false),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        // Kotlin parity: the floating pill bar OVERLAYS content inside a Box;
        // screens reserve room via BottomSafeWithFloatingNav content padding,
        // so lists scroll visually beneath the bar.
        body: Stack(
          children: [
            NotificationListener<LayoutChangedNotification>(
              onNotification: (_) {
                final insets = MediaQuery.viewInsetsOf(context);
                final ime = insets.bottom > 0;
                if (ime != _imeVisible) setState(() => _imeVisible = ime);
                return false;
              },
              child: widget.child,
            ),
            // Contextual permission cards (AppPermissionsOrchestrator parity) —
            // Home → notification permission, Finance → SMS permission, once each.
            Align(
              alignment: Alignment.bottomCenter,
              child: AppPermissionsOrchestrator(
                currentPath: widget.currentPath,
                bottomOffset:
                    showBottomBar ? AppDesignTokens.floatingNavBarHeight + 12 : 0,
              ),
            ),
            if (showBottomBar)
              Align(
                alignment: Alignment.bottomCenter,
                child: LifeOsBottomBar(
                  currentRoute: activeRoute.replaceFirst('/', ''),
                  onTabSelected: (route) => context.go('/$route'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


