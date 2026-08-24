/// 1:1 port of ProfileSubScreens.kt (androidMain actual) — ProfileInfoScreen,
/// ProfileSecurityScreen, ProfilePreferencesScreen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/controls.dart';
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/designsystem/tokens.dart';
import '../../../core/security/session_store.dart';
import '../../dashboard/data/providers.dart';
import 'package:lifeos/main.dart' show themeController;
import 'package:lifeos/ui/theme/theme.dart' show AppThemeMode;

// ─────────────────────────────────────────────────────────────────────────────
// 1.  ProfileInfoScreen
// ─────────────────────────────────────────────────────────────────────────────

class ProfileInfoScreen extends ConsumerStatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  ConsumerState<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends ConsumerState<ProfileInfoScreen> {
  bool _isEditing = false;
  bool _loading = true;

  // View-mode values
  String _name = '';
  String _username = '';

  // Edit-mode controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _usernameCtrl;

  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
    _loadPrefs();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final name = prefs.getString('user_name') ?? '';
    // Derive username from full name when auth_username has not been set yet
    // (e.g. first-time users who completed onboarding before this fix).
    var username = prefs.getString('auth_username') ?? '';
    if (username.isEmpty && name.isNotEmpty) {
      final parts = name.toLowerCase().split(RegExp(r'\s+'));
      username = parts.length > 1 ? parts.join('.') : parts.first;
      await prefs.setString('auth_username', username);
    }
    setState(() {
      _name = name;
      _username = username;
      _nameCtrl.text = name;
      _usernameCtrl.text = username;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    // Enforce 8-char limit on username before saving.
    final rawUsername = _usernameCtrl.text.trim();
    final clampedUsername = rawUsername.length > 8 ? rawUsername.substring(0, 8) : rawUsername;
    await prefs.setString('user_name', _nameCtrl.text.trim());
    await prefs.setString('auth_username', clampedUsername);
    // Invalidate the dashboard repository so the home screen greeting
    // picks up the new name without a manual refresh.
    ref.invalidate(dashboardRepositoryProvider);
    setState(() {
      _name = _nameCtrl.text.trim();
      _username = clampedUsername;
      _isEditing = false;
      _successMessage = 'Profile updated successfully.';
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _successMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PageScaffold(
      title: 'Personal Information',
      onBack: () => context.pop(),
      contentPadding: const EdgeInsets.only(bottom: AppSpacing.bottomSafeWithFloatingNav),
      topBanner: _successMessage != null
          ? _SuccessBanner(message: _successMessage!)
          : null,
      child: _loading
          ? const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),
                if (!_isEditing) _ProfileDetailsCard(
                  name: _name,
                  username: _username,
                  onEdit: () => setState(() => _isEditing = true),
                ) else _ProfileEditorSection(
                  nameCtrl: _nameCtrl,
                  usernameCtrl: _usernameCtrl,
                  onSave: _save,
                  onCancel: () {
                    _nameCtrl.text = _name;
                    _usernameCtrl.text = _username;
                    setState(() => _isEditing = false);
                  },
                ),
              ],
            ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
        border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF16A34A)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailsCard extends StatelessWidget {
  const _ProfileDetailsCard({
    required this.name,
    required this.username,
    required this.onEdit,
  });

  final String name;
  final String username;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      contentPadding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Full Name row
          _InfoRow(label: 'Full Name', value: name.isEmpty ? '—' : name),
          const SizedBox(height: AppSpacing.lg),
          // Username row
          _InfoRow(label: 'Username', value: username.isEmpty ? '—' : username),
          const SizedBox(height: AppSpacing.xl),
          // Edit Profile button — fills max width
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onEdit,
              child: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: tt.bodyLarge?.copyWith(color: scheme.onSurface),
        ),
      ],
    );
  }
}

class _ProfileEditorSection extends StatelessWidget {
  const _ProfileEditorSection({
    required this.nameCtrl,
    required this.usernameCtrl,
    required this.onSave,
    required this.onCancel,
  });

  final TextEditingController nameCtrl;
  final TextEditingController usernameCtrl;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    OutlineInputBorder _border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: color),
        );

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: scheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: _border(scheme.outlineVariant),
      enabledBorder: _border(scheme.outlineVariant),
      focusedBorder: _border(scheme.primary),
    );

    return AppCard(
      contentPadding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Full Name',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: nameCtrl,
            decoration: inputDecoration.copyWith(hintText: 'Enter your full name'),
            style: Theme.of(context).textTheme.bodyLarge,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Username',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: usernameCtrl,
            decoration: inputDecoration.copyWith(
              hintText: 'Enter a username (max 8 chars)',
              counterText: '',
            ),
            style: Theme.of(context).textTheme.bodyLarge,
            textInputAction: TextInputAction.done,
            maxLength: 8,
            inputFormatters: [
              LengthLimitingTextInputFormatter(8),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onSave,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2.  ProfileSecurityScreen
// ─────────────────────────────────────────────────────────────────────────────

class ProfileSecurityScreen extends ConsumerWidget {
  const ProfileSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final session = ref.watch(sessionProvider);

    return PageScaffold(
      title: 'Security',
      subtitle: 'Biometric lock settings',
      onBack: () => context.pop(),
      contentPadding: const EdgeInsets.only(bottom: AppSpacing.bottomSafeWithFloatingNav),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          AppCard(
            contentPadding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Lock icon box — 36dp, surfaceVariant bg, RoundedCornerShape(6)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: scheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.lock_outlined,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Biometric Lock',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    LifeOsSwitch(
                      value: session.biometricEnabled,
                      onChanged: (v) =>
                          ref.read(sessionProvider.notifier).setBiometricEnabled(v),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Require fingerprint or PIN to open the app.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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

// ─────────────────────────────────────────────────────────────────────────────
// 3.  ProfilePreferencesScreen
// ─────────────────────────────────────────────────────────────────────────────

class ProfilePreferencesScreen extends ConsumerStatefulWidget {
  const ProfilePreferencesScreen({super.key});

  @override
  ConsumerState<ProfilePreferencesScreen> createState() =>
      _ProfilePreferencesScreenState();
}

class _ProfilePreferencesScreenState
    extends ConsumerState<ProfilePreferencesScreen> {
  bool _notifEnabled = true;
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifEnabled = prefs.getBool('notif_enabled') ?? true;
      _themeMode = switch (prefs.getString('theme_mode')) {
        'LIGHT' => AppThemeMode.light,
        'DARK' => AppThemeMode.dark,
        _ => AppThemeMode.system,
      };
      _loading = false;
    });
  }

  Future<void> _setNotif(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_enabled', v);
    setState(() => _notifEnabled = v);
  }

  Future<void> _setTheme(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'theme_mode',
      switch (mode) {
        AppThemeMode.light => 'LIGHT',
        AppThemeMode.dark => 'DARK',
        AppThemeMode.system => 'SYSTEM',
      },
    );
    themeController.value = mode;
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PageScaffold(
      title: 'Preferences',
      subtitle: 'Notifications and appearance',
      onBack: () => context.pop(),
      contentPadding: const EdgeInsets.only(bottom: AppSpacing.bottomSafeWithFloatingNav),
      child: _loading
          ? const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),

                // ── NOTIFICATIONS card ──────────────────────────────────────
                AppCard(
                  contentPadding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: scheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notifications',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      LifeOsSwitch(
                        value: _notifEnabled,
                        onChanged: _setNotif,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ── THEME card ──────────────────────────────────────────────
                AppCard(
                  contentPadding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Appearance',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _ThemeToggleButton(
                            icon: Icons.settings_brightness_outlined,
                            label: 'System',
                            selected: _themeMode == AppThemeMode.system,
                            onTap: () => _setTheme(AppThemeMode.system),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _ThemeToggleButton(
                            icon: Icons.wb_sunny_outlined,
                            label: 'Light',
                            selected: _themeMode == AppThemeMode.light,
                            onTap: () => _setTheme(AppThemeMode.light),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _ThemeToggleButton(
                            icon: Icons.dark_mode_outlined,
                            label: 'Dark',
                            selected: _themeMode == AppThemeMode.dark,
                            onTap: () => _setTheme(AppThemeMode.dark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Tooltip(
          message: label,
          child: Icon(
            icon,
            size: 22,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
