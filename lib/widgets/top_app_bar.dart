import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Shared top app bar with hamburger menu, app title, and streak counter.
class HabitOsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HabitOsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceVariant, width: 2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hamburger menu
            GestureDetector(
              child: const Icon(Icons.menu, color: AppColors.primary, size: 28),
            ),
            // App title
            Text(
              'Habit_OS',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            // Streak counter
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Text(
                  '7',
                  style: AppTypography.headlineMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warningYellow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
