import 'dart:convert';

enum ProofSourceType { camera, webcam, gallery, fileUpload }

class ProofMemoryModel {
  final String proofId;
  final String projectId;
  final String projectName;
  final String imageReference;
  final String note;
  final DateTime createdAt;
  final ProofSourceType sourceType;

  const ProofMemoryModel({
    required this.proofId,
    required this.projectId,
    this.projectName = '',
    required this.imageReference,
    required this.note,
    required this.createdAt,
    required this.sourceType,
  });

  ProofMemoryModel copyWith({String? projectName}) {
    return ProofMemoryModel(
      proofId: proofId,
      projectId: projectId,
      projectName: projectName ?? this.projectName,
      imageReference: imageReference,
      note: note,
      createdAt: createdAt,
      sourceType: sourceType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'proofId': proofId,
      'projectId': projectId,
      'projectName': projectName,
      'imageReference': imageReference,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'sourceType': sourceType.name,
    };
  }

  factory ProofMemoryModel.fromMap(Map<String, dynamic> map) {
    return ProofMemoryModel(
      proofId: map['proofId'] as String? ?? '',
      projectId: map['projectId'] as String? ?? '',
      projectName: map['projectName'] as String? ?? '',
      imageReference: map['imageReference'] as String? ?? '',
      note: map['note'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      sourceType: ProofSourceType.values.firstWhere(
        (type) => type.name == map['sourceType'],
        orElse: () => ProofSourceType.gallery,
      ),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ProofMemoryModel.fromJson(String source) =>
      ProofMemoryModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
