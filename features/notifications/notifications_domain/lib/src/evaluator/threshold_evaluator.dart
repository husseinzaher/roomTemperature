import 'package:notifications_domain/src/models/threshold_breach.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// {@template threshold_evaluator}
/// Pure logic that decides whether a [Reading]'s room temperature breaches
/// a user's [ThresholdSettings].
/// {@endtemplate}
class ThresholdEvaluator {
  /// {@macro threshold_evaluator}
  const ThresholdEvaluator();

  /// Evaluates [reading] against [settings], returning the kind of breach
  /// (if any).
  ///
  /// Returns [ThresholdBreach.none] when thresholds are disabled, or when
  /// the room temperature is within `[settings.minCelsius,
  /// settings.maxCelsius]` inclusive.
  ThresholdBreach evaluate({
    required Reading reading,
    required ThresholdSettings settings,
  }) {
    if (!settings.enabled) return ThresholdBreach.none;
    if (reading.roomTemperatureCelsius < settings.minCelsius) {
      return ThresholdBreach.belowMinimum;
    }
    if (reading.roomTemperatureCelsius > settings.maxCelsius) {
      return ThresholdBreach.aboveMaximum;
    }
    return ThresholdBreach.none;
  }
}
