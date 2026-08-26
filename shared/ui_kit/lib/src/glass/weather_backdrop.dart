import 'package:flutter/material.dart';

/// The visual mood a [WeatherBackdrop] paints. The caller maps its own
/// weather-condition type onto this, so `ui_kit` stays independent of any
/// feature's domain model.
enum BackdropMood {
  /// Bright clear daytime.
  clearDay,

  /// Clear night.
  clearNight,

  /// Hazy, partly clouded daylight.
  partlyCloudy,

  /// Flat overcast.
  overcast,

  /// Fog or low cloud.
  fog,

  /// Rain or drizzle.
  rain,

  /// Snow.
  snow,

  /// Storm.
  storm,
}

/// {@template weather_backdrop}
/// The app's full-screen cinematic background.
///
/// Paints [imageAsset] edge to edge with `BoxFit.cover` when one is
/// supplied and loads, and otherwise falls back to a hand-tuned multi-stop
/// gradient for the [mood]. Either way a scrim is composited on top so
/// white type stays legible over bright or busy imagery.
///
/// Dropping real photography in later is a one-line change at the call
/// site — no layout or scrim retuning needed.
/// {@endtemplate}
class WeatherBackdrop extends StatelessWidget {
  /// {@macro weather_backdrop}
  const WeatherBackdrop({
    required this.mood,
    required this.child,
    super.key,
    this.imageAsset,
  });

  /// The mood to paint when no image is available.
  final BackdropMood mood;

  /// Optional asset path for a full-screen photograph. Falls back to the
  /// [mood] gradient if null or if the asset fails to load.
  final String? imageAsset;

  /// The UI that floats above the background.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // The gradient sits underneath even when an image is present, so a
      // slow-decoding image never flashes bare white.
      decoration: BoxDecoration(gradient: _gradientFor(mood)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageAsset != null)
            Image.asset(
              imageAsset!,
              fit: BoxFit.cover,
              // A missing asset is expected until real photography is
              // added — fall through to the gradient rather than showing
              // Flutter's error box.
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(gradient: _scrim),
            child: SizedBox.expand(),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(gradient: _glow),
            child: SizedBox.expand(),
          ),
          child,
        ],
      ),
    );
  }

  /// Darkens the top and bottom more than the middle: the top carries the
  /// status bar and unit toggle, the bottom the floating nav.
  static const _scrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x8A0B1014),
      Color(0x5C0B1014),
      Color(0x700B1014),
      Color(0xA60B1014),
    ],
    stops: [0, 0.28, 0.7, 1],
  );

  /// A soft highlight in the upper sky so the gradient feels lit rather
  /// than flat.
  static const _glow = RadialGradient(
    center: Alignment(0, -0.55),
    radius: 1.15,
    colors: [
      Color(0x33FFFFFF),
      Color(0x00000000),
    ],
  );

  static LinearGradient _gradientFor(BackdropMood mood) {
    final colors = switch (mood) {
      BackdropMood.clearDay => [
        const Color(0xFF2E6F97),
        const Color(0xFF4E93B0),
        const Color(0xFF9FC4C9),
      ],
      BackdropMood.clearNight => [
        const Color(0xFF0A1020),
        const Color(0xFF16233C),
        const Color(0xFF2B3D57),
      ],
      BackdropMood.partlyCloudy => [
        const Color(0xFF3A5F79),
        const Color(0xFF6F8A99),
        const Color(0xFFA8B6B8),
      ],
      BackdropMood.overcast => [
        const Color(0xFF3B444B),
        const Color(0xFF5E6A72),
        const Color(0xFF8D979D),
      ],
      BackdropMood.fog => [
        const Color(0xFF4A5459),
        const Color(0xFF7E888C),
        const Color(0xFFAEB5B6),
      ],
      BackdropMood.rain => [
        const Color(0xFF1F2A33),
        const Color(0xFF3C4E5C),
        const Color(0xFF61757F),
      ],
      BackdropMood.snow => [
        const Color(0xFF43525E),
        const Color(0xFF7C8B97),
        const Color(0xFFBFC8CE),
      ],
      BackdropMood.storm => [
        const Color(0xFF14181F),
        const Color(0xFF2A323C),
        const Color(0xFF454F5B),
      ],
    };

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
    );
  }
}
