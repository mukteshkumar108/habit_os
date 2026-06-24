import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../models/task.dart';
import '../state/app_state.dart';

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

    final project = appState.projects.firstWhere(
      (p) => p.id == currentTask.projectId,
      orElse: () => appState.projects.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onTap: () => Navigator.pop(context),
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
                          color: Color(project.iconBgColorValue),
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(project.iconBorderColorValue),
                              width: 4,
                            ),
                          ),
                        ),
                        child: Icon(
                          IconData(currentTask.iconCodePoint, fontFamily: 'MaterialIcons'),
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
                              project.title,
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
                    icon: currentTask.isCompleted ? Icons.check_circle : Icons.pending,
                    iconColor: currentTask.isCompleted ? AppColors.successGreen : AppColors.warningYellow,
                    label: 'Status',
                    value: currentTask.isCompleted ? 'Completed' : 'Pending',
                  ),
                  const SizedBox(height: AppSpacing.stackMd),

                  // Due Date & Time
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    iconColor: AppColors.infoBlue,
                    label: 'Due Date',
                    value: DateFormat('MMM dd, yyyy').format(currentTask.dueDate),
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
                    label: 'Reminder',
                    value: currentTask.reminderMinutes > 0
                        ? '${currentTask.reminderMinutes} mins before'
                        : 'No reminder',
                  ),
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
                        border: Border.all(color: AppColors.surfaceVariant, width: 2),
                      ),
                      child: Text(
                        currentTask.notes,
                        style: AppTypography.bodyLg.copyWith(color: AppColors.textMain),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentTask.isCompleted
                            ? AppColors.surfaceVariant
                            : AppColors.primaryContainer,
                        foregroundColor: currentTask.isCompleted
                            ? AppColors.textMain
                            : AppColors.onPrimaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: currentTask.isCompleted ? 0 : 2,
                      ),
                      onPressed: () {
                        context.read<AppState>().toggleTaskCompletion(currentTask.id);
                      },
                      child: Text(
                        currentTask.isCompleted ? 'Mark as Pending' : 'Complete Task',
                        style: AppTypography.headlineMd,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(color: AppColors.errorRed, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        context.read<AppState>().deleteTask(currentTask.id);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Delete Task',
                        style: AppTypography.headlineMd,
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
            Text(label, style: AppTypography.labelMd.copyWith(color: AppColors.textMuted)),
            Text(value, style: AppTypography.bodyLg.copyWith(color: AppColors.textMain)),
          ],
        ),
      ],
    );
  }
}
