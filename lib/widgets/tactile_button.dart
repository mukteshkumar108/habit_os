import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A tactile button with a thick bottom border that presses down on tap.
/// Used for FAB, Create Task, AM/PM toggles, and icon selectors.
class TactileButton extends StatefulWidget {
  final Widget child;
  final Color color;
  final Color borderColor;
  final double borderBottomWidth;
  final double borderRadius;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const TactileButton({
    super.key,
    required this.child,
    this.color = AppColors.primaryContainer,
    this.borderColor = AppColors.borderDepth,
    this.borderBottomWidth = 4,
    this.borderRadius = 16,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        width: widget.width,
        height: widget.height,
        transform: Matrix4.translationValues(
          0,
          _isPressed ? widget.borderBottomWidth : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border(
            top: BorderSide(color: widget.borderColor, width: 0),
            left: BorderSide(color: widget.borderColor, width: 0),
            right: BorderSide(color: widget.borderColor, width: 0),
            bottom: BorderSide(
              color: widget.borderColor,
              width: _isPressed ? 0 : widget.borderBottomWidth,
            ),
          ),
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
