import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedProjectCard extends StatefulWidget {
  final Widget child;
  final int staggerIndex;
  final int photoCount;

  const AnimatedProjectCard({
    super.key,
    required this.child,
    this.staggerIndex = 0,
    this.photoCount = 0,
  });

  @override
  State<AnimatedProjectCard> createState() => _AnimatedProjectCardState();
}

class _AnimatedProjectCardState extends State<AnimatedProjectCard>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _photoController;
  Timer? _entryDelay;
  bool _hasAnimatedIn = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: 1,
    );
    _photoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasAnimatedIn || !TickerMode.valuesOf(context).enabled) return;

    _hasAnimatedIn = true;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _entryController.value = 1;
      return;
    }

    _entryController.value = 0;
    _entryDelay = Timer(
      Duration(milliseconds: math.min(widget.staggerIndex, 6) * 65),
      () {
        if (mounted) _entryController.forward(from: 0);
      },
    );
  }

  @override
  void didUpdateWidget(AnimatedProjectCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.photoCount > oldWidget.photoCount) {
      _photoController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entryDelay?.cancel();
    _entryController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: entry,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(entry),
        child: AnimatedBuilder(
          animation: _photoController,
          child: widget.child,
          builder: (context, child) {
            final photoPulse =
                math.sin(_photoController.value * math.pi) * 0.025;
            return Transform.scale(scale: 1 + photoPulse, child: child);
          },
        ),
      ),
    );
  }
}
