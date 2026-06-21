import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'tactile_card.dart';

/// A task list item card matching the Home screen design.
/// Shows a circle icon, task title, subtitle tag, and drag indicator.
class TaskCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleColor = AppColors.infoBlue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TactileCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Circle icon button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerLowest,
              border: Border.all(color: AppColors.surfaceVariant, width: 2),
            ),
            child: Center(
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.labelMd.copyWith(color: subtitleColor),
                ),
              ],
            ),
          ),
          // Drag indicator
          const Icon(
            Icons.drag_indicator,
            color: AppColors.surfaceDim,
            size: 24,
          ),
        ],
      ),
    );
  }
}
