import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Bottom sheet for choosing how often an incomplete task should remind users.
class ReminderDrawer extends StatelessWidget {
  static const List<int> _presetMinutes = [0, 15, 30, 60];

  final int selectedMinutes;
  final ValueChanged<int> onSelected;

  const ReminderDrawer({
    super.key,
    this.selectedMinutes = 0,
    required this.onSelected,
  });

  static void show(
    BuildContext context, {
    int selectedMinutes = 0,
    required ValueChanged<int> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ReminderDrawer(
        selectedMinutes: selectedMinutes,
        onSelected: onSelected,
      ),
    );
  }

  static String labelForFrequency(int minutes) {
    if (minutes <= 0) return 'No reminder';
    if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return 'Every $hours ${hours == 1 ? 'hour' : 'hours'}';
    }
    return 'Every $minutes minutes';
  }

  @override
  Widget build(BuildContext context) {
    final isCustomFrequency =
        selectedMinutes > 0 && !_presetMinutes.contains(selectedMinutes);
    final options = <({String label, int? minutes})>[
      (label: 'No reminder', minutes: 0),
      (label: 'Every 15 minutes', minutes: 15),
      (label: 'Every 30 minutes', minutes: 30),
      (label: 'Every 1 hour', minutes: 60),
      (
        label: isCustomFrequency
            ? 'Custom (${labelForFrequency(selectedMinutes)})'
            : 'Custom...',
        minutes: null,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.surfaceContainerHighest, width: 4),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Reminder Frequency',
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Repeats until the task is completed or deleted.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              for (final option in options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _frequencyOption(
                    context,
                    label: option.label,
                    minutes: option.minutes,
                    isActive: option.minutes == null
                        ? isCustomFrequency
                        : selectedMinutes == option.minutes,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _frequencyOption(
    BuildContext context, {
    required String label,
    required int? minutes,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        if (minutes == null) {
          _selectCustomFrequency(context);
          return;
        }
        onSelected(minutes);
        Navigator.of(context).pop();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.surfaceVariant,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLg.copyWith(color: AppColors.textMain),
              ),
            ),
            Icon(
              minutes == null
                  ? Icons.settings_rounded
                  : isActive
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCustomFrequency(BuildContext context) async {
    final selectedFrequency = await showDialog<int>(
      context: context,
      builder: (_) => const _CustomFrequencyDialog(),
    );
    if (selectedFrequency == null || !context.mounted) return;
    onSelected(selectedFrequency);
    Navigator.of(context).pop();
  }
}

class _CustomFrequencyDialog extends StatefulWidget {
  const _CustomFrequencyDialog();

  @override
  State<_CustomFrequencyDialog> createState() => _CustomFrequencyDialogState();
}

class _CustomFrequencyDialogState extends State<_CustomFrequencyDialog> {
  final TextEditingController _controller = TextEditingController();
  int _unitInMinutes = 1;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = int.tryParse(_controller.text.trim());
    if (amount == null || amount < 1) {
      setState(() => _errorText = 'Enter a number greater than zero');
      return;
    }
    Navigator.pop(context, amount * _unitInMinutes);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom reminder frequency'),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Repeat every',
                errorText: _errorText,
              ),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<int>(
            value: _unitInMinutes,
            items: const [
              DropdownMenuItem(value: 1, child: Text('Minutes')),
              DropdownMenuItem(value: 60, child: Text('Hours')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _unitInMinutes = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Set Frequency')),
      ],
    );
  }
}
