import 'package:flutter/material.dart';
import 'package:ui_kit/src/glass/glass_card.dart';
import 'package:ui_kit/src/glass/glass_tokens.dart';

/// {@template glass_segmented_toggle}
/// A two-segment pill toggle on glass — the reference design's
/// Celsius/Fahrenheit control.
///
/// The selected segment is a bright near-opaque pill that slides between
/// positions; the unselected half stays translucent. Deliberately not a
/// Material `SegmentedButton`, which cannot be made to read as glass.
/// {@endtemplate}
class GlassSegmentedToggle extends StatelessWidget {
  /// {@macro glass_segmented_toggle}
  const GlassSegmentedToggle({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  /// The segment labels, in order. Exactly two are supported.
  final List<String> labels;

  /// Index of the currently selected segment.
  final int selectedIndex;

  /// Called with the index of a newly selected segment.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    assert(labels.length == 2, 'GlassSegmentedToggle supports two segments');

    return GlassCard(
      blur: GlassTokens.blurSmall,
      radius: GlassTokens.radiusPill,
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / labels.length;

          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: selectedIndex == 0
                    ? AlignmentDirectional.centerStart
                    : AlignmentDirectional.centerEnd,
                child: Container(
                  width: segmentWidth,
                  height: 44,
                  decoration: BoxDecoration(
                    color: GlassTokens.tintSelected,
                    borderRadius: BorderRadius.circular(
                      GlassTokens.radiusPill,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: _Segment(
                        label: labels[i],
                        selected: i == selectedIndex,
                        onTap: () => onChanged(i),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 44,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                color: selected
                    ? GlassTokens.onSelected
                    : GlassTokens.onGlassMuted,
                fontSize: 16,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                height: 1,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
