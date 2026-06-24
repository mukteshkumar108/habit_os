import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/responsive_layout.dart';
import '../state/app_state.dart';
import '../models/project.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Sticky top bar
          Container(
            height: MediaQuery.of(context).padding.top + 64,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceVariant, width: 4),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: AppSpacing.containerMargin,
                right: AppSpacing.containerMargin,
                top: AppSpacing.stackLg,
                bottom: 120,
              ),
              child: ResponsiveLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'My Projects',
                      style: AppTypography.headlineLg.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your active habits and goals',
                      style: AppTypography.bodyMd
                          .copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),

                    // Project grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossCount = 2;
                        if (constraints.maxWidth > 600) crossCount = 3;
                        if (constraints.maxWidth > 900) crossCount = 4;
                        
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossCount,
                            mainAxisSpacing: AppSpacing.stackMd,
                            crossAxisSpacing: AppSpacing.stackMd,
                            childAspectRatio: 0.95,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: appState.projects.length,
                          itemBuilder: (context, index) {
                            return _DashboardProjectCard(
                              project: appState.projects[index],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Blue FAB
      floatingActionButton: _buildBlueFab(),
    );
  }

  Widget _buildBlueFab() {
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.infoBlue,
        shape: BoxShape.circle,
        border: const Border(
          bottom: BorderSide(color: Color(0xFF148DC6), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.infoBlue.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}

class _DashboardProjectCard extends StatefulWidget {
  final Project project;

  const _DashboardProjectCard({required this.project});

  @override
  State<_DashboardProjectCard> createState() => _DashboardProjectCardState();
}

class _DashboardProjectCardState extends State<_DashboardProjectCard> {
  bool _isPressed = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null && mounted) {
      context.read<AppState>().addProjectPhoto(widget.project.id, image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            top: const BorderSide(color: AppColors.surfaceVariant, width: 0),
            left: const BorderSide(color: AppColors.surfaceVariant, width: 0),
            right: const BorderSide(color: AppColors.surfaceVariant, width: 0),
            bottom: BorderSide(
              color: AppColors.surfaceVariant,
              width: _isPressed ? 0 : 4,
            ),
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            // Top Row: Icon & Camera
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  IconData(widget.project.iconCodePoint, fontFamily: 'MaterialIcons'),
                  color: Color(widget.project.iconBorderColorValue),
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_camera,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Middle: Photos or Empty State
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: widget.project.photoPaths.isEmpty
                    ? Center(
                        child: Text(
                          'No memories yet',
                          style: AppTypography.labelMd.copyWith(color: AppColors.textMuted),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(4),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: widget.project.photoPaths.length,
                        itemBuilder: (context, i) {
                          final path = widget.project.photoPaths[i];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: kIsWeb 
                                ? Image.network(path, fit: BoxFit.cover)
                                : Image.file(File(path), fit: BoxFit.cover),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.stackSm),
            // Title
            Text(
              widget.project.title,
              style: AppTypography.headlineMd
                  .copyWith(color: AppColors.textMain, fontSize: 16),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
