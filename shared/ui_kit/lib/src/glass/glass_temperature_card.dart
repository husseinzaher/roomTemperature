import 'package:flutter/material.dart';
import 'package:ui_kit/src/glass/glass_card.dart';
import 'package:ui_kit/src/glass/glass_tokens.dart';

/// {@template glass_temperature_card}
/// The app's hero reading: a circled condition icon beside an oversized
/// light-weight temperature figure with a superscript unit.
///
/// Used for both the inside and outside readings, so the two align to the
/// same optical baseline.
/// {@endtemplate}
class GlassTemperatureCard extends StatelessWidget {
  /// {@macro glass_temperature_card}
  const GlassTemperatureCard({
    required this.icon,
    required this.value,
    required this.unit,
    super.key,
    this.badge,
    this.trailingContent,
  });

  /// The condition/thermometer icon, shown inside a soft circle.
  final Widget icon;

  /// The already-formatted temperature figure, e.g. `20.4`.
  ///
  /// Callers must format this — the card never sees a raw double, which is
  /// what kept full float precision out of the old UI.
  final String value;

  /// The unit symbol shown as a superscript, e.g. `°C`.
  final String unit;

  /// Optional small badge (e.g. an estimated/sensor chip) shown under the
  /// figure.
  final Widget? badge;

  /// Optional content laid out below the reading, inside the same card —
  /// used to nest the outside stat grid under the outside temperature.
  final Widget? trailingContent;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              _IconBubble(child: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Reading(value: value, unit: unit),
                    if (badge != null) ...[
                      const SizedBox(height: 8),
                      badge!,
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (trailingContent != null) ...[
            const SizedBox(height: 16),
            trailingContent!,
          ],
        ],
      ),
    );
  }
}

class _Reading extends StatelessWidget {
  const _Reading({required this.value, required this.unit});

  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    // The figure scales down rather than wrapping or overflowing, so an
    // unusually wide value (e.g. "-10.5") still fits any phone width.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerEnd,
      // A measurement reads left-to-right in every locale: forcing LTR here
      // keeps "20.4 °C" from being reordered to "C° 20.4" under RTL, where
      // the degree sign is bidi-neutral and would otherwise flip.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: GlassTokens.onGlass,
                fontSize: 82,
                fontWeight: FontWeight.w200,
                height: 0.95,
                letterSpacing: -1,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                unit,
                style: const TextStyle(
                  color: GlassTokens.onGlass,
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 1.05,
          colors: [
            Color(0x38FFFFFF),
            Color(0x14FFFFFF),
          ],
        ),
        border: Border.all(color: const Color(0x3DFFFFFF)),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
