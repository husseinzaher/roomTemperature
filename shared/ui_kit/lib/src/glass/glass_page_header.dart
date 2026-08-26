import 'package:flutter/material.dart';
import 'package:ui_kit/src/glass/glass_tokens.dart';

/// {@template glass_page_header}
/// A large tracked title for secondary screens (history, settings) so they
/// share the dashboard's cinematic typography instead of a Material AppBar.
/// {@endtemplate}
class GlassPageHeader extends StatelessWidget {
  /// {@macro glass_page_header}
  const GlassPageHeader({required this.title, super.key});

  /// The page title. Rendered in wide-tracked uppercase.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: GlassTokens.onGlass,
              fontSize: 26,
              fontWeight: FontWeight.w300,
              letterSpacing: 3.2,
              height: 1,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(child: _LeadingRules()),
        ],
      ),
    );
  }
}

class _LeadingRules extends StatelessWidget {
  const _LeadingRules();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        FractionallySizedBox(
          alignment: AlignmentDirectional.centerEnd,
          widthFactor: 0.7,
          child: Container(height: 1.4, color: const Color(0x66FFFFFF)),
        ),
        const SizedBox(height: 7),
        FractionallySizedBox(
          alignment: AlignmentDirectional.centerEnd,
          widthFactor: 0.4,
          child: Container(height: 1.4, color: const Color(0x40FFFFFF)),
        ),
      ],
    );
  }
}
