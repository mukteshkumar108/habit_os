import 'dart:convert';

class ProjectModel {
  final String projectId;
  final String projectName;
  final int projectIcon;
  final int iconBgColorValue;
  final int iconBorderColorValue;
  final String projectDescription;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int proofCount;
  final int currentProofStreak;
  final DateTime? lastProofDate;

  const ProjectModel({
    required this.projectId,
    required this.projectName,
    required this.projectIcon,
    required this.iconBgColorValue,
    required this.iconBorderColorValue,
    required this.projectDescription,
    required this.createdAt,
    required this.updatedAt,
    this.proofCount = 0,
    this.currentProofStreak = 0,
    this.lastProofDate,
  });

  ProjectModel copyWith({
    String? projectId,
    String? projectName,
    int? projectIcon,
    int? iconBgColorValue,
    int? iconBorderColorValue,
    String? projectDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? proofCount,
    int? currentProofStreak,
    DateTime? lastProofDate,
  }) {
    return ProjectModel(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      projectIcon: projectIcon ?? this.projectIcon,
      iconBgColorValue: iconBgColorValue ?? this.iconBgColorValue,
      iconBorderColorValue: iconBorderColorValue ?? this.iconBorderColorValue,
      projectDescription: projectDescription ?? this.projectDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      proofCount: proofCount ?? this.proofCount,
      currentProofStreak: currentProofStreak ?? this.currentProofStreak,
      lastProofDate: lastProofDate ?? this.lastProofDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'projectIcon': projectIcon,
      'iconBgColorValue': iconBgColorValue,
      'iconBorderColorValue': iconBorderColorValue,
      'projectDescription': projectDescription,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'proofCount': proofCount,
      'currentProofStreak': currentProofStreak,
      'lastProofDate': lastProofDate?.toIso8601String(),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();
    return ProjectModel(
      projectId: map['projectId'] as String? ?? '',
      projectName: map['projectName'] as String? ?? '',
      projectIcon: map['projectIcon'] as int? ?? 0,
      iconBgColorValue: map['iconBgColorValue'] as int? ?? 0xFFE2E2E2,
      iconBorderColorValue: map['iconBorderColorValue'] as int? ?? 0xFFDADADA,
      projectDescription: map['projectDescription'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? now,
      proofCount: map['proofCount'] as int? ?? 0,
      currentProofStreak: map['currentProofStreak'] as int? ?? 0,
      lastProofDate: DateTime.tryParse(map['lastProofDate'] as String? ?? ''),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ProjectModel.fromJson(String source) =>
      ProjectModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
