import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/animated_project_card.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/empty_projects_state.dart';
import '../widgets/project_card.dart';
import '../widgets/responsive_layout.dart';
import 'create_project_screen.dart';
import 'daily_proof_camera_flow.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            height: MediaQuery.paddingOf(context).top + 64,
            padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceVariant, width: 4),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.containerMargin,
                AppSpacing.stackLg,
                AppSpacing.containerMargin,
                160 + MediaQuery.paddingOf(context).bottom,
              ),
              child: ResponsiveLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Projects',
                      style: AppTypography.headlineLg.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your active habits and goals',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (appState.projects.isEmpty)
                      EmptyProjectsState(
                        onCreateProject: () => _openCreateProject(context),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          var crossCount = 2;
                          if (constraints.maxWidth > 600) crossCount = 3;
                          if (constraints.maxWidth > 900) crossCount = 4;

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossCount,
                                  mainAxisSpacing: AppSpacing.stackMd,
                                  crossAxisSpacing: AppSpacing.stackMd,
                                  mainAxisExtent: constraints.maxWidth < 520
                                      ? 260
                                      : 280,
                                ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: appState.projects.length,
                            itemBuilder: (context, index) {
                              final project = appState.projects[index];
                              final proofs = appState.proofsForProject(
                                project.projectId,
                              );
                              final proofAddedToday = appState.hasProofToday(
                                project.projectId,
                              );
                              return AnimatedProjectCard(
                                key: ValueKey('project-${project.projectId}'),
                                staggerIndex: index,
                                photoCount: proofs.length,
                                child: ProjectCard(
                                  project: project,
                                  proofMemories: proofs,
                                  proofAddedToday: proofAddedToday,
                                  onTap: () =>
                                      _openProject(context, project.projectId),
                                  onCameraTap: proofAddedToday
                                      ? null
                                      : () => _openDailyProof(
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
          child: AnimatedTapScale(
            onTap: () => _openCreateProject(context),
            child: Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.infoBlue,
                shape: BoxShape.circle,
                border: const Border(
                  bottom: BorderSide(color: Color(0xFF148DC6), width: 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.infoBlue.withAlpha(80),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
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
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) =>
            DailyProofCameraFlow(
              projectId: projectId,
              projectName: projectName,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
      ),
    );
  }
}
