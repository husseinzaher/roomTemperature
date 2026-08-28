import 'package:temperature_domain/src/indoor_estimator/indoor_estimator_models.dart';

/// Classifies thermal-zone type names without assuming a fixed sensor list.
class ThermalZoneClassifier {
  /// Creates a classifier.
  const ThermalZoneClassifier();

  /// Name-based prior. Behavioural scoring may still promote unknowns.
  ThermalZoneClass classifyName(String rawName) {
    final name = rawName.toLowerCase().trim();
    if (name.isEmpty) {
      return ThermalZoneClass.candidate;
    }
    if (isCpuName(name) || isGpuName(name) || _isComponent(name)) {
      return ThermalZoneClass.component;
    }
    if (_isEnvironmental(name)) {
      return ThermalZoneClass.environmental;
    }
    return ThermalZoneClass.candidate;
  }

  /// Whether [name] looks like a CPU cluster zone.
  static bool isCpuName(String name) {
    final n = name.toLowerCase();
    return n.contains('cpu') ||
        n.contains('cluster') ||
        n.contains('little') ||
        n.contains('big');
  }

  /// Whether [name] looks like a GPU zone.
  static bool isGpuName(String name) {
    return name.toLowerCase().contains('gpu');
  }

  bool _isComponent(String name) {
    const tokens = [
      'modem',
      'mdm',
      'camera',
      'video',
      'nsp',
      'npss',
      'pmic',
      'charger',
      'usb',
      'soc',
      'npu',
      'dsp',
      'wifi',
      'wlan',
      'aoss',
      'qfprom',
      'cdsp',
      'adsp',
      'mpss',
      'gpuss',
      'tmu',
    ];
    for (final token in tokens) {
      if (name.contains(token)) {
        return true;
      }
    }
    if (RegExp(r'(^|[_-])pa(\d+)?($|[_-])').hasMatch(name) || name == 'pa') {
      return true;
    }
    if (RegExp(r'(^|[_-])pm\d').hasMatch(name) || name.startsWith('pm')) {
      return true;
    }
    if (name.contains('xo')) {
      return true;
    }
    return false;
  }

  bool _isEnvironmental(String name) {
    const tokens = [
      'ambient',
      'skin',
      'shell',
      'case',
      'surface',
      'board',
      'pcb',
      'env',
      'sdr',
    ];
    for (final token in tokens) {
      if (name.contains(token)) {
        return true;
      }
    }
    return false;
  }
}
