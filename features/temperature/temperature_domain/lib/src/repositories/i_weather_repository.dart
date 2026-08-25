import 'package:temperature_domain/src/models/location.dart';

/// {@template i_weather_repository}
/// Fetches the real outside temperature for a given [Location].
/// {@endtemplate}
// ignore: one_member_abstracts
abstract interface class IWeatherRepository {
  /// Fetches the current real outside temperature in Celsius at [location].
  Future<double> fetchOutsideTemperatureCelsius({required Location location});
}
