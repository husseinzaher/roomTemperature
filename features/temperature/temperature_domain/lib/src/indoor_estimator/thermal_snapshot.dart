import 'package:equatable/equatable.dart';

/// One thermal zone discovered on the device.
class ThermalZoneReading extends Equatable {
  /// Creates a thermal-zone reading.
  const ThermalZoneReading({
    required this.name,
    required this.temperatureCelsius,
    this.timestamp,
  });

  /// Builds a reading from a JSON-like map produced by the platform channel.
  factory ThermalZoneReading.fromJson(Map<String, dynamic> json) {
    return ThermalZoneReading(
      name: json['name'] as String,
      temperatureCelsius: (json['temperatureCelsius'] as num).toDouble(),
      timestamp: json['timestampMs'] is num
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['timestampMs'] as num).toInt(),
            )
          : null,
    );
  }

  /// Kernel / firmware type name, e.g. `sdr0`, `cpu-0`, `xo-therm`.
  final String name;

  /// Temperature in Celsius.
  final double temperatureCelsius;

  /// When this zone was sampled, if the platform provided it.
  final DateTime? timestamp;

  /// JSON map for local persistence.
  Map<String, Object?> toJson() => {
    'name': name,
    'temperatureCelsius': temperatureCelsius,
    if (timestamp != null) 'timestampMs': timestamp!.millisecondsSinceEpoch,
  };

  @override
  List<Object?> get props => [name, temperatureCelsius, timestamp];
}

/// A single local-only snapshot of device thermal signals.
///
/// Contains no location, weather, or network fields.
class ThermalSnapshot extends Equatable {
  /// Creates a thermal snapshot.
  const ThermalSnapshot({
    required this.timestamp,
    required this.isCharging,
    this.batteryCelsius,
    this.batteryLevelPercent,
    this.batteryCurrentMicroamps,
    this.batteryVoltageMillivolts,
    this.screenOn,
    this.thermalStatus,
    this.cpuUsagePercent,
    this.uptime,
    this.zones = const [],
  });

  /// Builds a snapshot from a JSON-like map produced by the platform channel.
  factory ThermalSnapshot.fromJson(Map<String, dynamic> json) {
    final rawZones = json['zones'];
    return ThermalSnapshot(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestampMs'] as num).toInt(),
      ),
      isCharging: json['isCharging'] as bool? ?? false,
      batteryCelsius: (json['batteryCelsius'] as num?)?.toDouble(),
      batteryLevelPercent: (json['batteryLevelPercent'] as num?)?.toInt(),
      batteryCurrentMicroamps: (json['batteryCurrentMicroamps'] as num?)
          ?.toInt(),
      batteryVoltageMillivolts: (json['batteryVoltageMillivolts'] as num?)
          ?.toInt(),
      screenOn: json['screenOn'] as bool?,
      thermalStatus: (json['thermalStatus'] as num?)?.toInt(),
      cpuUsagePercent: (json['cpuUsagePercent'] as num?)?.toDouble(),
      uptime: json['uptimeMs'] is num
          ? Duration(milliseconds: (json['uptimeMs'] as num).toInt())
          : null,
      zones: [
        if (rawZones is List)
          for (final zone in rawZones)
            if (zone is Map)
              ThermalZoneReading.fromJson(
                Map<String, dynamic>.from(zone),
              ),
      ],
    );
  }

  /// When this snapshot was taken.
  final DateTime timestamp;

  /// Battery temperature in Celsius, when Android exposes it.
  final double? batteryCelsius;

  /// Battery charge in percent, 0–100.
  final int? batteryLevelPercent;

  /// Whether the device is plugged in.
  final bool isCharging;

  /// Instantaneous battery current in microamps, if available.
  final int? batteryCurrentMicroamps;

  /// Battery voltage in millivolts, if available.
  final int? batteryVoltageMillivolts;

  /// Instantaneous electrical power in watts (`|I| * V`), if both
  /// current and voltage are present.
  double? get batteryPowerWatts {
    final currentMicroamps = batteryCurrentMicroamps;
    final voltageMillivolts = batteryVoltageMillivolts;
    if (currentMicroamps == null || voltageMillivolts == null) {
      return null;
    }
    if (voltageMillivolts <= 0) {
      return null;
    }
    final amps = currentMicroamps.abs() / 1e6;
    final volts = voltageMillivolts / 1000.0;
    if (!amps.isFinite || !volts.isFinite) {
      return null;
    }
    return amps * volts;
  }

  /// Whether the screen is interactive, if known.
  final bool? screenOn;

  /// Android thermal status integer, if known.
  final int? thermalStatus;

  /// Process CPU usage percent, if a previous sample exists to delta against.
  final double? cpuUsagePercent;

  /// Elapsed realtime since boot, if known.
  final Duration? uptime;

  /// Discovered thermal zones. Empty when sysfs is inaccessible.
  final List<ThermalZoneReading> zones;

  /// JSON map for the platform channel / persistence.
  Map<String, Object?> toJson() => {
    'timestampMs': timestamp.millisecondsSinceEpoch,
    'isCharging': isCharging,
    'batteryCelsius': batteryCelsius,
    'batteryLevelPercent': batteryLevelPercent,
    'batteryCurrentMicroamps': batteryCurrentMicroamps,
    'batteryVoltageMillivolts': batteryVoltageMillivolts,
    'screenOn': screenOn,
    'thermalStatus': thermalStatus,
    'cpuUsagePercent': cpuUsagePercent,
    'uptimeMs': uptime?.inMilliseconds,
    'zones': [for (final zone in zones) zone.toJson()],
  };

  /// Mean of zones whose names look like CPU clusters, if any.
  double? get cpuClusterCelsius {
    final cpus = [
      for (final zone in zones)
        if (_looksLikeCpu(zone.name)) zone.temperatureCelsius,
    ];
    if (cpus.isEmpty) return null;
    return cpus.reduce((a, b) => a + b) / cpus.length;
  }

  /// Mean of zones whose names look like GPU, if any.
  double? get gpuCelsius {
    final gpus = [
      for (final zone in zones)
        if (_looksLikeGpu(zone.name)) zone.temperatureCelsius,
    ];
    if (gpus.isEmpty) return null;
    return gpus.reduce((a, b) => a + b) / gpus.length;
  }

  static bool _looksLikeCpu(String name) {
    final n = name.toLowerCase();
    return n.contains('cpu') ||
        n.contains('cluster') ||
        n.contains('little') ||
        n.contains('big');
  }

  static bool _looksLikeGpu(String name) {
    final n = name.toLowerCase();
    return n.contains('gpu');
  }

  @override
  List<Object?> get props => [
    timestamp,
    batteryCelsius,
    batteryLevelPercent,
    isCharging,
    batteryCurrentMicroamps,
    batteryVoltageMillivolts,
    screenOn,
    thermalStatus,
    cpuUsagePercent,
    uptime,
    zones,
  ];
}
