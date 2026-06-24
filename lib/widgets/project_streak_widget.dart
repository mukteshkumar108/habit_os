import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ProjectStreakWidget extends StatefulWidget {
  final int streak;
  final bool proofAddedToday;

  const ProjectStreakWidget({
    super.key,
    required this.streak,
    required this.proofAddedToday,
  });

  @override
  State<ProjectStreakWidget> createState() => _ProjectStreakWidgetState();
}

class _ProjectStreakWidgetState extends State<ProjectStreakWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(ProjectStreakWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streak > oldWidget.streak) {
      _controller.forward(from: 0).then((_) => _syncAnimation());
    } else if (widget.proofAddedToday != oldWidget.proofAddedToday) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.proofAddedToday) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
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
        final pulse = math.sin(_controller.value * math.pi) * 0.1;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withAlpha(
              widget.proofAddedToday ? 75 : 30,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 1 + pulse,
                child: Icon(
                  widget.proofAddedToday
                      ? Icons.local_fire_department_rounded
                      : Icons.fireplace_rounded,
                  color: widget.proofAddedToday
                      ? AppColors.warningYellow
                      : AppColors.textMuted,
                  size: 34,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: Text(
                      '${widget.streak}',
                      key: ValueKey(widget.streak),
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                  Text(
                    'day proof streak',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
