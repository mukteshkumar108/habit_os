import 'package:shared_preferences/shared_preferences.dart';

import '../models/project_model.dart';
import '../models/proof_memory_model.dart';

class ProjectStorageService {
  static const _projectsKey = 'habit_os_projects_v2';
  static const _proofsKey = 'habit_os_proof_memories_v1';
  static const _legacyProjectsKey = 'projects';

  Future<List<ProjectModel>> loadProjects() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_legacyProjectsKey);
    final encodedProjects = preferences.getStringList(_projectsKey) ?? [];
    return encodedProjects
        .map(ProjectModel.fromJson)
        .where(
          (project) =>
              project.projectId.isNotEmpty && project.projectName.isNotEmpty,
        )
        .toList();
  }

  Future<void> saveProjects(Iterable<ProjectModel> projects) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _projectsKey,
      projects.map((project) => project.toJson()).toList(),
    );
  }

  Future<List<ProofMemoryModel>> loadProofMemories() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedProofs = preferences.getStringList(_proofsKey) ?? [];
    return encodedProofs
        .map(ProofMemoryModel.fromJson)
        .where(
          (proof) => proof.proofId.isNotEmpty && proof.projectId.isNotEmpty,
        )
        .toList();
  }

  Future<void> saveProofMemories(
    Iterable<ProofMemoryModel> proofMemories,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _proofsKey,
      proofMemories.map((proof) => proof.toJson()).toList(),
    );
  }
}
