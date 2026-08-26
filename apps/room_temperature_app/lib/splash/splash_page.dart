import 'dart:math' as math;

import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Night-sky canvas sampled from the app icon artwork.
const Color _splashCanvas = Color(0xFF0A162A);

/// Warm highlight used for the logo's ambient glow.
const Color _splashGlow = Color(0xFFFFB24A);

/// {@template splash_page}
/// Branded launch screen: the app logo pops in with a glass sheen and a
/// soft float, the title follows, then the scene fades out before
/// [onFinished].
/// {@endtemplate}
class SplashPage extends StatefulWidget {
  /// {@macro splash_page}
  const SplashPage({super.key, this.onFinished});

  /// Asset path of the sun-and-cloud app logo.
  static const String logoAsset = 'assets/branding/app_logo.png';

  /// Full intro length, including the exit fade.
  static const Duration introDuration = Duration(milliseconds: 2600);

  /// Called once the intro animation completes. The router uses this to
  /// replace the splash with home.
  final VoidCallback? onFinished;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _didFinish = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: SplashPage.introDuration,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _finish();
          }
        });
    _controller.forward();
  }

  void _finish() {
    if (_didFinish) {
      return;
    }
    _didFinish = true;
    widget.onFinished?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _splashCanvas,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Opacity(
              opacity: _exitOpacity,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: Offset(0, _logoFloat),
                      child: Transform.rotate(
                        angle: _logoRotation,
                        child: Transform.scale(
                          scale: _logoScale,
                          child: Opacity(
                            opacity: _logoOpacity,
                            child: _GlowingLogo(
                              glowStrength: _glowStrength,
                              child: _ShimmerLogo(
                                progress: _shimmerProgress,
                                child: Image.asset(
                                  SplashPage.logoAsset,
                                  key: const Key('app_logo'),
                                  width: 176,
                                  height: 176,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Opacity(
                      opacity: _titleOpacity,
                      child: Transform.translate(
                        offset: Offset(0, (1 - _titleOpacity) * 14),
                        child: Text(
                          context.l10n.appTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFF4FBFF),
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double get _t => _controller.value;

  double get _logoOpacity => _interval(0, 0.22, Curves.easeOut);

  double get _logoScale {
    final pop = _interval(0, 0.38, Curves.easeOutBack);
    return 0.42 + 0.58 * pop;
  }

  double get _logoRotation => (1 - _logoOpacity) * -0.14;

  double get _logoFloat {
    final hold = _interval(0.38, 0.82, Curves.linear);
    if (hold <= 0) {
      return (1 - _logoOpacity) * 18;
    }
    return math.sin(hold * math.pi * 2) * 5;
  }

  double get _shimmerProgress => _interval(0.18, 0.52, Curves.easeInOut);

  double get _titleOpacity => _interval(0.32, 0.52, Curves.easeOut);

  double get _exitOpacity => 1 - _interval(0.84, 1, Curves.easeIn);

  double get _glowStrength {
    final entrance = _interval(0.08, 0.36, Curves.easeOut);
    final pulse = _interval(0.36, 0.82, Curves.linear);
    return entrance * 0.7 + 0.3 * (0.5 + 0.5 * math.sin(pulse * math.pi * 2));
  }

  double _interval(double start, double end, Curve curve) {
    if (_t <= start) {
      return 0;
    }
    if (_t >= end) {
      return 1;
    }
    return curve.transform((_t - start) / (end - start));
  }
}

class _GlowingLogo extends StatelessWidget {
  const _GlowingLogo({required this.glowStrength, required this.child});

  final double glowStrength;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: _splashGlow.withValues(
              alpha: 0.1 + 0.32 * glowStrength,
            ),
            blurRadius: 24 + 28 * glowStrength,
            spreadRadius: 1 + 4 * glowStrength,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// A diagonal glass highlight that sweeps once across the logo.
class _ShimmerLogo extends StatelessWidget {
  const _ShimmerLogo({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 || progress >= 1) {
      return child;
    }
    final slide = -1.3 + 2.6 * progress;
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(slide - 0.35, -1),
          end: Alignment(slide + 0.35, 1),
          colors: [
            const Color(0x00FFFFFF),
            Colors.white.withValues(alpha: 0.55),
            const Color(0x00FFFFFF),
          ],
          stops: const [0.28, 0.5, 0.72],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
