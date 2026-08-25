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
/// depend on a settings or location feature. [_readAmbientSensor] is
/// likewise injected: on most phones there is no real ambient-temperature
/// sensor, so it is expected to be `null` or to resolve to `null`, in which
/// case the room temperature is estimated from the real outside temperature
/// plus the indoor offset via [_estimator].
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

  StreamSubscription<Reading?>? _subscription;

  void _onReadingReceived(Reading? reading) {
    if (reading == null) {
      return;
    }
    emit(TemperatureState.loaded(reading: reading));
  }

  void _onWatchError(Object error) {
    emit(
      TemperatureState.error(
        errorMessage: error.toString(),
        reading: state.reading,
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
    emit(TemperatureState.loading(reading: state.reading));
    try {
      final location = await _getLocation();
      final outsideTemperatureCelsius = await _weatherRepository
          .fetchOutsideTemperatureCelsius(
            location: location,
          );
      final sensorTemperatureCelsius = await _readAmbientSensor?.call();

      final Reading reading;
      if (sensorTemperatureCelsius != null) {
        reading = Reading(
          roomTemperatureCelsius: sensorTemperatureCelsius,
          roomTemperatureSource: RoomTemperatureSource.sensor,
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

      await _temperatureRepository.recordReading(
        userId: userId,
        reading: reading,
      );

      emit(TemperatureState.loaded(reading: reading));
    } on Exception catch (error) {
      emit(
        TemperatureState.error(
          errorMessage: error.toString(),
          reading: state.reading,
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
