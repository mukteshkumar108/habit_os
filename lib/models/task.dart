import 'dart:convert';
import 'package:flutter/material.dart';

enum TaskStatus {
  pending('pending', 'Pending'),
  completedOnTime('completed_on_time', 'Completed On Time'),
  completedLate('completed_late', 'Completed Late'),
  missed('missed', 'Missed');

  final String storageValue;
  final String label;

  const TaskStatus(this.storageValue, this.label);

  static TaskStatus fromStorage(String? value) {
    return TaskStatus.values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => TaskStatus.pending,
    );
  }
}

class Task {
  static const int currentSchemaVersion = 4;

  final String id;
  final String title;
  final String? projectId;
  final String? projectName;
  final int iconCodePoint;
  final DateTime dueDate;
  final int reminderFrequencyMinutes;
  final String notes;
  final TaskStatus status;
  final DateTime? completedAt;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.projectId,
    this.projectName,
    required this.iconCodePoint,
    required this.dueDate,
    required this.reminderFrequencyMinutes,
    required this.notes,
    this.status = TaskStatus.pending,
    this.completedAt,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? projectId,
    String? projectName,
    int? iconCodePoint,
    DateTime? dueDate,
    int? reminderFrequencyMinutes,
    String? notes,
    TaskStatus? status,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      dueDate: dueDate ?? this.dueDate,
      reminderFrequencyMinutes:
          reminderFrequencyMinutes ?? this.reminderFrequencyMinutes,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schemaVersion': currentSchemaVersion,
      'id': id,
      'title': title,
      'projectId': projectId,
      'projectName': projectName,
      'iconCodePoint': iconCodePoint,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'reminderFrequencyMinutes': reminderFrequencyMinutes,
      'notes': notes,
      'status': status.storageValue,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final schemaVersion = map['schemaVersion'] as int? ?? 1;
    final rawProjectId = (map['projectId'] as String?)?.trim();
    final rawProjectName = (map['projectName'] as String?)?.trim();
    final hasExplicitProject =
        schemaVersion >= 2 &&
        rawProjectId != null &&
        rawProjectId.isNotEmpty &&
        rawProjectName != null &&
        rawProjectName.isNotEmpty;

    final legacyCompleted = map['isCompleted'] as bool? ?? false;
    final status = schemaVersion >= currentSchemaVersion
        ? TaskStatus.fromStorage(map['status'] as String?)
        : legacyCompleted
        ? TaskStatus.completedOnTime
        : TaskStatus.pending;
    final completedAtEpoch = map['completedAt'] as int?;

    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      projectId: hasExplicitProject ? rawProjectId : null,
      projectName: hasExplicitProject ? rawProjectName : null,
      iconCodePoint: map['iconCodePoint'] ?? Icons.task.codePoint,
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate'] ?? 0),
      reminderFrequencyMinutes: schemaVersion >= 3
          ? map['reminderFrequencyMinutes'] ?? 0
          : 0,
      notes: map['notes'] ?? '',
      status: status,
      completedAt: completedAtEpoch == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(completedAtEpoch),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));

  bool get isCompleted =>
      status == TaskStatus.completedOnTime ||
      status == TaskStatus.completedLate;

  bool get isPending => status == TaskStatus.pending;

  bool get isMissed => status == TaskStatus.missed;

  bool get isTerminal => status != TaskStatus.pending;

  bool isOverdueAt(DateTime moment) =>
      status == TaskStatus.pending && moment.isAfter(dueDate);

  String get reminderFrequencyLabel {
    if (reminderFrequencyMinutes <= 0) return 'No reminder';
    if (reminderFrequencyMinutes % 60 == 0) {
      final hours = reminderFrequencyMinutes ~/ 60;
      return 'Every $hours ${hours == 1 ? 'hour' : 'hours'}';
    }
    return 'Every $reminderFrequencyMinutes minutes';
  }
}
