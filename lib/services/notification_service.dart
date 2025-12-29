import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/animal.dart';

// Smart Notification Service
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<NotificationEvent> _notificationController =
      StreamController<NotificationEvent>.broadcast();

  Stream<NotificationEvent> get notificationStream => _notificationController.stream;

  // Initialize notifications
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels
    await _createNotificationChannels();
  }

  // Create notification channels for different types
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel healthChannel = AndroidNotificationChannel(
      'health_channel',
      'Health Alerts',
      description: 'Notifications about animal health issues',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel treatmentChannel = AndroidNotificationChannel(
      'treatment_channel',
      'Treatment Reminders',
      description: 'Reminders for medication and treatments',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel regulatoryChannel = AndroidNotificationChannel(
      'regulatory_channel',
      'Regulatory Updates',
      description: 'Compliance and regulatory notifications',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    const AndroidNotificationChannel emergencyChannel = AndroidNotificationChannel(
      'emergency_channel',
      'Emergency Alerts',
      description: 'Critical emergency notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(healthChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(treatmentChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(regulatoryChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(emergencyChannel);
  }

  // Health Monitoring Notifications
  Future<void> scheduleHealthCheckNotifications(List<Animal> animals) async {
    for (final animal in animals) {
      // Daily health check reminder
      await _scheduleDailyHealthCheck(animal);

      // Weight monitoring alerts
      await _scheduleWeightMonitoringAlerts(animal);

      // Reproductive cycle alerts
      await _scheduleReproductiveAlerts(animal);

      // Vaccination due alerts
      await _scheduleVaccinationAlerts(animal);
    }
  }

  // Treatment Schedule Notifications
  Future<void> scheduleTreatmentNotifications(List<Animal> animals) async {
    for (final animal in animals) {
      if (animal.treatmentHistory != null) {
        for (final treatment in animal.treatmentHistory!) {
          // Medication reminders
          await _scheduleMedicationReminders(treatment, animal);

          // Follow-up appointment reminders
          await _scheduleFollowUpReminders(treatment, animal);
        }
      }

      // Withdrawal period alerts
      if (animal.hasActiveTreatment) {
        await _scheduleWithdrawalPeriodAlerts(animal);
      }
    }
  }

  // Regulatory Compliance Notifications
  Future<void> scheduleRegulatoryNotifications() async {
    // Monthly compliance report reminders
    await _scheduleMonthlyComplianceReports();

    // Regulatory deadline alerts
    await _scheduleRegulatoryDeadlines();

    // MRL testing reminders
    await _scheduleMRLTestingReminders();
  }

  // Emergency Alert System
  Future<void> sendEmergencyAlert({
    required String title,
    required String message,
    required EmergencyPriority priority,
    List<String>? animalIds,
    String? location,
  }) async {
    final notificationId = DateTime.now().millisecondsSinceEpoch;

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'emergency_channel',
        'Emergency Alerts',
        channelDescription: 'Critical emergency notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        color: Color(0xFFFF0000),
        fullScreenIntent: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'emergency.caf',
        interruptionLevel: InterruptionLevel.critical,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      message,
      notificationDetails,
      payload: json.encode({
        'type': 'emergency',
        'animalIds': animalIds,
        'location': location,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    // Add to notification stream
    _notificationController.add(NotificationEvent(
      id: notificationId.toString(),
      type: NotificationType.emergency,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      priority: priority,
      data: {
        'animalIds': animalIds,
        'location': location,
      },
    ));
  }

  // Smart Context-Aware Notifications
  Future<void> sendSmartNotification({
    required String title,
    required String message,
    required NotificationType type,
    required SmartNotificationContext context,
    Map<String, dynamic>? data,
  }) async {
    // Check user preferences and context before sending
    if (!await _shouldSendNotification(type, context)) {
      return;
    }

    final notificationId = DateTime.now().millisecondsSinceEpoch;
    final channelId = _getChannelIdForType(type);

    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _getChannelNameForType(type),
        channelDescription: _getChannelDescriptionForType(type),
        importance: _getImportanceForType(type),
        priority: _getPriorityForType(type),
        playSound: await _shouldPlaySound(type),
        enableVibration: await _shouldVibrate(type),
        color: _getColorForType(type),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: await _shouldPlaySound(type),
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      message,
      notificationDetails,
      payload: json.encode({
        'type': type.toString(),
        'context': context.toString(),
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    // Add to notification stream
    _notificationController.add(NotificationEvent(
      id: notificationId.toString(),
      type: type,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      priority: _getEmergencyPriorityForType(type),
      data: data,
    ));
  }

  // Batch Notification Scheduling
  Future<void> scheduleBatchNotifications({
    required List<NotificationSchedule> schedules,
  }) async {
    for (final schedule in schedules) {
      await _scheduleNotification(schedule);
    }
  }

  // Notification History and Analytics
  Future<List<NotificationEvent>> getNotificationHistory({
    DateTime? startDate,
    DateTime? endDate,
    NotificationType? type,
    int? limit,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('notification_history') ?? [];

    List<NotificationEvent> history = historyJson
        .map((jsonStr) => NotificationEvent.fromJson(json.decode(jsonStr)))
        .toList();

    // Apply filters
    if (startDate != null) {
      history = history.where((n) => n.timestamp.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      history = history.where((n) => n.timestamp.isBefore(endDate)).toList();
    }
    if (type != null) {
      history = history.where((n) => n.type == type).toList();
    }

    // Sort by timestamp (newest first)
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Apply limit
    if (limit != null && history.length > limit) {
      history = history.sublist(0, limit);
    }

    return history;
  }

  // Notification Preferences Management
  Future<void> updateNotificationPreferences({
    required NotificationPreferences preferences,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_preferences', json.encode(preferences.toJson()));
  }

  Future<NotificationPreferences> getNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = prefs.getString('notification_preferences');

    if (preferencesJson != null) {
      return NotificationPreferences.fromJson(json.decode(preferencesJson));
    }

    // Return default preferences
    return NotificationPreferences(
      enableHealthAlerts: true,
      enableTreatmentReminders: true,
      enableRegulatoryUpdates: true,
      enableEmergencyAlerts: true,
      enableMarketingNotifications: false,
      quietHoursStart: TimeOfDay(hour: 22, minute: 0),
      quietHoursEnd: TimeOfDay(hour: 7, minute: 0),
      vibrationEnabled: true,
      soundEnabled: true,
    );
  }

  // Private helper methods

  Future<void> _scheduleDailyHealthCheck(Animal animal) async {
    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, 9, 0); // 9 AM daily

    if (scheduledTime.isBefore(now)) {
      scheduledTime.add(Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      animal.id.hashCode + 1000,
      'Daily Health Check',
      'Time to check on ${animal.species} ${animal.id}',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'health_channel',
          'Health Alerts',
          channelDescription: 'Daily health check reminders',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleWeightMonitoringAlerts(Animal animal) async {
    if (animal.weightHistory == null || animal.weightHistory!.length < 2) return;

    final latestWeight = animal.weightHistory!.last;
    final previousWeight = animal.weightHistory![animal.weightHistory!.length - 2];

    final weightChange = ((latestWeight.weight - previousWeight.weight) / previousWeight.weight) * 100;

    if (weightChange < -10) { // 10% weight loss
      await sendSmartNotification(
        title: 'Weight Loss Alert',
        message: '${animal.species} ${animal.id} has lost ${weightChange.abs().toStringAsFixed(1)}% of body weight',
        type: NotificationType.health,
        context: SmartNotificationContext.healthMonitoring,
        data: {'animalId': animal.id, 'weightChange': weightChange},
      );
    }
  }

  Future<void> _scheduleReproductiveAlerts(Animal animal) async {
    if (animal.reproductiveData?.expectedDueDate != null) {
      final dueDate = animal.reproductiveData!.expectedDueDate!;
      final daysUntilDue = dueDate.difference(DateTime.now()).inDays;

      if (daysUntilDue <= 7 && daysUntilDue > 0) {
        await sendSmartNotification(
          title: 'Pregnancy Due Soon',
          message: '${animal.species} ${animal.id} is due in $daysUntilDue days',
          type: NotificationType.health,
          context: SmartNotificationContext.reproductiveHealth,
          data: {'animalId': animal.id, 'daysUntilDue': daysUntilDue},
        );
      }
    }
  }

  Future<void> _scheduleVaccinationAlerts(Animal animal) async {
    if (animal.vaccinationHistory != null) {
      for (final vaccination in animal.vaccinationHistory!) {
        if (vaccination.nextDueDate != null) {
          final daysUntilDue = vaccination.nextDueDate!.difference(DateTime.now()).inDays;

          if (daysUntilDue <= 7 && daysUntilDue > 0) {
            await sendSmartNotification(
              title: 'Vaccination Due',
              message: '${vaccination.vaccineName} due for ${animal.species} ${animal.id} in $daysUntilDue days',
              type: NotificationType.treatment,
              context: SmartNotificationContext.vaccination,
              data: {'animalId': animal.id, 'vaccineName': vaccination.vaccineName},
            );
          }
        }
      }
    }
  }

  Future<void> _scheduleMedicationReminders(TreatmentRecord treatment, Animal animal) async {
    // Schedule reminders for medication timing
    // This would be more sophisticated in a real implementation
    final reminderTime = DateTime.now().add(Duration(hours: 1));

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      treatment.hashCode,
      'Medication Reminder',
      'Time for ${treatment.drugName} for ${animal.species} ${animal.id}',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'treatment_channel',
          'Treatment Reminders',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _scheduleFollowUpReminders(TreatmentRecord treatment, Animal animal) async {
    // Schedule follow-up reminders (typically 7-14 days after treatment)
    final followUpTime = treatment.dateAdministered.add(Duration(days: 7));

    if (followUpTime.isAfter(DateTime.now())) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        treatment.hashCode + 10000,
        'Follow-up Check',
        'Follow-up required for ${animal.species} ${animal.id} after ${treatment.drugName} treatment',
        tz.TZDateTime.from(followUpTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'treatment_channel',
            'Treatment Reminders',
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> _scheduleWithdrawalPeriodAlerts(Animal animal) async {
    if (animal.withdrawalEnd != null) {
      final withdrawalEnd = DateTime.parse(animal.withdrawalEnd!);
      final daysRemaining = withdrawalEnd.difference(DateTime.now()).inDays;

      if (daysRemaining <= 3 && daysRemaining > 0) {
        await sendSmartNotification(
          title: 'Withdrawal Period Ending',
          message: '${animal.species} ${animal.id} withdrawal period ends in $daysRemaining days',
          type: NotificationType.regulatory,
          context: SmartNotificationContext.withdrawalPeriod,
          data: {'animalId': animal.id, 'daysRemaining': daysRemaining},
        );
      }
    }
  }

  Future<void> _scheduleMonthlyComplianceReports() async {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1, 9, 0); // 1st of next month, 9 AM

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      999999, // Unique ID for monthly reports
      'Monthly Compliance Report',
      'Time to generate your monthly antibiotic usage compliance report',
      tz.TZDateTime.from(nextMonth, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'regulatory_channel',
          'Regulatory Updates',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> _scheduleRegulatoryDeadlines() async {
    // This would be populated with actual regulatory deadlines
    // For now, it's a placeholder
  }

  Future<void> _scheduleMRLTestingReminders() async {
    // Schedule quarterly MRL testing reminders
    final now = DateTime.now();
    final nextQuarter = DateTime(now.year, ((now.month - 1) ~/ 3 + 1) * 3 + 1, 1, 9, 0);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      999998, // Unique ID for MRL testing
      'MRL Testing Reminder',
      'Quarterly MRL testing is due. Schedule laboratory testing for your animals.',
      tz.TZDateTime.from(nextQuarter, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'regulatory_channel',
          'Regulatory Updates',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _scheduleNotification(NotificationSchedule schedule) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      schedule.id.hashCode,
      schedule.title,
      schedule.message,
      tz.TZDateTime.from(schedule.scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _getChannelIdForType(schedule.type),
          _getChannelNameForType(schedule.type),
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<bool> _shouldSendNotification(NotificationType type, SmartNotificationContext context) async {
    final preferences = await getNotificationPreferences();
    final now = TimeOfDay.now();

    // Check if notifications are enabled for this type
    switch (type) {
      case NotificationType.health:
        if (!preferences.enableHealthAlerts) return false;
        break;
      case NotificationType.treatment:
        if (!preferences.enableTreatmentReminders) return false;
        break;
      case NotificationType.regulatory:
        if (!preferences.enableRegulatoryUpdates) return false;
        break;
      case NotificationType.emergency:
        if (!preferences.enableEmergencyAlerts) return false;
        break;
      default:
        return false;
    }

    // Check quiet hours
    if (_isInQuietHours(now, preferences)) {
      return false;
    }

    return true;
  }

  bool _isInQuietHours(TimeOfDay now, NotificationPreferences preferences) {
    final quietStart = preferences.quietHoursStart;
    final quietEnd = preferences.quietHoursEnd;

    if (quietStart.hour < quietEnd.hour) {
      // Same day quiet hours
      return (now.hour > quietStart.hour || (now.hour == quietStart.hour && now.minute >= quietStart.minute)) &&
             (now.hour < quietEnd.hour || (now.hour == quietEnd.hour && now.minute <= quietEnd.minute));
    } else {
      // Overnight quiet hours
      return now.hour > quietStart.hour || now.hour < quietEnd.hour ||
             (now.hour == quietStart.hour && now.minute >= quietStart.minute) ||
             (now.hour == quietEnd.hour && now.minute <= quietEnd.minute);
    }
  }

  Future<bool> _shouldPlaySound(NotificationType type) async {
    final preferences = await getNotificationPreferences();
    return preferences.soundEnabled;
  }

  Future<bool> _shouldVibrate(NotificationType type) async {
    final preferences = await getNotificationPreferences();
    return preferences.vibrationEnabled;
  }

  String _getChannelIdForType(NotificationType type) {
    switch (type) {
      case NotificationType.health:
        return 'health_channel';
      case NotificationType.treatment:
        return 'treatment_channel';
      case NotificationType.regulatory:
        return 'regulatory_channel';
      case NotificationType.emergency:
        return 'emergency_channel';
      default:
        return 'default_channel';
    }
  }

  String _getChannelNameForType(NotificationType type) {
    switch (type) {
      case NotificationType.health:
        return 'Health Alerts';
      case NotificationType.treatment:
        return 'Treatment Reminders';
      case NotificationType.regulatory:
        return 'Regulatory Updates';
      case NotificationType.emergency:
        return 'Emergency Alerts';
      default:
        return 'Notifications';
    }
  }

  String _getChannelDescriptionForType(NotificationType type) {
    switch (type) {
      case NotificationType.health:
        return 'Notifications about animal health issues';
      case NotificationType.treatment:
        return 'Reminders for medication and treatments';
      case NotificationType.regulatory:
        return 'Compliance and regulatory notifications';
      case NotificationType.emergency:
        return 'Critical emergency notifications';
      default:
        return 'General notifications';
    }
  }

  Importance _getImportanceForType(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return Importance.max;
      case NotificationType.health:
      case NotificationType.treatment:
        return Importance.high;
      case NotificationType.regulatory:
        return Importance.defaultImportance;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _getPriorityForType(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return Priority.max;
      case NotificationType.health:
      case NotificationType.treatment:
        return Priority.high;
      case NotificationType.regulatory:
        return Priority.defaultPriority;
      default:
        return Priority.defaultPriority;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return const Color(0xFFFF0000);
      case NotificationType.health:
        return const Color(0xFFFF9800);
      case NotificationType.treatment:
        return const Color(0xFF2196F3);
      case NotificationType.regulatory:
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  EmergencyPriority _getEmergencyPriorityForType(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return EmergencyPriority.critical;
      case NotificationType.health:
        return EmergencyPriority.high;
      case NotificationType.treatment:
        return EmergencyPriority.medium;
      case NotificationType.regulatory:
        return EmergencyPriority.low;
      default:
        return EmergencyPriority.low;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    if (response.payload != null) {
      final data = json.decode(response.payload!);
      // Navigate to appropriate screen based on notification type
      _notificationController.add(NotificationEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: NotificationType.values.firstWhere(
          (e) => e.toString().split('.').last == data['type'],
          orElse: () => NotificationType.health,
        ),
        title: 'Notification Tapped',
        message: 'User tapped on notification',
        timestamp: DateTime.now(),
        priority: EmergencyPriority.low,
        data: data,
      ));
    }
  }
}

// Data Models

enum NotificationType {
  health,
  treatment,
  regulatory,
  emergency,
  marketing,
}

enum EmergencyPriority {
  low,
  medium,
  high,
  critical,
}

enum SmartNotificationContext {
  healthMonitoring,
  reproductiveHealth,
  vaccination,
  withdrawalPeriod,
  regulatoryDeadline,
  emergencyResponse,
  treatmentSchedule,
}

class NotificationEvent {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final EmergencyPriority priority;
  final Map<String, dynamic>? data;

  NotificationEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.priority,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'title': title,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'priority': priority.toString(),
    'data': data,
  };

  factory NotificationEvent.fromJson(Map<String, dynamic> json) => NotificationEvent(
    id: json['id'],
    type: NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == json['type'],
    ),
    title: json['title'],
    message: json['message'],
    timestamp: DateTime.parse(json['timestamp']),
    priority: EmergencyPriority.values.firstWhere(
      (e) => e.toString().split('.').last == json['priority'],
    ),
    data: json['data'],
  );
}

class NotificationSchedule {
  final String id;
  final String title;
  final String message;
  final DateTime scheduledTime;
  final NotificationType type;
  final bool repeat;
  final Duration? repeatInterval;

  NotificationSchedule({
    required this.id,
    required this.title,
    required this.message,
    required this.scheduledTime,
    required this.type,
    this.repeat = false,
    this.repeatInterval,
  });
}

class NotificationPreferences {
  final bool enableHealthAlerts;
  final bool enableTreatmentReminders;
  final bool enableRegulatoryUpdates;
  final bool enableEmergencyAlerts;
  final bool enableMarketingNotifications;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;
  final bool vibrationEnabled;
  final bool soundEnabled;

  NotificationPreferences({
    required this.enableHealthAlerts,
    required this.enableTreatmentReminders,
    required this.enableRegulatoryUpdates,
    required this.enableEmergencyAlerts,
    required this.enableMarketingNotifications,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.vibrationEnabled,
    required this.soundEnabled,
  });

  Map<String, dynamic> toJson() => {
    'enableHealthAlerts': enableHealthAlerts,
    'enableTreatmentReminders': enableTreatmentReminders,
    'enableRegulatoryUpdates': enableRegulatoryUpdates,
    'enableEmergencyAlerts': enableEmergencyAlerts,
    'enableMarketingNotifications': enableMarketingNotifications,
    'quietHoursStart': '${quietHoursStart.hour}:${quietHoursStart.minute}',
    'quietHoursEnd': '${quietHoursEnd.hour}:${quietHoursEnd.minute}',
    'vibrationEnabled': vibrationEnabled,
    'soundEnabled': soundEnabled,
  };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) => NotificationPreferences(
    enableHealthAlerts: json['enableHealthAlerts'] ?? true,
    enableTreatmentReminders: json['enableTreatmentReminders'] ?? true,
    enableRegulatoryUpdates: json['enableRegulatoryUpdates'] ?? true,
    enableEmergencyAlerts: json['enableEmergencyAlerts'] ?? true,
    enableMarketingNotifications: json['enableMarketingNotifications'] ?? false,
    quietHoursStart: _parseTimeOfDay(json['quietHoursStart'] ?? '22:0'),
    quietHoursEnd: _parseTimeOfDay(json['quietHoursEnd'] ?? '7:0'),
    vibrationEnabled: json['vibrationEnabled'] ?? true,
    soundEnabled: json['soundEnabled'] ?? true,
  );

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}