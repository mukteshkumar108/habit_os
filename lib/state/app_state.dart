import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/project.dart';

class AppState extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Project> _projects = [];
  int _streakCount = 0;
  DateTime? _lastActiveDate;

  List<Task> get tasks => _tasks;
  List<Project> get projects => _projects;
  int get streakCount => _streakCount;
  DateTime? get lastActiveDate => _lastActiveDate;

  AppState() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load tasks
    final tasksJson = prefs.getStringList('tasks') ?? [];
    _tasks = tasksJson.map((t) => Task.fromJson(t)).toList();

    // Load projects
    final projectsJson = prefs.getStringList('projects') ?? [];
    if (projectsJson.isNotEmpty) {
      _projects = projectsJson.map((p) => Project.fromJson(p)).toList();
    } else {
      // Default projects
      _projects = [
        Project(id: '1', title: 'Deep Work', iconCodePoint: Icons.work.codePoint, iconBgColorValue: 0xFFE2E2E2, iconBorderColorValue: 0xFFDADADA),
        Project(id: '2', title: 'Exercise', iconCodePoint: Icons.fitness_center.codePoint, iconBgColorValue: 0xFFFFDF92, iconBorderColorValue: 0xFFF4BF00),
        Project(id: '3', title: 'Flutter Learning', iconCodePoint: Icons.code.codePoint, iconBgColorValue: 0xFFC8E6FF, iconBorderColorValue: 0xFF88CEFF),
        Project(id: '4', title: 'Startup Building', iconCodePoint: Icons.rocket_launch.codePoint, iconBgColorValue: 0xFF58CC02, iconBorderColorValue: 0xFF2B6C00),
      ];
    }

    _streakCount = prefs.getInt('streakCount') ?? 0;
    final lastActiveEpoch = prefs.getInt('lastActiveDate');
    if (lastActiveEpoch != null) {
      _lastActiveDate = DateTime.fromMillisecondsSinceEpoch(lastActiveEpoch);
      _checkStreak();
    }
    
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((t) => t.toJson()).toList();
    final projectsJson = _projects.map((p) => p.toJson()).toList();
    
    await prefs.setStringList('tasks', tasksJson);
    await prefs.setStringList('projects', projectsJson);
    await prefs.setInt('streakCount', _streakCount);
    if (_lastActiveDate != null) {
      await prefs.setInt('lastActiveDate', _lastActiveDate!.millisecondsSinceEpoch);
    }
  }

  void _checkStreak() {
    if (_lastActiveDate == null) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = DateTime(_lastActiveDate!.year, _lastActiveDate!.month, _lastActiveDate!.day);
    
    final difference = today.difference(lastActive).inDays;
    
    if (difference > 1) {
      // Streak broken
      _streakCount = 0;
      notifyListeners();
      _saveState();
    }
  }

  void _updateStreakOnAction() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastActiveDate == null) {
      _streakCount = 1;
      _lastActiveDate = now;
    } else {
      final lastActive = DateTime(_lastActiveDate!.year, _lastActiveDate!.month, _lastActiveDate!.day);
      final difference = today.difference(lastActive).inDays;
      
      if (difference == 1) {
        _streakCount++;
        _lastActiveDate = now;
      } else if (difference > 1) {
        _streakCount = 1;
        _lastActiveDate = now;
      } else if (difference == 0) {
        _lastActiveDate = now; // update time
      }
    }
    notifyListeners();
    _saveState();
  }

  void addTask(Task task) {
    _tasks.add(task);
    _updateStreakOnAction();
  }

  void toggleTaskCompletion(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      if (_tasks[index].isCompleted) {
        _updateStreakOnAction();
      } else {
        notifyListeners();
        _saveState();
      }
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
    _saveState();
  }

  void addProjectPhoto(String projectId, String photoPath) {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final updatedPaths = List<String>.from(_projects[index].photoPaths)..add(photoPath);
      _projects[index] = _projects[index].copyWith(photoPaths: updatedPaths);
      notifyListeners();
      _saveState();
    }
  }
}
