import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/task_card.dart';
import '../widgets/project_card.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/responsive_layout.dart';
import '../state/app_state.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onAddTask;

  const HomeScreen({super.key, required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    final now = DateTime.now();
    final todayTasks = appState.tasks.where((t) {
      return t.dueDate.year == now.year &&
             t.dueDate.month == now.month &&
             t.dueDate.day == now.day &&
             !t.isCompleted;
    }).toList();
    
    // Sort tasks by time
    todayTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

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
              child: ResponsiveLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Active Streaks Banner ──
                    _ActiveStreaksBanner(streakCount: appState.streakCount),
                    const SizedBox(height: AppSpacing.stackSm),

                    // ── Today's Pending Tasks ──
                    Text(
                      "Today's Pending Tasks",
                      style: AppTypography.headlineLgMobile,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      todayTasks.isEmpty 
                          ? 'No tasks planned.'
                          : '${todayTasks.length} tasks remaining • You\'ve got this!',
                      style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    
                    if (todayTasks.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceVariant, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            "You didn't plan your day today. Please make your tasks.",
                            style: AppTypography.bodyLg.copyWith(color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todayTasks.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.stackMd),
                        itemBuilder: (context, index) {
                          final task = todayTasks[index];
                          final project = appState.projects.firstWhere(
                            (p) => p.id == task.projectId, 
                            orElse: () => appState.projects.first
                          );
                          return TaskCard(
                            icon: IconData(task.iconCodePoint, fontFamily: 'MaterialIcons'),
                            title: task.title,
                            subtitle: '${project.title} • ${DateFormat('h:mm a').format(task.dueDate)}',
                            subtitleColor: Color(project.iconBorderColorValue),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskDetailScreen(task: task),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    
                    const SizedBox(height: AppSpacing.stackLg),

                    // ── Projects Section ──
                    Text('Projects', style: AppTypography.headlineMd),
                    const SizedBox(height: AppSpacing.stackMd),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossCount = 2;
                        if (constraints.maxWidth > 600) crossCount = 3;
                        if (constraints.maxWidth > 900) crossCount = 4;
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossCount,
                            mainAxisSpacing: AppSpacing.gutter,
                            crossAxisSpacing: AppSpacing.gutter,
                            childAspectRatio: 1.0,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: appState.projects.length,
                          itemBuilder: (context, index) {
                            final project = appState.projects[index];
                            return ProjectCard(
                              icon: IconData(project.iconCodePoint, fontFamily: 'MaterialIcons'),
                              title: project.title,
                              iconBgColor: Color(project.iconBgColorValue),
                              iconBorderColor: Color(project.iconBorderColorValue),
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
  final int streakCount;
  
  const _ActiveStreaksBanner({required this.streakCount});

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
    );
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.streakCount > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_ActiveStreaksBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streakCount > 0 && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.streakCount == 0 && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasStreak = widget.streakCount > 0;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: hasStreak ? AppColors.secondaryContainer : AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border(
          top: BorderSide(
              color: hasStreak ? AppColors.onSecondaryContainer.withAlpha(50) : AppColors.surfaceDim, width: 2),
          left: BorderSide(
              color: hasStreak ? AppColors.onSecondaryContainer.withAlpha(50) : AppColors.surfaceDim, width: 2),
          right: BorderSide(
              color: hasStreak ? AppColors.onSecondaryContainer.withAlpha(50) : AppColors.surfaceDim, width: 2),
          bottom: BorderSide(
              color: hasStreak ? AppColors.onSecondaryContainer.withAlpha(50) : AppColors.surfaceDim, width: 6),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Shimmer overlay
          if (hasStreak)
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
                        scale: hasStreak ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                        child: Icon(
                          hasStreak ? Icons.local_fire_department : Icons.fireplace,
                          color: hasStreak ? AppColors.onSecondaryContainer : AppColors.textMuted,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hasStreak ? 'KEEP THE MOMENTUM' : 'START YOUR STREAK',
                      style: AppTypography.labelLg.copyWith(
                        color: hasStreak 
                            ? AppColors.onSecondaryContainer.withAlpha(180)
                            : AppColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Active Streaks',
                      style: AppTypography.displayLg.copyWith(
                        color: hasStreak ? AppColors.onSecondaryContainer : AppColors.textMain,
                      ),
                    ),
                  ],
                ),
              ),
              // Right: big number
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Text(
                      '${widget.streakCount}',
                      key: ValueKey<int>(widget.streakCount),
                      style: TextStyle(
                        fontSize: 64,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                        color: hasStreak ? AppColors.onSecondaryContainer : AppColors.textMuted,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasStreak ? Colors.white.withAlpha(75) : AppColors.surfaceDim,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      hasStreak ? 'DAYS STRONG' : 'LET\'S GO',
                      style: AppTypography.labelMd.copyWith(
                        color: hasStreak 
                            ? AppColors.onSecondaryContainer.withAlpha(200)
                            : AppColors.textMain.withAlpha(200),
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
