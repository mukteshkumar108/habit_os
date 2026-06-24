import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/task.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/add_task_screen.dart';
import 'widgets/animated_notification_banner.dart';
import 'widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const HabitOsApp(),
    ),
  );
}

class HabitOsApp extends StatelessWidget {
  const HabitOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    AppColors.setDarkMode(appState.isDarkMode);

    return MaterialApp(
      title: 'Habit_OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: appState.themeMode,
      home: const MainShell(),
    );
  }
}

/// Main scaffold with bottom navigation and tab persistence via IndexedStack.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  StreamSubscription<Task>? _reminderSubscription;
  Task? _activeReminder;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reminderSubscription = NotificationService().inAppReminders.listen((task) {
      if (!mounted) return;
      setState(() => _activeReminder = task);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<AppState>().refreshTaskStatuses();
    }
  }

  void _onAddTask() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddTaskScreen()));
  }

  void _dismissReminder(String taskId) {
    if (_activeReminder?.id != taskId || !mounted) return;
    setState(() => _activeReminder = null);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reminderSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(onAddTask: _onAddTask),
              const CalendarScreen(),
              const ProjectsScreen(),
            ],
          ),
          if (_activeReminder case final reminder?)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedNotificationBanner(
                  key: ValueKey(reminder.id),
                  task: reminder,
                  onDismissed: () => _dismissReminder(reminder.id),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Consumer<AppState>(
        builder: (context, _, child) => AppBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
