import 'dart:convert';

import 'package:local_database/local_database.dart';
import 'package:temperature_domain/temperature_domain.dart';

/// Persists indoor-estimator calibration and running state in Drift
/// key/value settings. Independent of weather and of user settings.
class IndoorEstimatorStore {
  /// Creates a store backed by [database].
  IndoorEstimatorStore({required AppDatabase database}) : _database = database;

  static const String profileKey = 'indoorCalibrationProfile';
  static const String stateKey = 'indoorEstimatorState';

  final AppDatabase _database;

  IndoorCalibrationProfile? _profile;
  IndoorEstimatorState? _state;

  /// Last loaded profile, or empty before the first read.
  IndoorCalibrationProfile get profileOrEmpty =>
      _profile ?? IndoorCalibrationProfile.empty;

  /// Last loaded estimator state, or empty before the first read.
  IndoorEstimatorState get stateOrEmpty => _state ?? IndoorEstimatorState.empty;

  /// Loads the calibration profile from local storage.
  Future<IndoorCalibrationProfile> loadProfile() async {
    final raw = await _database.readSetting(profileKey);
    _profile = _decodeProfile(raw);
    return _profile!;
  }

  /// Loads the running estimator state from local storage.
  Future<IndoorEstimatorState> loadState() async {
    final raw = await _database.readSetting(stateKey);
    _state = _decodeState(raw);
    return _state!;
  }

  /// Writes [profile] locally.
  Future<void> saveProfile(IndoorCalibrationProfile profile) async {
    _profile = profile;
    await _database.writeSetting(profileKey, jsonEncode(profile.toJson()));
  }

  /// Writes [state] locally.
  Future<void> saveState(IndoorEstimatorState state) async {
    _state = state;
    await _database.writeSetting(stateKey, jsonEncode(state.toJson()));
  }

  IndoorCalibrationProfile _decodeProfile(String? raw) {
    if (raw == null || raw.isEmpty) {
      return IndoorCalibrationProfile.empty;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return IndoorCalibrationProfile.fromJson(decoded);
      }
      if (decoded is Map) {
        return IndoorCalibrationProfile.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } on FormatException {
      return IndoorCalibrationProfile.empty;
    }
    return IndoorCalibrationProfile.empty;
  }

  IndoorEstimatorState _decodeState(String? raw) {
    if (raw == null || raw.isEmpty) {
      return IndoorEstimatorState.empty;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return IndoorEstimatorState.fromJson(decoded);
      }
      if (decoded is Map) {
        return IndoorEstimatorState.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } on FormatException {
      return IndoorEstimatorState.empty;
    }
    return IndoorEstimatorState.empty;
  }
}
