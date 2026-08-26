import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:temperature_presentation/src/cubit/temperature_state.dart';

/// {@template temperature_cubit}
/// Loads, refreshes, and streams the latest [Reading] for a user.
///
/// This cubit is deliberately ignorant of *how* the device location and the
/// user's indoor offset are obtained — those are injected as closures
/// ([_getLocation], [_getIndoorOffset]) so this package never needs to
/// depend on a settings or location feature. When
/// [_resolveIndoorTemperature] is provided, that resolver owns indoor
/// source selection. [_readAmbientSensor] remains a test/legacy fallback
/// used only when no resolver is injected.
/// {@endtemplate}
class TemperatureCubit extends Cubit<TemperatureState> {
  /// {@macro temperature_cubit}
  TemperatureCubit({
    required this.userId,
    required ITemperatureRepository temperatureRepository,
    required this._weatherRepository,
    required this._estimator,
    required this._getLocation,
    required this._getIndoorOffset,
    this._readAmbientSensor,
    this._resolveIndoorTemperature,
  }) : _temperatureRepository = temperatureRepository,
       super(const TemperatureState.loading()) {
    _subscription = temperatureRepository
        .watchLatestReading(userId: userId)
        .listen(_onReadingReceived, onError: _onWatchError);
  }

  /// The id of the user this cubit tracks readings for.
  final String userId;

  final ITemperatureRepository _temperatureRepository;
  final IWeatherRepository _weatherRepository;
  final RoomTemperatureEstimator _estimator;
  final Future<Location> Function() _getLocation;
  final double Function() _getIndoorOffset;
  final Future<double?> Function()? _readAmbientSensor;
  final Future<IndoorTemperatureReading?> Function(OutsideWeather weather)?
  _resolveIndoorTemperature;

  StreamSubscription<Reading?>? _subscription;

  void _onReadingReceived(Reading? reading) {
    if (reading == null) {
      return;
    }
    // Preserve any weather detail already fetched this session: only the two
    // temperatures round-trip through storage, so a stored reading arriving
    // here must not blank out the stat grid.
    emit(TemperatureState.loaded(reading: reading, weather: state.weather));
  }

  void _onWatchError(Object error) {
    emit(
      TemperatureState.error(
        errorMessage: error.toString(),
        reading: state.reading,
        weather: state.weather,
      ),
    );
  }

  /// Fetches the real outside temperature, determines the room temperature
  /// (from a real sensor if [_readAmbientSensor] resolves to a value,
  /// otherwise estimated via [_estimator]), records the resulting [Reading],
  /// and emits a loaded state immediately.
  ///
  /// The [_temperatureRepository]'s `watchLatestReading` stream will also
  /// eventually emit the same reading once it round-trips through storage,
  /// but this emits directly first so the UI updates without waiting on
  /// that round trip.
  Future<void> refresh() async {
    emit(
      TemperatureState.loading(reading: state.reading, weather: state.weather),
    );
    try {
      final location = await _getLocation();
      final weather = await _weatherRepository.fetchOutsideWeather(
        location: location,
      );
      final outsideTemperatureCelsius = weather.temperatureCelsius;

      final Reading reading;
      final resolvedIndoorTemperature = await _resolveIndoorTemperature?.call(
        weather,
      );
      if (resolvedIndoorTemperature != null) {
        reading = Reading(
          roomTemperatureCelsius: resolvedIndoorTemperature.celsius,
          roomTemperatureSource: resolvedIndoorTemperature.source,
          outsideTemperatureCelsius: outsideTemperatureCelsius,
          timestamp: DateTime.now(),
        );
      } else if (_resolveIndoorTemperature != null) {
        emit(
          TemperatureState.sourceUnavailable(
            reading: state.reading,
            weather: weather,
          ),
        );
        return;
      } else {
        final sensorTemperatureCelsius = await _readAmbientSensor?.call();
        if (sensorTemperatureCelsius != null) {
          reading = Reading(
            roomTemperatureCelsius: sensorTemperatureCelsius,
            roomTemperatureSource: RoomTemperatureSource.ambientSensor,
            outsideTemperatureCelsius: outsideTemperatureCelsius,
            timestamp: DateTime.now(),
          );
        } else {
          final estimatedRoomTemperatureCelsius = _estimator.estimate(
            outsideTemperatureCelsius: outsideTemperatureCelsius,
            indoorOffsetCelsius: _getIndoorOffset(),
          );
          reading = Reading(
            roomTemperatureCelsius: estimatedRoomTemperatureCelsius,
            roomTemperatureSource: RoomTemperatureSource.estimated,
            outsideTemperatureCelsius: outsideTemperatureCelsius,
            timestamp: DateTime.now(),
          );
        }
      }

      // Show the fresh reading regardless of whether it persists: storage
      // is a cache for the next cold start, not a precondition for
      // displaying data we already hold. Losing a whole refresh because
      // the backend rejected the write would be the wrong trade.
      emit(TemperatureState.loaded(reading: reading, weather: weather));

      try {
        await _temperatureRepository.recordReading(
          userId: userId,
          reading: reading,
        );
      } on Exception {
        // Deliberately swallowed — the reading is already on screen, and
        // the history feature surfaces its own persistence errors.
      }
    } on Exception catch (error) {
      emit(
        TemperatureState.error(
          errorMessage: error.toString(),
          reading: state.reading,
          weather: state.weather,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
