import 'package:flutter/material.dart';

enum ProjectThemedIconVariant { primary, camera, detail }

class ProjectThemedIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final ProjectThemedIconVariant variant;

  const ProjectThemedIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor;
    final Color borderColor;
    final Color iconColor;

    switch (variant) {
      case ProjectThemedIconVariant.primary:
      case ProjectThemedIconVariant.detail:
        backgroundColor = Color.alphaBlend(
          colors.primary.withAlpha(isDark ? 34 : 20),
          isDark ? colors.surfaceContainerHigh : colors.surfaceContainerLowest,
        );
        borderColor = colors.primary.withAlpha(isDark ? 105 : 70);
        iconColor = colors.primary;
        break;
      case ProjectThemedIconVariant.camera:
        backgroundColor = isDark
            ? colors.surfaceContainerHigh
            : colors.surfaceContainerLow;
        borderColor = colors.outlineVariant.withAlpha(isDark ? 150 : 190);
        iconColor = colors.onSurfaceVariant;
        break;
    }

    final isDetail = variant == ProjectThemedIconVariant.detail;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: isDetail ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isDetail ? BorderRadius.circular(22) : null,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Icon(icon, size: iconSize, color: iconColor),
    );
  }
}
