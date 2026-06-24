import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/material_icon.dart';
import '../widgets/animated_empty_state.dart';
import '../widgets/animated_fab.dart';
import '../widgets/animated_project_card.dart';
import '../widgets/animated_streak_card.dart';
import '../widgets/animated_task_card.dart';
import '../widgets/empty_projects_state.dart';
import '../widgets/project_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/task_card.dart';
import '../widgets/top_app_bar.dart';
import 'create_project_screen.dart';
import 'daily_proof_camera_flow.dart';
import 'project_detail_screen.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onAddTask;

  const HomeScreen({super.key, required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final now = DateTime.now();
    final todayTasks = appState.tasksForDate(now);
    final pendingTasks = todayTasks
        .where(
          (task) =>
              task.status == TaskStatus.pending && !now.isAfter(task.dueDate),
        )
        .toList();
    final missedTasks = todayTasks
        .where((task) => task.status == TaskStatus.missed)
        .toList();
    final projectsNeedingProof = appState.projects
        .where((project) => !appState.hasProofToday(project.projectId))
        .toList();
    final hasNoPlannedTasks = todayTasks.isEmpty;
    final completedAllTasks =
        todayTasks.isNotEmpty && todayTasks.every((task) => task.isCompleted);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const HabitOsAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.containerMargin,
                right: AppSpacing.containerMargin,
                top: AppSpacing.stackLg,
                bottom: 176 + MediaQuery.paddingOf(context).bottom,
              ),
              child: ResponsiveLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedStreakCard(
                      streakCount: appState.streakCount,
                      wasMissed: appState.streakWasMissed,
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    Text(
                      "Today's Pending Tasks",
                      style: AppTypography.headlineLgMobile,
                    ),
                    const SizedBox(height: 4),
                    _AnimatedPendingCount(
                      pendingCount: pendingTasks.length,
                      hasPlannedTasks: todayTasks.isNotEmpty,
                      missedCount: missedTasks.length,
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    if (hasNoPlannedTasks)
                      const AnimatedEmptyState()
                    else ...[
                      Column(
                        children: [
                          for (
                            var index = 0;
                            index < pendingTasks.length;
                            index++
                          )
                            _buildAnimatedTask(
                              context,
                              appState,
                              pendingTasks[index],
                              index,
                            ),
                        ],
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        child: completedAllTasks
                            ? const Padding(
                                key: ValueKey('completed-today'),
                                padding: EdgeInsets.only(top: 8),
                                child: AnimatedEmptyState(isCelebration: true),
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('tasks-pending'),
                              ),
                      ),
                    ],
                    if (missedTasks.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.stackLg),
                      Text(
                        'Missed / Overdue',
                        style: AppTypography.headlineMd.copyWith(
                          color: AppColors.errorRed,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.stackMd),
                      for (var index = 0; index < missedTasks.length; index++)
                        _buildAnimatedTask(
                          context,
                          appState,
                          missedTasks[index],
                          index,
                        ),
                    ],
                    if (appState.projects.isEmpty ||
                        projectsNeedingProof.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.stackLg),
                      Text('Projects', style: AppTypography.headlineMd),
                      const SizedBox(height: AppSpacing.stackMd),
                      if (appState.projects.isEmpty)
                        EmptyProjectsState(
                          compact: true,
                          message:
                              'No projects yet. Create a project to start your proof journey.',
                          onCreateProject: () => _openCreateProject(context),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            var crossCount = 1;
                            if (constraints.maxWidth >= 520) crossCount = 2;
                            if (constraints.maxWidth > 760) crossCount = 3;
                            if (constraints.maxWidth > 900) crossCount = 4;
                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossCount,
                                    mainAxisSpacing: AppSpacing.gutter,
                                    crossAxisSpacing: AppSpacing.gutter,
                                    mainAxisExtent: crossCount == 1 ? 184 : 176,
                                  ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: projectsNeedingProof.length,
                              itemBuilder: (context, index) {
                                final project = projectsNeedingProof[index];
                                final proofs = appState.proofsForProject(
                                  project.projectId,
                                );
                                return AnimatedProjectCard(
                                  key: ValueKey(
                                    'home-project-${project.projectId}',
                                  ),
                                  staggerIndex: index,
                                  photoCount: proofs.length,
                                  child: ProjectCard(
                                    project: project,
                                    proofMemories: proofs,
                                    proofAddedToday: false,
                                    compact: true,
                                    onTap: () => _openProject(
                                      context,
                                      project.projectId,
                                    ),
                                    onCameraTap: () => _openDailyProof(
                                      context,
                                      project.projectId,
                                      project.projectName,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: math.min(MediaQuery.sizeOf(context).width - 48, 800),
        height: 80,
        child: Align(
          alignment: Alignment.centerRight,
          child: AnimatedHabitFab(
            onTap: onAddTask,
            shouldPulse: hasNoPlannedTasks,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTask(
    BuildContext context,
    AppState appState,
    Task task,
    int index,
  ) {
    final project = task.projectId == null
        ? null
        : appState.projectById(task.projectId!);
    final dueTime = DateFormat('h:mm a').format(task.dueDate);
    final projectName = task.projectName?.trim();
    final isMissed = task.status == TaskStatus.missed;
    final subtitle = isMissed
        ? 'Missed - Due $dueTime'
        : projectName == null || projectName.isEmpty
        ? dueTime
        : '$projectName - $dueTime';

    return AnimatedTaskCard(
      key: ValueKey('today-task-${task.id}'),
      staggerIndex: index,
      isCompleted: task.isCompleted,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
        child: TaskCard(
          icon: materialIconFromCodePoint(task.iconCodePoint),
          title: task.title,
          subtitle: subtitle,
          subtitleColor: isMissed
              ? AppColors.errorRed
              : project == null
              ? AppColors.infoBlue
              : Color(project.iconBorderColorValue),
          onTap: () async {
            final action = await Navigator.push<TaskDetailAction>(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: task),
              ),
            );
            if (!context.mounted) return;
            if (action == TaskDetailAction.complete) {
              context.read<AppState>().completeTask(task.id);
            }
          },
        ),
      ),
    );
  }

  Future<void> _openCreateProject(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (context) => const CreateProjectScreen()),
    );
  }

  Future<void> _openProject(BuildContext context, String projectId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(projectId: projectId),
      ),
    );
  }

  Future<void> _openDailyProof(
    BuildContext context,
    String projectId,
    String projectName,
  ) async {
    if (context.read<AppState>().hasProofToday(projectId)) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => DailyProofCameraFlow(
          projectId: projectId,
          projectName: projectName,
        ),
      ),
    );
  }
}

class _AnimatedPendingCount extends StatelessWidget {
  final int pendingCount;
  final bool hasPlannedTasks;
  final int missedCount;

  const _AnimatedPendingCount({
    required this.pendingCount,
    required this.hasPlannedTasks,
    required this.missedCount,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: pendingCount),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, count, child) {
        final message = !hasPlannedTasks
            ? 'No tasks planned.'
            : missedCount > 0 && count == 0
            ? '$missedCount ${missedCount == 1 ? 'task' : 'tasks'} missed today.'
            : count == 0
            ? '0 tasks remaining • Day complete!'
            : '$count ${count == 1 ? 'task' : 'tasks'} remaining • You\'ve got this!';
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            message,
            key: ValueKey(message),
            style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
          ),
        );
      },
    );
  }
}
