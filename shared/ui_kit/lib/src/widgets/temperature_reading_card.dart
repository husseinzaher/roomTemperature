import 'package:flutter/material.dart';

/// The direction a temperature reading is trending.
enum TemperatureTrend {
  /// The reading is rising.
  up,

  /// The reading is falling.
  down,

  /// The reading is stable.
  stable,
}

/// {@template temperature_reading_card}
/// A large card that displays a single temperature reading.
///
/// Shows the value in large type, a [label] (e.g. "Room" / "Outside"), a
/// chip indicating whether the reading [isEstimated] or came from a sensor,
/// a leading [icon], and an optional [trend] arrow.
/// {@endtemplate}
class TemperatureReadingCard extends StatelessWidget {
  /// {@macro temperature_reading_card}
  const TemperatureReadingCard({
    required this.label,
    required this.temperatureCelsius,
    required this.icon,
    super.key,
    this.useFahrenheit = false,
    this.isEstimated = false,
    this.accentColor,
    this.trend,
    this.onTap,
  });

  /// The label describing the reading, e.g. "Room" or "Outside".
  final String label;

  /// The temperature value, always supplied in Celsius.
  final double temperatureCelsius;

  /// Whether to render the value in Fahrenheit instead of Celsius.
  final bool useFahrenheit;

  /// Whether this reading is an estimate rather than a direct sensor read.
  final bool isEstimated;

  /// The icon shown above the label.
  final IconData icon;

  /// An optional accent color for the icon and trend arrow.
  final Color? accentColor;

  /// An optional trend indicator.
  final TemperatureTrend? trend;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  double get _displayValue =>
      useFahrenheit ? (temperatureCelsius * 9 / 5) + 32 : temperatureCelsius;

  String get _unitSuffix => useFahrenheit ? '°F' : '°C';

  IconData? get _trendIcon => switch (trend) {
    TemperatureTrend.up => Icons.arrow_upward,
    TemperatureTrend.down => Icons.arrow_downward,
    TemperatureTrend.stable => Icons.trending_flat,
    null => null,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = accentColor ?? colorScheme.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  _EstimatedOrSensorChip(isEstimated: isEstimated),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_displayValue.toStringAsFixed(1)}$_unitSuffix',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_trendIcon != null) ...[
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: 8),
                      child: Icon(_trendIcon, color: color, size: 20),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstimatedOrSensorChip extends StatelessWidget {
  const _EstimatedOrSensorChip({required this.isEstimated});

  final bool isEstimated;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(isEstimated ? 'Estimated' : 'Sensor'),
      avatar: Icon(
        isEstimated ? Icons.auto_awesome : Icons.sensors,
        size: 16,
        color: colorScheme.onSurfaceVariant,
      ),
      side: BorderSide.none,
    );
  }
}
