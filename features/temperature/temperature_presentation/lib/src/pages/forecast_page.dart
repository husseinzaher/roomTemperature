import 'package:app_localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';
import 'package:temperature_presentation/src/cubit/temperature_cubit.dart';
import 'package:temperature_presentation/src/format/weather_format.dart';
import 'package:temperature_presentation/src/widgets/weather_icon.dart';
import 'package:ui_kit/ui_kit.dart';

/// Simple 5-day outdoor forecast list from the cached [OutsideWeather].
class ForecastPage extends StatelessWidget {
  /// Creates a forecast page.
  const ForecastPage({required this.units, super.key});

  /// Display units.
  final Units units;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weather = context.watch<TemperatureCubit>().state.weather;
    final days = weather?.forecastDays ?? const <DailyForecast>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: GlassTokens.onGlass,
                  ),
                ),
                Expanded(child: GlassPageHeader(title: l10n.fiveDayForecast)),
              ],
            ),
            const SizedBox(height: 16),
            if (days.isEmpty)
              GlassCard(
                child: Text(
                  l10n.noForecastYet,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: GlassTokens.onGlassMuted,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              )
            else
              for (final day in days) ...[
                GlassCard(
                  child: Row(
                    children: [
                      WeatherIcon(
                        WeatherIcons.forCondition(day.condition),
                        size: 32,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _dayLabel(day.date),
                          style: const TextStyle(
                            color: GlassTokens.onGlass,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        _range(day),
                        style: const TextStyle(
                          color: GlassTokens.onGlass,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }

  String _dayLabel(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday ${date.month}/${date.day}';
  }

  String _range(DailyForecast day) {
    final high = WeatherFormat.temperatureValue(day.maxCelsius, units);
    final low = WeatherFormat.temperatureValue(day.minCelsius, units);
    return '$high${units.symbol} / $low${units.symbol}';
  }
}
