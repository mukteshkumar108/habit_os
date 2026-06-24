import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_os/models/project_model.dart';
import 'package:habit_os/models/proof_memory_model.dart';
import 'package:habit_os/models/task.dart';
import 'package:habit_os/services/notification_service.dart';
import 'package:habit_os/state/app_state.dart';
import 'package:habit_os/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('task JSON preserves project, status, and completion time', () {
    final completedAt = DateTime(2026, 6, 23, 19, 27);
    final task = Task(
      id: 'task-1',
      title: 'Study',
      projectId: 'study-project',
      projectName: 'Study Project',
      iconCodePoint: 123,
      dueDate: DateTime(2026, 6, 23, 18, 45),
      reminderFrequencyMinutes: 15,
      notes: '',
      status: TaskStatus.completedLate,
      completedAt: completedAt,
      createdAt: DateTime(2026, 6, 23),
    );

    final restored = Task.fromJson(task.toJson());

    expect(restored.projectId, 'study-project');
    expect(restored.projectName, 'Study Project');
    expect(restored.reminderFrequencyMinutes, 15);
    expect(restored.status, TaskStatus.completedLate);
    expect(restored.completedAt, completedAt);
  });

  test('legacy automatic project associations load as No Project', () {
    final legacyJson = jsonEncode({
      'id': 'legacy-task',
      'title': 'Padhai',
      'projectId': 'sports-project',
      'iconCodePoint': 123,
      'dueDate': DateTime(2026, 6, 23, 18).millisecondsSinceEpoch,
      'reminderMinutes': 0,
      'notes': '',
      'isCompleted': false,
      'createdAt': DateTime(2026, 6, 23).millisecondsSinceEpoch,
    });

    final restored = Task.fromJson(legacyJson);

    expect(restored.projectId, isNull);
    expect(restored.projectName, isNull);
    expect(restored.reminderFrequencyMinutes, 0);
    expect(restored.status, TaskStatus.pending);
  });

  test('schema v3 completed tasks migrate to completed on time', () {
    final legacyJson = jsonEncode({
      'schemaVersion': 3,
      'id': 'completed-task',
      'title': 'Study',
      'projectId': 'study-project',
      'projectName': 'Study Project',
      'iconCodePoint': 123,
      'dueDate': DateTime(2026, 6, 23, 18).millisecondsSinceEpoch,
      'reminderFrequencyMinutes': 15,
      'notes': '',
      'isCompleted': true,
      'createdAt': DateTime(2026, 6, 23).millisecondsSinceEpoch,
    });

    final restored = Task.fromJson(legacyJson);

    expect(restored.projectId, 'study-project');
    expect(restored.status, TaskStatus.completedOnTime);
  });

  test(
    'future tasks cannot be completed before their scheduled date',
    () async {
      final state = await _stateAt(() => DateTime(2026, 6, 23, 19, 27));
      addTearDown(state.dispose);
      state.addTask(_task('future', DateTime(2026, 6, 24, 16, 40)));

      final completed = state.completeTask('future');

      expect(completed, isFalse);
      expect(state.tasks.single.status, TaskStatus.pending);
    },
  );

  test(
    'completion before due time is completed on time and grows streak',
    () async {
      final completedAt = DateTime(2026, 6, 23, 18, 30);
      final state = await _stateAt(() => completedAt);
      addTearDown(state.dispose);
      state.addTask(_task('on-time', DateTime(2026, 6, 23, 18, 45)));

      expect(state.completeTask('on-time'), isTrue);

      expect(state.tasks.single.status, TaskStatus.completedOnTime);
      expect(state.tasks.single.completedAt, completedAt);
      expect(state.streakCount, 1);
    },
  );

  test('pending task becomes missed when due time passes', () async {
    var now = DateTime(2026, 6, 23, 18, 30);
    final state = await _stateAt(() => now);
    addTearDown(state.dispose);
    state.addTask(_task('missed', DateTime(2026, 6, 23, 18, 45)));

    now = DateTime(2026, 6, 23, 19, 27);
    state.refreshTaskStatuses();

    expect(state.tasks.single.status, TaskStatus.missed);
    expect(state.tasks.single.completedAt, isNull);
    expect(state.streakCount, 0);
  });

  test(
    'missed task can only be completed late without growing streak',
    () async {
      var now = DateTime(2026, 6, 23, 18, 30);
      final state = await _stateAt(() => now);
      addTearDown(state.dispose);
      state.addTask(_task('late', DateTime(2026, 6, 23, 18, 45)));
      now = DateTime(2026, 6, 23, 19, 27);
      state.refreshTaskStatuses();

      expect(state.completeTask('late'), isTrue);

      expect(state.tasks.single.status, TaskStatus.completedLate);
      expect(state.tasks.single.completedAt, now);
      expect(state.streakCount, 0);
    },
  );

  test('tasks cannot be deleted after due time or terminal status', () async {
    var now = DateTime(2026, 6, 23, 18, 30);
    final state = await _stateAt(() => now);
    addTearDown(state.dispose);
    state.addTask(_task('deletable', DateTime(2026, 6, 23, 20)));
    state.addTask(_task('history', DateTime(2026, 6, 23, 18, 45)));

    expect(state.deleteTask('deletable'), isTrue);
    now = DateTime(2026, 6, 23, 19, 27);
    state.refreshTaskStatuses();
    expect(state.deleteTask('history'), isFalse);

    final calendarTasks = state.tasksForDate(DateTime(2026, 6, 23));
    expect(calendarTasks.single.id, 'history');
    expect(calendarTasks.single.status, TaskStatus.missed);
  });

  test('daily reminder plan avoids irrelevant and duplicate categories', () {
    final now = DateTime(2026, 6, 23, 8);
    final projects = [
      _project('exercise', 'Exercise', now),
      _project('study', 'Study', now),
    ];
    final plan = NotificationService().buildDailyAccountabilityPlan(
      tasks: [
        _task('before-afternoon', DateTime(2026, 6, 23, 16)),
        _task('evening', DateTime(2026, 6, 23, 19)),
      ],
      projects: projects,
      proofs: [_proof('exercise-proof', 'exercise', 'Exercise', now)],
      now: now,
    );

    expect(plan.planningAt, isNull);
    expect(plan.pendingAt, DateTime(2026, 6, 23, 17));
    expect(plan.pendingTaskCount, 1);
    expect(plan.proofAt, DateTime(2026, 6, 23, 18));
    expect(plan.missingProofProjects.map((project) => project.projectName), [
      'Study',
    ]);
  });

  test('morning planning reminder is created only when no tasks exist', () {
    final now = DateTime(2026, 6, 23, 8);
    final plan = NotificationService().buildDailyAccountabilityPlan(
      tasks: const [],
      projects: const [],
      proofs: const [],
      now: now,
    );

    expect(plan.planningAt, DateTime(2026, 6, 23, 9));
    expect(plan.pendingAt, isNull);
    expect(plan.proofAt, isNull);
  });

  test('dark mode preference is persisted and restored', () async {
    final state = await _stateAt(() => DateTime(2026, 6, 24, 9));
    AppState? restored;
    addTearDown(() {
      state.dispose();
      restored?.dispose();
      AppColors.setDarkMode(false);
    });

    expect(state.isDarkMode, isFalse);
    await state.setDarkMode(true);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('habit_os_dark_mode'), isTrue);

    restored = await _stateAt(() => DateTime(2026, 6, 24, 9));
    expect(restored.isDarkMode, isTrue);
    expect(restored.themeMode, ThemeMode.dark);
  });

  test('task reminder copy uses discipline-focused variants', () {
    final dueDate = DateTime(2026, 6, 24, 18);
    final disciplineCopy = NotificationService().buildTaskReminderCopy(
      _task('b', dueDate).copyWith(notes: 'Finish the chapter'),
    );
    final chainCopy = NotificationService().buildTaskReminderCopy(
      _task('a', dueDate),
    );

    expect(disciplineCopy.title, '⏰ Discipline Check');
    expect(
      disciplineCopy.body,
      'Complete “Study” now. Future you is watching.',
    );
    expect(disciplineCopy.subText, 'Note: Finish the chapter');
    expect(chainCopy.title, '🔥 Don’t break the chain');
    expect(chainCopy.body, 'Complete “Study”. Small task, big identity shift.');
    expect(chainCopy.subText, isNull);
  });

  test('proof limit is enforced per project and calendar date', () async {
    final state = await _stateAt(() => DateTime(2026, 6, 23, 9));
    addTearDown(state.dispose);
    final createdAt = DateTime(2026, 6, 23, 9);
    await state.addProject(_project('sports', 'Sports', createdAt));
    await state.addProject(_project('study', 'Study', createdAt));

    expect(
      await state.addProofMemory(
        _proof('sports-1', 'sports', 'Sports', DateTime(2026, 6, 23, 10)),
      ),
      isTrue,
    );
    expect(
      await state.addProofMemory(
        _proof(
          'sports-duplicate',
          'sports',
          'Sports',
          DateTime(2026, 6, 23, 18),
        ),
      ),
      isFalse,
    );
    expect(
      await state.addProofMemory(
        _proof('study-1', 'study', 'Study', DateTime(2026, 6, 23, 12)),
      ),
      isTrue,
    );

    expect(state.proofsForProject('sports'), hasLength(1));
    expect(state.proofsForProject('study'), hasLength(1));
  });

  test('deleting a project cascades to linked proof memories', () async {
    final state = await _stateAt(() => DateTime(2026, 6, 23, 9));
    addTearDown(state.dispose);
    final createdAt = DateTime(2026, 6, 23, 9);
    await state.addProject(_project('exercise', 'Exercise', createdAt));
    await state.addProofMemory(
      _proof('proof-1', 'exercise', '', DateTime(2026, 6, 23, 10)),
    );

    await state.deleteProject('exercise');

    expect(state.projectById('exercise'), isNull);
    expect(state.proofsForDate(DateTime(2026, 6, 23)), isEmpty);
    expect(state.proofsForProject('exercise'), isEmpty);
    expect(state.proofMemories, isEmpty);
  });

  test('orphan proof memories are removed during state loading', () async {
    final orphanProof = _proof(
      'orphan-proof',
      'deleted-project',
      'Deleted Project',
      DateTime(2026, 6, 23, 10),
    );
    SharedPreferences.setMockInitialValues({
      'habit_os_proof_memories_v1': [orphanProof.toJson()],
    });

    final state = AppState(now: () => DateTime(2026, 6, 24, 9));
    addTearDown(state.dispose);
    await pumpEventQueue(times: 20);

    expect(state.proofMemories, isEmpty);
    expect(state.proofsForDate(DateTime(2026, 6, 23)), isEmpty);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getStringList('habit_os_proof_memories_v1'), isEmpty);
  });
}

Future<AppState> _stateAt(DateTime Function() now) async {
  final state = AppState(now: now);
  await pumpEventQueue(times: 20);
  return state;
}

Task _task(String id, DateTime dueDate) {
  return Task(
    id: id,
    title: 'Study',
    iconCodePoint: 123,
    dueDate: dueDate,
    reminderFrequencyMinutes: 0,
    notes: '',
    createdAt: DateTime(2026, 6, 23),
  );
}

ProjectModel _project(String id, String name, DateTime createdAt) {
  return ProjectModel(
    projectId: id,
    projectName: name,
    projectIcon: 123,
    iconBgColorValue: 0xFFE2E2E2,
    iconBorderColorValue: 0xFFDADADA,
    projectDescription: '',
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

ProofMemoryModel _proof(
  String id,
  String projectId,
  String projectName,
  DateTime createdAt,
) {
  return ProofMemoryModel(
    proofId: id,
    projectId: projectId,
    projectName: projectName,
    imageReference: 'proofs/$id.jpg',
    note: '',
    createdAt: createdAt,
    sourceType: ProofSourceType.camera,
  );
}
