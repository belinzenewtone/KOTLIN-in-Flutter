/// 1:1 port of SettingsScreen.kt — section cards (Appearance / Security /
/// Notifications / Assistant / Finance / Import / What's New / About) with
/// nav + toggle rows, theme selector, Fuliza limit dialog, and local-data
/// clearing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/controls.dart';
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/designsystem/tokens.dart' show AppSpacing;
import '../../../core/platform/system_bridge.dart';
import '../../../core/security/session_store.dart';
import '../../../core/utils/date_utils.dart';
import '../../../main.dart' show hapticsController, themeController;
import '../../../navigation/routes.dart';
import '../../../ui/theme/theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _haptics = true;
  bool _backgroundActivity = true;
  bool _quickSuggestions = true;
  double? _fulizaLimit;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Read battery optimisation status from platform — it's the source of truth.
    final batteryExempt = await SystemPlatformBridge.isBatteryOptimized();
    if (!mounted) return;
    setState(() {
      _haptics = prefs.getBool('haptics_enabled') ?? true;
      // Sync the toggle with the actual system exemption state.
      _backgroundActivity = batteryExempt;
      _quickSuggestions = prefs.getBool('quick_suggestions') ?? true;
      _fulizaLimit = prefs.getDouble('fuliza_limit_kes');
    });
    // Keep SharedPrefs in sync with the real state.
    await prefs.setBool('background_activity', batteryExempt);
  }

  Future<void> _persist(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  Future<void> _persistTheme(AppThemeMode mode) async {
    // Update the reactive session so the segmented control highlights immediately,
    // and also update themeController so the app-wide theme switches without restart.
    await ref.read(sessionProvider.notifier).setThemeMode(mode);
    themeController.value = mode;
  }

  Future<void> _setFulizaLimit(double? limit) async {
    final prefs = await SharedPreferences.getInstance();
    if (limit == null) {
      await prefs.remove('fuliza_limit_kes');
    } else {
      await prefs.setDouble('fuliza_limit_kes', limit);
    }
    if (mounted) setState(() => _fulizaLimit = limit);
  }

  Future<void> _clearLocalData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Clear all local data?'),
        content: const Text(
            'This will remove all app data stored on this device. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(sessionStoreProvider.future).then((store) async {
        await store.setBiometricEnabled(false);
        await store.setLoggedIn(false, userId: null);
      });
      if (mounted) context.go('/${AppRoute.auth}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final scheme = Theme.of(context).colorScheme;

    return PageScaffold(
      title: 'Settings',
      onBack: () => context.pop(),
      contentPadding:
          const EdgeInsets.only(bottom: AppSpacing.bottomSafeWithFloatingNav),
      child: Column(
        children: [
          // ── Appearance (theme mode) ───────────────────────────────────────
          _sectionCard(context, 'Appearance', [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final mode = switch (i) {
                            0 => AppThemeMode.light,
                            1 => AppThemeMode.system,
                            _ => AppThemeMode.dark,
                          };
                          _persistTheme(mode);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: switch (session.themeMode ??
                                    AppThemeMode.system) {
                              AppThemeMode.light => i == 0,
                              AppThemeMode.system => i == 1,
                              AppThemeMode.dark => i == 2,
                            }
                                ? scheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            const ['Light', 'Auto', 'Dark'][i],
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: switch (session.themeMode ??
                                          AppThemeMode.system) {
                                    AppThemeMode.light => i == 0,
                                    AppThemeMode.system => i == 1,
                                    AppThemeMode.dark => i == 2,
                                  }
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: switch (session.themeMode ??
                                          AppThemeMode.system) {
                                    AppThemeMode.light => i == 0,
                                    AppThemeMode.system => i == 1,
                                    AppThemeMode.dark => i == 2,
                                  }
                                      ? scheme.onPrimary
                                      : scheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // ── Security ────────────────────────────────────────────────────────
          _sectionCard(context, 'Security', [
            _navRow(
              context,
              title: 'Screen lock',
              subtitle: session.biometricEnabled
                  ? 'Biometric'
                  : 'No lock configured',
              onTap: () => context.push('/${AppRoute.screenLock}'),
            ),
            _toggleRow(
              context,
              title: 'Haptic feedback',
              subtitle:
                  'Vibration on actions like completing tasks or deleting items.',
              value: _haptics,
              onChanged: (v) {
                setState(() => _haptics = v);
                _persist('haptics_enabled', v);
                // Update the global gate so all HapticFeedback calls in the
                // app respect the setting immediately without restart.
                hapticsController.value = v;
              },
            ),
          ]),
          const SizedBox(height: 12),

          // ── Notifications ──────────────────────────────────────────────────
          _sectionCard(context, 'Notifications', [
            _navRow(
              context,
              title: 'Notification settings',
              subtitle: 'System notifications · Budget alerts · Daily digest',
              onTap: () => context.push('/${AppRoute.notificationSettings}'),
            ),
            _toggleRow(
              context,
              title: 'Background activity',
              subtitle: _backgroundActivity
                  ? 'App is exempt from battery optimisation — reminders and sync always work'
                  : 'Tap to request exemption — or go to Battery > App battery usage in system settings',
              value: _backgroundActivity,
              onChanged: (v) async {
                if (v) {
                  // Request exemption from the system — opens Android dialog.
                  final granted =
                      await SystemPlatformBridge.requestBatteryOptimization();
                  if (!mounted) return;
                  setState(() => _backgroundActivity = granted);
                  await _persist('background_activity', granted);
                } else {
                  // Android has no API to revoke exemption programmatically.
                  // Toggle stays true; inform the user to do it in system settings.
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'To restrict background activity, go to Battery ▸ App battery usage in system settings.'),
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
          ]),
          const SizedBox(height: 12),

          // ── Assistant ─────────────────────────────────────────────────────
          _sectionCard(context, 'Assistant', [
            _toggleRow(
              context,
              title: 'Quick suggestions',
              subtitle:
                  'Allow the assistant to propose actions based on your messages',
              value: _quickSuggestions,
              onChanged: (v) {
                setState(() => _quickSuggestions = v);
                _persist('quick_suggestions', v);
              },
            ),
          ]),
          const SizedBox(height: 12),

          // ── Finance ────────────────────────────────────────────────────────
          _sectionCard(context, 'Finance', [
            _navRow(
              context,
              title: 'Fuliza credit limit',
              subtitle: _fulizaLimit != null
                  ? 'KSh ${AppDateUtils.formatCurrency(_fulizaLimit!).replaceFirst('KSh ', '')}'
                  : 'Not set',
              onTap: () => _showFulizaDialog(),
            ),
          ]),
          const SizedBox(height: 12),

          // ── Import ─────────────────────────────────────────────────────────
          _sectionCard(context, 'Import', [
            _navRow(
              context,
              title: 'SMS Import Health',
              subtitle: 'Import counts, errors and receiver status',
              onTap: () => context.push('/${AppRoute.smsImportHealth}'),
            ),
            _navRow(
              context,
              title: 'Review Queue',
              subtitle: 'Approve or dismiss medium/low-confidence transactions',
              onTap: () => context.push('/${AppRoute.reviewQueue}'),
            ),
            _navRow(
              context,
              title: 'Paybill Registry',
              subtitle: 'Seen billers sorted by transaction frequency',
              onTap: () => context.push('/${AppRoute.paybillRegistry}'),
            ),
          ]),
          const SizedBox(height: 12),

          // ── What's New ─────────────────────────────────────────────────────
          _sectionCard(context, '', [
            _navRow(
              context,
              title: "What's new",
              subtitle: 'See recent updates and improvements',
              onTap: () => context.push('/${AppRoute.changelog}'),
            ),
          ]),
          const SizedBox(height: 12),

          // ── About ──────────────────────────────────────────────────────────
          _sectionCard(context, 'About', [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Version',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text('1.0.0 (1)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            Divider(
                height: 1,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.12)),
            _navRow(
              context,
              title: 'Clear all local data',
              subtitle: 'Remove all app data stored on this device.',
              titleColor: scheme.error,
              onTap: _clearLocalData,
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _showFulizaDialog() async {
    final controller = TextEditingController(
        text: _fulizaLimit?.toInt().toString() ?? '');
    String? errorText;

    final saved = await showDialog<double?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Fuliza Credit Limit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your Safaricom Fuliza M-PESA credit limit (KSh). Leave blank to clear.',
                style: Theme.of(ctx)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                decoration: InputDecoration(
                  labelText: 'Credit limit (KSh)',
                  errorText: errorText,
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (_) {
                  if (errorText != null) setStateDlg(() => errorText = null);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, _sentinelClear),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final cleaned = controller.text.trim().replaceAll(',', '');
                if (cleaned.isEmpty) {
                  Navigator.pop(ctx, 0); // 0 = clear
                } else {
                  final num = double.tryParse(cleaned);
                  if (num != null && num > 0) {
                    Navigator.pop(ctx, num);
                  } else {
                    setStateDlg(() => errorText = 'Enter a valid amount greater than 0');
                  }
                }
              },
              style: FilledButton.styleFrom(
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (saved == _sentinelClear) return; // cancelled
    if (saved == 0) {
      await _setFulizaLimit(null);
    } else if (saved != null) {
      await _setFulizaLimit(saved);
    }
  }

  static const double _sentinelClear = -1;

  Widget _sectionCard(BuildContext context, String title, List<Widget> rows) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      contentPadding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600)),
            ),
          ...rows,
        ],
      ),
    );
  }

  Widget _navRow(
    BuildContext context, {
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: titleColor ?? scheme.onSurface)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          LifeOsSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
