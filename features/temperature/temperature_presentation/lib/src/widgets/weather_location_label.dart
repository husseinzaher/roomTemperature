import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// {@template weather_location_label}
/// A pin-and-name location row, matching the home-screen widget's
/// location line (e.g. `Sandub`).
/// {@endtemplate}
class WeatherLocationLabel extends StatelessWidget {
  /// {@macro weather_location_label}
  const WeatherLocationLabel({required this.placeName, super.key});

  /// The reverse-geocoded locality to display.
  final String placeName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 18,
          color: GlassTokens.onGlass,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            placeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GlassTokens.onGlass,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
