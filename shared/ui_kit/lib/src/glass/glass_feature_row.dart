import 'package:flutter/material.dart';
import 'package:ui_kit/src/glass/glass_card.dart';
import 'package:ui_kit/src/glass/glass_tokens.dart';

/// {@template glass_feature_row}
/// A full-width glass row that navigates onward — the reference design's
/// "5-Day Forecast / Air Quality Meter / Weather Radar" list.
///
/// The trailing chevron resolves against text direction, so it points the
/// correct way in both LTR and RTL.
/// {@endtemplate}
class GlassFeatureRow extends StatelessWidget {
  /// {@macro glass_feature_row}
  const GlassFeatureRow({
    required this.icon,
    required this.title,
    super.key,
    this.onTap,
  });

  /// The leading line icon.
  final Widget icon;

  /// The row's title.
  final String title;

  /// Called when the row is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: GlassTokens.blurSmall,
      radius: GlassTokens.radiusSmall,
      tint: GlassTokens.tintStrong,
      padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 16, 18),
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(width: 34, child: Center(child: icon)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: GlassTokens.onGlass,
                fontSize: 19,
                fontWeight: FontWeight.w400,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.chevron_right,
            size: 22,
            color: GlassTokens.onGlassMuted,
          ),
        ],
      ),
    );
  }
}
