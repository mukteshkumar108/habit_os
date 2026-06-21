import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Bottom sheet drawer for notification/reminder frequency options.
/// Shows radio-style options: 15 mins, 1 hour, 2 hours, Custom.
class ReminderDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const ReminderDrawer({
    super.key,
    this.selectedIndex = 0,
    required this.onSelected,
  });

  static void show(BuildContext context, {int selectedIndex = 0, required ValueChanged<int> onSelected}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ReminderDrawer(
        selectedIndex: selectedIndex,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      '15 mins before',
      '1 hour before',
      '2 hours before',
      'Custom...',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.surfaceContainerHighest, width: 4),
          left: BorderSide(color: AppColors.surfaceContainerHighest, width: 4),
          right: BorderSide(color: AppColors.surfaceContainerHighest, width: 4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          // Handle
          Container(
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            'Notification Settings',
            style: AppTypography.headlineMd.copyWith(color: AppColors.textMain),
          ),
          const SizedBox(height: 16),
          // Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: List.generate(options.length, (index) {
                final isActive = index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      onSelected(index);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border(
                          top: BorderSide(
                              color: AppColors.surfaceVariant, width: 2),
                          left: BorderSide(
                              color: AppColors.surfaceVariant, width: 2),
                          right: BorderSide(
                              color: AppColors.surfaceVariant, width: 2),
                          bottom: BorderSide(
                              color: AppColors.surfaceVariant, width: 4),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            options[index],
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.textMain,
                            ),
                          ),
                          Icon(
                            index == options.length - 1
                                ? Icons.settings
                                : (isActive
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked),
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }
}
