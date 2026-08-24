/// 1:1 port of ProfileScreen (androidMain actual) — ProfileHeroCard +
/// ToolHubSection with the exact 3×2 colored grid, plus SettingsScreen.
library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/controls.dart';
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/designsystem/tokens.dart';
import '../../../core/security/session_store.dart';
import '../../../navigation/routes.dart';
import '../../dashboard/data/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _name = '';
  String _username = '';
  bool _prefsLoaded = false;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final name = prefs.getString('user_name') ?? '';
    var username = prefs.getString('auth_username') ?? '';
    // Derive username if not yet set (same logic as ProfileInfoScreen).
    if (username.isEmpty && name.isNotEmpty) {
      final parts = name.toLowerCase().split(RegExp(r'\s+'));
      username = parts.length > 1 ? parts.join('.') : parts.first;
      await prefs.setString('auth_username', username);
    }
    if (!mounted) return;
    setState(() {
      _name = name;
      _username = username;
      _avatarPath = prefs.getString('profile_avatar_path');
      _prefsLoaded = true;
    });
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_avatar_path', path);
    if (!mounted) return;
    setState(() => _avatarPath = path);
  }

  Future<void> _removeAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_avatar_path');
    if (!mounted) return;
    setState(() => _avatarPath = null);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PageScaffold(
      title: 'Profile',
      contentPadding:
          const EdgeInsets.only(bottom: AppSpacing.bottomSafeWithFloatingNav),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── ProfileHeroCard ────────────────────────────────────────────────
          AppCard(
            contentPadding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Avatar — tappable; shows photo or initials.
                    GestureDetector(
                      onTap: () => _showAvatarSheet(context, scheme),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.primaryContainer,
                            ),
                            clipBehavior: Clip.hardEdge,
                            alignment: Alignment.center,
                            child: _avatarPath != null && File(_avatarPath!).existsSync()
                                ? Image.file(
                                    File(_avatarPath!),
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  )
                                : Text(
                                    _initials(_name),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(color: scheme.onPrimaryContainer),
                                  ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: scheme.primary,
                                border: Border.all(color: scheme.surface, width: 2),
                              ),
                              child: Icon(Icons.camera_alt, size: 11, color: scheme.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              _name.isEmpty ? 'Set up your profile' : _name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                              _username.isEmpty
                                  ? 'Local Workspace'
                                  : '@$_username',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant)),
                          if (_prefsLoaded) ...[
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: scheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(
                                    AppDesignTokens.radius.sm),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Text('Member since 2026',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          color: scheme.onSurfaceVariant)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () =>
                            context.push('/${AppRoute.profileInfo}'),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit Profile'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () =>
                            context.push('/${AppRoute.settings}'),
                        icon: const Icon(Icons.settings_outlined, size: 16),
                        label: const Text('Settings'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── ToolHubSection ─────────────────────────────────────────────────
          AppCard(
            contentPadding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('TOOL HUB',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _toolRow([
                  _Tool(Icons.analytics_outlined, 'Insights', const Color(0xFF2DD4BF),
                      () => context.push('/${AppRoute.insights}')),
                  _Tool(Icons.explore_outlined, 'Review', const Color(0xFFA78BFA),
                      () => context.push('/${AppRoute.review}')),
                  _Tool(Icons.search_outlined, 'Search', const Color(0xFF60A5FA),
                      () => context.push('/${AppRoute.search}')),
                ]),
                const SizedBox(height: 12),
                _toolRow([
                  _Tool(Icons.event_repeat_outlined, 'Recurring', const Color(0xFF34D399),
                      () => context.push('/${AppRoute.recurring}')),
                  _Tool(Icons.download_outlined, 'Export', const Color(0xFFFBBF24),
                      () => context.push('/${AppRoute.export}')),
                  _Tool(Icons.account_balance_outlined, 'Hub', const Color(0xFF22D3EE),
                      () => context.push('/${AppRoute.planner}')),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarSheet(BuildContext context, ColorScheme scheme) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: scheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          if (_avatarPath != null && File(_avatarPath!).existsSync())
            ListTile(
              leading: Icon(Icons.image_outlined, color: scheme.primary),
              title: const Text('View photo'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _showPhotoViewer(context, scheme);
              },
            ),
          ListTile(
            leading: Icon(Icons.photo_library_outlined, color: scheme.primary),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.of(sheetCtx).pop();
              _pickAvatar();
            },
          ),
          if (_avatarPath != null)
            ListTile(
              leading: Icon(Icons.delete_outline, color: scheme.error),
              title: Text('Remove photo', style: TextStyle(color: scheme.error)),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _removeAvatar();
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showPhotoViewer(BuildContext context, ColorScheme scheme) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: true,
        pageBuilder: (ctx, animation, _) => FadeTransition(
          opacity: animation,
          child: GestureDetector(
            onTap: () => Navigator.of(ctx).pop(),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Stack(
                  children: [
                    Center(
                      child: Hero(
                        tag: 'profile_avatar',
                        child: InteractiveViewer(
                          child: Image.file(
                            File(_avatarPath!),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black38,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'))..removeWhere((p) => p.isEmpty);
    if (parts.isEmpty) return 'B';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _toolRow(List<_Tool> tools) {
    return Row(
      children: [
        for (final (i, t) in tools.indexed) ...[
          Expanded(child: _ToolCard(tool: t)),
          if (i < tools.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _Tool {
  const _Tool(this.icon, this.label, this.color, this.onTap);
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});
  final _Tool tool;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: tool.onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.54),
              width: 0.85,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
                  color: tool.color.withValues(alpha: 0.15),
                ),
                alignment: Alignment.center,
                child: Icon(tool.icon, size: 24, color: tool.color),
              ),
              const SizedBox(height: 8),
              Text(tool.label,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
