/// AppPermissionsOrchestrator — 1:1 port of
/// androidMain/.../core/permissions/{AppPermissionsOrchestrator,
/// PermissionRationaleCard}.kt.
///
/// Shows a bottom-anchored permission rationale card once per permission group:
/// a notification-permission card on Home and an SMS-permission card on
/// Finance. "Not now" / Allow both mark the group as asked so it never
/// reappears (AppSettingsStore parity via SharedPreferences).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../navigation/routes.dart' show AppRoute;

class AppPermissionsOrchestrator extends ConsumerStatefulWidget {
  const AppPermissionsOrchestrator({
    super.key,
    required this.currentPath,
    this.bottomOffset = 0,
  });

  final String currentPath;

  /// Space reserved for the floating nav bar (58dp + offset + hairlines) so the
  /// card floats above it, matching Kotlin's navigationBarsPadding placement.
  final double bottomOffset;

  @override
  ConsumerState<AppPermissionsOrchestrator> createState() =>
      _AppPermissionsOrchestratorState();
}

class _AppPermissionsOrchestratorState
    extends ConsumerState<AppPermissionsOrchestrator> {
  bool _showNotificationCard = false;
  bool _showSmsCard = false;

  String get _route => widget.currentPath.split('?').first;

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void didUpdateWidget(AppPermissionsOrchestrator old) {
    super.didUpdateWidget(old);
    if (old.currentPath != widget.currentPath) _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final isHome = _route == '/${AppRoute.home}';
    final isFinance = _route == '/${AppRoute.finance}';
    setState(() {
      _showNotificationCard =
          isHome && !(prefs.getBool('notification_permission_asked') ?? false);
      _showSmsCard =
          isFinance && !(prefs.getBool('sms_permission_asked') ?? false);
    });
  }

  Future<void> _markAsked(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = widget.bottomOffset;
    if (_showSmsCard) {
      return _PermissionRationaleCard(
        icon: Icons.message_outlined,
        title: 'Auto-import M-Pesa transactions',
        description:
            'Allow LifeOS to read your M-Pesa SMS messages to automatically track your transactions.',
        bottomPadding: bottomPadding,
        onAllow: () async {
          await _markAsked('sms_permission_asked');
          await Permission.sms.request();
          if (mounted) setState(() => _showSmsCard = false);
        },
        onDeny: () async {
          await _markAsked('sms_permission_asked');
          if (mounted) setState(() => _showSmsCard = false);
        },
      );
    }
    if (_showNotificationCard) {
      return _PermissionRationaleCard(
        icon: Icons.notifications_outlined,
        title: 'Stay on top of reminders',
        description:
            'Allow LifeOS to send you timely reminders for tasks, bills, and daily digests.',
        bottomPadding: bottomPadding,
        onAllow: () async {
          await _markAsked('notification_permission_asked');
          await Permission.notification.request();
          if (mounted) setState(() => _showNotificationCard = false);
        },
        onDeny: () async {
          await _markAsked('notification_permission_asked');
          if (mounted) setState(() => _showNotificationCard = false);
        },
      );
    }
    return const SizedBox.shrink();
  }
}

/// Bottom-anchored permission rationale card (PermissionRationaleCard.kt).
class _PermissionRationaleCard extends StatelessWidget {
  const _PermissionRationaleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onAllow,
    required this.onDeny,
    this.bottomPadding = 0,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onAllow;
  final VoidCallback onDeny;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 12),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 26, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                    onPressed: onDeny,
                    child: Text('Not now',
                        style: TextStyle(color: scheme.onSurfaceVariant))),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: onAllow,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Allow'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
