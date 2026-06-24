import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/project_model.dart';
import '../models/proof_memory_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/proof_image.dart';

class ProofMemoryViewer extends StatelessWidget {
  final ProjectModel project;
  final ProofMemoryModel proof;
  final String heroTag;

  const ProofMemoryViewer({
    super.key,
    required this.project,
    required this.proof,
    required this.heroTag,
  });

  Future<void> _share(BuildContext context) async {
    final text = StringBuffer()
      ..writeln(project.projectName)
      ..writeln(DateFormat('MMM d, yyyy • h:mm a').format(proof.createdAt));
    if (proof.note.isNotEmpty) text.writeln(proof.note);
    await Clipboard.setData(ClipboardData(text: text.toString().trim()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memory details copied to share.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: heroTag,
                child: ProofImage(
                  imageReference: proof.imageReference,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: AnimatedTapScale(
                onTap: () => Navigator.pop(context),
                child: _circleButton(Icons.close_rounded),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: AnimatedTapScale(
                onTap: () => _share(context),
                child: _circleButton(Icons.share_rounded),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(185),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      project.projectName,
                      style: AppTypography.headlineMd.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'MMM d, yyyy • h:mm a',
                      ).format(proof.createdAt),
                      style: AppTypography.bodyMd.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    if (proof.note.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        proof.note,
                        style: AppTypography.bodyLg.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(165),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.onPrimary),
    );
  }
}
