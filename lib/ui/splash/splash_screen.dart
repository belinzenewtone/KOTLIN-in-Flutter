/// 1:1 port of ui/splash/PersonalOsSplashScreen.kt.
///
/// Pulsing primary glow (220dp, 0.92→1.08 scale @35% alpha) behind a logo that
/// fades+scales in (900ms, spring), with a 28dp circular progress spinner.
library;

import 'package:flutter/material.dart';

class PersonalOsSplashScreen extends StatefulWidget {
  const PersonalOsSplashScreen({super.key});

  @override
  State<PersonalOsSplashScreen> createState() => _PersonalOsSplashScreenState();
}

class _PersonalOsSplashScreenState extends State<PersonalOsSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _animateIn = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
      lowerBound: 0.92,
      upperBound: 1.08,
    )..repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _animateIn = true);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Container(
        color: scheme.background,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing radial glow — alpha 0.35, blurred.
                  Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            scheme.primary.withValues(alpha: 0.35),
                            scheme.primary.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Logo fades + scales in — width = 74% of screen (Kotlin
                  // fillMaxWidth(0.74f)).
                  AnimatedOpacity(
                    opacity: _animateIn ? 1 : 0,
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOut,
                    child: AnimatedScale(
                      scale: _animateIn ? 1.0 : 0.88,
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutBack,
                      child: Image.asset(
                        'assets/logo/logo_personalos.png',
                        width: MediaQuery.sizeOf(context).width * 0.74,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.fingerprint,
                          size: 96,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(
                  scheme.primary.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
