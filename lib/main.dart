import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:workmanager/workmanager.dart';

import 'core/notifications/notification_service.dart';
import 'core/platform/sms_bridge.dart';
import 'features/sms/background/sms_background_worker.dart';
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

  // WorkManager — wire background SMS drain (MpesaSmsIngestionWorker parity).
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    kSmsPeriodicUniqueId,
    kSmsPeriodicSync,
    frequency: const Duration(minutes: 30),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    constraints: Constraints(networkType: NetworkType.notRequired),
  );

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
      child: _App(router: router, container: container),
    ),
  );
}

class _App extends StatefulWidget {
  const _App({required this.router, required this.container});

  final GoRouter router;
  final ProviderContainer container;

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> with WidgetsBindingObserver {
  bool _draining = false;
  bool _drainPending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SmsPlatformBridge.setNativeCallHandler(_drainRealtimeQueue);
    WidgetsBinding.instance.addPostFrameCallback((_) => _drainRealtimeQueue());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _drainRealtimeQueue();
    }
  }

  Future<void> _drainRealtimeQueue() async {
    if (_draining) {
      _drainPending = true;
      return;
    }
    _draining = true;
    try {
      await drainRealtimeAndIngest(widget.container);
    } catch (_) {
      // Never crash on drain failure — queue persists for retry.
    } finally {
      _draining = false;
      if (_drainPending) {
        _drainPending = false;
        unawaited(_drainRealtimeQueue());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) =>
          buildLifeOsApp(themeMode: mode, routerConfig: widget.router),
    );
  }
}
