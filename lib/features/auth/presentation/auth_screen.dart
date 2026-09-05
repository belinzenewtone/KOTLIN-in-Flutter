/// 1:1 port of features/auth/presentation/AuthScreen.kt.
///
/// Gradient backdrop (PrimaryMuted 30% → background), branding HeroSurface,
/// local sign-up AppCard with Full Name / Username fields, 54dp CTA, and the
/// "No account required" footnote. Loading state swaps to a centered logo +
/// spinner. Errors/success surface through a styled snackbar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/designsystem/app_card.dart';
import '../../../core/designsystem/page_scaffold.dart';
import '../../../core/designsystem/tokens.dart';
import '../../../core/security/session_store.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/colors.dart';
import '../../../ui/theme/theme.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._prefs) {
    // Pre-fill from onboarding data so the user doesn't re-type their name.
    // Onboarding step 3 saves 'user_name' before routing here.
    _fullName = _prefs.getString(_kName) ?? '';
    // Cap at 8 chars — guards against any legacy long value stored before
    // the limit was enforced at the save points.
    final raw = _prefs.getString('auth_username') ?? '';
    _username = raw.length > 8 ? raw.substring(0, 8) : raw;
  }

  final SharedPreferences _prefs;
  bool _loading = false;
  String _fullName = '';
  String _username = '';
  String? _error;

  bool get loading => _loading;
  String get fullName => _fullName;
  String get username => _username;
  String? get error => _error;

  static const _kName = 'user_name';

  void updateFullName(String v) {
    _fullName = v;
    notifyListeners();
  }

  void updateUsername(String v) {
    _username = v;
    notifyListeners();
  }

  /// Kotlin signUp(): blank name → error; else persist name/username and log in.
  Future<bool> signUp() async {
    if (_fullName.trim().isEmpty) {
      _error = 'Please enter your full name to continue.';
      notifyListeners();
      return false;
    }
    _loading = true;
    notifyListeners();
    try {
      await _prefs.setString(_kName, _fullName.trim());
      // Cap username at 8 chars — matches the Profile Settings limit.
      var uname = _username.trim().isNotEmpty
          ? _username.trim()
          : _fullName.trim().split(' ').first.toLowerCase();
      if (uname.length > 8) uname = uname.substring(0, 8);
      await _prefs.setString('auth_username', uname);
      return true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  AuthController? _controller;
  // Stable controllers — created once when prefs load, never recreated on rebuild.
  // Fixes the cursor-jump bug that occurred when AnimatedBuilder rebuilt the
  // AuthTextField and a new TextEditingController was created each time.
  TextEditingController? _nameCtrl;
  TextEditingController? _usernameCtrl;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      final ctrl = AuthController(prefs);
      setState(() {
        _controller = ctrl;
        _nameCtrl = TextEditingController(text: ctrl.fullName);
        _usernameCtrl = TextEditingController(text: ctrl.username);
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl?.dispose();
    _usernameCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = _controller;
    if (controller == null) return const AuthLoadingState();

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Builder(builder: (context) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            // Error snackbar (LaunchedEffect parity).
            if (controller.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scaffoldMessengerKey.currentState
                    ?.showSnackBar(SnackBar(content: Text(controller.error!)));
                controller.clearError();
              });
            }
            return _AuthFormBody(
              context: context,
              scheme: scheme,
              controller: controller,
            );
          },
        );
      }),
    );
  }

  Widget _AuthFormBody({
    required BuildContext context,
    required ColorScheme scheme,
    required AuthController controller,
  }) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kPrimaryMuted.withValues(alpha: 0.3), scheme.background],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      _authBrandingHeader(context),
                      const SizedBox(height: AppSpacing.md),
                      _signUpCard(context, controller),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _authBrandingHeader(BuildContext context) {
    final c = Theme.of(context).extension<LifeOsColors>() ?? LifeOsColors.light;
    final scheme = Theme.of(context).colorScheme;
    return HeroSurface(
      eyebrow: 'Welcome',
      title: 'Your PersonalOS',
      subtitle:
          'All your tasks, calendar, and finances — stored locally on your device.',
      action: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
            gradient: LinearGradient(
              colors: [c.primaryContainer, scheme.surfaceContainerHighest],
            ),
          ),
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
            child: Image.asset('assets/logo/logo_personalos.png',
                width: 24, height: 24, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  Widget _signUpCard(BuildContext context, AuthController controller) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pass the stable controllers so AuthTextField never recreates them
          // on rebuild — fixes cursor-jump on every keystroke.
          AuthTextField(
            controller: _nameCtrl,
            value: controller.fullName,
            onChanged: controller.updateFullName,
            label: 'Full Name',
            icon: Icons.person_outline,
            placeholder: 'Your full name',
          ),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _usernameCtrl,
            value: controller.username,
            onChanged: controller.updateUsername,
            label: 'Username (optional)',
            icon: Icons.person_outline,
            placeholder: 'Pick a username (max 8 chars)',
            maxLength: 8,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm)),
              ),
              onPressed: controller.loading
                  ? null
                  : () async {
                      final ok = await controller.signUp();
                      if (!mounted) return;
                      if (ok) {
                        await ref.read(sessionProvider.notifier).login(controller.fullName.trim());
                        // Go directly to home — the router guard would redirect
                        // /onboarding → /home anyway but this avoids the double
                        // navigation jitter.
                        if (context.mounted) context.go('/${AppRoute.home}');
                      } else {
                        _scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                              content: Text('Please enter your full name to continue.')),
                        );
                      }
                    },
              child: controller.loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No account required. Your data stays on this device.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Shared auth-style text field — label above an outlined field (6dp gap).
///
/// Pass [controller] (a stable instance owned by the parent State) to avoid
/// recreating the controller on every rebuild — required when this widget is
/// inside an AnimatedBuilder.  [value] is only used as the initial text when
/// [controller] is null (legacy fallback).
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    this.controller,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.icon,
    required this.placeholder,
    this.maxLength = 64,
  });

  final TextEditingController? controller;
  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final IconData icon;
  final String placeholder;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Use the caller-supplied stable controller when available; otherwise
    // fall back to a one-shot controller seeded with the current value.
    final effectiveController = controller ??
        (TextEditingController(text: value)
          ..selection = TextSelection.collapsed(offset: value.length));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 6),
        TextField(
          controller: effectiveController,
          onChanged: onChanged,
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
          style: TextStyle(color: scheme.onSurface),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: scheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            prefixIcon: Icon(icon,
                size: 22, color: scheme.onSurfaceVariant.withValues(alpha: 0.85)),
            hintText: placeholder,
            hintStyle: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
              borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.48)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
              borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.48)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
              borderSide: BorderSide(color: scheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthLoadingState extends StatelessWidget {
  const AuthLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kPrimaryMuted.withValues(alpha: 0.3), scheme.background],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
              child: Image.asset('assets/logo/logo_personalos.png',
                  width: 88, height: 88, fit: BoxFit.cover),
            ),
            const SizedBox(height: AppSpacing.sm),
            CircularProgressIndicator(
                strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(scheme.primary)),
          ],
        ),
      ),
    );
  }
}
