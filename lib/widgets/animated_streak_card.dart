import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AnimatedStreakCard extends StatefulWidget {
  final int streakCount;
  final bool wasMissed;

  const AnimatedStreakCard({
    super.key,
    required this.streakCount,
    this.wasMissed = false,
  });

  @override
  State<AnimatedStreakCard> createState() => _AnimatedStreakCardState();
}

class _AnimatedStreakCardState extends State<AnimatedStreakCard>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _glowController;
  late final AnimationController _successController;
  late final AnimationController _extinguishController;
  late int _countFrom;

  bool get _hasStreak => widget.streakCount > 0;

  @override
  void initState() {
    super.initState();
    _countFrom = widget.streakCount;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _extinguishController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _syncAmbientAnimations();
  }

  @override
  void didUpdateWidget(AnimatedStreakCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _countFrom = oldWidget.streakCount;

    if (widget.streakCount > oldWidget.streakCount) {
      _successController.forward(from: 0);
    } else if (oldWidget.streakCount > 0 && widget.streakCount == 0) {
      _extinguishController.forward(from: 0);
    }

    _syncAmbientAnimations();
  }

  void _syncAmbientAnimations() {
    if (_hasStreak) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
      if (!_glowController.isAnimating) {
        _glowController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
      _glowController.stop();
      _glowController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _successController.dispose();
    _extinguishController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseController,
        _glowController,
        _successController,
        _extinguishController,
      ]),
      builder: (context, child) {
        final glow = _hasStreak ? _glowController.value : 0.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _hasStreak
                ? AppColors.secondaryContainer
                : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
            border: Border(
              top: BorderSide(color: _borderColor, width: 2),
              left: BorderSide(color: _borderColor, width: 2),
              right: BorderSide(color: _borderColor, width: 2),
              bottom: BorderSide(color: _borderColor, width: 6),
            ),
            boxShadow: _hasStreak
                ? [
                    BoxShadow(
                      color: AppColors.warningYellow.withAlpha(
                        25 + (glow * 40).round(),
                      ),
                      blurRadius: 12 + (glow * 10),
                      spreadRadius: glow * 2,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : const [],
          ),
          child: Stack(
            children: [
              if (_hasStreak) _buildEnergyWash(glow),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildMessage()),
                  const SizedBox(width: 16),
                  _buildCount(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color get _borderColor => _hasStreak
      ? AppColors.onSecondaryContainer.withAlpha(50)
      : AppColors.surfaceDim;

  Widget _buildEnergyWash(double glow) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment(-1 + glow * 1.4, -1),
              end: Alignment(1 + glow * 0.4, 1),
              colors: [
                Colors.white.withAlpha(0),
                Colors.white.withAlpha(24 + (glow * 28).round()),
                Colors.white.withAlpha(0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(_hasStreak ? 55 : 35),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: _buildFlameState(),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _hasStreak
                ? 'KEEP THE MOMENTUM'
                : widget.wasMissed
                ? 'RESET. REFOCUS. RESTART.'
                : 'START YOUR STREAK',
            key: ValueKey('${_hasStreak}_${widget.wasMissed}'),
            style: AppTypography.labelLg.copyWith(
              color: _hasStreak
                  ? AppColors.onSecondaryContainer.withAlpha(180)
                  : AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.wasMissed && !_hasStreak
              ? 'Today is a fresh start'
              : 'Active Streaks',
          style: AppTypography.displayLg.copyWith(
            color: _hasStreak
                ? AppColors.onSecondaryContainer
                : AppColors.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildFlameState() {
    if (!_hasStreak) {
      final extinguish = Curves.easeOut.transform(_extinguishController.value);
      return Transform.translate(
        offset: Offset(0, -3 * extinguish),
        child: Opacity(
          opacity: widget.wasMissed ? 0.55 + extinguish * 0.25 : 0.75,
          child: Icon(
            widget.wasMissed ? Icons.cloud_outlined : Icons.fireplace,
            key: ValueKey(widget.wasMissed ? 'smoke' : 'resting-fire'),
            color: AppColors.textMuted,
            size: 32,
          ),
        ),
      );
    }

    final ambientScale = 1 + (_pulseController.value * 0.08);
    final successScale =
        1 + math.sin(_successController.value * math.pi) * 0.28;

    return Transform.scale(
      key: const ValueKey('active-fire'),
      scale: ambientScale * successScale,
      child: const Icon(
        Icons.local_fire_department,
        color: AppColors.onSecondaryContainer,
        size: 32,
      ),
    );
  }

  Widget _buildCount() {
    final bounce = 1 + math.sin(_successController.value * math.pi) * 0.12;

    return Transform.scale(
      scale: bounce,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: _countFrom.toDouble(),
              end: widget.streakCount.toDouble(),
            ),
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                '${value.round()}',
                style: TextStyle(
                  fontSize: 64,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: _hasStreak
                      ? AppColors.onSecondaryContainer
                      : AppColors.textMuted,
                  letterSpacing: -2,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _hasStreak
                  ? Colors.white.withAlpha(75)
                  : AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              _hasStreak ? 'DAYS STRONG' : 'LET\'S GO',
              style: AppTypography.labelMd.copyWith(
                color: _hasStreak
                    ? AppColors.onSecondaryContainer.withAlpha(200)
                    : AppColors.textMain.withAlpha(200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
