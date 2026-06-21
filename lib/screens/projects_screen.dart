import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      final crossCount = constraints.maxWidth > 600 ? 4 : 2;
                      return GridView.count(
                        crossAxisCount: crossCount,
                        mainAxisSpacing: AppSpacing.stackMd,
                        crossAxisSpacing: AppSpacing.stackMd,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 0.95,
                        children: const [
                          _DashboardProjectCard(title: 'Morning Routine'),
                          _DashboardProjectCard(title: 'Deep Work'),
                          _DashboardProjectCard(title: 'Fitness Goal'),
                          _DashboardProjectCard(title: 'Reading List'),
                        ],
                      );
                    },
                  ),
                ],
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

/// A project card for the dashboard grid with dashed border placeholder.
class _DashboardProjectCard extends StatefulWidget {
  final String title;

  const _DashboardProjectCard({required this.title});

  @override
  State<_DashboardProjectCard> createState() => _DashboardProjectCardState();
}

class _DashboardProjectCardState extends State<_DashboardProjectCard> {
  bool _isPressed = false;

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dashed placeholder area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: CustomPaint(
                  painter: _DashedBorderPainter(),
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      size: 32,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.stackSm),
            // Title
            Text(
              widget.title,
              style: AppTypography.headlineMd
                  .copyWith(color: AppColors.textMain, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter for dashed border effect on project cards.
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Border is handled by the Container decoration for simplicity;
    // the dashed effect is visually approximated by the outline-variant border.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
