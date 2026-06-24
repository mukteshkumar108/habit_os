import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/project_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/material_icon.dart';
import '../widgets/project_themed_icon.dart';
import '../widgets/project_streak_widget.dart';
import '../widgets/proof_memory_grid.dart';
import '../widgets/responsive_layout.dart';
import 'create_project_screen.dart';
import 'daily_proof_camera_flow.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final project = appState.projectById(projectId);
    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Project no longer exists.')),
      );
    }
    final proofs = appState.proofsForProject(projectId);
    final proofAddedToday = appState.hasProofToday(projectId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Project Details', style: AppTypography.headlineMd),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        minimum: const EdgeInsets.only(bottom: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.containerMargin,
            AppSpacing.stackLg,
            AppSpacing.containerMargin,
            AppSpacing.stackLg,
          ),
          child: ResponsiveLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProjectThemedIcon(
                      key: ValueKey('project-detail-icon-${project.projectId}'),
                      icon: materialIconFromCodePoint(project.projectIcon),
                      size: 88,
                      iconSize: 42,
                      variant: ProjectThemedIconVariant.detail,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.projectName,
                            style: AppTypography.headlineLg,
                          ),
                          if (project.projectDescription.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              project.projectDescription,
                              style: AppTypography.bodyLg.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackLg),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ProjectStreakWidget(
                      streak: project.currentProofStreak,
                      proofAddedToday: proofAddedToday,
                    ),
                    _statCard(
                      icon: Icons.photo_library_rounded,
                      value: '${project.proofCount}',
                      label: 'proof memories',
                    ),
                    if (project.lastProofDate != null)
                      _statCard(
                        icon: Icons.history_rounded,
                        value: DateFormat(
                          'MMM d',
                        ).format(project.lastProofDate!),
                        label: 'last proof',
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: proofAddedToday
                        ? AppColors.primaryContainer.withAlpha(40)
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: proofAddedToday
                          ? AppColors.primary.withAlpha(80)
                          : AppColors.surfaceVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        proofAddedToday
                            ? Icons.check_circle_rounded
                            : Icons.camera_alt_outlined,
                        color: proofAddedToday
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          proofAddedToday
                              ? 'Proof added today'
                              : 'No proof added today. Add your daily proof.',
                          style: AppTypography.bodyLg.copyWith(
                            color: proofAddedToday
                                ? AppColors.primary
                                : AppColors.textMain,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.stackMd),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      disabledBackgroundColor: AppColors.surfaceContainerHigh,
                      disabledForegroundColor: AppColors.textMuted,
                      side: BorderSide(
                        color: proofAddedToday
                            ? AppColors.outlineVariant
                            : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    onPressed: proofAddedToday
                        ? null
                        : () => _openDailyProof(
                            context,
                            project.projectId,
                            project.projectName,
                          ),
                    icon: Icon(
                      proofAddedToday
                          ? Icons.check_circle_outline_rounded
                          : Icons.camera_alt_rounded,
                    ),
                    label: Text(
                      proofAddedToday
                          ? 'Proof already added today'
                          : 'Add Today\'s Proof',
                      style: AppTypography.headlineMd.copyWith(
                        color: proofAddedToday
                            ? AppColors.textMuted
                            : AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.stackLg),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Proof Memories',
                        style: AppTypography.headlineMd,
                      ),
                    ),
                    Text(
                      '${proofs.length}',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ProofMemoryGrid(project: project, proofs: proofs),
                const SizedBox(height: AppSpacing.stackLg),
                _buildProjectActions(context, project),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectActions(BuildContext context, ProjectModel project) {
    final editButton = OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateProjectScreen(project: project),
          ),
        );
      },
      icon: const Icon(Icons.edit_rounded),
      label: const Text('Edit Project'),
    );
    final deleteButton = OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.errorRed,
        side: const BorderSide(color: AppColors.errorRed),
      ),
      onPressed: () => _deleteProject(context, projectId),
      icon: const Icon(Icons.delete_outline_rounded),
      label: const Text('Delete Project'),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 50, child: editButton),
              const SizedBox(height: 12),
              SizedBox(height: 50, child: deleteButton),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: SizedBox(height: 50, child: editButton)),
            const SizedBox(width: 12),
            Expanded(child: SizedBox(height: 50, child: deleteButton)),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.infoBlue, size: 28),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTypography.headlineMd),
              Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openDailyProof(
    BuildContext context,
    String projectId,
    String projectName,
  ) async {
    if (context.read<AppState>().hasProofToday(projectId)) return;
    await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) =>
            DailyProofCameraFlow(
              projectId: projectId,
              projectName: projectName,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteProject(BuildContext context, String projectId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete project?'),
        content: const Text(
          'This project and all linked proof memories will be permanently deleted and cannot be recovered.',
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
    await context.read<AppState>().deleteProject(projectId);
    if (context.mounted) Navigator.pop(context);
  }
}
