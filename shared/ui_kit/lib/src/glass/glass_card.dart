import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui_kit/src/glass/glass_tokens.dart';

/// {@template glass_card}
/// The app's one translucent surface primitive: a rounded rectangle that
/// blurs whatever sits behind it, tints it, and edges it with a hairline
/// border.
///
/// Every card, tile, toggle, and bar in the app is built from this, so the
/// glass reads as a single consistent material.
/// {@endtemplate}
class GlassCard extends StatelessWidget {
  /// {@macro glass_card}
  const GlassCard({
    required this.child,
    super.key,
    this.blur = GlassTokens.blurLarge,
    this.radius = GlassTokens.radiusLarge,
    this.tint = GlassTokens.tint,
    this.padding = const EdgeInsets.all(20),
    this.border = true,
    this.shadow = true,
    this.onTap,
  });

  /// The content painted on top of the glass.
  final Widget child;

  /// Backdrop blur sigma. See [GlassTokens.blurLarge] / [GlassTokens.blurSmall].
  final double blur;

  /// Corner radius.
  final double radius;

  /// Tint painted over the blurred backdrop.
  final Color tint;

  /// Padding around [child].
  final EdgeInsetsGeometry padding;

  /// Whether to draw the hairline light-catching border.
  final bool border;

  /// Whether to lift the surface with a soft shadow.
  final bool shadow;

  /// Called when the surface is tapped. When null the surface is inert and
  /// no ink response is attached.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: borderRadius,
        border: border
            ? Border.all(color: GlassTokens.border, width: 1)
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      surface = Stack(
        children: [
          surface,
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                splashColor: const Color(0x1FFFFFFF),
                highlightColor: const Color(0x14FFFFFF),
              ),
            ),
          ),
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadow ? GlassTokens.shadow : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: surface,
        ),
      ),
    );
  }
}
