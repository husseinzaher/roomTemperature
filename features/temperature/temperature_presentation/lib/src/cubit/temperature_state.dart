import 'package:equatable/equatable.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// The lifecycle status of a [TemperatureState].
enum TemperatureStatus {
  /// A reading is being fetched or refreshed.
  loading,

  /// A reading is available.
  loaded,

  /// The most recent fetch or refresh failed.
  error,

  /// The user-selected indoor source is not available on this device.
  sourceUnavailable,
}

/// {@template temperature_state}
/// State for TemperatureCubit.
///
/// [reading] may be non-null even while [status] is [TemperatureStatus.loading]
/// or [TemperatureStatus.error] — e.g. a cached reading is shown while a
/// refresh is in flight, or while a refresh has failed.
///
/// [weather] carries the full outside conditions (humidity, wind, sunset,
/// and so on) for the current [reading]. It is null when the reading came
/// from storage rather than a live fetch, since only the two temperatures
/// are persisted — the dashboard shows placeholders for the detail stats in
/// that case.
/// {@endtemplate}
class TemperatureState extends Equatable {
  /// {@macro temperature_state}
  const TemperatureState({
    this.status = TemperatureStatus.loading,
    this.reading,
    this.weather,
    this.errorMessage,
  });

  /// The initial state: loading, with no reading yet.
  const TemperatureState.loading({this.reading, this.weather})
    : status = TemperatureStatus.loading,
      errorMessage = null;

  /// A state with a successfully loaded [reading], and [weather] when the
  /// reading came from a live fetch.
  const TemperatureState.loaded({required Reading this.reading, this.weather})
    : status = TemperatureStatus.loaded,
      errorMessage = null;

  /// A state where the most recent fetch or refresh failed with
  /// [errorMessage], optionally preserving a previously loaded [reading]
  /// and [weather].
  const TemperatureState.error({
    required String this.errorMessage,
    this.reading,
    this.weather,
  }) : status = TemperatureStatus.error;

  /// The selected indoor source cannot produce a reading on this device.
  const TemperatureState.sourceUnavailable({this.reading, this.weather})
    : status = TemperatureStatus.sourceUnavailable,
      errorMessage =
          'This indoor temperature source is unavailable on this '
          'device. Choose another source in Settings.';

  /// The current lifecycle status.
  final TemperatureStatus status;

  /// The most recently known reading, if any.
  final Reading? reading;

  /// The full outside conditions behind [reading], when known.
  final OutsideWeather? weather;

  /// A human-readable error message, set when [status] is
  /// [TemperatureStatus.error] or [TemperatureStatus.sourceUnavailable].
  final String? errorMessage;

  @override
  List<Object?> get props => [status, reading, weather, errorMessage];
}
