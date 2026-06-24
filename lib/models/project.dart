import 'dart:convert';
import 'package:flutter/material.dart';

class Project {
  final String id;
  final String title;
  final int iconCodePoint;
  final int iconBgColorValue;
  final int iconBorderColorValue;
  final List<String> photoPaths;

  Project({
    required this.id,
    required this.title,
    required this.iconCodePoint,
    required this.iconBgColorValue,
    required this.iconBorderColorValue,
    this.photoPaths = const [],
  });

  Project copyWith({
    String? id,
    String? title,
    int? iconCodePoint,
    int? iconBgColorValue,
    int? iconBorderColorValue,
    List<String>? photoPaths,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconBgColorValue: iconBgColorValue ?? this.iconBgColorValue,
      iconBorderColorValue: iconBorderColorValue ?? this.iconBorderColorValue,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'iconCodePoint': iconCodePoint,
      'iconBgColorValue': iconBgColorValue,
      'iconBorderColorValue': iconBorderColorValue,
      'photoPaths': photoPaths,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      iconCodePoint: map['iconCodePoint'] ?? Icons.work.codePoint,
      iconBgColorValue: map['iconBgColorValue'] ?? 0xFFE2E2E2,
      iconBorderColorValue: map['iconBorderColorValue'] ?? 0xFFDADADA,
      photoPaths: List<String>.from(map['photoPaths'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Project.fromJson(String source) =>
      Project.fromMap(json.decode(source));
}
