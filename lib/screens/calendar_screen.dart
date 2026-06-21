import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/calendar_day_cell.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedDay = 24;

  // October 2023: starts on Sunday (weekday index 6 in Mon-start grid),
  // 31 days total
  final int _startOffset = 6; // 6 empty cells before day 1 (Mon-start grid)
  final int _daysInMonth = 31;

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text('Calendar', style: AppTypography.headlineLgMobile),
              const SizedBox(height: AppSpacing.stackMd),

              // Desktop: side by side
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildCalendar()),
                        const SizedBox(width: 48),
                        Expanded(child: _buildTaskList()),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCalendar(),
                      const SizedBox(height: AppSpacing.stackLg),
                      _buildTaskList(),
                    ],
                  );
                },
              ),
            ],
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
                _buildNavButton(Icons.chevron_left),
                Text(
                  'October 2023',
                  style: AppTypography.headlineMd
                      .copyWith(color: AppColors.textMain),
                ),
                _buildNavButton(Icons.chevron_right),
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
              return CalendarDayCell(
                day: day,
                isSelected: day == _selectedDay,
                onTap: () => setState(() => _selectedDay = day),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon) {
    return GestureDetector(
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

  Widget _buildTaskList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tasks for Oct $_selectedDay',
          style: AppTypography.headlineMd.copyWith(color: AppColors.textMain),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        // Completed task
        _CalendarTaskCard(
          icon: Icons.check_circle,
          title: 'Morning Meditation',
          subtitle: '07:00 AM',
          isCompleted: true,
        ),
        const SizedBox(height: AppSpacing.stackMd),
        // Pending tasks
        _CalendarTaskCard(
          icon: Icons.menu_book,
          title: 'Study Flutter',
          subtitle: '10:00 AM - 2 hours',
        ),
        const SizedBox(height: AppSpacing.stackMd),
        _CalendarTaskCard(
          icon: Icons.fitness_center,
          title: 'Workout',
          subtitle: '05:30 PM',
          trailingIcon: Icons.photo_camera,
        ),
        const SizedBox(height: AppSpacing.stackMd),
        _CalendarTaskCard(
          icon: Icons.book,
          title: 'Read 10 Pages',
          subtitle: '09:00 PM',
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

  const _CalendarTaskCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.trailingIcon,
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
