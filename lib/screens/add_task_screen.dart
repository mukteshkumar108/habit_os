import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/material_icon.dart';
import '../widgets/animated_create_task_button.dart';
import '../widgets/animated_icon_picker.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/reminder_drawer.dart';
import '../state/app_state.dart';
import '../models/project_model.dart';
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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _nameFocusNode = FocusNode();
  final GlobalKey _taskNameKey = GlobalKey();
  int _selectedIconIndex = 0;
  String? _selectedProjectId;
  bool _hasAttemptedSubmit = false;
  bool _hasInteractedWithName = false;
  bool _hasInteractedWithDeadline = false;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  int _reminderFrequencyMinutes = 0;

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
    _resetDeadline();
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus && _nameController.text.isEmpty && mounted) {
        setState(() => _hasInteractedWithName = true);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  bool _isDateToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool get _isValid {
    if (_nameController.text.trim().isEmpty) return false;

    // Check if time is in the past for today
    if (_isDateToday(_selectedDate)) {
      final now = TimeOfDay.now();
      if (_selectedTime.hour < now.hour ||
          (_selectedTime.hour == now.hour &&
              _selectedTime.minute < now.minute)) {
        return false;
      }
    }
    return true;
  }

  bool get _isDeadlineInPast {
    if (!_isDateToday(_selectedDate)) return false;
    final now = TimeOfDay.now();
    return _selectedTime.hour < now.hour ||
        (_selectedTime.hour == now.hour && _selectedTime.minute < now.minute);
  }

  bool get _showNameError =>
      _nameController.text.trim().isEmpty &&
      (_hasAttemptedSubmit || _hasInteractedWithName);

  bool get _showDeadlineError =>
      _isDeadlineInPast && (_hasAttemptedSubmit || _hasInteractedWithDeadline);

  void _resetDeadline() {
    final future = DateTime.now().add(const Duration(minutes: 30));
    final roundedMinute = ((future.minute + 4) ~/ 5) * 5;
    final due = DateTime(
      future.year,
      future.month,
      future.day,
      future.hour,
      roundedMinute,
    );
    _selectedDate = DateTime(due.year, due.month, due.day);
    _selectedTime = TimeOfDay.fromDateTime(due);
  }

  void _resetForm() {
    _nameController.clear();
    _notesController.clear();
    _selectedProjectId = null;
    _selectedIconIndex = 0;
    _reminderFrequencyMinutes = 0;
    _hasAttemptedSubmit = false;
    _hasInteractedWithName = false;
    _hasInteractedWithDeadline = false;
    _resetDeadline();
  }

  Future<void> _createTask() async {
    if (!_isValid) {
      setState(() => _hasAttemptedSubmit = true);
      if (_nameController.text.trim().isEmpty) {
        _nameFocusNode.requestFocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final taskNameContext = _taskNameKey.currentContext;
          if (taskNameContext != null) {
            Scrollable.ensureVisible(
              taskNameContext,
              alignment: 0.2,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
      return;
    }

    final appState = context.read<AppState>();
    ProjectModel? selectedProject;
    for (final project in appState.projects) {
      if (project.projectId == _selectedProjectId) {
        selectedProject = project;
        break;
      }
    }

    final dueDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _nameController.text.trim(),
      projectId: selectedProject?.projectId,
      projectName: selectedProject?.projectName,
      iconCodePoint: _icons[_selectedIconIndex].codePoint,
      dueDate: dueDate,
      reminderFrequencyMinutes: _reminderFrequencyMinutes,
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    appState.addTask(task);

    unawaited(NotificationService().scheduleRepeatingTaskReminder(task));

    if (mounted) {
      _resetForm();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final projects = context.select<AppState, List<ProjectModel>>(
      (state) => state.projects,
    );

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
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textMain,
                      size: 32,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
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
                          style: AppTypography.headlineLgMobile.copyWith(
                            color: AppColors.textMain,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.stackMd),

                        // ── Avatar Preview & Icon Selection ──
                        AnimatedTapScale(
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
                                  border: Border.all(
                                    color: AppColors.surfaceVariant,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackMd),

                        // ── Task Name Input ──
                        _buildLabel('TASK NAME'),
                        const SizedBox(height: AppSpacing.base),
                        _buildTaskNameInput(),
                        if (_showNameError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Task name is required',
                              style: AppTypography.labelMd.copyWith(
                                color: AppColors.errorRed,
                              ),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.stackMd),

                        // Optional project association. Never defaults to a project.
                        _buildLabel('PROJECT (OPTIONAL)'),
                        const SizedBox(height: AppSpacing.base),
                        _buildProjectSelector(projects),
                        const SizedBox(height: AppSpacing.stackMd),

                        // ── Deadline Section ──
                        _buildDeadlineSection(),
                        if (_showDeadlineError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Cannot select a past time for today',
                              style: AppTypography.labelMd.copyWith(
                                color: AppColors.errorRed,
                              ),
                            ),
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AnimatedIconPicker(
        icons: _icons,
        selectedIndex: _selectedIconIndex,
        onSelected: (index) => setState(() => _selectedIconIndex = index),
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
        border: Border(
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
          child: Icon(
            _icons[_selectedIconIndex],
            key: ValueKey(_selectedIconIndex),
            size: 40,
            color: AppColors.primary,
          ),
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
      key: _taskNameKey,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          top: BorderSide(color: AppColors.surfaceVariant, width: 2),
          left: BorderSide(color: AppColors.surfaceVariant, width: 2),
          right: BorderSide(color: AppColors.surfaceVariant, width: 2),
          bottom: BorderSide(color: AppColors.surfaceVariant, width: 4),
        ),
      ),
      child: TextField(
        controller: _nameController,
        focusNode: _nameFocusNode,
        onTap: () {
          if (!_hasInteractedWithName) {
            setState(() => _hasInteractedWithName = true);
          }
        },
        onChanged: (_) {
          setState(() => _hasInteractedWithName = true);
        },
        style: AppTypography.bodyLg,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildProjectSelector(List<ProjectModel> projects) {
    ProjectModel? selectedProject;
    for (final project in projects) {
      if (project.projectId == _selectedProjectId) {
        selectedProject = project;
        break;
      }
    }

    return AnimatedTapScale(
      onTap: () => _showProjectPicker(projects),
      pressedScale: 0.98,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            top: BorderSide(color: AppColors.surfaceVariant, width: 2),
            left: BorderSide(color: AppColors.surfaceVariant, width: 2),
            right: BorderSide(color: AppColors.surfaceVariant, width: 2),
            bottom: BorderSide(color: AppColors.surfaceVariant, width: 4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selectedProject == null
                  ? Icons.folder_off_outlined
                  : Icons.folder_rounded,
              color: selectedProject == null
                  ? AppColors.textMuted
                  : AppColors.primary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                selectedProject?.projectName ?? 'No Project',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyLg.copyWith(
                  color: selectedProject == null
                      ? AppColors.textMuted
                      : AppColors.textMain,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.expand_more_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _showProjectPicker(List<ProjectModel> projects) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text('Choose Project', style: AppTypography.headlineMd),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.folder_off_outlined),
              title: const Text('No Project'),
              trailing: _selectedProjectId == null
                  ? Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _selectedProjectId = null);
                Navigator.pop(sheetContext);
              },
            ),
            for (final project in projects)
              ListTile(
                leading: Icon(
                  materialIconFromCodePoint(project.projectIcon),
                  color: AppColors.primary,
                ),
                title: Text(project.projectName),
                trailing: _selectedProjectId == project.projectId
                    ? Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedProjectId = project.projectId);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    setState(() => _hasInteractedWithDeadline = true);
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
    setState(() => _hasInteractedWithDeadline = true);
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
        border: Border(
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

          _buildDeadlineAction(
            icon: Icons.calendar_today,
            iconColor: AppColors.infoBlue,
            value: DateFormat('MMM dd, yyyy').format(_selectedDate),
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
          _buildDeadlineAction(
            icon: Icons.access_time,
            iconColor: AppColors.warningYellow,
            value: DateFormat('h:mm').format(
              DateTime(2020, 1, 1, _selectedTime.hour, _selectedTime.minute),
            ),
            badge: _selectedTime.period == DayPeriod.am ? 'AM' : 'PM',
            onTap: _pickTime,
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineAction({
    required IconData icon,
    required Color iconColor,
    required String value,
    required VoidCallback onTap,
    String? badge,
  }) {
    return AnimatedTapScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  value,
                  key: ValueKey(value),
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ),
            if (badge != null) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTrigger() {
    return GestureDetector(
      onTap: () => ReminderDrawer.show(
        context,
        selectedMinutes: _reminderFrequencyMinutes,
        onSelected: (minutes) =>
            setState(() => _reminderFrequencyMinutes = minutes),
      ),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            top: BorderSide(color: AppColors.surfaceVariant, width: 2),
            left: BorderSide(color: AppColors.surfaceVariant, width: 2),
            right: BorderSide(color: AppColors.surfaceVariant, width: 2),
            bottom: BorderSide(color: AppColors.surfaceVariant, width: 4),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.notifications_active,
              color: AppColors.warningYellow,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Reminder',
                style: AppTypography.bodyLg.copyWith(color: AppColors.textMain),
              ),
            ),
            Text(
              ReminderDrawer.labelForFrequency(_reminderFrequencyMinutes),
              style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(width: 8),
            Icon(Icons.expand_more, color: AppColors.textMuted),
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
        border: Border(
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
              hintStyle: AppTypography.bodyMd.copyWith(
                color: AppColors.textMuted,
              ),
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
    return AnimatedCreateTaskButton(enabled: _isValid, onPressed: _createTask);
  }
}
