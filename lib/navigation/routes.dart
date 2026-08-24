/// 1:1 port of navigation/Screen.kt — route constants, primary tabs,
/// deep-link helpers.
library;

import 'package:flutter/material.dart';

abstract final class AppRoute {
  static const auth = 'auth';
  static const onboarding = 'onboarding';
  static const home = 'home';
  static const tasks = 'tasks';
  static const finance = 'finance';
  static const calendar = 'calendar';
  static const assistant = 'assistant';

  static const profile = 'profile';
  static const settings = 'settings';
  static const export = 'export';
  static const insights = 'insights';
  static const search = 'search';
  static const planner = 'planner';
  static const review = 'review';
  static const events = 'events';

  // Finance sub-screens
  static const budget = 'budget';
  static const income = 'income';
  static const recurring = 'recurring';
  static const loans = 'loans';
  static const bills = 'bills';

  // Finance utility screens
  static const categorize = 'categorize';
  static const feeAnalytics = 'fee_analytics';
  static const merchantDetail = 'merchant_detail';
  static const statementExport = 'statement_export';

  // Learning module
  static const learning = 'learning';

  // Goals module
  static const goals = 'goals';

  // Changelog
  static const changelog = 'changelog';

  // SMS diagnostics
  static const smsImportHealth = 'sms_import_health';
  static const reviewQueue = 'review_queue';
  static const smsQuarantine = 'sms_quarantine';
  static const paybillRegistry = 'paybill_registry';

  // Monthly Wrapped
  static const monthlyWrapped = 'monthly_wrapped';

  // Settings sub-pages
  static const screenLock = 'screen_lock';
  static const notificationSettings = 'notification_settings';

  // Profile sub-screens
  static const profileInfo = 'profile_info';
  static const profileSecurity = 'profile_security';
  static const profilePreferences = 'profile_preferences';

  // ── Deep-link helpers ────────────────────────────────────────────────────
  static String tasksWithItem(int taskId) => '$tasks?itemId=$taskId';
  static String calendarWithEvent(int eventId, int eventDate) =>
      '$calendar?eventId=$eventId&eventDate=$eventDate';
  static String financeWithTransaction(int transactionId) =>
      '$finance?transactionId=$transactionId';
  static String monthlyWrappedRoute(int year, int month) =>
      '$monthlyWrapped/$year/$month';

  /// Percent-encode like Kotlin's manual encoder (letters/digits/-_.~ kept).
  static String merchantDetailRoute(String merchant) {
    final sb = StringBuffer();
    for (final code in merchant.codeUnits) {
      final c = String.fromCharCode(code);
      final keep = RegExp(r'[A-Za-z0-9\-_.~]').hasMatch(c);
      if (keep) {
        sb.write(c);
      } else {
        for (final byte in c.codeUnits) {
          sb
            ..write('%')
            ..write(byte.toRadixString(16).toUpperCase().padLeft(2, '0'));
        }
      }
    }
    return '$merchantDetail/$sb';
  }
}

class AppPrimaryTab {
  const AppPrimaryTab({
    required this.route,
    required this.label,
    required this.selectedIcon,
    required this.unselectedIcon,
    this.routeAliases = const {},
  });

  final String route;
  final String label;
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final Set<String> routeAliases;
}

const List<AppPrimaryTab> primaryTabs = [
  AppPrimaryTab(
    route: AppRoute.home,
    label: 'Home',
    selectedIcon: Icons.home,
    unselectedIcon: Icons.home_outlined,
    routeAliases: {AppRoute.home},
  ),
  AppPrimaryTab(
    route: AppRoute.finance,
    label: 'Finance',
    selectedIcon: Icons.payments,
    unselectedIcon: Icons.payments_outlined,
    routeAliases: {AppRoute.finance},
  ),
  AppPrimaryTab(
    route: AppRoute.calendar,
    label: 'Calendar',
    selectedIcon: Icons.calendar_month,
    unselectedIcon: Icons.calendar_month_outlined,
    routeAliases: {AppRoute.calendar},
  ),
  AppPrimaryTab(
    route: AppRoute.assistant,
    label: 'AI',
    selectedIcon: Icons.smart_toy,
    unselectedIcon: Icons.smart_toy_outlined,
    routeAliases: {AppRoute.assistant},
  ),
  AppPrimaryTab(
    route: AppRoute.profile,
    label: 'Profile',
    selectedIcon: Icons.person,
    unselectedIcon: Icons.person_outlined,
    routeAliases: {AppRoute.profile},
  ),
];

bool isPrimaryTabSelected(AppPrimaryTab tab, Set<String> activeRoutes) {
  if (activeRoutes.contains(tab.route)) return true;
  return activeRoutes.any(tab.routeAliases.contains);
}
