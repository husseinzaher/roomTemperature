import 'package:flutter/material.dart';
import 'package:ui_kit/src/glass/glass_tokens.dart';

/// {@template glass_select_tile}
/// A compact selectable row on glass — used for indoor-temperature source
/// choices instead of a Material radio list.
/// {@endtemplate}
class GlassSelectTile extends StatelessWidget {
  /// {@macro glass_select_tile}
  const GlassSelectTile({
    required this.title,
    required this.selected,
    super.key,
    this.subtitle,
    this.icon,
    this.enabled = true,
    this.onTap,
  });

  /// The row's title.
  final String title;

  /// Optional supporting copy.
  final String? subtitle;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether this row is the current selection.
  final bool selected;

  /// Whether the row can be tapped.
  final bool enabled;

  /// Called when the row is tapped. Ignored when [enabled] is false.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final titleColor = enabled
        ? GlassTokens.onGlass
        : GlassTokens.onGlassMuted.withValues(alpha: 0.45);
    final subtitleColor = enabled
        ? GlassTokens.onGlassMuted
        : GlassTokens.onGlassMuted.withValues(alpha: 0.35);

    return Opacity(
      opacity: enabled ? 1 : 0.72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          splashColor: const Color(0x1FFFFFFF),
          highlightColor: const Color(0x14FFFFFF),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0x28FFFFFF)
                  : const Color(0x14FFFFFF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? GlassTokens.borderSelected
                    : GlassTokens.border,
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: titleColor),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15.5,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 12.5,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _SelectionDot(selected: selected, enabled: enabled),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.selected, required this.enabled});

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? GlassTokens.onGlass : GlassTokens.borderSelected,
          width: 1.6,
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: selected ? 10 : 0,
        height: selected ? 10 : 0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? GlassTokens.onGlass : GlassTokens.onGlassMuted,
        ),
      ),
    );
  }
}
