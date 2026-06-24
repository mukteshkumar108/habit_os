import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import 'animated_tap_scale.dart';
import 'project_themed_icon.dart';

class AnimatedIconPicker extends StatefulWidget {
  final List<IconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AnimatedIconPicker({
    super.key,
    required this.icons,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<AnimatedIconPicker> createState() => _AnimatedIconPickerState();
}

class _AnimatedIconPickerState extends State<AnimatedIconPicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();
  }

  Future<void> _select(int index) async {
    if (_selectedIndex == index) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _selectedIndex = index);
    widget.onSelected(index);
    await Future<void>.delayed(const Duration(milliseconds: 170));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final entrance = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Choose an Icon', style: AppTypography.headlineMd),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: entrance,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(entrance),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                      itemCount: widget.icons.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedIndex == index;
                        return AnimatedTapScale(
                          onTap: () => _select(index),
                          child: AnimatedScale(
                            scale: isSelected ? 1.08 : 1,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutBack,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ProjectThemedIcon(
                                  icon: widget.icons[index],
                                  size: 56,
                                  iconSize: 26,
                                  variant: ProjectThemedIconVariant.primary,
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colors.primary.withAlpha(
                                        isSelected ? 210 : 0,
                                      ),
                                      width: 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: colors.primary.withAlpha(
                                                45,
                                              ),
                                              blurRadius: 14,
                                            ),
                                          ]
                                        : const [],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
