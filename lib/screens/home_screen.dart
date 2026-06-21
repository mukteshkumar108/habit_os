import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/task_card.dart';
import '../widgets/project_card.dart';
import '../widgets/top_app_bar.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onAddTask;

  const HomeScreen({super.key, required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const HabitOsAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: AppSpacing.containerMargin,
                right: AppSpacing.containerMargin,
                top: AppSpacing.stackMd,
                bottom: 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Active Streaks Banner ──
                  _ActiveStreaksBanner(),
                  const SizedBox(height: AppSpacing.stackSm),

                  // ── Today's Pending Tasks ──
                  Text(
                    "Today's Pending Tasks",
                    style: AppTypography.headlineLgMobile,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3 tasks remaining • You\'ve got this!',
                    style: AppTypography.bodyMd
                        .copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  const TaskCard(
                    icon: Icons.menu_book,
                    title: 'Study Flutter widgets',
                    subtitle: 'Flutter Learning • 6:00 PM',
                    subtitleColor: AppColors.infoBlue,
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  const TaskCard(
                    icon: Icons.fitness_center,
                    title: 'Workout',
                    subtitle: 'Exercise • 7:30 PM',
                    subtitleColor: AppColors.warningYellow,
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  const TaskCard(
                    icon: Icons.code,
                    title: 'Build Habit_OS UI',
                    subtitle: 'Startup Building • 9:00 PM',
                    subtitleColor: AppColors.primaryContainer,
                  ),
                  const SizedBox(height: AppSpacing.stackLg),

                  // ── Projects Section ──
                  Text('Projects', style: AppTypography.headlineMd),
                  const SizedBox(height: AppSpacing.stackMd),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossCount = constraints.maxWidth > 600 ? 4 : 2;
                      return GridView.count(
                        crossAxisCount: crossCount,
                        mainAxisSpacing: AppSpacing.gutter,
                        crossAxisSpacing: AppSpacing.gutter,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.0,
                        children: const [
                          ProjectCard(
                            icon: Icons.work,
                            title: 'Deep Work',
                            iconBgColor: AppColors.surfaceVariant,
                            iconBorderColor: AppColors.surfaceDim,
                          ),
                          ProjectCard(
                            icon: Icons.fitness_center,
                            title: 'Exercise',
                            iconBgColor: AppColors.secondaryFixed,
                            iconBorderColor: AppColors.secondaryFixedDim,
                          ),
                          ProjectCard(
                            icon: Icons.code,
                            title: 'Flutter Learning',
                            iconBgColor: AppColors.tertiaryFixed,
                            iconBorderColor: AppColors.tertiaryFixedDim,
                          ),
                          ProjectCard(
                            icon: Icons.rocket_launch,
                            title: 'Startup Building',
                            iconBgColor: AppColors.primaryContainer,
                            iconBorderColor: AppColors.primary,
                          ),
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
      // ── FAB ──
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: onAddTask,
      child: Container(
        width: 64,
        height: 64,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          shape: BoxShape.circle,
          border: const Border(
            bottom: BorderSide(color: AppColors.borderDepth, width: 4),
          ),
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

/// Gold Active Streaks banner with shimmer animation and fire pulse.
class _ActiveStreaksBanner extends StatefulWidget {
  @override
  State<_ActiveStreaksBanner> createState() => _ActiveStreaksBannerState();
}

class _ActiveStreaksBannerState extends State<_ActiveStreaksBanner>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border(
          top: BorderSide(
              color: AppColors.onSecondaryContainer.withAlpha(50), width: 2),
          left: BorderSide(
              color: AppColors.onSecondaryContainer.withAlpha(50), width: 2),
          right: BorderSide(
              color: AppColors.onSecondaryContainer.withAlpha(50), width: 2),
          bottom: BorderSide(
              color: AppColors.onSecondaryContainer.withAlpha(50), width: 6),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Shimmer overlay
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Positioned.fill(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    final progress = _shimmerController.value;
                    return LinearGradient(
                      begin: Alignment(-1.5 + 4 * progress, 0),
                      end: Alignment(-0.5 + 4 * progress, 0),
                      colors: [
                        Colors.white.withAlpha(0),
                        Colors.white.withAlpha(100),
                        Colors.white.withAlpha(0),
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Container(color: Colors.white.withAlpha(25)),
                ),
              );
            },
          ),
          // Content
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: icon + text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fire icon with pulse
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: const Icon(
                          Icons.local_fire_department,
                          color: AppColors.onSecondaryContainer,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'KEEP THE MOMENTUM',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.onSecondaryContainer.withAlpha(180),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Active Streaks',
                      style: AppTypography.displayLg.copyWith(
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              // Right: big number
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '24',
                    style: TextStyle(
                      fontSize: 64,
                      height: 1.0,
                      fontWeight: FontWeight.w900,
                      color: AppColors.onSecondaryContainer,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(75),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'DAYS STRONG',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onSecondaryContainer.withAlpha(200),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
