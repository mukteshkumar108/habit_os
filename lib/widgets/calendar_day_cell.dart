import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A single calendar day cell. Supports normal, selected (gold), and empty states.
class CalendarDayCell extends StatelessWidget {
  final int? day;
  final bool isSelected;
  final VoidCallback? onTap;

  const CalendarDayCell({
    super.key,
    this.day,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Empty cell
    if (day == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.warningYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? const Border(
                  top: BorderSide(color: AppColors.secondary, width: 2),
                  left: BorderSide(color: AppColors.secondary, width: 2),
                  right: BorderSide(color: AppColors.secondary, width: 2),
                  bottom: BorderSide(color: AppColors.secondary, width: 4),
                )
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: AppTypography.bodyMd.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.onSecondaryContainer
                  : AppColors.textMain,
            ),
          ),
        ),
      ),
    );
  }
}
