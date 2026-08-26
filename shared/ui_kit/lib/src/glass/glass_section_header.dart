import 'package:flutter/material.dart';
import 'package:ui_kit/src/glass/glass_tokens.dart';

/// {@template glass_section_header}
/// A section label in the reference design's style: wide-tracked uppercase
/// text with a small circular help affordance, preceded by a pair of thin
/// rules that trail off toward the opposite edge.
///
/// The rules are decorative but directional — they run *away* from the
/// label, which in an RTL layout means they mirror automatically.
/// {@endtemplate}
class GlassSectionHeader extends StatelessWidget {
  /// {@macro glass_section_header}
  const GlassSectionHeader({
    required this.label,
    super.key,
    this.onHelpTap,
    this.helpSemanticLabel,
  });

  /// The section label, e.g. `INSIDE`. Rendered uppercase.
  final String label;

  /// Called when the help affordance is tapped. When null, no help icon is
  /// shown.
  final VoidCallback? onHelpTap;

  /// Accessibility label for the help affordance.
  final String? helpSemanticLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _TrailingRules()),
        const SizedBox(width: 16),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: GlassTokens.onGlass,
            fontSize: 26,
            fontWeight: FontWeight.w300,
            letterSpacing: 3.2,
            height: 1,
          ),
        ),
        if (onHelpTap != null) ...[
          const SizedBox(width: 10),
          _HelpButton(
            onTap: onHelpTap!,
            semanticLabel: helpSemanticLabel,
          ),
        ],
      ],
    );
  }
}

class _TrailingRules extends StatelessWidget {
  const _TrailingRules();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: 0.55,
          child: Container(height: 1.4, color: const Color(0x66FFFFFF)),
        ),
        const SizedBox(height: 7),
        FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: 0.3,
          child: Container(height: 1.4, color: const Color(0x40FFFFFF)),
        ),
      ],
    );
  }
}

class _HelpButton extends StatelessWidget {
  const _HelpButton({required this.onTap, this.semanticLabel});

  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x8AFFFFFF), width: 1.4),
            ),
            alignment: Alignment.center,
            child: const Text(
              '?',
              style: TextStyle(
                color: GlassTokens.onGlass,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
