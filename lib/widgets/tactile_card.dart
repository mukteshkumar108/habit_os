import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A Duolingo-inspired tactile card with a thick bottom border that
/// compresses on press to simulate a 3D button-press effect.
class TactileCard extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderBottomWidth;
  final double borderRadius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const TactileCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderBottomWidth = 6,
    this.borderRadius = 24,
    this.onTap,
    this.padding,
  });

  @override
  State<TactileCard> createState() => _TactileCardState();
}

class _TactileCardState extends State<TactileCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.backgroundColor ?? AppColors.surfaceContainerLowest;
    final borderColor = widget.borderColor ?? AppColors.surfaceVariant;
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
        transform: Matrix4.translationValues(
          0,
          _isPressed ? widget.borderBottomWidth - 2 : 0,
          0,
        ),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border(
            top: BorderSide(color: borderColor, width: 2),
            left: BorderSide(color: borderColor, width: 2),
            right: BorderSide(color: borderColor, width: 2),
            bottom: BorderSide(
              color: borderColor,
              width: _isPressed ? 2 : widget.borderBottomWidth,
            ),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
