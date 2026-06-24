import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Shared top app bar with hamburger menu and app title.
class HabitOsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HabitOsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceVariant, width: 2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'Open menu',
              onPressed: () => _showMenu(context),
              icon: Icon(Icons.menu, color: primaryColor, size: 28),
            ),
            Text(
              'Habit_OS',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 620),
      builder: (_) => const _HabitMenuSheet(),
    );
  }
}

class _HabitMenuSheet extends StatelessWidget {
  const _HabitMenuSheet();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Material(
      color: AppColors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Menu', style: AppTypography.headlineMd),
              ),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                secondary: Icon(
                  appState.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: AppColors.warningYellow,
                ),
                title: Text(
                  appState.isDarkMode ? 'Dark Mode' : 'Light Mode',
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  appState.isDarkMode
                      ? 'Switch off for Light Mode'
                      : 'Switch on for Dark Mode',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                value: appState.isDarkMode,
                activeThumbColor: AppColors.primaryContainer,
                onChanged: appState.setDarkMode,
              ),
              Divider(color: AppColors.surfaceVariant),
              _MenuItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                color: primaryColor,
                onTap: () => _showUnavailable(context, 'Profile'),
              ),
              _MenuItem(
                icon: Icons.timer_outlined,
                label: 'Pomodoro Mode',
                color: AppColors.warningYellow,
                onTap: () => _showUnavailable(context, 'Pomodoro Mode'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnavailable(BuildContext context, String feature) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(content: Text('$feature is not available yet.')),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: onTap,
    );
  }
}
