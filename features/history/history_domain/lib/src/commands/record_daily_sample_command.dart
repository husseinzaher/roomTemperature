import 'package:history_domain/src/repositories/i_history_repository.dart';

/// {@template record_daily_sample_command}
/// Incorporates one raw temperature sample into a day's running average via
/// an [IHistoryRepository].
///
/// Callers pass raw temperature values already extracted from a `Reading` —
/// this command (and the history feature as a whole) has zero dependency on
/// the temperature feature.
/// {@endtemplate}
class RecordDailySampleCommand {
  /// {@macro record_daily_sample_command}
  const RecordDailySampleCommand({required this._historyRepository});

  final IHistoryRepository _historyRepository;

  /// Records a new sample for [userId] on [day].
  Future<void> execute({
    required String userId,
    required DateTime day,
    required double roomTemperatureCelsius,
    required double outsideTemperatureCelsius,
  }) {
    return _historyRepository.recordSample(
      userId: userId,
      day: day,
      roomTemperatureCelsius: roomTemperatureCelsius,
      outsideTemperatureCelsius: outsideTemperatureCelsius,
    );
  }
}
