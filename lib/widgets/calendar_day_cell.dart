import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A single calendar day cell. Supports normal, selected (gold), and empty states.
class CalendarDayCell extends StatelessWidget {
  final int? day;
  final bool isSelected;
  final List<Color> markers;
  final VoidCallback? onTap;

  const CalendarDayCell({
    super.key,
    this.day,
    this.isSelected = false,
    this.markers = const [],
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
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.warningYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            border: isSelected
                ? Border.all(color: AppColors.secondary, width: 2)
                : null,
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: AppColors.secondaryFixedDim,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$day',
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.onSecondaryContainer
                        : AppColors.textMain,
                  ),
                ),
                if (markers.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final color in markers.take(4))
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
