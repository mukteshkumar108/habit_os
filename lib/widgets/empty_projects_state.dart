import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'animated_tap_scale.dart';
import 'project_themed_icon.dart';

class EmptyProjectsState extends StatefulWidget {
  final VoidCallback onCreateProject;
  final bool compact;
  final String message;

  const EmptyProjectsState({
    super.key,
    required this.onCreateProject,
    this.compact = false,
    this.message =
        'No projects yet. Create your first project and start building proof.',
  });

  @override
  State<EmptyProjectsState> createState() => _EmptyProjectsStateState();
}

class _EmptyProjectsStateState extends State<EmptyProjectsState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final wave = math.sin(_controller.value * math.pi * 2);
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(widget.compact ? 20 : 32),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceVariant),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(
                  (10 + wave.abs() * 10).round(),
                ),
                blurRadius: 18,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(0, wave * 3),
                child: const ProjectThemedIcon(
                  icon: Icons.folder_special_rounded,
                  size: 56,
                  iconSize: 26,
                  variant: ProjectThemedIconVariant.primary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 18),
              AnimatedTapScale(
                onTap: widget.onCreateProject,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                    border: const Border(
                      bottom: BorderSide(
                        color: AppColors.borderDepth,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Text(
                    'Create Project',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
