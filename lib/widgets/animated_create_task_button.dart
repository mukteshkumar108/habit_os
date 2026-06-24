import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AnimatedCreateTaskButton extends StatefulWidget {
  final bool enabled;
  final Future<void> Function()? onPressed;
  final String label;

  const AnimatedCreateTaskButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    this.label = 'Create Task',
  });

  @override
  State<AnimatedCreateTaskButton> createState() =>
      _AnimatedCreateTaskButtonState();
}

class _AnimatedCreateTaskButtonState extends State<AnimatedCreateTaskButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _activationController;
  bool _isPressed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _activationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 440),
      value: widget.enabled ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(AnimatedCreateTaskButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.enabled && widget.enabled) {
      _activationController.forward(from: 0);
    } else if (oldWidget.enabled && !widget.enabled) {
      _activationController.reverse();
    }
  }

  Future<void> _handleTap() async {
    if (_isLoading || widget.onPressed == null) return;
    setState(() => _isLoading = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPressed = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _activationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPress = !_isLoading && widget.onPressed != null;

    return AnimatedBuilder(
      animation: _activationController,
      builder: (context, child) {
        final activation = Curves.easeOutBack.transform(
          _activationController.value,
        );
        final enabledScale = 0.98 + activation * 0.02;

        return Semantics(
          button: true,
          enabled: widget.enabled,
          label: widget.label,
          child: GestureDetector(
            onTapDown: canPress
                ? (_) => setState(() => _isPressed = true)
                : null,
            onTapUp: canPress
                ? (_) => setState(() => _isPressed = false)
                : null,
            onTapCancel: canPress
                ? () => setState(() => _isPressed = false)
                : null,
            onTap: canPress ? _handleTap : null,
            child: AnimatedScale(
              scale: _isPressed ? 0.97 : enabledScale,
              duration: const Duration(milliseconds: 110),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: 64,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? AppColors.primaryContainer
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border(
                    bottom: BorderSide(
                      color: widget.enabled
                          ? AppColors.borderDepth
                          : AppColors.surfaceDim,
                      width: _isPressed ? 3 : 8,
                    ),
                  ),
                  boxShadow: widget.enabled && !_isPressed
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(
                              22 + (activation * 24).round(),
                            ),
                            blurRadius: 14 + activation * 6,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : const [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: AppTypography.headlineMd.copyWith(
                        color: widget.enabled
                            ? AppColors.onPrimary
                            : AppColors.textMuted,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isLoading
                          ? SizedBox(
                              key: const ValueKey('loading'),
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : Icon(
                              Icons.check_circle,
                              key: const ValueKey('ready'),
                              color: widget.enabled
                                  ? AppColors.onPrimary
                                  : AppColors.textMuted,
                              size: 24,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
