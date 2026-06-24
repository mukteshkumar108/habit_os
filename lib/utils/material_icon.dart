import 'package:flutter/material.dart';

const List<IconData> _storedMaterialIcons = [
  Icons.task,
  Icons.work,
  Icons.menu_book,
  Icons.fitness_center,
  Icons.code,
  Icons.sports_basketball,
  Icons.palette,
  Icons.language,
  Icons.music_note,
  Icons.rocket_launch,
  Icons.bolt,
  Icons.water_drop,
  Icons.self_improvement,
  Icons.brush,
  Icons.work_rounded,
  Icons.menu_book_rounded,
  Icons.fitness_center_rounded,
  Icons.code_rounded,
  Icons.palette_rounded,
  Icons.language_rounded,
  Icons.rocket_launch_rounded,
  Icons.brush_rounded,
  Icons.folder_special_rounded,
];

IconData materialIconFromCodePoint(int codePoint) {
  for (final icon in _storedMaterialIcons) {
    if (icon.codePoint == codePoint) {
      return icon;
    }
  }

  return Icons.task;
}
