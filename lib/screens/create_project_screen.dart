import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/project_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/animated_create_task_button.dart';
import '../widgets/animated_icon_picker.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/project_themed_icon.dart';

class CreateProjectScreen extends StatefulWidget {
  final ProjectModel? project;

  const CreateProjectScreen({super.key, this.project});

  bool get isEditing => project != null;

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  static const _icons = [
    Icons.work_rounded,
    Icons.fitness_center_rounded,
    Icons.code_rounded,
    Icons.rocket_launch_rounded,
    Icons.palette_rounded,
    Icons.menu_book_rounded,
    Icons.language_rounded,
    Icons.brush_rounded,
  ];
  static const _backgroundColors = [
    0xFFE2E2E2,
    0xFFFFDF92,
    0xFFC8E6FF,
    0xFFB8F28E,
    0xFFFFD7ED,
    0xFFDAD2FF,
    0xFFC9F4E8,
    0xFFFFD8B8,
  ];
  static const _borderColors = [
    0xFFDADADA,
    0xFFF4BF00,
    0xFF88CEFF,
    0xFF58CC02,
    0xFFFF8AC7,
    0xFF9C86FF,
    0xFF51C9A9,
    0xFFFFA45B,
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final FocusNode _nameFocusNode;
  late int _selectedIconIndex;
  bool _attemptedSubmit = false;
  bool _interactedWithName = false;

  bool get _isValid => _nameController.text.trim().isNotEmpty;
  bool get _showNameError =>
      !_isValid && (_attemptedSubmit || _interactedWithName);

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    _nameController = TextEditingController(text: project?.projectName ?? '');
    _descriptionController = TextEditingController(
      text: project?.projectDescription ?? '',
    );
    _nameFocusNode = FocusNode();
    _selectedIconIndex = project == null
        ? 0
        : _icons.indexWhere((icon) => icon.codePoint == project.projectIcon);
    if (_selectedIconIndex < 0) _selectedIconIndex = 0;
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus && mounted) {
        setState(() => _interactedWithName = true);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveProject() async {
    if (!_isValid) {
      setState(() => _attemptedSubmit = true);
      _nameFocusNode.requestFocus();
      return;
    }

    final now = DateTime.now();
    final existingProject = widget.project;
    final project = existingProject == null
        ? ProjectModel(
            projectId: now.microsecondsSinceEpoch.toString(),
            projectName: _nameController.text.trim(),
            projectIcon: _icons[_selectedIconIndex].codePoint,
            iconBgColorValue: _backgroundColors[_selectedIconIndex],
            iconBorderColorValue: _borderColors[_selectedIconIndex],
            projectDescription: _descriptionController.text.trim(),
            createdAt: now,
            updatedAt: now,
          )
        : existingProject.copyWith(
            projectName: _nameController.text.trim(),
            projectIcon: _icons[_selectedIconIndex].codePoint,
            iconBgColorValue: _backgroundColors[_selectedIconIndex],
            iconBorderColorValue: _borderColors[_selectedIconIndex],
            projectDescription: _descriptionController.text.trim(),
            updatedAt: now,
          );

    if (existingProject == null) {
      await context.read<AppState>().addProject(project);
    } else {
      await context.read<AppState>().updateProject(project);
    }
    if (mounted) Navigator.pop(context, project.projectId);
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AnimatedIconPicker(
        icons: _icons,
        selectedIndex: _selectedIconIndex,
        onSelected: (index) => setState(() => _selectedIconIndex = index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 30),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.containerMargin,
                  8,
                  AppSpacing.containerMargin,
                  48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      children: [
                        Text(
                          widget.isEditing ? 'Edit Project' : 'Create Project',
                          style: AppTypography.headlineLgMobile,
                        ),
                        const SizedBox(height: 24),
                        AnimatedTapScale(
                          onTap: _showIconPicker,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            child: ProjectThemedIcon(
                              key: ValueKey(_selectedIconIndex),
                              icon: _icons[_selectedIconIndex],
                              size: 112,
                              iconSize: 46,
                              variant: ProjectThemedIconVariant.detail,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildLabel('PROJECT NAME'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          onTap: () =>
                              setState(() => _interactedWithName = true),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'What are you building?',
                            errorText: _showNameError
                                ? 'Project name is required'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _buildLabel('DESCRIPTION (OPTIONAL)'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          minLines: 4,
                          maxLines: 6,
                          maxLength: 240,
                          decoration: const InputDecoration(
                            hintText: 'Add a short purpose or goal...',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 28),
                        AnimatedCreateTaskButton(
                          enabled: _isValid,
                          label: widget.isEditing
                              ? 'Save Changes'
                              : 'Create Project',
                          onPressed: _saveProject,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: AppTypography.labelLg.copyWith(
          color: AppColors.textMuted,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}
