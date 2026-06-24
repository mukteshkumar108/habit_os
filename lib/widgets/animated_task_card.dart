import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AnimatedTaskCard extends StatefulWidget {
  final Widget child;
  final bool isCompleted;
  final int staggerIndex;

  const AnimatedTaskCard({
    super.key,
    required this.child,
    required this.isCompleted,
    this.staggerIndex = 0,
  });

  @override
  State<AnimatedTaskCard> createState() => _AnimatedTaskCardState();
}

class _AnimatedTaskCardState extends State<AnimatedTaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _entryDelay;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      reverseDuration: const Duration(milliseconds: 430),
    );

    if (widget.isCompleted) {
      _controller.value = 0;
    } else {
      final delay = 220 + math.min(widget.staggerIndex, 4) * 55;
      _entryDelay = Timer(Duration(milliseconds: delay), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedTaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCompleted == widget.isCompleted) return;

    if (widget.isCompleted) {
      setState(() => _showSuccess = true);
      _controller.reverse().whenComplete(() {
        if (mounted) setState(() => _showSuccess = false);
      });
    } else {
      _showSuccess = false;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _entryDelay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return SizeTransition(
      sizeFactor: curved,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(curved),
          child: AnimatedBuilder(
            animation: _controller,
            child: widget.child,
            builder: (context, child) {
              final scale = 0.96 + (_controller.value * 0.04);
              final successProgress = 1 - _controller.value;

              return Transform.scale(
                scale: scale,
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    child!,
                    if (_showSuccess)
                      IgnorePointer(
                        child: Opacity(
                          opacity: math.sin(successProgress * math.pi),
                          child: Transform.scale(
                            scale: 0.75 + successProgress * 0.45,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(55),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: AppColors.onPrimaryContainer,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
