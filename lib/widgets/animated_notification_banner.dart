import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'animated_tap_scale.dart';

class AnimatedNotificationBanner extends StatefulWidget {
  final Task task;
  final VoidCallback onDismissed;

  const AnimatedNotificationBanner({
    super.key,
    required this.task,
    required this.onDismissed,
  });

  @override
  State<AnimatedNotificationBanner> createState() =>
      _AnimatedNotificationBannerState();
}

class _AnimatedNotificationBannerState extends State<AnimatedNotificationBanner>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      reverseDuration: const Duration(milliseconds: 260),
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _dismissTimer = Timer(const Duration(seconds: 5), _dismiss);
  }

  Future<void> _dismiss() async {
    if (_isDismissing) return;
    _isDismissing = true;
    _dismissTimer?.cancel();
    await _entranceController.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entrance = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: FadeTransition(
          opacity: entrance,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.35),
              end: Offset.zero,
            ).animate(entrance),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 620),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                  border: const Border(
                    bottom: BorderSide(color: AppColors.borderDepth, width: 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(45),
                      blurRadius: 22,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) => Transform.scale(
                        scale: 1 + _pulseController.value * 0.1,
                        child: child,
                      ),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.warningYellow.withAlpha(210),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: AppColors.textMain,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.onPrimaryContainer,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Due ${DateFormat('h:mm a').format(widget.task.dueDate)}',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.onPrimaryContainer.withAlpha(
                                190,
                              ),
                            ),
                          ),
                          if (widget.task.notes.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.task.notes,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedTapScale(
                      onTap: _dismiss,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.onPrimaryContainer,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
