import 'package:flutter/material.dart';
import 'package:settings_domain/settings_domain.dart';
import 'package:ui_kit/ui_kit.dart';

/// {@template weather_top_bar}
/// The dashboard's top row: a Celsius/Fahrenheit glass toggle beside refresh
/// and settings actions.
/// {@endtemplate}
class WeatherTopBar extends StatelessWidget {
  /// {@macro weather_top_bar}
  const WeatherTopBar({
    required this.units,
    required this.onUnitsChanged,
    required this.celsiusLabel,
    required this.fahrenheitLabel,
    super.key,
    this.onRefresh,
    this.onOpenSettings,
    this.isRefreshing = false,
  });

  /// The currently selected unit.
  final Units units;

  /// Called when the user picks a different unit.
  final ValueChanged<Units> onUnitsChanged;

  /// Localized label for the Celsius segment.
  final String celsiusLabel;

  /// Localized label for the Fahrenheit segment.
  final String fahrenheitLabel;

  /// Called when the refresh action is tapped.
  final VoidCallback? onRefresh;

  /// Called when the settings action is tapped.
  final VoidCallback? onOpenSettings;

  /// Whether a refresh is currently in flight — spins the refresh icon.
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassSegmentedToggle(
            labels: [celsiusLabel, fahrenheitLabel],
            selectedIndex: units == Units.celsius ? 0 : 1,
            onChanged: (index) => onUnitsChanged(
              index == 0 ? Units.celsius : Units.fahrenheit,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _RefreshAction(onTap: onRefresh, isRefreshing: isRefreshing),
        const SizedBox(width: 8),
        GlassIconButton(
          icon: Icons.settings_outlined,
          onTap: onOpenSettings,
        ),
      ],
    );
  }
}

class _RefreshAction extends StatefulWidget {
  const _RefreshAction({required this.onTap, required this.isRefreshing});

  final VoidCallback? onTap;
  final bool isRefreshing;

  @override
  State<_RefreshAction> createState() => _RefreshActionState();
}

class _RefreshActionState extends State<_RefreshAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isRefreshing) _controller.repeat();
  }

  @override
  void didUpdateWidget(_RefreshAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRefreshing && _controller.isAnimating) {
      _controller
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: GlassIconButton(icon: Icons.refresh, onTap: widget.onTap),
    );
  }
}
