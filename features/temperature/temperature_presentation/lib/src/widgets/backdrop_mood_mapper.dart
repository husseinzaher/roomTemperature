import 'package:temperature_domain/temperature_domain.dart';
import 'package:ui_kit/ui_kit.dart';

/// Maps the temperature feature's [WeatherCondition] onto the `ui_kit`
/// [BackdropMood], and onto the background asset path for that mood.
///
/// This adapter lives in the feature (not in `ui_kit`) so the shared UI
/// package stays free of any feature's domain model.
abstract final class BackdropMoodMapper {
  /// The mood to paint for [condition] at this time of day.
  static BackdropMood moodFor(
    WeatherCondition condition, {
    required bool isDay,
  }) {
    return switch (condition) {
      WeatherCondition.clear =>
        isDay ? BackdropMood.clearDay : BackdropMood.clearNight,
      WeatherCondition.partlyCloudy =>
        isDay ? BackdropMood.partlyCloudy : BackdropMood.clearNight,
      WeatherCondition.cloudy => BackdropMood.overcast,
      WeatherCondition.fog => BackdropMood.fog,
      WeatherCondition.drizzle || WeatherCondition.rain => BackdropMood.rain,
      WeatherCondition.snow => BackdropMood.snow,
      WeatherCondition.thunderstorm => BackdropMood.storm,
    };
  }

  /// The asset path holding the photograph for [mood].
  ///
  /// Nothing ships at these paths yet — [WeatherBackdrop] falls back to its
  /// gradient for a missing asset, so dropping real photography into
  /// `assets/backgrounds/` is all that's needed to switch the app over to
  /// cinematic imagery. The app's `pubspec.yaml` already declares the
  /// directory.
  static String assetFor(BackdropMood mood) {
    final name = switch (mood) {
      BackdropMood.clearDay => 'clear_day',
      BackdropMood.clearNight => 'clear_night',
      BackdropMood.partlyCloudy => 'partly_cloudy',
      BackdropMood.overcast => 'overcast',
      BackdropMood.fog => 'fog',
      BackdropMood.rain => 'rain',
      BackdropMood.snow => 'snow',
      BackdropMood.storm => 'storm',
    };
    return 'assets/backgrounds/$name.jpg';
  }
}
