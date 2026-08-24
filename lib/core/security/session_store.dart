/// Session store — port of AuthSessionStore.kt + bootstrap state flags
/// (onboardingCompleted, biometricEnabled) backed by SharedPreferences.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ui/theme/theme.dart';

class AppSessionState {
  const AppSessionState({
    required this.isLoggedIn,
    required this.onboardingCompleted,
    required this.biometricEnabled,
    required this.userId,
    this.themeMode,
  });

  final bool isLoggedIn;
  final bool onboardingCompleted;
  final bool biometricEnabled;
  final String userId;
  final AppThemeMode? themeMode;

  AppSessionState copyWith({
    bool? isLoggedIn,
    bool? onboardingCompleted,
    bool? biometricEnabled,
    String? userId,
    AppThemeMode? themeMode,
    bool clearThemeMode = false,
  }) =>
      AppSessionState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        userId: userId ?? this.userId,
        themeMode:
            clearThemeMode ? null : (themeMode ?? this.themeMode),
      );

  static const initial = AppSessionState(
    isLoggedIn: false,
    onboardingCompleted: false,
    biometricEnabled: false,
    userId: '',
  );
}

class SessionStore {
  SessionStore(this._prefs);

  final SharedPreferences _prefs;

  static const _kLoggedIn = 'auth_logged_in';
  static const _kOnboarded = 'onboarding_completed';
  static const _kBiometrics = 'biometric_enabled';
  static const _kUserId = 'auth_user_id';
  static const _kThemeMode = 'theme_mode';

  AppSessionState load() => AppSessionState(
        isLoggedIn: _prefs.getBool(_kLoggedIn) ?? false,
        onboardingCompleted: _prefs.getBool(_kOnboarded) ?? false,
        biometricEnabled: _prefs.getBool(_kBiometrics) ?? false,
        userId: _prefs.getString(_kUserId) ?? '',
        themeMode: switch (_prefs.getString(_kThemeMode)) {
          'LIGHT' => AppThemeMode.light,
          'DARK' => AppThemeMode.dark,
          'SYSTEM' => AppThemeMode.system,
          _ => null,
        },
      );

  Future<void> setLoggedIn(bool v, {String? userId}) async {
    await _prefs.setBool(_kLoggedIn, v);
    if (userId != null) await _prefs.setString(_kUserId, userId);
  }

  Future<void> setOnboardingCompleted(bool v) =>
      _prefs.setBool(_kOnboarded, v);

  Future<void> setBiometricEnabled(bool v) => _prefs.setBool(_kBiometrics, v);

  Future<void> setThemeMode(AppThemeMode mode) =>
      _prefs.setString(_kThemeMode, mode.name.toUpperCase());
}

final sharedPrefsProvider = FutureProvider<SharedPreferences>(
    (ref) => SharedPreferences.getInstance());

final sessionStoreProvider = FutureProvider<SessionStore>((ref) async =>
    SessionStore(await ref.watch(sharedPrefsProvider.future)));

/// Reactive session snapshot consumed by router guards and UI.
class SessionNotifier extends Notifier<AppSessionState> {
  @override
  AppSessionState build() {
    final store = ref.watch(sessionStoreProvider).value;
    return store?.load() ?? AppSessionState.initial;
  }

  void refresh() {
    final store = ref.read(sessionStoreProvider).value;
    if (store != null) {
      state = store.load();
      _notifySessionChanged();
    }
  }

  Future<void> login(String userId) async {
    final store = ref.read(sessionStoreProvider).value;
    if (store == null) return;
    await store.setLoggedIn(true, userId: userId);
    state = store.load();
    _notifySessionChanged();
  }

  Future<void> completeOnboarding() async {
    final store = ref.read(sessionStoreProvider).value;
    if (store == null) return;
    await store.setOnboardingCompleted(true);
    state = store.load();
    _notifySessionChanged();
  }

  Future<void> setBiometricEnabled(bool v) async {
    final store = ref.read(sessionStoreProvider).value;
    if (store == null) return;
    await store.setBiometricEnabled(v);
    state = store.load();
    _notifySessionChanged();
  }
}

final sessionProvider =
    NotifierProvider<SessionNotifier, AppSessionState>(SessionNotifier.new);

/// Global change signal consumed by go_router.refreshListenable so guards
/// re-run on login/logout/onboarding changes.
final ChangeNotifier sessionChanges = ChangeNotifier();

void _notifySessionChanged() => sessionChanges.notifyListeners();
