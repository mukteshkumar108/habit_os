import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Horizontal scrollable icon picker with tactile border-depth buttons.
/// Used in the Add Task screen for selecting a task avatar icon.
class IconSelector extends StatefulWidget {
  final List<IconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const IconSelector({
    super.key,
    required this.icons,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<IconSelector> createState() => _IconSelectorState();
}

class _IconSelectorState extends State<IconSelector> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.icons.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == widget.selectedIndex;
          return GestureDetector(
            onTap: () => widget.onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  top: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    width: 2,
                  ),
                  left: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    width: 2,
                  ),
                  right: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    width: 2,
                  ),
                  bottom: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    width: 4,
                  ),
                ),
              ),
              child: Center(
                child: Icon(
                  widget.icons[index],
                  size: 32,
                  color: isSelected ? AppColors.primary : AppColors.textMain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
