import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/project_model.dart';
import '../models/proof_memory_model.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/project_storage_service.dart';
import '../services/proof_image_storage.dart';
import '../theme/app_colors.dart';

class AppState extends ChangeNotifier {
  static const _themePreferenceKey = 'habit_os_dark_mode';

  final ProjectStorageService _projectStorage = ProjectStorageService();
  final DateTime Function() _now;

  List<Task> _tasks = [];
  List<ProjectModel> _projects = [];
  List<ProofMemoryModel> _proofMemories = [];
  int _streakCount = 0;
  DateTime? _lastActiveDate;
  bool _streakWasMissed = false;
  bool _isDarkMode = false;
  Timer? _taskStatusTimer;

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<ProjectModel> get projects => List.unmodifiable(_projects);
  List<ProofMemoryModel> get proofMemories => List.unmodifiable(
    _proofMemories.where(
      (proof) =>
          _projects.any((project) => project.projectId == proof.projectId),
    ),
  );
  int get streakCount => _streakCount;
  DateTime? get lastActiveDate => _lastActiveDate;
  bool get streakWasMissed => _streakWasMissed;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  AppState({DateTime Function()? now}) : _now = now ?? DateTime.now {
    _loadState();
  }

  Future<void> _loadState() async {
    final preferences = await SharedPreferences.getInstance();
    _isDarkMode = preferences.getBool(_themePreferenceKey) ?? false;
    AppColors.setDarkMode(_isDarkMode);
    final taskJson = preferences.getStringList('tasks') ?? [];
    _tasks = taskJson.map(Task.fromJson).toList();
    _projects = await _projectStorage.loadProjects();
    _proofMemories = await _projectStorage.loadProofMemories();
    await _removeOrphanProofMemories();
    final taskStatusesChanged = _markOverdueTasks(_now());

    _streakCount = preferences.getInt('streakCount') ?? 0;
    final lastActiveEpoch = preferences.getInt('lastActiveDate');
    if (lastActiveEpoch != null) {
      _lastActiveDate = DateTime.fromMillisecondsSinceEpoch(lastActiveEpoch);
      _checkStreak();
    }

    final projectStreaksChanged = _refreshBrokenProjectStreaks();
    if (projectStreaksChanged) {
      unawaited(_projectStorage.saveProjects(_projects));
    }
    if (taskStatusesChanged) {
      await _saveTaskState();
    }
    await NotificationService().restoreTaskReminders(_tasks);
    await _syncDailyNotifications();
    _scheduleNextTaskStatusRefresh();
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    if (_isDarkMode == enabled) return;
    _isDarkMode = enabled;
    AppColors.setDarkMode(enabled);
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_themePreferenceKey, enabled);
  }

  Future<void> _saveTaskState() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      'tasks',
      _tasks.map((task) => task.toJson()).toList(),
    );
    await preferences.setInt('streakCount', _streakCount);
    if (_lastActiveDate != null) {
      await preferences.setInt(
        'lastActiveDate',
        _lastActiveDate!.millisecondsSinceEpoch,
      );
    }
  }

  void _checkStreak() {
    if (_lastActiveDate == null) return;
    final difference = _dateOnly(
      DateTime.now(),
    ).difference(_dateOnly(_lastActiveDate!)).inDays;
    if (difference > 1) {
      _streakCount = 0;
      _streakWasMissed = true;
      unawaited(_saveTaskState());
    }
  }

  void _updateStreakOnAction({DateTime? at}) {
    final now = at ?? _now();
    final today = _dateOnly(now);

    if (_lastActiveDate == null) {
      _streakCount = 1;
    } else {
      final difference = today.difference(_dateOnly(_lastActiveDate!)).inDays;
      if (difference == 1) {
        _streakCount++;
      } else if (difference > 1) {
        _streakCount = 1;
      }
    }

    _lastActiveDate = now;
    _streakWasMissed = false;
    notifyListeners();
    unawaited(_saveTaskState());
  }

  void addTask(Task task) {
    _tasks.add(task);
    _scheduleNextTaskStatusRefresh();
    notifyListeners();
    unawaited(_saveTaskState());
    unawaited(_syncDailyNotifications());
  }

  bool canCompleteTask(Task task, {DateTime? now}) {
    if (task.status != TaskStatus.pending && task.status != TaskStatus.missed) {
      return false;
    }
    final today = _dateOnly(now ?? _now());
    return !_dateOnly(task.dueDate).isAfter(today);
  }

  bool willCompleteLate(Task task, {DateTime? now}) {
    final moment = now ?? _now();
    return task.status == TaskStatus.missed || moment.isAfter(task.dueDate);
  }

  bool completeTask(String taskId, {DateTime? now}) {
    final moment = now ?? _now();
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1 || !canCompleteTask(_tasks[index], now: moment)) {
      return false;
    }
    final completedLate = willCompleteLate(_tasks[index], now: moment);
    _tasks[index] = _tasks[index].copyWith(
      status: completedLate
          ? TaskStatus.completedLate
          : TaskStatus.completedOnTime,
      completedAt: moment,
    );
    unawaited(NotificationService().cancelTaskReminder(taskId));
    _scheduleNextTaskStatusRefresh();
    if (completedLate) {
      notifyListeners();
      unawaited(_saveTaskState());
    } else {
      _updateStreakOnAction(at: moment);
    }
    unawaited(_syncDailyNotifications());
    return true;
  }

  List<Task> tasksForDate(DateTime date) {
    final targetDate = _dateOnly(date);
    final matchingTasks = _tasks
        .where((task) => _dateOnly(task.dueDate) == targetDate)
        .toList();
    matchingTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return List.unmodifiable(matchingTasks);
  }

  bool canDeleteTask(Task task, {DateTime? now}) {
    final moment = now ?? _now();
    return task.status == TaskStatus.pending && !moment.isAfter(task.dueDate);
  }

  bool deleteTask(String taskId, {DateTime? now}) {
    final moment = now ?? _now();
    refreshTaskStatuses(now: moment);
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1 || !canDeleteTask(_tasks[taskIndex], now: moment)) {
      return false;
    }
    _tasks.removeWhere((task) => task.id == taskId);
    unawaited(NotificationService().cancelTaskReminder(taskId));
    _scheduleNextTaskStatusRefresh();
    notifyListeners();
    unawaited(_saveTaskState());
    unawaited(_syncDailyNotifications());
    return true;
  }

  Future<void> addProject(ProjectModel project) async {
    _projects.add(project);
    notifyListeners();
    await _projectStorage.saveProjects(_projects);
    await _syncDailyNotifications();
  }

  Future<void> updateProject(ProjectModel project) async {
    final index = _projects.indexWhere(
      (item) => item.projectId == project.projectId,
    );
    if (index == -1) return;
    _projects[index] = project.copyWith(updatedAt: DateTime.now());
    notifyListeners();
    await _projectStorage.saveProjects(_projects);
    await _syncDailyNotifications();
  }

  Future<void> deleteProject(String projectId) async {
    final removedProofs = _proofMemories
        .where((proof) => proof.projectId == projectId)
        .toList();
    _projects.removeWhere((project) => project.projectId == projectId);
    _proofMemories.removeWhere((proof) => proof.projectId == projectId);
    notifyListeners();
    await Future.wait([
      _projectStorage.saveProjects(_projects),
      _projectStorage.saveProofMemories(_proofMemories),
      ...removedProofs.map(
        (proof) => ProofImageStorage.deleteReference(proof.imageReference),
      ),
    ]);
    await _syncDailyNotifications();
  }

  Future<bool> addProofMemory(ProofMemoryModel proof) async {
    final projectIndex = _projects.indexWhere(
      (project) => project.projectId == proof.projectId,
    );
    if (projectIndex == -1 ||
        hasProofOnDate(proof.projectId, proof.createdAt)) {
      return false;
    }

    final project = _projects[projectIndex];
    final proofDate = _dateOnly(proof.createdAt);
    final lastProofDate = project.lastProofDate;
    var proofStreak = project.currentProofStreak;
    if (lastProofDate == null) {
      proofStreak = 1;
    } else {
      final difference = proofDate.difference(_dateOnly(lastProofDate)).inDays;
      if (difference == 1) {
        proofStreak++;
      } else if (difference > 1) {
        proofStreak = 1;
      }
    }

    _proofMemories.add(proof);
    _projects[projectIndex] = project.copyWith(
      proofCount: project.proofCount + 1,
      currentProofStreak: proofStreak,
      lastProofDate: proof.createdAt,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    await Future.wait([
      _projectStorage.saveProjects(_projects),
      _projectStorage.saveProofMemories(_proofMemories),
    ]);
    await _syncDailyNotifications();
    return true;
  }

  List<ProofMemoryModel> proofsForProject(String projectId) {
    if (projectById(projectId) == null) return const [];
    final proofs = _proofMemories
        .where((proof) => proof.projectId == projectId)
        .toList();
    proofs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return proofs;
  }

  bool hasProofToday(String projectId) {
    return hasProofOnDate(projectId, DateTime.now());
  }

  bool hasProofOnDate(String projectId, DateTime date) {
    final targetDate = _dateOnly(date);
    return _proofMemories.any(
      (proof) =>
          proof.projectId == projectId &&
          _dateOnly(proof.createdAt) == targetDate,
    );
  }

  ProofMemoryModel? proofForProjectOnDate(String projectId, DateTime date) {
    if (projectById(projectId) == null) return null;
    final targetDate = _dateOnly(date);
    for (final proof in _proofMemories) {
      if (proof.projectId == projectId &&
          _dateOnly(proof.createdAt) == targetDate) {
        return proof;
      }
    }
    return null;
  }

  List<ProofMemoryModel> proofsForDate(DateTime date) {
    final targetDate = _dateOnly(date);
    final proofs = _proofMemories
        .where(
          (proof) =>
              projectById(proof.projectId) != null &&
              _dateOnly(proof.createdAt) == targetDate,
        )
        .toList();
    proofs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(proofs);
  }

  ProjectModel? projectById(String projectId) {
    for (final project in _projects) {
      if (project.projectId == projectId) return project;
    }
    return null;
  }

  Future<void> _removeOrphanProofMemories() async {
    final activeProjectIds = _projects
        .map((project) => project.projectId)
        .toSet();
    final orphanProofs = _proofMemories
        .where((proof) => !activeProjectIds.contains(proof.projectId))
        .toList();
    if (orphanProofs.isEmpty) return;
    _proofMemories.removeWhere(
      (proof) => !activeProjectIds.contains(proof.projectId),
    );
    await Future.wait([
      _projectStorage.saveProofMemories(_proofMemories),
      ...orphanProofs.map(
        (proof) => ProofImageStorage.deleteReference(proof.imageReference),
      ),
    ]);
  }

  bool _refreshBrokenProjectStreaks() {
    var changed = false;
    final today = _dateOnly(DateTime.now());
    for (var index = 0; index < _projects.length; index++) {
      final project = _projects[index];
      final lastProofDate = project.lastProofDate;
      if (lastProofDate == null || project.currentProofStreak == 0) continue;
      if (today.difference(_dateOnly(lastProofDate)).inDays > 1) {
        _projects[index] = project.copyWith(
          currentProofStreak: 0,
          updatedAt: DateTime.now(),
        );
        changed = true;
      }
    }
    return changed;
  }

  void refreshTaskStatuses({DateTime? now}) {
    final moment = now ?? _now();
    final changed = _markOverdueTasks(moment);
    _scheduleNextTaskStatusRefresh();
    if (!changed) return;
    notifyListeners();
    unawaited(_saveTaskState());
    unawaited(_syncDailyNotifications());
  }

  bool _markOverdueTasks(DateTime moment) {
    var changed = false;
    for (var index = 0; index < _tasks.length; index++) {
      final task = _tasks[index];
      if (!task.isOverdueAt(moment)) continue;
      _tasks[index] = task.copyWith(
        status: TaskStatus.missed,
        clearCompletedAt: true,
      );
      unawaited(NotificationService().cancelTaskReminder(task.id));
      changed = true;
    }
    return changed;
  }

  void _scheduleNextTaskStatusRefresh() {
    _taskStatusTimer?.cancel();
    final moment = _now();
    DateTime? nextDueDate;
    for (final task in _tasks) {
      if (task.status != TaskStatus.pending || !task.dueDate.isAfter(moment)) {
        continue;
      }
      if (nextDueDate == null || task.dueDate.isBefore(nextDueDate)) {
        nextDueDate = task.dueDate;
      }
    }
    if (nextDueDate == null) return;
    final delay =
        nextDueDate.difference(moment) + const Duration(milliseconds: 250);
    _taskStatusTimer = Timer(delay, refreshTaskStatuses);
  }

  Future<void> _syncDailyNotifications() {
    return NotificationService().syncDailyAccountabilityReminders(
      tasks: _tasks,
      projects: _projects,
      proofs: _proofMemories,
      now: _now(),
    );
  }

  @override
  void dispose() {
    _taskStatusTimer?.cancel();
    super.dispose();
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
