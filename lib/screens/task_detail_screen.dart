import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../models/task.dart';
import '../state/app_state.dart';
import '../utils/material_icon.dart';

enum TaskDetailAction { complete }

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentTask = appState.tasks.firstWhere(
      (t) => t.id == task.id,
      orElse: () => task,
    );

    final matchingProjects = appState.projects.where(
      (project) => project.projectId == currentTask.projectId,
    );
    final project = matchingProjects.isEmpty ? null : matchingProjects.first;
    final projectBackground = project == null
        ? AppColors.surfaceContainerHigh
        : Color(project.iconBgColorValue);
    final projectBorder = project == null
        ? AppColors.infoBlue
        : Color(project.iconBorderColorValue);
    final canComplete = appState.canCompleteTask(currentTask);
    final isScheduledForFuture =
        currentTask.status == TaskStatus.pending && !canComplete;
    final isLateAction = appState.willCompleteLate(currentTask);
    final canDelete = appState.canDeleteTask(currentTask);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Task Details',
          style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and Title
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: projectBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            bottom: BorderSide(color: projectBorder, width: 4),
                          ),
                        ),
                        child: Icon(
                          materialIconFromCodePoint(currentTask.iconCodePoint),
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentTask.title,
                              style: AppTypography.headlineLg.copyWith(
                                color: AppColors.textMain,
                              ),
                            ),
                            Text(
                              currentTask.projectName ?? 'No Project',
                              style: AppTypography.bodyLg.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.stackLg),

                  // Status
                  _buildDetailRow(
                    icon: _statusIcon(currentTask.status),
                    iconColor: _statusColor(currentTask.status),
                    label: 'Status',
                    value: currentTask.status.label,
                  ),
                  const SizedBox(height: AppSpacing.stackMd),

                  // Due Date & Time
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    iconColor: AppColors.infoBlue,
                    label: 'Due Date',
                    value: DateFormat(
                      'MMM dd, yyyy',
                    ).format(currentTask.dueDate),
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  _buildDetailRow(
                    icon: Icons.access_time,
                    iconColor: AppColors.infoBlue,
                    label: 'Due Time',
                    value: DateFormat('hh:mm a').format(currentTask.dueDate),
                  ),
                  const SizedBox(height: AppSpacing.stackMd),

                  // Reminder
                  _buildDetailRow(
                    icon: Icons.notifications,
                    iconColor: AppColors.warningYellow,
                    label: 'Reminder Frequency',
                    value: currentTask.reminderFrequencyLabel,
                  ),
                  if (currentTask.completedAt != null) ...[
                    const SizedBox(height: AppSpacing.stackMd),
                    _buildDetailRow(
                      icon: Icons.done_all_rounded,
                      iconColor: _statusColor(currentTask.status),
                      label: 'Completion Time',
                      value: DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(currentTask.completedAt!),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.stackLg),

                  // Notes
                  if (currentTask.notes.isNotEmpty) ...[
                    Text(
                      'NOTES',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.surfaceVariant,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        currentTask.notes,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  // Action Buttons
                  if (canComplete || isScheduledForFuture)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLateAction
                              ? AppColors.lateOrange
                              : AppColors.primaryContainer,
                          foregroundColor: isLateAction
                              ? AppColors.onSecondary
                              : AppColors.onPrimaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        onPressed: canComplete
                            ? () => Navigator.pop(
                                context,
                                TaskDetailAction.complete,
                              )
                            : null,
                        child: Text(
                          isScheduledForFuture
                              ? 'Available on ${DateFormat('MMM d').format(currentTask.dueDate)}'
                              : isLateAction
                              ? 'Complete Late'
                              : 'Complete Task',
                          style: AppTypography.headlineMd,
                        ),
                      ),
                    ),
                  if (canComplete || isScheduledForFuture)
                    const SizedBox(height: AppSpacing.stackMd),
                  if (canDelete)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.errorRed,
                          side: const BorderSide(
                            color: AppColors.errorRed,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () =>
                            _confirmDeleteTask(context, currentTask),
                        child: Text(
                          'Delete Task',
                          style: AppTypography.headlineMd,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'This task is part of your calendar history and cannot be deleted after its due time.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => Icons.pending_rounded,
      TaskStatus.completedOnTime => Icons.check_circle_rounded,
      TaskStatus.completedLate => Icons.schedule_rounded,
      TaskStatus.missed => Icons.cancel_rounded,
    };
  }

  Color _statusColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => AppColors.warningYellow,
      TaskStatus.completedOnTime => AppColors.successGreen,
      TaskStatus.completedLate => AppColors.lateOrange,
      TaskStatus.missed => AppColors.errorRed,
    };
  }

  Future<void> _confirmDeleteTask(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text(
          '"${task.title}" will be permanently deleted and cannot be recovered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<AppState>().deleteTask(task.id);
    Navigator.pop(context);
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelMd.copyWith(color: AppColors.textMuted),
            ),
            Text(
              value,
              style: AppTypography.bodyLg.copyWith(color: AppColors.textMain),
            ),
          ],
        ),
      ],
    );
  }
}
