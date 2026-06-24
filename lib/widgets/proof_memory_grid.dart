import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/project_model.dart';
import '../models/proof_memory_model.dart';
import '../screens/proof_memory_viewer.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'animated_tap_scale.dart';
import 'proof_image.dart';

class ProofMemoryGrid extends StatelessWidget {
  final ProjectModel project;
  final List<ProofMemoryModel> proofs;

  const ProofMemoryGrid({
    super.key,
    required this.project,
    required this.proofs,
  });

  @override
  Widget build(BuildContext context) {
    if (proofs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          'No memories yet',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLg.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        var crossAxisCount = 2;
        if (constraints.maxWidth >= 620) crossAxisCount = 3;
        if (constraints.maxWidth >= 860) crossAxisCount = 4;
        const spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
            crossAxisCount;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: itemWidth * 0.75 + 52,
          ),
          itemCount: proofs.length,
          itemBuilder: (context, index) {
            final proof = proofs[index];
            final heroTag = 'proof-${proof.proofId}';
            final staggerIndex = index.clamp(0, 5);
            return TweenAnimationBuilder<double>(
              key: ValueKey(proof.proofId),
              tween: Tween(begin: 0.9, end: 1),
              duration: Duration(milliseconds: 280 + staggerIndex * 45),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Opacity(
                opacity: ((scale - 0.9) / 0.1).clamp(0.0, 1.0),
                child: Transform.scale(scale: scale, child: child),
              ),
              child: AnimatedTapScale(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProofMemoryViewer(
                        project: project,
                        proof: proof,
                        heroTag: heroTag,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Hero(
                          tag: heroTag,
                          child: ProofImage(
                            imageReference: proof.imageReference,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat(
                                  'MMM d • h:mm a',
                                ).format(proof.createdAt),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            if (proof.note.isNotEmpty)
                              Icon(
                                Icons.notes_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
