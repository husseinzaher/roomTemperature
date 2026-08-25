import 'package:equatable/equatable.dart';
import 'package:settings_domain/src/models/units.dart';

/// {@template threshold_settings}
/// The user's temperature alert threshold configuration.
///
/// When [enabled] is `true`, the notifications feature evaluates incoming
/// readings against [minCelsius] and [maxCelsius] and alerts the user when a
/// reading falls outside that range. Bounds are always stored in Celsius,
/// regardless of the user's display [Units] preference.
/// {@endtemplate}
class ThresholdSettings extends Equatable {
  /// {@macro threshold_settings}
  const ThresholdSettings({
    required this.minCelsius,
    required this.maxCelsius,
    required this.enabled,
  });

  /// The lower bound of the alert range, in Celsius.
  final double minCelsius;

  /// The upper bound of the alert range, in Celsius.
  final double maxCelsius;

  /// Whether threshold alerts are enabled.
  final bool enabled;

  /// Returns a copy of this [ThresholdSettings] with the given fields
  /// replaced.
  ThresholdSettings copyWith({
    double? minCelsius,
    double? maxCelsius,
    bool? enabled,
  }) {
    return ThresholdSettings(
      minCelsius: minCelsius ?? this.minCelsius,
      maxCelsius: maxCelsius ?? this.maxCelsius,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List<Object?> get props => [minCelsius, maxCelsius, enabled];
}
