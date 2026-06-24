import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/calendar_day_cell.dart';
import '../widgets/responsive_layout.dart';
import '../state/app_state.dart';
import 'task_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(now.year, now.month);
  }

  int get _daysInMonth => DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
  int get _startOffset => DateTime(_currentMonth.year, _currentMonth.month, 1).weekday - 1;

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final selectedTasks = appState.tasks.where((t) {
      return t.dueDate.year == _selectedDate.year &&
             t.dueDate.month == _selectedDate.month &&
             t.dueDate.day == _selectedDate.day;
    }).toList();
    selectedTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppSpacing.containerMargin,
            right: AppSpacing.containerMargin,
            top: AppSpacing.stackMd,
            bottom: 120,
          ),
          child: ResponsiveLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text('Calendar', style: AppTypography.headlineLgMobile),
                const SizedBox(height: AppSpacing.stackMd),

                // Desktop: side by side, Mobile: stacked
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 700) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildCalendar()),
                          const SizedBox(width: 48),
                          Expanded(child: _buildTaskList(selectedTasks, appState)),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalendar(),
                        const SizedBox(height: AppSpacing.stackLg),
                        _buildTaskList(selectedTasks, appState),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          top: BorderSide(color: AppColors.surfaceContainerHighest, width: 2),
          left: BorderSide(color: AppColors.surfaceContainerHighest, width: 2),
          right: BorderSide(color: AppColors.surfaceContainerHighest, width: 2),
          bottom:
              BorderSide(color: AppColors.surfaceContainerHighest, width: 4),
        ),
      ),
      child: Column(
        children: [
          // Month header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(Icons.chevron_left, _previousMonth),
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: AppTypography.headlineMd
                      .copyWith(color: AppColors.textMain),
                ),
                _buildNavButton(Icons.chevron_right, _nextMonth),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Day-of-week headers
          Row(
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: AppTypography.labelMd
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _startOffset + _daysInMonth,
            itemBuilder: (context, index) {
              if (index < _startOffset) {
                return const CalendarDayCell();
              }
              final day = index - _startOffset + 1;
              final isSelected = day == _selectedDate.day &&
                                 _currentMonth.month == _selectedDate.month &&
                                 _currentMonth.year == _selectedDate.year;
              return CalendarDayCell(
                day: day,
                isSelected: isSelected,
                onTap: () => setState(() {
                  _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, day);
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Icon(icon, size: 28, color: AppColors.textMain),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<dynamic> tasks, AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tasks for ${DateFormat('MMM d').format(_selectedDate)}',
          style: AppTypography.headlineMd.copyWith(color: AppColors.textMain),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        if (tasks.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No tasks scheduled for this day.',
                style: AppTypography.bodyLg.copyWith(color: AppColors.textMuted),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.stackMd),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _CalendarTaskCard(
                icon: IconData(task.iconCodePoint, fontFamily: 'MaterialIcons'),
                title: task.title,
                subtitle: DateFormat('h:mm a').format(task.dueDate),
                isCompleted: task.isCompleted,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(task: task),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class _CalendarTaskCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const _CalendarTaskCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.trailingIcon,
    this.onTap,
  });

  @override
  State<_CalendarTaskCard> createState() => _CalendarTaskCardState();
}

class _CalendarTaskCardState extends State<_CalendarTaskCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isCompleted
        ? AppColors.primaryContainer
        : AppColors.surfaceContainerLowest;
    final borderColor = widget.isCompleted
        ? AppColors.primary
        : AppColors.surfaceContainerHighest;
    final iconBgColor = widget.isCompleted
        ? AppColors.surfaceContainerLowest
        : AppColors.surfaceContainer;
    final iconBorderColor = widget.isCompleted
        ? AppColors.primary
        : AppColors.surfaceContainerHighest;
    final iconColor =
        widget.isCompleted ? AppColors.primary : AppColors.textMuted;
    final titleColor =
        widget.isCompleted ? AppColors.onPrimaryContainer : AppColors.onSurface;
    final subtitleColor = widget.isCompleted
        ? AppColors.onPrimaryContainer.withAlpha(200)
        : AppColors.textMuted;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            top: BorderSide(color: borderColor, width: 2),
            left: BorderSide(color: borderColor, width: 2),
            right: BorderSide(color: borderColor, width: 2),
            bottom: BorderSide(color: borderColor, width: _isPressed ? 2 : 4),
          ),
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor,
                border: Border.all(color: iconBorderColor, width: 2),
              ),
              child: Center(
                child: Icon(widget.icon, size: 24, color: iconColor),
              ),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: AppTypography.labelMd.copyWith(color: subtitleColor),
                  ),
                ],
              ),
            ),
            // Optional trailing icon (camera)
            if (widget.trailingIcon != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.infoBlue.withAlpha(50),
                ),
                child: Center(
                  child: Icon(
                    widget.trailingIcon,
                    size: 20,
                    color: AppColors.infoBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
