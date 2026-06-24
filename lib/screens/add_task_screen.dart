import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/icon_selector.dart';
import '../widgets/reminder_drawer.dart';
import '../widgets/tactile_button.dart';
import '../state/app_state.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  int _selectedIconIndex = 0;
  
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  
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
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _isDateToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool get _isValid {
    if (_nameController.text.trim().isEmpty) return false;
    
    // Check if time is in the past for today
    if (_isDateToday(_selectedDate)) {
      final now = TimeOfDay.now();
      if (_selectedTime.hour < now.hour || 
         (_selectedTime.hour == now.hour && _selectedTime.minute < now.minute)) {
        return false;
      }
    }
    return true;
  }

  void _createTask() async {
    if (!_isValid) return;

    final appState = context.read<AppState>();
    
    // Default to first project if none selected (simplified for this screen)
    final projectId = appState.projects.isNotEmpty ? appState.projects.first.id : '1';
    
    final dueDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    int reminderMinutes = 0;
    switch (_reminderIndex) {
      case 0: reminderMinutes = 0; break;
      case 1: reminderMinutes = 15; break;
      case 2: reminderMinutes = 30; break;
      case 3: reminderMinutes = 60; break;
    }

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _nameController.text.trim(),
      projectId: projectId,
      iconCodePoint: _icons[_selectedIconIndex].codePoint,
      dueDate: dueDate,
      reminderMinutes: reminderMinutes,
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    appState.addTask(task);
    
    // Schedule notification
    await NotificationService().scheduleTaskReminder(task);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMain, size: 32),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerMargin,
                  vertical: AppSpacing.stackMd,
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

                        // ── Avatar Preview & Icon Selection ──
                        GestureDetector(
                          onTap: _showIconPicker,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              _buildAvatarPreview(),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.surfaceVariant, width: 2),
                                ),
                                child: const Icon(Icons.edit, size: 20, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackMd),

                        // ── Task Name Input ──
                        _buildLabel('TASK NAME'),
                        const SizedBox(height: AppSpacing.base),
                        _buildTaskNameInput(),
                        if (_nameController.text.trim().isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Task name is required', style: AppTypography.labelMd.copyWith(color: AppColors.errorRed)),
                          ),
                        const SizedBox(height: AppSpacing.stackMd),

                        // ── Deadline Section ──
                        _buildDeadlineSection(),
                        if (_isDateToday(_selectedDate) && _selectedTime.hour < TimeOfDay.now().hour || 
                           (_isDateToday(_selectedDate) && _selectedTime.hour == TimeOfDay.now().hour && _selectedTime.minute < TimeOfDay.now().minute))
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Cannot select a past time for today', style: AppTypography.labelMd.copyWith(color: AppColors.errorRed)),
                          ),
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
          ],
        ),
      ),
    );
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose an Icon', style: AppTypography.headlineMd),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedIconIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedIconIndex = index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.surfaceVariant, 
                          width: 2
                        ),
                      ),
                      child: Icon(
                        _icons[index], 
                        color: isSelected ? AppColors.onPrimaryContainer : AppColors.primary
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
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

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
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
          GestureDetector(
            onTap: _pickDate,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, color: AppColors.infoBlue, size: 32),
                const SizedBox(width: 12),
                Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                  style: AppTypography.headlineMd.copyWith(color: AppColors.textMain),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),

          // Time picker natively
          GestureDetector(
            onTap: _pickTime,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, color: AppColors.warningYellow, size: 32),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: AppTypography.headlineMd.copyWith(color: AppColors.textMain),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTrigger() {
    final options = ['No reminder', '15 mins before', '30 mins before', '1 hour before'];
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
                'Reminder',
                style: AppTypography.bodyLg.copyWith(color: AppColors.textMain),
              ),
            ),
            Text(
              options[_reminderIndex < options.length ? _reminderIndex : 0],
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
    return Opacity(
      opacity: _isValid ? 1.0 : 0.5,
      child: TactileButton(
        height: 64,
        color: _isValid ? AppColors.primaryContainer : AppColors.surfaceVariant,
        borderColor: _isValid ? AppColors.borderDepth : AppColors.surfaceDim,
        borderBottomWidth: 8,
        borderRadius: 9999,
        onTap: _isValid ? _createTask : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Create Task',
              style: AppTypography.headlineMd.copyWith(
                color: _isValid ? AppColors.onPrimaryContainer : AppColors.textMuted,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.check_circle,
                color: _isValid ? AppColors.onPrimaryContainer : AppColors.textMuted, size: 24),
          ],
        ),
      ),
    );
  }
}
