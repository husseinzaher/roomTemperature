import 'dart:math' as math;

import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Night-sky canvas sampled from the app icon artwork.
const Color _splashCanvas = Color(0xFF0A162A);

/// Warm highlight used for the logo's ambient glow.
const Color _splashGlow = Color(0xFFFFB24A);

/// {@template splash_page}
/// Branded launch screen: the app logo eases in with a soft glow, the
/// title follows, then the scene fades out before [onFinished].
/// {@endtemplate}
class SplashPage extends StatefulWidget {
  /// {@macro splash_page}
  const SplashPage({super.key, this.onFinished});

  /// Asset path of the sun-and-cloud app logo.
  static const String logoAsset = 'assets/branding/app_logo.png';

  /// Full intro length, including the exit fade.
  static const Duration introDuration = Duration(milliseconds: 1800);

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
                    Transform.scale(
                      scale: _logoScale,
                      child: Opacity(
                        opacity: _logoOpacity,
                        child: _GlowingLogo(
                          glowStrength: _glowStrength,
                          child: Image.asset(
                            SplashPage.logoAsset,
                            key: const Key('app_logo'),
                            width: 168,
                            height: 168,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Opacity(
                      opacity: _titleOpacity,
                      child: Transform.translate(
                        offset: Offset(0, (1 - _titleOpacity) * 12),
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

  double get _logoOpacity => _interval(0, 0.32, Curves.easeOut);

  double get _logoScale =>
      0.86 + 0.14 * _interval(0, 0.42, Curves.easeOutCubic);

  double get _titleOpacity => _interval(0.28, 0.52, Curves.easeOut);

  double get _exitOpacity => 1 - _interval(0.82, 1, Curves.easeIn);

  double get _glowStrength {
    final window = _interval(0.12, 0.78, Curves.linear);
    return 0.5 + 0.5 * math.sin(window * math.pi);
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
              alpha: 0.12 + 0.22 * glowStrength,
            ),
            blurRadius: 28 + 20 * glowStrength,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
