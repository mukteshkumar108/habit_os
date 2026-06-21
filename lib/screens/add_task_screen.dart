import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/icon_selector.dart';
import '../widgets/reminder_drawer.dart';
import '../widgets/tactile_button.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  int _selectedIconIndex = 0;
  int _hour = 9;
  int _minute = 30;
  bool _isAm = true;
  int _reminderIndex = 0;

  final List<IconData> _icons = [
    Icons.menu_book,
    Icons.fitness_center,
    Icons.code,
    Icons.sports_basketball,
    Icons.palette,
    Icons.language,
    Icons.music_note,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
            vertical: AppSpacing.stackLg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  // Title
                  Text(
                    'Create New Task',
                    style: AppTypography.headlineLgMobile
                        .copyWith(color: AppColors.textMain),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.stackMd),

                  // ── Avatar Preview ──
                  _buildAvatarPreview(),
                  const SizedBox(height: AppSpacing.stackSm),

                  // ── Icon Selector ──
                  IconSelector(
                    icons: _icons,
                    selectedIndex: _selectedIconIndex,
                    onSelected: (i) => setState(() => _selectedIconIndex = i),
                  ),
                  const SizedBox(height: AppSpacing.stackMd),

                  // ── Task Name Input ──
                  _buildLabel('TASK NAME'),
                  const SizedBox(height: AppSpacing.base),
                  _buildTaskNameInput(),
                  const SizedBox(height: AppSpacing.stackMd),

                  // ── Deadline Section ──
                  _buildDeadlineSection(),
                  const SizedBox(height: AppSpacing.stackMd),

                  // ── Reminder Frequency ──
                  _buildReminderTrigger(),
                  const SizedBox(height: AppSpacing.stackLg),

                  // ── Notes ──
                  _buildLabel('NOTES (OPTIONAL)'),
                  const SizedBox(height: AppSpacing.base),
                  _buildNotesField(),
                  const SizedBox(height: AppSpacing.stackLg),

                  // ── Create Button ──
                  _buildCreateButton(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          top: BorderSide(color: AppColors.surfaceVariant, width: 2),
          left: BorderSide(color: AppColors.surfaceVariant, width: 2),
          right: BorderSide(color: AppColors.surfaceVariant, width: 2),
          bottom: BorderSide(color: AppColors.surfaceVariant, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _icons[_selectedIconIndex],
          size: 40,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTypography.labelLg.copyWith(
          color: AppColors.textMuted,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildTaskNameInput() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          top: BorderSide(color: AppColors.surfaceVariant, width: 2),
          left: BorderSide(color: AppColors.surfaceVariant, width: 2),
          right: BorderSide(color: AppColors.surfaceVariant, width: 2),
          bottom: BorderSide(color: AppColors.surfaceVariant, width: 4),
        ),
      ),
      child: TextField(
        controller: _nameController,
        style: AppTypography.bodyLg,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDeadlineSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          top: BorderSide(color: AppColors.surfaceVariant, width: 2),
          left: BorderSide(color: AppColors.surfaceVariant, width: 2),
          right: BorderSide(color: AppColors.surfaceVariant, width: 2),
          bottom: BorderSide(color: AppColors.surfaceVariant, width: 4),
        ),
      ),
      child: Column(
        children: [
          Text(
            'DEADLINE',
            style: AppTypography.labelLg.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.stackMd),

          // Date
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today,
                  color: AppColors.infoBlue, size: 40),
              const SizedBox(width: 12),
              Text(
                'Oct 24, 2023',
                style: AppTypography.headlineMd
                    .copyWith(color: AppColors.textMain),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackMd),

          // Time picker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hours
              _buildTimeColumn(
                value: _hour.toString().padLeft(2, '0'),
                onUp: () => setState(() => _hour = (_hour % 12) + 1),
                onDown: () =>
                    setState(() => _hour = _hour <= 1 ? 12 : _hour - 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  ':',
                  style: AppTypography.headlineLg
                      .copyWith(color: AppColors.textMuted),
                ),
              ),
              // Minutes
              _buildTimeColumn(
                value: _minute.toString().padLeft(2, '0'),
                onUp: () => setState(() => _minute = (_minute + 5) % 60),
                onDown: () => setState(
                    () => _minute = _minute < 5 ? 55 : _minute - 5),
              ),
              const SizedBox(width: 12),
              // AM/PM
              Column(
                children: [
                  TactileButton(
                    width: 48,
                    height: 32,
                    color: _isAm
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainerLow,
                    borderColor: _isAm
                        ? AppColors.borderDepth
                        : AppColors.surfaceVariant,
                    borderBottomWidth: _isAm ? 4 : 2,
                    borderRadius: 8,
                    onTap: () => setState(() => _isAm = true),
                    child: Text(
                      'AM',
                      style: AppTypography.labelLg.copyWith(
                        color: _isAm
                            ? AppColors.onPrimaryContainer
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TactileButton(
                    width: 48,
                    height: 32,
                    color: !_isAm
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainerLow,
                    borderColor: !_isAm
                        ? AppColors.borderDepth
                        : AppColors.surfaceVariant,
                    borderBottomWidth: !_isAm ? 4 : 2,
                    borderRadius: 8,
                    onTap: () => setState(() => _isAm = false),
                    child: Text(
                      'PM',
                      style: AppTypography.labelLg.copyWith(
                        color: !_isAm
                            ? AppColors.onPrimaryContainer
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackMd),
          // Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule,
                  size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                'Due by ${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')} ${_isAm ? 'AM' : 'PM'}',
                style:
                    AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn({
    required String value,
    required VoidCallback onUp,
    required VoidCallback onDown,
  }) {
    return Column(
      children: [
        _buildSmallCircleButton(Icons.expand_less, onUp),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.headlineLg.copyWith(color: AppColors.textMain),
        ),
        const SizedBox(height: 8),
        _buildSmallCircleButton(Icons.expand_more, onDown),
      ],
    );
  }

  Widget _buildSmallCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          shape: BoxShape.circle,
          border: const Border(
            bottom: BorderSide(color: AppColors.surfaceVariant, width: 2),
          ),
        ),
        child: Center(child: Icon(icon, size: 20)),
      ),
    );
  }

  Widget _buildReminderTrigger() {
    final options = ['15 mins before', '1 hour before', '2 hours before', 'Custom...'];
    return GestureDetector(
      onTap: () => ReminderDrawer.show(
        context,
        selectedIndex: _reminderIndex,
        onSelected: (i) => setState(() => _reminderIndex = i),
      ),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            top: BorderSide(color: AppColors.surfaceVariant, width: 2),
            left: BorderSide(color: AppColors.surfaceVariant, width: 2),
            right: BorderSide(color: AppColors.surfaceVariant, width: 2),
            bottom: BorderSide(color: AppColors.surfaceVariant, width: 4),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_active,
                color: AppColors.warningYellow),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Reminder Frequency',
                style: AppTypography.bodyLg.copyWith(color: AppColors.textMain),
              ),
            ),
            Text(
              options[_reminderIndex],
              style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.expand_more, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          top: BorderSide(color: AppColors.surfaceVariant, width: 2),
          left: BorderSide(color: AppColors.surfaceVariant, width: 2),
          right: BorderSide(color: AppColors.surfaceVariant, width: 2),
          bottom: BorderSide(color: AppColors.surfaceVariant, width: 4),
        ),
      ),
      child: Stack(
        children: [
          TextField(
            controller: _notesController,
            maxLines: 5,
            maxLength: 180,
            style: AppTypography.bodyMd,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
              hintText: 'Add some context...',
              hintStyle:
                  AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
              contentPadding: const EdgeInsets.all(24),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 16,
            child: Text(
              '${_notesController.text.length}/180',
              style: AppTypography.labelMd.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return TactileButton(
      height: 64,
      color: AppColors.primaryContainer,
      borderColor: AppColors.borderDepth,
      borderBottomWidth: 8,
      borderRadius: 9999,
      onTap: () => Navigator.of(context).pop(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'CREATE TASK',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onPrimaryContainer,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.check_circle,
              color: AppColors.onPrimaryContainer, size: 24),
        ],
      ),
    );
  }
}
