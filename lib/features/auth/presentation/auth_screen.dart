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
    _username = _prefs.getString('auth_username') ?? '';
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
      final uname = _username.trim().isNotEmpty
          ? _username.trim()
          : _fullName.trim().split(' ').first.toLowerCase();
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
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) setState(() => _controller = AuthController(prefs));
    });
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
    return Container(
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
          AuthTextField(
            value: controller.fullName,
            onChanged: controller.updateFullName,
            label: 'Full Name',
            icon: Icons.person_outline,
            placeholder: 'Your full name',
          ),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            value: controller.username,
            onChanged: controller.updateUsername,
            label: 'Username (optional)',
            icon: Icons.person_outline,
            placeholder: 'Pick a username',
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
                        if (context.mounted) context.go('/${AppRoute.onboarding}');
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
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.icon,
    required this.placeholder,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final IconData icon;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          onChanged: onChanged,
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          inputFormatters: [LengthLimitingTextInputFormatter(64)],
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
