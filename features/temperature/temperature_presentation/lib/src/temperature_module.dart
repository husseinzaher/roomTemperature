import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:temperature_presentation/src/cubit/temperature_cubit.dart';

/// {@template temperature_module}
/// Wires up a [TemperatureCubit] and provides it to [child] via
/// [BlocProvider].
///
/// This is the single entry point app-assembly code should use to mount the
/// temperature feature: it takes concrete repositories plus the small set
/// of closures the cubit needs (device location, indoor offset, and an
/// optional real ambient sensor reader) and builds the cubit from them.
/// {@endtemplate}
class TemperatureModule extends StatelessWidget {
  /// {@macro temperature_module}
  const TemperatureModule({
    required this.userId,
    required this.temperatureRepository,
    required this.weatherRepository,
    required this.estimator,
    required this.getLocation,
    required this.getIndoorOffset,
    required this.child,
    this.readAmbientSensor,
    super.key,
  });

  /// The id of the user this module tracks readings for.
  final String userId;

  /// Persists and streams the user's readings.
  final ITemperatureRepository temperatureRepository;

  /// Fetches the real outside temperature.
  final IWeatherRepository weatherRepository;

  /// Estimates the room temperature when no real sensor is available.
  final RoomTemperatureEstimator estimator;

  /// Resolves the device's current [Location].
  final Future<Location> Function() getLocation;

  /// Resolves the user's current indoor offset in Celsius.
  final double Function() getIndoorOffset;

  /// Optionally resolves a real ambient sensor reading in Celsius, or
  /// `null` when no such sensor is available — which is the common case,
  /// since most phones have no real ambient-temperature sensor.
  final Future<double?> Function()? readAmbientSensor;

  /// The subtree that can access the provided [TemperatureCubit].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TemperatureCubit(
        userId: userId,
        temperatureRepository: temperatureRepository,
        weatherRepository: weatherRepository,
        estimator: estimator,
        getLocation: getLocation,
        getIndoorOffset: getIndoorOffset,
        readAmbientSensor: readAmbientSensor,
      ),
      child: child,
    );
  }
}
