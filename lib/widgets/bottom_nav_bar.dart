import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

/// Shared bottom navigation bar with 3 tabs: Home, Calendar, Projects.
/// Active tab shows green icon with filled variant and subtle background.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('bottom-nav-surface'),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.surfaceContainerHighest, width: 4),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.calendar_today,
                label: 'Calendar',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.folder,
                label: 'Projects',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedColor = colorScheme.primary;
    final unselectedColor = colorScheme.onSurfaceVariant.withAlpha(180);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        key: ValueKey('bottom-nav-item-$label'),
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.surfaceContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border(bottom: BorderSide(color: selectedColor, width: 4))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              key: ValueKey('bottom-nav-icon-$label'),
              icon,
              size: 28,
              color: isActive ? selectedColor : unselectedColor,
            ),
            const SizedBox(height: 2),
            Text(
              key: ValueKey('bottom-nav-label-$label'),
              label,
              style: AppTypography.labelLg.copyWith(
                color: isActive ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
