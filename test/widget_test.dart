import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_os/main.dart';
import 'package:habit_os/models/task.dart';
import 'package:habit_os/models/project_model.dart';
import 'package:habit_os/models/proof_memory_model.dart';
import 'package:habit_os/screens/calendar_screen.dart';
import 'package:habit_os/screens/home_screen.dart';
import 'package:habit_os/screens/task_detail_screen.dart';
import 'package:habit_os/state/app_state.dart';
import 'package:habit_os/theme/app_theme.dart';
import 'package:habit_os/widgets/proof_image.dart';
import 'package:habit_os/widgets/project_card.dart';
import 'package:habit_os/widgets/project_themed_icon.dart';
import 'package:habit_os/widgets/reminder_drawer.dart';
import 'package:habit_os/widgets/calendar_day_cell.dart';
import 'package:habit_os/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const HabitOsApp(),
      ),
    );

    expect(find.text('Habit_OS'), findsOneWidget);
  });

  testWidgets('hamburger menu persists the dark mode toggle', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await pumpEventQueue(times: 20);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: state, child: const HabitOsApp()),
    );
    await tester.pump();

    final lightScheme = AppTheme.light.colorScheme;
    final lightNav = tester.widget<Container>(
      find.byKey(const ValueKey('bottom-nav-surface')),
    );
    expect((lightNav.decoration! as BoxDecoration).color, lightScheme.surface);
    expect(
      tester
          .widget<Icon>(find.byKey(const ValueKey('bottom-nav-icon-Home')))
          .color,
      lightScheme.primary,
    );

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();

    expect(find.text('Light Mode'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Pomodoro Mode'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(state.isDarkMode, isTrue);
    expect(find.text('Dark Mode'), findsOneWidget);
    final darkScheme = AppTheme.dark.colorScheme;
    final darkNav = tester.widget<Container>(
      find.byKey(const ValueKey('bottom-nav-surface')),
    );
    expect((darkNav.decoration! as BoxDecoration).color, darkScheme.surface);
    final selectedHome = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('bottom-nav-item-Home')),
    );
    expect(
      (selectedHome.decoration! as BoxDecoration).color,
      darkScheme.surfaceContainer,
    );
    expect(
      tester
          .widget<Icon>(find.byKey(const ValueKey('bottom-nav-icon-Home')))
          .color,
      darkScheme.primary,
    );
    expect(
      tester
          .widget<Icon>(find.byKey(const ValueKey('bottom-nav-icon-Calendar')))
          .color,
      darkScheme.onSurfaceVariant.withAlpha(180),
    );
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('bottom-nav-label-Home')))
          .style
          ?.color,
      darkScheme.primary,
    );
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('habit_os_dark_mode'), isTrue);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(state.isDarkMode, isFalse);
    expect(find.text('Light Mode'), findsOneWidget);
    final restoredLightNav = tester.widget<Container>(
      find.byKey(const ValueKey('bottom-nav-surface')),
    );
    expect(
      (restoredLightNav.decoration! as BoxDecoration).color,
      lightScheme.surface,
    );
    expect(
      tester
          .widget<Icon>(find.byKey(const ValueKey('bottom-nav-icon-Home')))
          .color,
      lightScheme.primary,
    );
    expect(preferences.getBool('habit_os_dark_mode'), isFalse);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
    AppColors.setDarkMode(false);
  });

  testWidgets('custom reminder frequency closes without lifecycle errors', (
    WidgetTester tester,
  ) async {
    int? selectedMinutes;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => ReminderDrawer.show(
                context,
                onSelected: (value) => selectedMinutes = value,
              ),
              child: const Text('Open reminders'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open reminders'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom...'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '2');
    await tester.tap(find.text('Set Frequency'));
    await tester.pumpAndSettle();

    expect(selectedMinutes, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missed task leaves pending list and offers Complete Late', (
    WidgetTester tester,
  ) async {
    final now = DateTime(2026, 6, 23, 19, 27);
    SharedPreferences.setMockInitialValues({});
    final state = AppState(now: () => now);
    await pumpEventQueue(times: 20);
    final task = Task(
      id: 'overdue-task',
      title: 'Flutter',
      iconCodePoint: Icons.menu_book.codePoint,
      dueDate: DateTime(2026, 6, 23, 18, 45),
      reminderFrequencyMinutes: 0,
      notes: '',
      createdAt: DateTime(2026, 6, 23, 17),
    );
    state.addTask(task);
    state.refreshTaskStatuses();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(home: HomeScreen(onAddTask: () {})),
      ),
    );
    await tester.pump();

    expect(find.text('Missed / Overdue'), findsOneWidget);
    expect(find.textContaining('missed today'), findsOneWidget);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(home: TaskDetailScreen(task: task)),
      ),
    );
    await tester.pump();

    expect(find.text('Missed'), findsOneWidget);
    expect(find.text('Complete Late'), findsOneWidget);
    expect(find.text('Complete Task'), findsNothing);
    expect(find.text('Delete Task'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('selected calendar day fits markers without overflow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 46,
              height: 52,
              child: CalendarDayCell(
                day: 23,
                isSelected: true,
                markers: [
                  AppColors.primaryContainer,
                  AppColors.lateOrange,
                  AppColors.errorRed,
                  AppColors.surfaceDim,
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('23'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Project icons follow ColorScheme in light and dark mode', (
    WidgetTester tester,
  ) async {
    addTearDown(() => AppColors.setDarkMode(false));
    final now = DateTime(2026, 6, 24, 12);
    final project = ProjectModel(
      projectId: 'dark-project',
      projectName: 'Dark Project',
      projectIcon: Icons.code_rounded.codePoint,
      iconBgColorValue: 0xFFFFDF92,
      iconBorderColorValue: 0xFFF4BF00,
      projectDescription: '',
      createdAt: now,
      updatedAt: now,
    );

    Widget projectCardWithTheme(ThemeData theme) {
      return MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 260,
              child: ProjectCard(
                project: project,
                proofMemories: const [],
                proofAddedToday: false,
                onCameraTap: () {},
              ),
            ),
          ),
        ),
      );
    }

    AppColors.setDarkMode(true);
    await tester.pumpWidget(projectCardWithTheme(AppTheme.dark));

    final themedIcon = tester.widget<ProjectThemedIcon>(
      find.byKey(const ValueKey('project-icon-dark-project')),
    );
    expect(themedIcon.size, 56);
    expect(themedIcon.iconSize, 26);
    expect(themedIcon.variant, ProjectThemedIconVariant.primary);
    final iconContainer = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byKey(const ValueKey('project-icon-dark-project')),
            matching: find.byType(Container),
          ),
        )
        .first;
    final iconDecoration = iconContainer.decoration! as BoxDecoration;
    expect(iconDecoration.shape, BoxShape.circle);
    final darkColors = AppTheme.dark.colorScheme;
    expect(
      iconDecoration.color,
      Color.alphaBlend(
        darkColors.primary.withAlpha(34),
        darkColors.surfaceContainerHigh,
      ),
    );
    final projectIcon = tester.widget<Icon>(
      find.descendant(
        of: find.byKey(const ValueKey('project-icon-dark-project')),
        matching: find.byIcon(Icons.code_rounded),
      ),
    );
    expect(projectIcon.color, darkColors.primary);

    final themedCamera = tester.widget<ProjectThemedIcon>(
      find.byKey(const ValueKey('project-camera-dark-project')),
    );
    expect(themedCamera.size, 44);
    expect(themedCamera.iconSize, 20);
    expect(themedCamera.variant, ProjectThemedIconVariant.camera);
    final cameraContainer = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byKey(const ValueKey('project-camera-dark-project')),
            matching: find.byType(Container),
          ),
        )
        .first;
    final cameraDecoration = cameraContainer.decoration! as BoxDecoration;
    expect(cameraDecoration.shape, BoxShape.circle);
    expect(cameraDecoration.color, darkColors.surfaceContainerHigh);

    AppColors.setDarkMode(false);
    await tester.pumpWidget(projectCardWithTheme(AppTheme.light));
    final lightContainer = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byKey(const ValueKey('project-icon-dark-project')),
            matching: find.byType(Container),
          ),
        )
        .first;
    final lightDecoration = lightContainer.decoration! as BoxDecoration;
    final lightColors = AppTheme.light.colorScheme;
    expect(
      lightDecoration.color,
      Color.alphaBlend(
        lightColors.primary.withAlpha(20),
        lightColors.surfaceContainerLowest,
      ),
    );
    expect(lightDecoration.color, isNot(iconDecoration.color));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Calendar uses task records card and proof memory wall', (
    WidgetTester tester,
  ) async {
    final current = DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final now = DateTime(today.year, today.month, today.day, 20);
    SharedPreferences.setMockInitialValues({});
    final state = AppState(now: () => now);
    await pumpEventQueue(times: 20);

    state.addTask(
      Task(
        id: 'reading',
        title: 'Reading',
        iconCodePoint: Icons.menu_book.codePoint,
        dueDate: today.add(const Duration(hours: 8)),
        reminderFrequencyMinutes: 0,
        notes: '',
        status: TaskStatus.completedOnTime,
        completedAt: today.add(const Duration(hours: 7, minutes: 50)),
        createdAt: today,
      ),
    );
    state.addTask(
      Task(
        id: 'exercise',
        title: 'Exercise',
        iconCodePoint: Icons.fitness_center.codePoint,
        dueDate: today.add(const Duration(hours: 9)),
        reminderFrequencyMinutes: 0,
        notes: '',
        status: TaskStatus.completedOnTime,
        completedAt: today.add(const Duration(hours: 8, minutes: 45)),
        createdAt: today,
      ),
    );
    state.addTask(
      Task(
        id: 'study',
        title: 'Study',
        iconCodePoint: Icons.school.codePoint,
        dueDate: today.add(const Duration(hours: 9, minutes: 25)),
        reminderFrequencyMinutes: 0,
        notes: '',
        status: TaskStatus.missed,
        createdAt: today,
      ),
    );
    state.addTask(
      Task(
        id: 'flutter',
        title: 'Flutter',
        projectId: 'work',
        projectName: 'Work',
        iconCodePoint: Icons.code.codePoint,
        dueDate: today.add(const Duration(hours: 18, minutes: 45)),
        reminderFrequencyMinutes: 0,
        notes: '',
        status: TaskStatus.completedLate,
        completedAt: today.add(const Duration(hours: 19, minutes: 2)),
        createdAt: today,
      ),
    );
    const proofProjects = [
      {
        'id': 'work',
        'name': 'Work',
        'note': 'Finished the calendar memory wall.',
      },
      {'id': 'wildlife', 'name': 'Wildlife', 'note': 'Tiger'},
      {
        'id': 'sky',
        'name': 'Sky is not the limit',
        'note': 'Hmmm room with a long note that must stay readable.',
      },
    ];
    for (var index = 0; index < proofProjects.length; index++) {
      final memory = proofProjects[index];
      final projectId = memory['id']!;
      final projectName = memory['name']!;
      await state.addProject(
        ProjectModel(
          projectId: projectId,
          projectName: projectName,
          projectIcon: Icons.work.codePoint,
          iconBgColorValue: 0xFFE2E2E2,
          iconBorderColorValue: 0xFFDADADA,
          projectDescription: '',
          createdAt: today,
          updatedAt: today,
        ),
      );
      await state.addProofMemory(
        ProofMemoryModel(
          proofId: '$projectId-proof',
          projectId: projectId,
          projectName: projectName,
          imageReference: 'proofs/$projectId-proof.jpg',
          note: memory['note']!,
          createdAt: today.add(Duration(hours: 19, minutes: 10 + index)),
          sourceType: ProofSourceType.camera,
        ),
      );
    }

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: CalendarScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Daily Task Records'), findsOneWidget);
    expect(
      find.text('2 completed • 1 missed • 1 late • 4 total'),
      findsOneWidget,
    );
    expect(find.textContaining('Tasks for'), findsNothing);
    expect(find.text('Proof Memories'), findsNothing);
    expect(find.text('Project Records'), findsOneWidget);
    expect(find.byType(ProofImage), findsNWidgets(3));
    expect(find.byKey(const ValueKey('calendar-proof-sky-proof')), findsOne);
    expect(
      find.byKey(const ValueKey('project-records-layout-3')),
      findsOneWidget,
    );
    final skyRect = tester.getRect(
      find.byKey(const ValueKey('calendar-proof-sky-proof')),
    );
    final wildlifeRect = tester.getRect(
      find.byKey(const ValueKey('calendar-proof-wildlife-proof')),
    );
    final workRect = tester.getRect(
      find.byKey(const ValueKey('calendar-proof-work-proof')),
    );
    final recordsRect = tester.getRect(
      find.byKey(const ValueKey('project-records-layout-3')),
    );
    expect(skyRect.top, closeTo(wildlifeRect.top, 0.1));
    expect(workRect.top, greaterThan(skyRect.bottom));
    expect(workRect.width, closeTo(skyRect.width, 0.1));
    expect(workRect.center.dx, closeTo(recordsRect.center.dx, 0.1));
    final skyClip = tester.widget<ClipRRect>(
      find.byKey(const ValueKey('calendar-proof-sky-proof')),
    );
    expect(skyClip.borderRadius, BorderRadius.circular(10));

    await tester.tap(find.text('Daily Task Records'));
    await tester.pumpAndSettle();

    expect(find.text('Status: Missed'), findsOneWidget);
    expect(find.text('Status: Completed Late'), findsOneWidget);
    expect(find.text('Completed: 7:02 PM'), findsOneWidget);
    expect(find.text('Project: Work'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    final skyProof = find.byKey(const ValueKey('calendar-proof-sky-proof'));
    await tester.ensureVisible(skyProof);
    await tester.tap(skyProof);
    await tester.pumpAndSettle();

    expect(find.text('Project'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);
    expect(find.text('Sky is not the limit'), findsWidgets);
    expect(
      find.text('Hmmm room with a long note that must stay readable.'),
      findsWidgets,
    );
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('project leaves Home after today proof is added', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    SharedPreferences.setMockInitialValues({});
    final state = AppState(now: () => now);
    await pumpEventQueue(times: 20);
    await state.addProject(
      ProjectModel(
        projectId: 'work',
        projectName: 'Work',
        projectIcon: Icons.work.codePoint,
        iconBgColorValue: 0xFFE2E2E2,
        iconBorderColorValue: 0xFFDADADA,
        projectDescription: 'Ship the feature',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await state.addProofMemory(
      ProofMemoryModel(
        proofId: 'work-proof',
        projectId: 'work',
        projectName: 'Work',
        imageReference: 'proofs/work-proof.jpg',
        note: '',
        createdAt: now,
        sourceType: ProofSourceType.camera,
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(home: HomeScreen(onAddTask: () {})),
      ),
    );
    await tester.pump();

    expect(find.text('Work'), findsNothing);
    expect(find.text('Projects'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
