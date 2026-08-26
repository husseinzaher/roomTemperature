import 'package:flutter/material.dart';
import 'package:ui_kit/src/glass/glass_card.dart';
import 'package:ui_kit/src/glass/glass_tokens.dart';

/// {@template glass_stat_tile}
/// One cell of the weather stat grid: a line icon, a label, and a value.
///
/// Sized by its grid parent rather than intrinsically, so a row of tiles
/// always aligns regardless of label length.
/// {@endtemplate}
class GlassStatTile extends StatelessWidget {
  /// {@macro glass_stat_tile}
  const GlassStatTile({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  /// The line icon shown above the label.
  final Widget icon;

  /// The stat's name, e.g. `Humidity`.
  final String label;

  /// The formatted value, e.g. `36 %`. Callers format this — the tile never
  /// touches raw numbers.
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: GlassTokens.blurSmall,
      radius: GlassTokens.radiusSmall,
      tint: GlassTokens.tintStrong,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 38, child: Center(child: icon)),
          const SizedBox(height: 12),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GlassTokens.onGlassMuted,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: GlassTokens.onGlass,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.1,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
