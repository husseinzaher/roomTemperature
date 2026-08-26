import 'package:flutter/material.dart';
import 'package:ui_kit/src/glass/glass_card.dart';
import 'package:ui_kit/src/glass/glass_tokens.dart';

/// {@template glass_icon_button}
/// A circular glass action used in the dashboard top bar.
/// {@endtemplate}
class GlassIconButton extends StatelessWidget {
  /// {@macro glass_icon_button}
  const GlassIconButton({
    required this.icon,
    super.key,
    this.onTap,
    this.semanticLabel,
  });

  /// The icon drawn in the circle.
  final IconData icon;

  /// Called when the button is tapped.
  final VoidCallback? onTap;

  /// Accessibility label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GlassCard(
        blur: GlassTokens.blurSmall,
        radius: GlassTokens.radiusPill,
        padding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, size: 22, color: GlassTokens.onGlass),
          ),
        ),
      ),
    );
  }
}
