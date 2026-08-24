import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import 'core/notifications/notification_service.dart';
import 'navigation/app_router.dart';
import 'ui/theme/theme.dart';
import 'core/security/session_store.dart';

/// Global reactive theme controller — Kotlin ThemePreferences.themeModeFlow()
/// parity (Settings changes apply immediately without restart).
final ValueNotifier<AppThemeMode> themeController =
    ValueNotifier<AppThemeMode>(AppThemeMode.system);

/// Global haptics flag — gating platform HapticFeedback calls on the
/// "Haptic feedback" toggle in Settings (haptics_enabled pref).
/// Default true so haptics work before Settings is first loaded.
final ValueNotifier<bool> hapticsController = ValueNotifier<bool>(true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialise notifications early so channels exist before any scheduling.
  await NotificationService.init();
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPrefsProvider.overrideWith((ref) async => prefs),
    ],
  );
  final router = buildAppRouter(container);
  themeController.value = switch (prefs.getString('theme_mode')) {
    'LIGHT' => AppThemeMode.light,
    'DARK' => AppThemeMode.dark,
    _ => AppThemeMode.system,
  };
  hapticsController.value = prefs.getBool('haptics_enabled') ?? true;
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: _App(router: router),
    ),
  );
}

class _App extends StatelessWidget {
  const _App({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) =>
          buildLifeOsApp(themeMode: mode, routerConfig: router),
    );
  }
}
