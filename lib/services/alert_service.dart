import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/animal.dart';
import '../data/medicine_data.dart';
import '../l10n/app_localizations.dart';

/// Automated Alert Service for Compliance Monitoring
class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  Timer? _monitoringTimer;
  final List<Alert> _activeAlerts = [];
  final StreamController<Alert> _alertStream = StreamController<Alert>.broadcast();

  /// Alert types
  static const String WITHDRAWAL_WARNING = 'withdrawal_warning';
  static const String WITHDRAWAL_EXPIRED = 'withdrawal_expired';
  static const String WITHDRAWAL_STATUS = 'withdrawal_status';
  static const String MRL_VIOLATION = 'mrl_violation';
  static const String TREATMENT_OVERDUE = 'treatment_overdue';
  static const String COMPLIANCE_RISK = 'compliance_risk';
  static const String MEDICINE_EXPIRY = 'medicine_expiry';

  /// Initialize the alert service
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(settings);
    _startMonitoring();
    _scheduleDailyWithdrawalAlerts();
  }

  /// Start monitoring for alerts
  void _startMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(Duration(hours: 6), (_) => _checkForAlerts());
  }

  /// Schedule daily withdrawal alerts at 2:00 PM and 3:00 PM
  Future<void> _scheduleDailyWithdrawalAlerts() async {
    final now = DateTime.now();

    // Schedule 2:00 PM alert
    final twoPM = DateTime(now.year, now.month, now.day, 14, 0); // 2:00 PM
    if (twoPM.isBefore(now)) {
      twoPM.add(Duration(days: 1)); // Schedule for tomorrow if already passed
    }

    // Schedule 3:00 PM alert
    final threePM = DateTime(now.year, now.month, now.day, 15, 0); // 3:00 PM
    if (threePM.isBefore(now)) {
      threePM.add(Duration(days: 1)); // Schedule for tomorrow if already passed
    }

    // Schedule the 2:00 PM notification
    await _notifications.zonedSchedule(
      2000, // Unique ID for 2 PM alert
      'Daily Withdrawal Status Check',
      'Checking withdrawal status for all animals at 2:00 PM',
      tz.TZDateTime.from(twoPM, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'compliance_channel',
          'Compliance Alerts',
          channelDescription: 'Daily withdrawal status notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Schedule the 3:00 PM notification
    await _notifications.zonedSchedule(
      3000, // Unique ID for 3 PM alert
      'Daily Withdrawal Status Check',
      'Checking withdrawal status for all animals at 3:00 PM',
      tz.TZDateTime.from(threePM, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'compliance_channel',
          'Compliance Alerts',
          channelDescription: 'Daily withdrawal status notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Check for new alerts
  Future<void> _checkForAlerts() async {
    // Load animals from storage for alert checking
    final animals = await _loadAnimalsForAlerts();
    final alerts = await _scanForAlerts(animals);
    for (final alert in alerts) {
      if (!_isDuplicateAlert(alert)) {
        _activeAlerts.add(alert);
        _alertStream.add(alert);
        await _sendNotification(alert);
      }
    }

    // Clean up old alerts
    _cleanupOldAlerts();
  }

  /// Load animals for alert checking (simplified - in real app would use AnimalStorageService)
  Future<List<Animal>> _loadAnimalsForAlerts() async {
    // This is a placeholder - in the real implementation, this would load from AnimalStorageService
    // For now, return empty list to avoid errors
    return [];
  }

  /// Scan animals for potential alerts
  Future<List<Alert>> _scanForAlerts(List<Animal> animals) async {
    final alerts = <Alert>[];

    for (final animal in animals) {
      // Check withdrawal period alerts
      final withdrawalAlerts = await _checkWithdrawalAlerts(animal);
      alerts.addAll(withdrawalAlerts);

      // Check MRL alerts
      final mrlAlerts = await _checkMRLAlerts(animal);
      alerts.addAll(mrlAlerts);

      // Check treatment overdue alerts
      final treatmentAlerts = await _checkTreatmentAlerts(animal);
      alerts.addAll(treatmentAlerts);

      // Check compliance risk alerts
      final complianceAlerts = await _checkComplianceAlerts(animal);
      alerts.addAll(complianceAlerts);
    }

    return alerts;
  }

  /// Check for withdrawal period alerts
  Future<List<Alert>> _checkWithdrawalAlerts(Animal animal) async {
    final alerts = <Alert>[];

    if (animal.withdrawalEnd != null) {
      final withdrawalEnd = DateTime.parse(animal.withdrawalEnd!);
      final now = DateTime.now();
      final daysUntilExpiry = withdrawalEnd.difference(now).inDays;

      if (daysUntilExpiry <= 0) {
        // Withdrawal period has expired - animal is safe
        alerts.add(Alert(
          id: 'withdrawal_expired_${animal.id}',
          type: WITHDRAWAL_EXPIRED,
          title: 'Withdrawal Period Completed',
          message: '${animal.species} (${animal.id}) withdrawal period has expired. Product is now safe for consumption.',
          animalId: animal.id,
          severity: AlertSeverity.low,
          timestamp: now,
        ));
      } else if (daysUntilExpiry <= 3) {
        // Warning for upcoming expiry
        alerts.add(Alert(
          id: 'withdrawal_warning_${animal.id}',
          type: WITHDRAWAL_WARNING,
          title: 'Withdrawal Period Ending Soon',
          message: '${animal.species} (${animal.id}) withdrawal period ends in $daysUntilExpiry days.',
          animalId: animal.id,
          severity: AlertSeverity.medium,
          timestamp: now,
        ));
      } else {
        // Active withdrawal period - create daily status alert
        alerts.add(Alert(
          id: 'withdrawal_status_${animal.id}_${now.day}',
          type: 'withdrawal_status',
          title: 'Animal in Withdrawal Period',
          message: '${animal.species} (${animal.id}) is currently in withdrawal period. Ends on ${withdrawalEnd.toLocal().toString().split(' ')[0]}.',
          animalId: animal.id,
          severity: AlertSeverity.high,
          timestamp: now,
        ));
      }
    }

    return alerts;
  }

  /// Check for MRL violation alerts
  Future<List<Alert>> _checkMRLAlerts(Animal animal) async {
    final alerts = <Alert>[];

    if (animal.currentMRL != null && animal.currentMRL! > safeThreshold) {
      alerts.add(Alert(
        id: 'mrl_violation_${animal.id}',
        type: MRL_VIOLATION,
        title: 'MRL Violation Detected',
        message: '${animal.species} (${animal.id}) has MRL level of ${animal.currentMRL!.toStringAsFixed(3)}, which exceeds safe threshold.',
        animalId: animal.id,
        severity: AlertSeverity.critical,
        timestamp: DateTime.now(),
      ));
    }

    return alerts;
  }

  /// Check for treatment overdue alerts
  Future<List<Alert>> _checkTreatmentAlerts(Animal animal) async {
    final alerts = <Alert>[];

    // Check if animal hasn't been treated recently (e.g., no treatment in last 30 days)
    if (animal.treatmentHistory != null && animal.treatmentHistory!.isNotEmpty) {
      final lastTreatment = animal.treatmentHistory!
          .reduce((a, b) => a.dateAdministered.isAfter(b.dateAdministered) ? a : b);

      final daysSinceLastTreatment = DateTime.now().difference(lastTreatment.dateAdministered).inDays;

      if (daysSinceLastTreatment > 30) {
        alerts.add(Alert(
          id: 'treatment_overdue_${animal.id}',
          type: TREATMENT_OVERDUE,
          title: 'Treatment Check Due',
          message: '${animal.species} (${animal.id}) hasn\'t been treated in $daysSinceLastTreatment days. Consider health check.',
          animalId: animal.id,
          severity: AlertSeverity.low,
          timestamp: DateTime.now(),
        ));
      }
    }

    return alerts;
  }

  /// Check for compliance risk alerts
  Future<List<Alert>> _checkComplianceAlerts(Animal animal) async {
    final alerts = <Alert>[];

    // Check for frequent treatments (potential overuse)
    if (animal.treatmentHistory != null) {
      final recentTreatments = animal.treatmentHistory!
          .where((t) => t.dateAdministered.isAfter(DateTime.now().subtract(Duration(days: 30))))
          .toList();

      if (recentTreatments.length >= 3) {
        alerts.add(Alert(
          id: 'compliance_risk_${animal.id}',
          type: COMPLIANCE_RISK,
          title: 'Frequent Treatment Alert',
          message: '${animal.species} (${animal.id}) has received ${recentTreatments.length} treatments in the last 30 days.',
          animalId: animal.id,
          severity: AlertSeverity.medium,
          timestamp: DateTime.now(),
        ));
      }
    }

    return alerts;
  }

  /// Send notification for alert
  Future<void> _sendNotification(Alert alert) async {
    const androidDetails = AndroidNotificationDetails(
      'compliance_channel',
      'Compliance Alerts',
      channelDescription: 'Notifications for compliance and safety alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      alert.id.hashCode,
      alert.title,
      alert.message,
      details,
      payload: alert.animalId,
    );
  }

  /// Check if alert is duplicate
  bool _isDuplicateAlert(Alert newAlert) {
    return _activeAlerts.any((existing) =>
        existing.type == newAlert.type &&
        existing.animalId == newAlert.animalId &&
        existing.timestamp.difference(newAlert.timestamp).inHours < 24);
  }

  /// Clean up old alerts
  void _cleanupOldAlerts() {
    final cutoffDate = DateTime.now().subtract(Duration(days: 30));
    _activeAlerts.removeWhere((alert) => alert.timestamp.isBefore(cutoffDate));
  }

  /// Get active alerts
  List<Alert> getActiveAlerts() {
    return List.unmodifiable(_activeAlerts);
  }

  /// Get alerts for specific animal
  List<Alert> getAlertsForAnimal(String animalId) {
    return _activeAlerts.where((alert) => alert.animalId == animalId).toList();
  }

  /// Get alerts by type
  List<Alert> getAlertsByType(String type) {
    return _activeAlerts.where((alert) => alert.type == type).toList();
  }

  /// Mark alert as read
  void markAlertAsRead(String alertId) {
    final alert = _activeAlerts.firstWhere((a) => a.id == alertId);
    alert.isRead = true;
  }

  /// Dismiss alert
  void dismissAlert(String alertId) {
    _activeAlerts.removeWhere((alert) => alert.id == alertId);
  }

  /// Get alert stream for real-time updates
  Stream<Alert> get alertStream => _alertStream.stream;

  /// Create custom alert
  void createCustomAlert({
    required String title,
    required String message,
    required String animalId,
    required AlertSeverity severity,
    String type = 'custom',
  }) {
    final alert = Alert(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: title,
      message: message,
      animalId: animalId,
      severity: severity,
      timestamp: DateTime.now(),
    );

    _activeAlerts.add(alert);
    _alertStream.add(alert);
    _sendNotification(alert);
  }

  /// Get alert statistics
  Map<String, dynamic> getAlertStatistics() {
    final stats = <String, dynamic>{
      'total_alerts': _activeAlerts.length,
      'unread_alerts': _activeAlerts.where((a) => !a.isRead).length,
      'by_type': <String, int>{},
      'by_severity': <String, int>{},
      'by_animal': <String, int>{},
    };

    for (final alert in _activeAlerts) {
      stats['by_type'][alert.type] = (stats['by_type'][alert.type] ?? 0) + 1;
      stats['by_severity'][alert.severity.toString()] = (stats['by_severity'][alert.severity.toString()] ?? 0) + 1;
      stats['by_animal'][alert.animalId] = (stats['by_animal'][alert.animalId] ?? 0) + 1;
    }

    return stats;
  }

  /// Export alerts for reporting
  List<Map<String, dynamic>> exportAlerts() {
    return _activeAlerts.map((alert) => alert.toJson()).toList();
  }

  /// Dispose resources
  void dispose() {
    _monitoringTimer?.cancel();
    _alertStream.close();
  }
}

/// Alert data model
class Alert {
  final String id;
  final String type;
  final String title;
  final String message;
  final String animalId;
  final AlertSeverity severity;
  final DateTime timestamp;
  bool isRead;

  Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.animalId,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'message': message,
    'animalId': animalId,
    'severity': severity.toString(),
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  static Alert fromJson(Map<String, dynamic> json) => Alert(
    id: json['id'],
    type: json['type'],
    title: json['title'],
    message: json['message'],
    animalId: json['animalId'],
    severity: AlertSeverity.values.firstWhere(
      (e) => e.toString() == json['severity'],
      orElse: () => AlertSeverity.low,
    ),
    timestamp: DateTime.parse(json['timestamp']),
    isRead: json['isRead'] ?? false,
  );
}

/// Alert severity levels
enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

extension AlertSeverityExtension on AlertSeverity {
  Color get color {
    switch (this) {
      case AlertSeverity.low:
        return Colors.blue;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.critical:
        return Colors.red.shade900;
    }
  }

  String displayName(BuildContext context) {
    switch (this) {
      case AlertSeverity.low:
        return AppLocalizations.of(context)!.low;
      case AlertSeverity.medium:
        return AppLocalizations.of(context)!.medium;
      case AlertSeverity.high:
        return AppLocalizations.of(context)!.high;
      case AlertSeverity.critical:
        return AppLocalizations.of(context)!.critical;
    }
  }

  IconData get icon {
    switch (this) {
      case AlertSeverity.low:
        return Icons.info;
      case AlertSeverity.medium:
        return Icons.warning;
      case AlertSeverity.high:
        return Icons.error;
      case AlertSeverity.critical:
        return Icons.dangerous;
    }
  }
}