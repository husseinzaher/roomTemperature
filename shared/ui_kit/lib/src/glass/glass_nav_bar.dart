import 'package:flutter/material.dart';
import 'package:ui_kit/src/glass/glass_card.dart';
import 'package:ui_kit/src/glass/glass_tokens.dart';

/// One destination in a [GlassNavBar].
class GlassNavItem {
  /// Creates a [GlassNavItem].
  const GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  /// Icon shown when this destination is not selected.
  final IconData icon;

  /// Icon shown when this destination is selected.
  final IconData selectedIcon;

  /// The destination's short label.
  final String label;
}

/// {@template glass_nav_bar}
/// A floating translucent navigation bar. The selected destination sits in a
/// soft pill highlight rather than being marked by a Material indicator.
/// {@endtemplate}
class GlassNavBar extends StatelessWidget {
  /// {@macro glass_nav_bar}
  const GlassNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  /// The destinations, in display order.
  final List<GlassNavItem> items;

  /// Index of the selected destination.
  final int selectedIndex;

  /// Called with the index of a newly selected destination.
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: GlassTokens.radiusPill,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _NavDestination(
                item: items[i],
                selected: i == selectedIndex,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavDestination extends StatelessWidget {
  const _NavDestination({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0x38FFFFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
            border: selected
                ? Border.all(color: const Color(0x3DFFFFFF))
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 23,
                color: selected
                    ? GlassTokens.onGlass
                    : GlassTokens.onGlassMuted,
              ),
              const SizedBox(height: 5),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? GlassTokens.onGlass
                      : GlassTokens.onGlassMuted,
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
