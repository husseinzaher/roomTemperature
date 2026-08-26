import 'package:temperature_domain/src/models/location.dart';
import 'package:temperature_domain/src/models/outside_weather.dart';

/// {@template i_weather_repository}
/// Fetches the real outside weather for a given [Location].
/// {@endtemplate}
// ignore: one_member_abstracts
abstract interface class IWeatherRepository {
  /// Fetches the current outside weather at [location].
  Future<OutsideWeather> fetchOutsideWeather({required Location location});
}
