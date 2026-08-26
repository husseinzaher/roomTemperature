import 'package:flutter/material.dart';
import 'package:ui_kit/src/glass/glass_tokens.dart';

/// {@template glass_chip}
/// A small translucent pill with an optional leading icon — used to label a
/// reading's provenance ("Estimated" / "Sensor") on top of a glass card.
///
/// Deliberately not a Material `Chip`: it needs to read as part of the glass
/// rather than as a filled surface.
/// {@endtemplate}
class GlassChip extends StatelessWidget {
  /// {@macro glass_chip}
  const GlassChip({required this.label, super.key, this.icon});

  /// The chip's text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 12, 5),
      decoration: BoxDecoration(
        color: const Color(0x24FFFFFF),
        borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
        border: Border.all(color: const Color(0x2EFFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: GlassTokens.onGlassMuted),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: GlassTokens.onGlassMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
