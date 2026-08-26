import 'package:equatable/equatable.dart';
import 'package:settings_domain/src/models/indoor_temperature_preference.dart';
import 'package:settings_domain/src/models/threshold_settings.dart';
import 'package:settings_domain/src/models/units.dart';

/// {@template user_settings}
/// The full set of user-configurable settings owned by the settings
/// feature: display [units], the [threshold] alert configuration, and the
/// [indoorOffsetCelsius] calibration offset.
///
/// [indoorOffsetCelsius] is added to a real outside-temperature reading by
/// the temperature feature's `RoomTemperatureEstimator` to produce the
/// room-temperature estimate; letting the user calibrate it against a real
/// thermometer they own is the entire point of exposing it here.
/// {@endtemplate}
class UserSettings extends Equatable {
  /// {@macro user_settings}
  const UserSettings({
    required this.units,
    required this.threshold,
    required this.indoorOffsetCelsius,
    this.indoorTemperaturePreference = IndoorTemperaturePreference.automatic,
    this.manualIndoorTemperatureCelsius,
  });

  /// A sensible set of defaults for a brand-new user: Celsius display units,
  /// an 18-28°C threshold range that is disabled until the user opts in, and
  /// no indoor offset calibration.
  factory UserSettings.defaults() => const UserSettings(
    units: Units.celsius,
    threshold: ThresholdSettings(
      minCelsius: 18,
      maxCelsius: 28,
      enabled: false,
    ),
    indoorOffsetCelsius: 0,
    indoorTemperaturePreference: IndoorTemperaturePreference.automatic,
  );

  /// The user's preferred display unit.
  final Units units;

  /// The user's alert threshold configuration.
  final ThresholdSettings threshold;

  /// The calibration offset, in Celsius, added to a real outside reading to
  /// produce the room-temperature estimate.
  final double indoorOffsetCelsius;

  /// The user's preferred indoor-temperature source.
  final IndoorTemperaturePreference indoorTemperaturePreference;

  /// The manually entered indoor temperature, used only when
  /// [indoorTemperaturePreference] is [IndoorTemperaturePreference.manual].
  final double? manualIndoorTemperatureCelsius;

  /// Returns a copy of this [UserSettings] with the given fields replaced.
  UserSettings copyWith({
    Units? units,
    ThresholdSettings? threshold,
    double? indoorOffsetCelsius,
    IndoorTemperaturePreference? indoorTemperaturePreference,
    double? manualIndoorTemperatureCelsius,
  }) {
    return UserSettings(
      units: units ?? this.units,
      threshold: threshold ?? this.threshold,
      indoorOffsetCelsius: indoorOffsetCelsius ?? this.indoorOffsetCelsius,
      indoorTemperaturePreference:
          indoorTemperaturePreference ?? this.indoorTemperaturePreference,
      manualIndoorTemperatureCelsius:
          manualIndoorTemperatureCelsius ?? this.manualIndoorTemperatureCelsius,
    );
  }

  @override
  List<Object?> get props => [
    units,
    threshold,
    indoorOffsetCelsius,
    indoorTemperaturePreference,
    manualIndoorTemperatureCelsius,
  ];
}
