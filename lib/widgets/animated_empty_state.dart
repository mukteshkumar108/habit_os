import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AnimatedEmptyState extends StatefulWidget {
  final bool isCelebration;

  const AnimatedEmptyState({super.key, this.isCelebration = false});

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with TickerProviderStateMixin {
  late final AnimationController _breathingController;
  late final AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _syncAnimations();
  }

  @override
  void didUpdateWidget(AnimatedEmptyState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCelebration != widget.isCelebration) {
      _syncAnimations();
    }
  }

  void _syncAnimations() {
    if (widget.isCelebration) {
      _breathingController.stop();
      _celebrationController.forward(from: 0);
    } else {
      _celebrationController.stop();
      if (!_breathingController.isAnimating) {
        _breathingController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _breathingController,
        _celebrationController,
      ]),
      builder: (context, child) {
        final breathing = _breathingController.value;
        final celebration = Curves.easeOutCubic.transform(
          _celebrationController.value,
        );

        return Transform.scale(
          scale: widget.isCelebration
              ? 0.96 + celebration * 0.04
              : 0.995 + breathing * 0.01,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.isCelebration
                  ? AppColors.primaryContainer.withAlpha(32)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isCelebration
                    ? AppColors.primary.withAlpha(80)
                    : AppColors.surfaceVariant,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (widget.isCelebration
                              ? AppColors.primary
                              : AppColors.infoBlue)
                          .withAlpha(
                            widget.isCelebration
                                ? (18 + celebration * 24).round()
                                : (8 + breathing * 12).round(),
                          ),
                  blurRadius: 14 + breathing * 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.isCelebration)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _CelebrationPainter(
                          progress: _celebrationController.value,
                        ),
                      ),
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: Offset(
                        0,
                        widget.isCelebration
                            ? -math.sin(celebration * math.pi) * 5
                            : -3 + breathing * 6,
                      ),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: widget.isCelebration
                              ? AppColors.primaryContainer
                              : AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.isCelebration
                              ? Icons.celebration_rounded
                              : Icons.add_task_rounded,
                          color: widget.isCelebration
                              ? AppColors.onPrimaryContainer
                              : AppColors.primary,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        widget.isCelebration
                            ? 'All tasks completed. Strong finish!'
                            : "You didn't plan your day today. Please make your tasks.",
                        key: ValueKey(widget.isCelebration),
                        style: AppTypography.bodyLg.copyWith(
                          color: widget.isCelebration
                              ? AppColors.primary
                              : AppColors.textMuted,
                          fontWeight: widget.isCelebration
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CelebrationPainter extends CustomPainter {
  final double progress;

  const _CelebrationPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      AppColors.primary,
      AppColors.warningYellow,
      AppColors.infoBlue,
    ];
    final paint = Paint()..style = PaintingStyle.fill;

    for (var index = 0; index < 10; index++) {
      final phase = (progress * 1.25 - index * 0.035).clamp(0.0, 1.0);
      if (phase == 0 || phase == 1) continue;
      final direction = index.isEven ? 1.0 : -1.0;
      final x = size.width * (0.15 + (index % 5) * 0.175);
      final y = size.height * 0.48 - phase * size.height * 0.42;
      paint.color = colors[index % colors.length].withAlpha(
        ((1 - phase) * 150).round(),
      );
      canvas.drawCircle(
        Offset(x + direction * math.sin(phase * math.pi) * 12, y),
        2.5 + (index % 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CelebrationPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
