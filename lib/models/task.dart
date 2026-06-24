import 'dart:convert';
import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String projectId;
  final int iconCodePoint;
  final DateTime dueDate;
  final int reminderMinutes;
  final String notes;
  final bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.projectId,
    required this.iconCodePoint,
    required this.dueDate,
    required this.reminderMinutes,
    required this.notes,
    this.isCompleted = false,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? projectId,
    int? iconCodePoint,
    DateTime? dueDate,
    int? reminderMinutes,
    String? notes,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      projectId: projectId ?? this.projectId,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      dueDate: dueDate ?? this.dueDate,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'projectId': projectId,
      'iconCodePoint': iconCodePoint,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'reminderMinutes': reminderMinutes,
      'notes': notes,
      'isCompleted': isCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      projectId: map['projectId'] ?? '',
      iconCodePoint: map['iconCodePoint'] ?? Icons.task.codePoint,
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate'] ?? 0),
      reminderMinutes: map['reminderMinutes'] ?? 0,
      notes: map['notes'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}
