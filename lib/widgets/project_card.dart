import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'tactile_card.dart';

/// A project folder card for the Projects grid on Home screen.
/// Shows an icon badge with a colored background, title, and camera badge.
class ProjectCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconBgColor;
  final Color iconBorderColor;

  const ProjectCard({
    super.key,
    required this.icon,
    required this.title,
    this.iconBgColor = AppColors.surfaceVariant,
    this.iconBorderColor = AppColors.surfaceDim,
  });

  @override
  Widget build(BuildContext context) {
    return TactileCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    top: BorderSide(color: iconBorderColor, width: 2),
                    left: BorderSide(color: iconBorderColor, width: 2),
                    right: BorderSide(color: iconBorderColor, width: 2),
                    bottom: BorderSide(color: iconBorderColor, width: 4),
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: 24, color: AppColors.onSurfaceVariant),
                ),
              ),
              // Camera badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: const Icon(
                  Icons.photo_camera,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.bodyLg.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
