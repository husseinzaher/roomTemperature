import 'package:equatable/equatable.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// The lifecycle status of a [TemperatureState].
enum TemperatureStatus {
  /// A reading is being fetched or refreshed.
  loading,

  /// A reading is available.
  loaded,

  /// The most recent fetch or refresh failed.
  error,
}

/// {@template temperature_state}
/// State for TemperatureCubit.
///
/// [reading] may be non-null even while [status] is [TemperatureStatus.loading]
/// or [TemperatureStatus.error] — e.g. a cached reading is shown while a
/// refresh is in flight, or while a refresh has failed.
/// {@endtemplate}
class TemperatureState extends Equatable {
  /// {@macro temperature_state}
  const TemperatureState({
    this.status = TemperatureStatus.loading,
    this.reading,
    this.errorMessage,
  });

  /// The initial state: loading, with no reading yet.
  const TemperatureState.loading({this.reading})
    : status = TemperatureStatus.loading,
      errorMessage = null;

  /// A state with a successfully loaded [reading].
  const TemperatureState.loaded({required Reading this.reading})
    : status = TemperatureStatus.loaded,
      errorMessage = null;

  /// A state where the most recent fetch or refresh failed with
  /// [errorMessage], optionally preserving a previously loaded [reading].
  const TemperatureState.error({
    required String this.errorMessage,
    this.reading,
  }) : status = TemperatureStatus.error;

  /// The current lifecycle status.
  final TemperatureStatus status;

  /// The most recently known reading, if any.
  final Reading? reading;

  /// A human-readable error message, set only when [status] is
  /// [TemperatureStatus.error].
  final String? errorMessage;

  @override
  List<Object?> get props => [status, reading, errorMessage];
}
