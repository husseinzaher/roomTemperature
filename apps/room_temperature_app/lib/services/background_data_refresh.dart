import 'package:temperature_domain/temperature_domain.dart';

/// One background tick: indoor (local) then outdoor (best-effort), then
/// persist, widget, and threshold alerts.
///
/// Indoor never waits on weather. Weather failure still publishes indoor.
class BackgroundDataRefresh {
  /// Creates a background refresh runner.
  const BackgroundDataRefresh({
    required this.resolveIndoor,
    required this.fetchWeather,
    required this.readLatest,
    required this.persist,
    required this.syncWidget,
    required this.checkThresholds,
  });

  /// Local indoor calculation. Must not use the network.
  final Future<IndoorTemperatureReading?> Function() resolveIndoor;

  /// Outdoor weather. May throw or return null when offline.
  final Future<OutsideWeather?> Function() fetchWeather;

  /// Cached last reading, used when outdoor is missing.
  final Future<Reading?> Function() readLatest;

  /// Persist a combined reading. May no-op if outdoor is still unknown.
  final Future<void> Function(Reading reading) persist;

  /// Push the latest values to the home-screen widget.
  final Future<void> Function(Reading reading, OutsideWeather? weather)
  syncWidget;

  /// Threshold alerts against the latest stored reading.
  final Future<void> Function() checkThresholds;

  /// Runs one independent indoor + outdoor cycle.
  Future<void> run() async {
    IndoorTemperatureReading? indoor;
    try {
      indoor = await resolveIndoor();
    } on Exception {
      indoor = null;
    }

    OutsideWeather? weather;
    try {
      weather = await fetchWeather();
    } on Exception {
      weather = null;
    }

    final latest = await readLatest();
    final outside =
        weather?.temperatureCelsius ?? latest?.outsideTemperatureCelsius;
    final now = DateTime.now();

    if (indoor != null) {
      final reading = Reading(
        roomTemperatureCelsius: indoor.celsius,
        roomTemperatureSource: indoor.source,
        outsideTemperatureCelsius: outside,
        timestamp: now,
        indoorConfidence: indoor.confidence,
      );
      await persist(reading);
      await syncWidget(reading, weather);
    } else if (latest != null) {
      final reading = Reading(
        roomTemperatureCelsius: latest.roomTemperatureCelsius,
        roomTemperatureSource: latest.roomTemperatureSource,
        outsideTemperatureCelsius: outside,
        timestamp: now,
        indoorConfidence: latest.indoorConfidence,
      );
      if (weather != null) {
        await persist(reading);
      }
      await syncWidget(reading, weather);
    }

    try {
      await checkThresholds();
    } on Exception {
      // Alerts must not roll back a successful indoor update.
    }
  }
}
