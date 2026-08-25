import 'package:flutter/material.dart';

/// The threshold state a reading can be in.
enum ThresholdStatus {
  /// The reading is within the configured range.
  normal,

  /// The reading is above the configured maximum.
  above,

  /// The reading is below the configured minimum.
  below,
}

/// {@template threshold_status_badge}
/// A small color-coded pill badge that communicates a [ThresholdStatus].
///
/// Green for [ThresholdStatus.normal], red for [ThresholdStatus.above], and
/// blue for [ThresholdStatus.below].
/// {@endtemplate}
class ThresholdStatusBadge extends StatelessWidget {
  /// {@macro threshold_status_badge}
  const ThresholdStatusBadge({required this.status, super.key});

  /// The status this badge represents.
  final ThresholdStatus status;

  String get _label => switch (status) {
    ThresholdStatus.normal => 'Normal',
    ThresholdStatus.above => 'Above threshold',
    ThresholdStatus.below => 'Below threshold',
  };

  Color get _color => switch (status) {
    ThresholdStatus.normal => const Color(0xFF2E7D32),
    ThresholdStatus.above => const Color(0xFFC62828),
    ThresholdStatus.below => const Color(0xFF1565C0),
  };

  IconData get _icon => switch (status) {
    ThresholdStatus.normal => Icons.check_circle,
    ThresholdStatus.above => Icons.arrow_circle_up,
    ThresholdStatus.below => Icons.arrow_circle_down,
  };

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            _label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
