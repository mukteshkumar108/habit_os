import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'animated_tap_scale.dart';

class AnimatedHabitFab extends StatefulWidget {
  final VoidCallback onTap;
  final bool shouldPulse;

  const AnimatedHabitFab({
    super.key,
    required this.onTap,
    required this.shouldPulse,
  });

  @override
  State<AnimatedHabitFab> createState() => _AnimatedHabitFabState();
}

class _AnimatedHabitFabState extends State<AnimatedHabitFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(AnimatedHabitFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shouldPulse != widget.shouldPulse) _syncPulse();
  }

  void _syncPulse() {
    if (widget.shouldPulse) {
      _pulseController.repeat();
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final wave = math.sin(_pulseController.value * math.pi);
        return Transform.scale(
          scale: widget.shouldPulse ? 1 + wave * 0.035 : 1,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: widget.shouldPulse
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(
                          (20 + wave * 35).round(),
                        ),
                        blurRadius: 16 + wave * 10,
                        spreadRadius: wave * 2,
                      ),
                    ]
                  : const [],
            ),
            child: child,
          ),
        );
      },
      child: AnimatedTapScale(
        onTap: widget.onTap,
        pressedScale: 0.88,
        child: Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
            border: Border(
              bottom: BorderSide(color: AppColors.borderDepth, width: 4),
            ),
          ),
          child: const Center(
            child: Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}
