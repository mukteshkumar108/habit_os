import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/project_model.dart';
import '../models/proof_memory_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/material_icon.dart';
import 'animated_tap_scale.dart';
import 'proof_image.dart';
import 'project_themed_icon.dart';
import 'tactile_card.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final List<ProofMemoryModel> proofMemories;
  final bool compact;
  final bool proofAddedToday;
  final VoidCallback? onTap;
  final VoidCallback? onCameraTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.proofMemories,
    required this.proofAddedToday,
    required this.onCameraTap,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final latestProof = proofMemories.isEmpty ? null : proofMemories.first;
    return TactileCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 16 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProjectThemedIcon(
                key: ValueKey('project-icon-${project.projectId}'),
                icon: materialIconFromCodePoint(project.projectIcon),
                size: 56,
                iconSize: 26,
                variant: ProjectThemedIconVariant.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  project.projectName,
                  maxLines: compact ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.textMain,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AnimatedTapScale(
                onTap: onCameraTap,
                child: Opacity(
                  opacity: onCameraTap == null ? 0.58 : 1,
                  child: ProjectThemedIcon(
                    key: ValueKey('project-camera-${project.projectId}'),
                    icon: Icons.photo_camera_rounded,
                    size: 44,
                    iconSize: 20,
                    variant: ProjectThemedIconVariant.camera,
                  ),
                ),
              ),
            ],
          ),
          if (compact) ...[
            const Spacer(),
            _buildProofStatus(),
            const SizedBox(height: 8),
            Text(
              '${project.proofCount} proof ${project.proofCount == 1 ? 'memory' : 'memories'}',
              style: AppTypography.labelMd.copyWith(color: AppColors.textMuted),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Expanded(child: _buildMemoryPreview(latestProof)),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(child: _buildProofStatus()),
                Text(
                  '${project.proofCount} proof${project.proofCount == 1 ? '' : 's'}',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            if (project.lastProofDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Last proof ${DateFormat('MMM d').format(project.lastProofDate!)}',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildProofStatus() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          proofAddedToday
              ? Icons.local_fire_department_rounded
              : Icons.circle_outlined,
          size: 16,
          color: proofAddedToday
              ? AppColors.warningYellow
              : AppColors.textMuted,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            proofAddedToday ? 'Proof added today' : 'Proof needed today',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMd.copyWith(
              color: proofAddedToday ? AppColors.primary : AppColors.textMuted,
              fontWeight: proofAddedToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryPreview(ProofMemoryModel? proof) {
    if (proof == null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        alignment: Alignment.center,
        child: Text(
          'No memories yet',
          style: AppTypography.labelMd.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        child: SizedBox.expand(
          key: ValueKey(proof.proofId),
          child: ProofImage(imageReference: proof.imageReference),
        ),
      ),
    );
  }
}
