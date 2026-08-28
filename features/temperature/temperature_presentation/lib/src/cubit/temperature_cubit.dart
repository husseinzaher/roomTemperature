import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:temperature_presentation/src/cubit/temperature_state.dart';

/// {@template temperature_cubit}
/// Loads, refreshes, and streams the latest [Reading].
///
/// Indoor and outdoor paths are independent: a weather/location failure
/// must not block a local indoor estimate, and indoor resolution never
/// requires a network.
/// {@endtemplate}
class TemperatureCubit extends Cubit<TemperatureState> {
  /// {@macro temperature_cubit}
  TemperatureCubit({
    required ITemperatureRepository temperatureRepository,
    required this._weatherRepository,
    required this._estimator,
    required this._getLocation,
    required this._getIndoorOffset,
    this._readAmbientSensor,
    this._resolveIndoorTemperature,
    this._loadCachedWeather,
    this._persistWeather,
  }) : _temperatureRepository = temperatureRepository,
       super(const TemperatureState.loading()) {
    _subscription = temperatureRepository.watchLatestReading().listen(
      _onReadingReceived,
      onError: _onWatchError,
    );
    unawaited(_seedCachedWeather());
  }

  final ITemperatureRepository _temperatureRepository;
  final IWeatherRepository _weatherRepository;
  final RoomTemperatureEstimator _estimator;
  final Future<Location> Function() _getLocation;
  final double Function() _getIndoorOffset;
  final Future<double?> Function()? _readAmbientSensor;
  final Future<IndoorTemperatureReading?> Function()? _resolveIndoorTemperature;
  final Future<OutsideWeather?> Function()? _loadCachedWeather;
  final Future<void> Function(OutsideWeather weather)? _persistWeather;

  StreamSubscription<Reading?>? _subscription;

  Future<void> _seedCachedWeather() async {
    final loader = _loadCachedWeather;
    if (loader == null) {
      return;
    }
    try {
      final cached = await loader();
      if (cached == null || isClosed || state.weather != null) {
        return;
      }
      final reading = state.reading;
      if (reading != null) {
        emit(TemperatureState.loaded(reading: reading, weather: cached));
      } else {
        emit(TemperatureState.loading(weather: cached));
      }
    } on Exception {
      // Corrupt cache must not block startup.
    }
  }

  void _onReadingReceived(Reading? reading) {
    if (reading == null) {
      return;
    }
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

  /// Refreshes indoor (local) and outdoor (weather) independently.
  Future<void> refresh() async {
    emit(
      TemperatureState.loading(reading: state.reading, weather: state.weather),
    );

    IndoorTemperatureReading? indoor;
    Object? indoorError;
    if (_resolveIndoorTemperature != null) {
      try {
        indoor = await _resolveIndoorTemperature();
      } on Exception catch (error) {
        indoorError = error;
      }
    }

    OutsideWeather? weather;
    Object? weatherError;
    try {
      final location = await _getLocation();
      weather = await _weatherRepository.fetchOutsideWeather(
        location: location,
      );
      final persist = _persistWeather;
      if (persist != null && weather != null) {
        await persist(weather);
      }
    } on Exception catch (error) {
      weatherError = error;
      weather = state.weather;
      if (weather == null) {
        try {
          weather = await _loadCachedWeather?.call();
        } on Exception {
          weather = null;
        }
      }
    }

    final outsideTemperatureCelsius =
        weather?.temperatureCelsius ?? state.reading?.outsideTemperatureCelsius;

    if (_resolveIndoorTemperature != null) {
      if (indoor == null) {
        if (weather != null) {
          emit(
            TemperatureState.sourceUnavailable(
              reading: state.reading,
              weather: weather,
            ),
          );
          return;
        }
        emit(
          TemperatureState.error(
            errorMessage: (indoorError ?? weatherError).toString(),
            reading: state.reading,
            weather: state.weather,
          ),
        );
        return;
      }

      final reading = Reading(
        roomTemperatureCelsius: indoor.celsius,
        roomTemperatureSource: indoor.source,
        outsideTemperatureCelsius: outsideTemperatureCelsius,
        timestamp: DateTime.now(),
        indoorConfidence: indoor.confidence,
      );
      emit(
        TemperatureState.loaded(
          reading: reading,
          weather: weather ?? state.weather,
        ),
      );
      await _persist(reading);
      return;
    }

    if (weather == null) {
      emit(
        TemperatureState.error(
          errorMessage: (weatherError ?? Exception('network down')).toString(),
          reading: state.reading,
          weather: state.weather,
        ),
      );
      return;
    }

    final sensorTemperatureCelsius = await _readAmbientSensor?.call();
    final Reading reading;
    if (sensorTemperatureCelsius != null) {
      reading = Reading(
        roomTemperatureCelsius: sensorTemperatureCelsius,
        roomTemperatureSource: RoomTemperatureSource.ambientSensor,
        outsideTemperatureCelsius: weather.temperatureCelsius,
        timestamp: DateTime.now(),
      );
    } else {
      final estimatedRoomTemperatureCelsius = _estimator.estimate(
        outsideTemperatureCelsius: weather.temperatureCelsius,
        indoorOffsetCelsius: _getIndoorOffset(),
      );
      reading = Reading(
        roomTemperatureCelsius: estimatedRoomTemperatureCelsius,
        roomTemperatureSource: RoomTemperatureSource.estimated,
        outsideTemperatureCelsius: weather.temperatureCelsius,
        timestamp: DateTime.now(),
      );
    }

    emit(TemperatureState.loaded(reading: reading, weather: weather));
    await _persist(reading);
  }

  Future<void> _persist(Reading reading) async {
    try {
      await _temperatureRepository.recordReading(reading: reading);
    } on Exception {
      // Deliberately swallowed — the reading is already on screen.
    }
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
