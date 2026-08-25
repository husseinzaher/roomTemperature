import 'package:temperature_data/src/sources/open_meteo_client.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// {@template open_meteo_weather_repository}
/// An [IWeatherRepository] backed by the free, keyless Open-Meteo weather
/// API (https://open-meteo.com).
/// {@endtemplate}
class OpenMeteoWeatherRepository implements IWeatherRepository {
  /// {@macro open_meteo_weather_repository}
  const OpenMeteoWeatherRepository(this._client);

  final OpenMeteoClient _client;

  @override
  Future<double> fetchOutsideTemperatureCelsius({required Location location}) {
    return _client.fetchCurrentTemperatureCelsius(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }
}
