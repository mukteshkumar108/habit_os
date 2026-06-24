import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/proof_memory_model.dart';
import '../models/task.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/calendar_day_cell.dart';
import '../widgets/proof_image.dart';
import '../widgets/responsive_layout.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(now.year, now.month);
  }

  int get _daysInMonth =>
      DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
  int get _startOffset =>
      DateTime(_currentMonth.year, _currentMonth.month, 1).weekday - 1;

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final selectedTasks = appState.tasksForDate(_selectedDate);
    final selectedProofs = appState.proofsForDate(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
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
                Text('Calendar', style: AppTypography.headlineLgMobile),
                const SizedBox(height: AppSpacing.stackMd),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 700) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildCalendar(appState)),
                          const SizedBox(width: 48),
                          Expanded(
                            child: _buildSelectedDateContent(
                              selectedTasks,
                              selectedProofs,
                              appState,
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalendar(appState),
                        const SizedBox(height: AppSpacing.stackLg),
                        _buildSelectedDateContent(
                          selectedTasks,
                          selectedProofs,
                          appState,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          top: BorderSide(color: AppColors.surfaceContainerHighest, width: 2),
          left: BorderSide(color: AppColors.surfaceContainerHighest, width: 2),
          right: BorderSide(color: AppColors.surfaceContainerHighest, width: 2),
          bottom: BorderSide(
            color: AppColors.surfaceContainerHighest,
            width: 4,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(Icons.chevron_left, _previousMonth),
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.textMain,
                  ),
                ),
                _buildNavButton(Icons.chevron_right, _nextMonth),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 52,
            ),
            itemCount: _startOffset + _daysInMonth,
            itemBuilder: (context, index) {
              if (index < _startOffset) {
                return const CalendarDayCell();
              }
              final day = index - _startOffset + 1;
              final isSelected =
                  day == _selectedDate.day &&
                  _currentMonth.month == _selectedDate.month &&
                  _currentMonth.year == _selectedDate.year;
              final date = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                day,
              );
              return CalendarDayCell(
                day: day,
                isSelected: isSelected,
                markers: _statusMarkers(appState.tasksForDate(date)),
                onTap: () => setState(() {
                  _selectedDate = DateTime(
                    _currentMonth.year,
                    _currentMonth.month,
                    day,
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Color> _statusMarkers(List<Task> tasks) {
    final statuses = tasks.map((task) => task.status).toSet();
    return [
      if (statuses.contains(TaskStatus.missed)) AppColors.errorRed,
      if (statuses.contains(TaskStatus.completedLate)) AppColors.lateOrange,
      if (statuses.contains(TaskStatus.completedOnTime))
        AppColors.primaryContainer,
      if (statuses.contains(TaskStatus.pending)) AppColors.surfaceDim,
    ];
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Center(child: Icon(icon, size: 28, color: AppColors.textMain)),
      ),
    );
  }

  Widget _buildSelectedDateContent(
    List<Task> tasks,
    List<ProofMemoryModel> proofs,
    AppState appState,
  ) {
    final validProofs = proofs
        .where((proof) => appState.projectById(proof.projectId) != null)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DailyTaskRecordsCard(
          subtitle: _taskSummary(tasks),
          onTap: () => _showTaskRecordsSheet(tasks),
        ),
        if (validProofs.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.stackLg),
          Text('Project Records', style: AppTypography.headlineMd),
          const SizedBox(height: AppSpacing.stackMd),
          _ProofMemoryWall(
            proofs: validProofs,
            projectNameFor: (proof) =>
                appState.projectById(proof.projectId)!.projectName,
            onTap: (proof) {
              final project = appState.projectById(proof.projectId);
              if (project == null) return;
              _showProofDetails(proof, project.projectName);
            },
          ),
        ],
      ],
    );
  }

  String _taskSummary(List<Task> tasks) {
    final completed = tasks
        .where((task) => task.status == TaskStatus.completedOnTime)
        .length;
    final missed = tasks
        .where((task) => task.status == TaskStatus.missed)
        .length;
    final late = tasks
        .where((task) => task.status == TaskStatus.completedLate)
        .length;
    final pending = tasks
        .where((task) => task.status == TaskStatus.pending)
        .length;
    final parts = <String>[
      '$completed completed',
      '$missed missed',
      '$late late',
      if (pending > 0) '$pending pending',
      '${tasks.length} total',
    ];
    return parts.join(' • ');
  }

  void _showTaskRecordsSheet(List<Task> tasks) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 720),
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.84,
        child: _TaskRecordsSheet(date: _selectedDate, tasks: tasks),
      ),
    );
  }

  void _showProofDetails(ProofMemoryModel proof, String projectName) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 720),
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.9,
        child: _ProofDetailSheet(proof: proof, projectName: projectName),
      ),
    );
  }
}

class _DailyTaskRecordsCard extends StatelessWidget {
  final String subtitle;
  final VoidCallback onTap;

  const _DailyTaskRecordsCard({required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.surfaceContainerHighest,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.surfaceContainerHighest,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(24),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.fact_check_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Task Records',
                      style: AppTypography.bodyLg.copyWith(
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      style: AppTypography.labelMd.copyWith(
                        height: 1.35,
                        color: AppColors.textMain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskRecordsSheet extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;

  const _TaskRecordsSheet({required this.date, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 14, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Task Records',
                          style: AppTypography.headlineMd,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMM d, yyyy').format(date),
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.surfaceContainerHighest),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        'No tasks scheduled for this day.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: tasks.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _TaskRecordRow(number: index + 1, task: tasks[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskRecordRow extends StatelessWidget {
  final int number;
  final Task task;

  const _TaskRecordRow({required this.number, required this.task});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(task.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withAlpha(120), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(24),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: AppTypography.labelMd.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTypography.bodyLg.copyWith(
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Status: ${task.status.label}',
                  style: AppTypography.labelMd.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                _RecordDetail(
                  label: 'Due',
                  value: DateFormat('h:mm a').format(task.dueDate),
                ),
                if (task.completedAt case final completedAt?) ...[
                  const SizedBox(height: 5),
                  _RecordDetail(
                    label: 'Completed',
                    value: DateFormat('h:mm a').format(completedAt),
                  ),
                ],
                if (task.projectName?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 5),
                  _RecordDetail(label: 'Project', value: task.projectName!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordDetail extends StatelessWidget {
  final String label;
  final String value;

  const _RecordDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: AppTypography.labelMd.copyWith(
        height: 1.25,
        color: AppColors.textMain,
      ),
    );
  }
}

class _ProofMemoryWall extends StatelessWidget {
  final List<ProofMemoryModel> proofs;
  final String Function(ProofMemoryModel proof) projectNameFor;
  final ValueChanged<ProofMemoryModel> onTap;

  const _ProofMemoryWall({
    required this.proofs,
    required this.projectNameFor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        const featuredAspectRatio = 16 / 10;
        const pairedAspectRatio = 4 / 3;
        final screenWidth = MediaQuery.sizeOf(context).width;
        var crossAxisCount = 2;
        if (screenWidth >= 700 && constraints.maxWidth >= 360) {
          crossAxisCount = 3;
        }
        if (screenWidth >= 1100 && constraints.maxWidth >= 520) {
          crossAxisCount = 4;
        }
        final layout = switch (proofs.length) {
          1 => AspectRatio(
            aspectRatio: featuredAspectRatio,
            child: _buildTile(0),
          ),
          2 => Column(
            children: [
              AspectRatio(
                aspectRatio: featuredAspectRatio,
                child: _buildTile(0),
              ),
              const SizedBox(height: spacing),
              AspectRatio(
                aspectRatio: featuredAspectRatio,
                child: _buildTile(1),
              ),
            ],
          ),
          3 => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: pairedAspectRatio,
                      child: _buildTile(0),
                    ),
                  ),
                  const SizedBox(width: spacing),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: pairedAspectRatio,
                      child: _buildTile(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: spacing),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: (constraints.maxWidth - spacing) / 2,
                  child: AspectRatio(
                    aspectRatio: pairedAspectRatio,
                    child: _buildTile(2),
                  ),
                ),
              ),
            ],
          ),
          _ => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: 1,
            ),
            itemCount: proofs.length,
            itemBuilder: (context, index) => _buildTile(index),
          ),
        };
        return SizedBox(
          key: ValueKey('project-records-layout-${proofs.length}'),
          width: double.infinity,
          child: layout,
        );
      },
    );
  }

  Widget _buildTile(int index) {
    final proof = proofs[index];
    return _ProofMemoryTile(
      proof: proof,
      projectName: projectNameFor(proof),
      onTap: () => onTap(proof),
    );
  }
}

class _ProofMemoryTile extends StatelessWidget {
  final ProofMemoryModel proof;
  final String projectName;
  final VoidCallback onTap;

  const _ProofMemoryTile({
    required this.proof,
    required this.projectName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: ValueKey('calendar-proof-${proof.proofId}'),
      borderRadius: BorderRadius.circular(10),
      child: Material(
        color: AppColors.inverseSurface,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ProofImage(
                imageReference: proof.imageReference,
                fit: BoxFit.cover,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x16000000),
                      Color(0xC9000000),
                    ],
                    stops: [0.45, 0.62, 1],
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(proof.createdAt),
                      style: AppTypography.labelMd.copyWith(
                        height: 1.2,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        shadows: const [Shadow(blurRadius: 3)],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      projectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMd.copyWith(
                        height: 1.2,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        shadows: const [Shadow(blurRadius: 3)],
                      ),
                    ),
                    if (proof.note.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Note: ${proof.note.trim()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMd.copyWith(
                          height: 1.2,
                          color: Colors.white.withAlpha(225),
                          shadows: const [Shadow(blurRadius: 3)],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProofDetailSheet extends StatelessWidget {
  final ProofMemoryModel proof;
  final String projectName;

  const _ProofDetailSheet({required this.proof, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 2, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(projectName, style: AppTypography.headlineMd),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.sizeOf(context).height * 0.42,
                        color: Colors.black,
                        child: ProofImage(
                          imageReference: proof.imageReference,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ProofDetailLine(label: 'Project', value: projectName),
                    const SizedBox(height: 10),
                    _ProofDetailLine(
                      label: 'Date',
                      value: DateFormat('dd/MM/yyyy').format(proof.createdAt),
                    ),
                    const SizedBox(height: 10),
                    _ProofDetailLine(
                      label: 'Time',
                      value: DateFormat('h:mm a').format(proof.createdAt),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Note',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      proof.note.trim().isEmpty
                          ? 'No note added.'
                          : proof.note.trim(),
                      style: AppTypography.bodyMd,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProofDetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _ProofDetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: AppTypography.labelMd.copyWith(color: AppColors.textMuted),
          ),
        ),
        Expanded(
          child: Text(value, style: AppTypography.bodyMd.copyWith(height: 1.2)),
        ),
      ],
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      child: Container(
        width: 42,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

Color _statusColor(TaskStatus status) {
  return switch (status) {
    TaskStatus.completedOnTime => AppColors.primaryContainer,
    TaskStatus.completedLate => AppColors.lateOrange,
    TaskStatus.missed => AppColors.errorRed,
    TaskStatus.pending => AppColors.outline,
  };
}
