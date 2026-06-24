import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/project_model.dart';
import '../models/proof_memory_model.dart';
import '../models/task.dart';

class DailyAccountabilityReminderPlan {
  final DateTime? planningAt;
  final DateTime? pendingAt;
  final int pendingTaskCount;
  final DateTime? proofAt;
  final List<ProjectModel> missingProofProjects;

  const DailyAccountabilityReminderPlan({
    required this.planningAt,
    required this.pendingAt,
    required this.pendingTaskCount,
    required this.proofAt,
    required this.missingProofProjects,
  });
}

class TaskReminderCopy {
  final String title;
  final String body;
  final String? subText;

  const TaskReminderCopy({
    required this.title,
    required this.body,
    required this.subText,
  });
}

class NotificationService {
  static const String _androidReminderChannelId = 'task_reminder_alerts_v2';
  static const String _androidReminderChannelName = 'Task Reminder Alerts';
  static const int _planningReminderId = 0x70000001;
  static const int _pendingReminderId = 0x70000002;
  static const int _proofReminderId = 0x70000003;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<Task> _inAppReminderController =
      StreamController<Task>.broadcast();
  final Map<String, Timer> _inAppTimers = {};
  bool _isInitialized = false;
  bool _timezoneReady = false;
  Future<void> _dailySync = Future<void>.value();

  Stream<Task> get inAppReminders => _inAppReminderController.stream;

  Future<void> init() async {
    tz_data.initializeTimeZones();
    if (!kIsWeb) {
      try {
        final timezone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timezone.identifier));
        _timezoneReady = true;
      } catch (_) {
        _timezoneReady = false;
      }
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
    _isInitialized = true;

    if (defaultTargetPlatform == TargetPlatform.android) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _androidReminderChannelId,
              _androidReminderChannelName,
              description:
                  'Repeating sound alerts for incomplete Habit_OS tasks',
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
              audioAttributesUsage: AudioAttributesUsage.notification,
            ),
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return true;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
      return await androidPlugin?.requestExactAlarmsPermission() ?? false;
    }

    return true;
  }

  Future<void> scheduleRepeatingTaskReminder(Task task) async {
    scheduleInAppReminder(task);

    if (!_supportsNativeRepeatingNotifications ||
        !_isInitialized ||
        task.status != TaskStatus.pending ||
        task.reminderFrequencyMinutes <= 0) {
      return;
    }

    final canScheduleExact = await requestPermissions();

    await _scheduleNativeRepeatingReminder(
      task,
      canScheduleExact: canScheduleExact,
    );
  }

  Future<void> _scheduleNativeRepeatingReminder(
    Task task, {
    required bool canScheduleExact,
  }) async {
    if (task.status != TaskStatus.pending ||
        task.reminderFrequencyMinutes <= 0) {
      return;
    }

    final copy = buildTaskReminderCopy(task);

    await flutterLocalNotificationsPlugin.cancel(id: task.id.hashCode);
    await flutterLocalNotificationsPlugin.periodicallyShowWithDuration(
      id: task.id.hashCode,
      title: copy.title,
      body: copy.body,
      repeatDurationInterval: Duration(minutes: task.reminderFrequencyMinutes),
      notificationDetails: _notificationDetailsWithSubText(copy.subText),
      androidScheduleMode: canScheduleExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  void scheduleInAppReminder(Task task) {
    _inAppTimers.remove(task.id)?.cancel();
    if (task.status != TaskStatus.pending ||
        task.reminderFrequencyMinutes <= 0) {
      return;
    }

    final frequency = Duration(minutes: task.reminderFrequencyMinutes);
    _inAppTimers[task.id] = Timer.periodic(frequency, (_) {
      final lifecycleState = WidgetsBinding.instance.lifecycleState;
      if (lifecycleState == null ||
          lifecycleState == AppLifecycleState.resumed) {
        _inAppReminderController.add(task);
      }
    });
  }

  void restoreInAppReminders(Iterable<Task> tasks) {
    for (final task in tasks) {
      scheduleInAppReminder(task);
    }
  }

  Future<void> restoreTaskReminders(Iterable<Task> tasks) async {
    final taskList = tasks.toList();
    restoreInAppReminders(taskList);
    if (!_supportsNativeRepeatingNotifications || !_isInitialized) return;

    await flutterLocalNotificationsPlugin.cancelAllPendingNotifications();
    var canScheduleExact = true;
    if (defaultTargetPlatform == TargetPlatform.android) {
      canScheduleExact =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.canScheduleExactNotifications() ??
          false;
    }
    for (final task in taskList) {
      await _scheduleNativeRepeatingReminder(
        task,
        canScheduleExact: canScheduleExact,
      );
    }
  }

  Future<void> syncDailyAccountabilityReminders({
    required Iterable<Task> tasks,
    required Iterable<ProjectModel> projects,
    required Iterable<ProofMemoryModel> proofs,
    DateTime? now,
  }) {
    final taskSnapshot = tasks.toList();
    final projectSnapshot = projects.toList();
    final proofSnapshot = proofs.toList();
    final moment = now ?? DateTime.now();
    _dailySync = _dailySync.then(
      (_) => _performDailyAccountabilitySync(
        tasks: taskSnapshot,
        projects: projectSnapshot,
        proofs: proofSnapshot,
        now: moment,
      ),
    );
    return _dailySync;
  }

  Future<void> _performDailyAccountabilitySync({
    required List<Task> tasks,
    required List<ProjectModel> projects,
    required List<ProofMemoryModel> proofs,
    required DateTime now,
  }) async {
    if (!_supportsNativeRepeatingNotifications ||
        !_isInitialized ||
        !_timezoneReady) {
      return;
    }

    await Future.wait([
      flutterLocalNotificationsPlugin.cancel(id: _planningReminderId),
      flutterLocalNotificationsPlugin.cancel(id: _pendingReminderId),
      flutterLocalNotificationsPlugin.cancel(id: _proofReminderId),
    ]);

    final plan = buildDailyAccountabilityPlan(
      tasks: tasks,
      projects: projects,
      proofs: proofs,
      now: now,
    );
    if (plan.planningAt case final planningAt?) {
      await _scheduleDailyNotification(
        id: _planningReminderId,
        scheduledAt: planningAt,
        title: 'Plan your day',
        body: 'Plan your day. You have not scheduled any task for today.',
      );
    }

    if (plan.pendingAt case final pendingAt?) {
      await _scheduleDailyNotification(
        id: _pendingReminderId,
        scheduledAt: pendingAt,
        title: 'Pending tasks',
        body:
            'You still have ${plan.pendingTaskCount} ${plan.pendingTaskCount == 1 ? 'task' : 'tasks'} to complete today.',
      );
    }

    if (plan.proofAt case final proofAt?) {
      final project = plan.missingProofProjects.first;
      final additionalProjects = plan.missingProofProjects.length - 1;
      await _scheduleDailyNotification(
        id: _proofReminderId,
        scheduledAt: proofAt,
        title: '📸 Proof Time',
        body:
            'Upload today’s proof for ${project.projectName}. Memory beats motivation.${additionalProjects > 0 ? ' $additionalProjects more ${additionalProjects == 1 ? 'project needs' : 'projects need'} proof.' : ''}',
        notificationDetails: _notificationDetailsWithSubText(
          project.projectDescription.trim().isEmpty
              ? null
              : 'Note: ${project.projectDescription.trim()}',
        ),
      );
    }
  }

  @visibleForTesting
  DailyAccountabilityReminderPlan buildDailyAccountabilityPlan({
    required Iterable<Task> tasks,
    required Iterable<ProjectModel> projects,
    required Iterable<ProofMemoryModel> proofs,
    required DateTime now,
  }) {
    final taskList = tasks.toList();
    final proofList = proofs.toList();
    final planningAt = _nextDailyTime(now, hour: 9);
    final planningDate = _dateOnly(planningAt);
    final hasTasksPlanned = taskList.any(
      (task) => _dateOnly(task.dueDate) == planningDate,
    );

    final pendingAt = _nextDailyTime(now, hour: 17);
    final pendingDate = _dateOnly(pendingAt);
    final pendingTaskCount = taskList.where((task) {
      return _dateOnly(task.dueDate) == pendingDate &&
          task.status == TaskStatus.pending &&
          task.dueDate.isAfter(pendingAt);
    }).length;

    final proofAt = _nextDailyTime(now, hour: 18);
    final proofDate = _dateOnly(proofAt);
    final missingProofProjects = projects.where((project) {
      return !proofList.any(
        (proof) =>
            proof.projectId == project.projectId &&
            _dateOnly(proof.createdAt) == proofDate,
      );
    }).toList();

    return DailyAccountabilityReminderPlan(
      planningAt: hasTasksPlanned ? null : planningAt,
      pendingAt: pendingTaskCount == 0 ? null : pendingAt,
      pendingTaskCount: pendingTaskCount,
      proofAt: missingProofProjects.isEmpty ? null : proofAt,
      missingProofProjects: List.unmodifiable(missingProofProjects),
    );
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
    NotificationDetails? notificationDetails,
  }) {
    return flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
      notificationDetails: notificationDetails ?? _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @visibleForTesting
  TaskReminderCopy buildTaskReminderCopy(Task task) {
    final note = task.notes.trim();
    final stableVariant =
        task.id.codeUnits.fold<int>(
          0,
          (hash, value) => (hash * 31 + value) & 0x7fffffff,
        ) %
        2;
    if (stableVariant == 0) {
      return TaskReminderCopy(
        title: '⏰ Discipline Check',
        body: 'Complete “${task.title}” now. Future you is watching.',
        subText: note.isNotEmpty
            ? 'Note: $note'
            : 'No excuses. Just finish it.',
      );
    }
    return TaskReminderCopy(
      title: '🔥 Don’t break the chain',
      body: 'Complete “${task.title}”. Small task, big identity shift.',
      subText: note.isNotEmpty ? 'Note: $note' : null,
    );
  }

  NotificationDetails _notificationDetailsWithSubText(String? subText) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _androidReminderChannelId,
        _androidReminderChannelName,
        channelDescription:
            'Repeating sound alerts for incomplete Habit_OS tasks',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.notification,
        showWhen: false,
        subText: subText,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: subText,
      ),
    );
  }

  DateTime _nextDailyTime(DateTime now, {required int hour}) {
    final todayAtTime = DateTime(now.year, now.month, now.day, hour);
    return now.isBefore(todayAtTime)
        ? todayAtTime
        : todayAtTime.add(const Duration(days: 1));
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> cancelTaskReminder(String taskId) async {
    _inAppTimers.remove(taskId)?.cancel();
    if (_supportsNativeRepeatingNotifications && _isInitialized) {
      await flutterLocalNotificationsPlugin.cancel(id: taskId.hashCode);
    }
  }

  bool get _supportsNativeRepeatingNotifications =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _androidReminderChannelId,
      _androidReminderChannelName,
      channelDescription:
          'Repeating sound alerts for incomplete Habit_OS tasks',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
      showWhen: false,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );
}
