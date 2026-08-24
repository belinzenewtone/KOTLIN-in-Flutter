/// 1:1 port of the biometric re-lock overlay in LifeOSNavHost.kt
/// (BiometricLockOverlay + rememberBiometricLockState).
///
/// Behavior contract:
///  • Locks when requiresLock becomes true and app is backgrounded past
///    [lockTimeoutMs] (default 5 minutes), or on first arm.
///  • Overlay covers ALL content; unlock via local_auth (biometrics/device PIN).
///  • "Reset App" opens a destructive confirm dialog wired to [onReset].
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/designsystem/tokens.dart';
import '../../ui/theme/theme.dart';

class BiometricLockState {
  const BiometricLockState({
    required this.requiresLock,
    required this.appContentUnlocked,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool requiresLock;
  final bool appContentUnlocked;
  final String? errorMessage;
  final VoidCallback onRetry;
}

class BiometricLockCoordinator extends StatefulWidget {
  const BiometricLockCoordinator({
    super.key,
    required this.enabled,
    required this.child,
    this.lockTimeoutMs = 5 * 60000,
    this.onReset,
  });

  /// authState.isLoggedIn && biometricEnabled && !onPublicFlow
  final bool enabled;
  final Widget child;
  final int lockTimeoutMs;
  final VoidCallback? onReset;

  @override
  State<BiometricLockCoordinator> createState() =>
      _BiometricLockCoordinatorState();
}

class _BiometricLockCoordinatorState extends State<BiometricLockCoordinator>
    with WidgetsBindingObserver {
  bool _unlocked = false;
  bool _promptedOnce = false;
  String? _error;
  DateTime _pausedAt = DateTime.now();
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Auto-prompt on first arm so the user doesn't need to tap "Unlock".
    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_unlocked) _authenticate();
      });
    }
  }

  @override
  void didUpdateWidget(covariant BiometricLockCoordinator old) {
    super.didUpdateWidget(old);
    if (!old.enabled && widget.enabled) {
      // Freshly armed (login/biometric toggle): force prompt.
      setState(() {
        _unlocked = false;
        _promptedOnce = false;
      });
    }
    if (old.enabled && !widget.enabled) {
      setState(() => _unlocked = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enabled) return;
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final away = DateTime.now().difference(_pausedAt).inMilliseconds;
      if (_promptedOnce && away > widget.lockTimeoutMs) {
        setState(() => _unlocked = false);
      }
    }
  }

  Future<void> _authenticate() async {
    setState(() => _error = null);
    try {
      // Check device capability first.
      final canCheck = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
      if (!canCheck) {
        if (mounted) {
          setState(() => _error = 'No biometrics or device PIN available.\n'
              'Please enroll a fingerprint or set a screen lock in device settings.');
        }
        return;
      }
      final ok = await _localAuth.authenticate(
        localizedReason: 'Unlock BELTECH to continue',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (!mounted) return;
      setState(() {
        if (ok) {
          _unlocked = true;
          _promptedOnce = true;
          _error = null;
        } else {
          // User cancelled — stay locked, no error text shown.
          _error = null;
        }
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      final msg = e.message ?? 'Authentication error';
      setState(() => _error = msg.contains('No enrolled') || msg.contains('NotEnrolled')
          ? 'No fingerprint or PIN enrolled. Please set up device security first.'
          : msg.contains('NotAvailable') || msg.contains('unavailable')
              ? 'Biometrics not available on this device.'
              : 'Unlock failed. Please try again.');
    } catch (_) {
      if (mounted) setState(() => _error = 'Unlock failed. Please try again.');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requiresLock = widget.enabled && !_unlocked;
    if (!requiresLock) {
      // Content is unlocked; keep lifecycle observers active for re-lock.
      return widget.child;
    }
    return BiometricLockOverlay(
      errorMessage: _error,
      onRetry: () {
        setState(() => _error = null);
        _authenticate();
      },
      onReset: widget.onReset,
    );
  }
}

/// The visual overlay — fingerprint icon card, exact Compose layout metrics:
/// 32dp outer padding, 28dp inner padding, 52dp icon, 16dp column gap.
class BiometricLockOverlay extends StatefulWidget {
  const BiometricLockOverlay({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.onReset,
  });

  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback? onReset;

  @override
  State<BiometricLockOverlay> createState() => _BiometricLockOverlayState();
}

class _BiometricLockOverlayState extends State<BiometricLockOverlay> {
  bool _showResetConfirm = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final err = widget.errorMessage;

    if (_showResetConfirm) {
      return Stack(
        children: [
          _backdrop(scheme),
          // Barrier + centered dialog without showDialog() so it stays in-tree.
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black54,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Material(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Reset App?',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          const Text(
                              'This will permanently delete all your local data and cannot be undone.'),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    setState(() => _showResetConfirm = false),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: scheme.error,
                                  foregroundColor: scheme.onError,
                                ),
                                onPressed: widget.onReset,
                                child: const Text('Delete & Reset'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _backdropWithCard(scheme, err);
  }

  Widget _backdrop(ColorScheme scheme) =>
      Container(color: scheme.background, alignment: Alignment.center);

  Widget _backdropWithCard(ColorScheme scheme, String? err) {
    return Container(
      color: scheme.background,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(AppDesignTokens.radius.sm),
            border: Border.all(color: scheme.outlineVariant),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fingerprint_outlined,
                  size: 52, color: err != null ? scheme.error : scheme.primary),
              const SizedBox(height: 16),
              Text(
                err != null ? 'Unlock failed' : 'Unlock LifeOS',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  err ??
                      'Touch the fingerprint sensor or use your device PIN to continue.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => _showResetConfirm = true),
                    child: const Text('Reset App'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: widget.onRetry,
                    child: Text(err != null ? 'Try Again' : 'Unlock'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
