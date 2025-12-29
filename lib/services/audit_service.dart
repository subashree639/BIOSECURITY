import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import '../models/animal.dart';

// Audit Trail Service
class AuditService {
  static final AuditService _instance = AuditService._internal();
  factory AuditService() => _instance;

  AuditService._internal();

  final List<AuditEntry> _auditLog = [];
  bool _isInitialized = false;

  // Initialize audit service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadAuditLog();
      _isInitialized = true;

      // Log service initialization
      await logEvent(
        action: 'AUDIT_SERVICE_INITIALIZED',
        performedBy: 'SYSTEM',
        entityType: 'system',
        entityId: 'audit_service',
        details: {'timestamp': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      print('Failed to initialize audit service: $e');
    }
  }

  // Log audit event
  Future<void> logEvent({
    required String action,
    required String performedBy,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? details,
    AuditSeverity severity = AuditSeverity.info,
    bool requiresApproval = false,
  }) async {
    final entry = AuditEntry(
      id: _generateAuditId(),
      timestamp: DateTime.now(),
      action: action,
      performedBy: performedBy,
      entityType: entityType,
      entityId: entityId,
      details: details ?? {},
      severity: severity,
      requiresApproval: requiresApproval,
      checksum: _calculateChecksum(action, performedBy, entityId, details),
    );

    _auditLog.add(entry);

    // Save to persistent storage
    await _saveAuditEntry(entry);

    // Check for suspicious activity
    await _checkForSuspiciousActivity(entry);

    // Trigger alerts if necessary
    if (severity == AuditSeverity.critical || requiresApproval) {
      await _triggerAuditAlert(entry);
    }

    // Auto-archive old entries
    await _autoArchiveOldEntries();
  }

  // Comprehensive audit logging for animal operations
  Future<void> logAnimalOperation({
    required String operation,
    required String performedBy,
    required Animal animal,
    Map<String, dynamic>? changes,
    String? reason,
  }) async {
    final details = {
      'animal_id': animal.id,
      'species': animal.species,
      'operation': operation,
      'changes': changes,
      'reason': reason,
      'animal_health_score': animal.healthScore,
      'previous_treatments_count': animal.treatmentHistory?.length ?? 0,
      'location': animal.currentLocation != null
          ? '${animal.currentLocation!.latitude},${animal.currentLocation!.longitude}'
          : null,
    };

    await logEvent(
      action: 'ANIMAL_${operation.toUpperCase()}',
      performedBy: performedBy,
      entityType: 'animal',
      entityId: animal.id,
      details: details,
      severity: _determineAnimalOperationSeverity(operation),
    );
  }

  // Treatment audit logging
  Future<void> logTreatment({
    required String performedBy,
    required Animal animal,
    required TreatmentRecord treatment,
    String? prescriptionId,
    bool isEmergency = false,
  }) async {
    final treatmentId =
        'treatment_${animal.id}_${treatment.dateAdministered.millisecondsSinceEpoch}';
    final details = {
      'animal_id': animal.id,
      'drug_name': treatment.drugName,
      'dosage': treatment.dosage,
      'condition': treatment.condition,
      'prescription_id': prescriptionId,
      'is_emergency': isEmergency,
      'cost': treatment.cost,
      'administered_by': treatment.administeredBy,
      'date_administered': treatment.dateAdministered.toIso8601String(),
    };

    await logEvent(
      action: 'TREATMENT_ADMINISTERED',
      performedBy: performedBy,
      entityType: 'treatment',
      entityId: treatmentId,
      details: details,
      severity: isEmergency ? AuditSeverity.high : AuditSeverity.info,
      requiresApproval: _requiresTreatmentApproval(treatment),
    );
  }

  // Regulatory compliance audit
  Future<void> logComplianceEvent({
    required String eventType,
    required String performedBy,
    required String entityId,
    required ComplianceStatus status,
    Map<String, dynamic>? complianceData,
    List<String>? violations,
  }) async {
    final details = {
      'event_type': eventType,
      'compliance_status': status.toString(),
      'compliance_data': complianceData,
      'violations': violations,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await logEvent(
      action: 'COMPLIANCE_${eventType.toUpperCase()}',
      performedBy: performedBy,
      entityType: 'compliance',
      entityId: entityId,
      details: details,
      severity: status == ComplianceStatus.nonCompliant
          ? AuditSeverity.critical
          : AuditSeverity.info,
    );
  }

  // User access audit
  Future<void> logUserAccess({
    required String userId,
    required String action,
    required String resource,
    required bool success,
    String? ipAddress,
    String? userAgent,
  }) async {
    final details = {
      'user_id': userId,
      'action': action,
      'resource': resource,
      'success': success,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await logEvent(
      action: 'USER_ACCESS_${action.toUpperCase()}',
      performedBy: userId,
      entityType: 'user_access',
      entityId: userId,
      details: details,
      severity: success ? AuditSeverity.info : AuditSeverity.warning,
    );
  }

  // Data export audit
  Future<void> logDataExport({
    required String performedBy,
    required String exportType,
    required int recordCount,
    required String destination,
    String? filters,
  }) async {
    final details = {
      'export_type': exportType,
      'record_count': recordCount,
      'destination': destination,
      'filters': filters,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await logEvent(
      action: 'DATA_EXPORT',
      performedBy: performedBy,
      entityType: 'data_export',
      entityId: 'export_${DateTime.now().millisecondsSinceEpoch}',
      details: details,
      severity: AuditSeverity.info,
      requiresApproval: recordCount > 1000, // Large exports require approval
    );
  }

  // Query audit log
  Future<List<AuditEntry>> queryAuditLog({
    DateTime? startDate,
    DateTime? endDate,
    String? performedBy,
    String? entityType,
    String? entityId,
    String? action,
    AuditSeverity? minSeverity,
    int? limit,
    int? offset,
  }) async {
    List<AuditEntry> results = List.from(_auditLog);

    // Apply filters
    if (startDate != null) {
      results =
          results.where((entry) => entry.timestamp.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      results =
          results.where((entry) => entry.timestamp.isBefore(endDate)).toList();
    }
    if (performedBy != null) {
      results =
          results.where((entry) => entry.performedBy == performedBy).toList();
    }
    if (entityType != null) {
      results =
          results.where((entry) => entry.entityType == entityType).toList();
    }
    if (entityId != null) {
      results = results.where((entry) => entry.entityId == entityId).toList();
    }
    if (action != null) {
      results = results.where((entry) => entry.action == action).toList();
    }
    if (minSeverity != null) {
      results = results
          .where((entry) => entry.severity.index >= minSeverity.index)
          .toList();
    }

    // Sort by timestamp (newest first)
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Apply pagination
    if (offset != null && offset > 0) {
      results = results.skip(offset).toList();
    }
    if (limit != null && limit > 0) {
      results = results.take(limit).toList();
    }

    return results;
  }

  // Generate audit report
  Future<String> generateAuditReport({
    required DateTime startDate,
    required DateTime endDate,
    String? performedBy,
    String? entityType,
    bool includeDetails = true,
  }) async {
    final entries = await queryAuditLog(
      startDate: startDate,
      endDate: endDate,
      performedBy: performedBy,
      entityType: entityType,
    );

    final report = AuditReport(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      totalEntries: entries.length,
      entries: includeDetails ? entries : null,
      summary: await _generateAuditSummary(entries),
    );

    // Save report to file
    return await _saveAuditReport(report);
  }

  // Integrity verification
  Future<AuditIntegrityReport> verifyIntegrity({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final entries = await queryAuditLog(startDate: startDate, endDate: endDate);
    final violations = <String>[];

    // Check for tampered entries
    for (final entry in entries) {
      final expectedChecksum = _calculateChecksum(
        entry.action,
        entry.performedBy,
        entry.entityId,
        entry.details,
      );

      if (entry.checksum != expectedChecksum) {
        violations.add('Entry ${entry.id} has been tampered with');
      }
    }

    // Check for missing sequence numbers
    final sequenceGaps = _checkSequenceGaps(entries);
    violations.addAll(sequenceGaps);

    // Check for suspicious patterns
    final suspiciousPatterns = await _detectSuspiciousPatterns(entries);
    violations.addAll(suspiciousPatterns);

    return AuditIntegrityReport(
      verifiedAt: DateTime.now(),
      totalEntries: entries.length,
      violations: violations,
      isIntegrityMaintained: violations.isEmpty,
      verificationDetails: {
        'sequence_check': sequenceGaps.isEmpty,
        'checksum_verification': !violations.any((v) => v.contains('tampered')),
        'pattern_analysis': suspiciousPatterns.isEmpty,
      },
    );
  }

  // Archive old entries
  Future<void> archiveOldEntries({
    required Duration retentionPeriod,
  }) async {
    final cutoffDate = DateTime.now().subtract(retentionPeriod);
    final oldEntries = _auditLog
        .where((entry) => entry.timestamp.isBefore(cutoffDate))
        .toList();

    if (oldEntries.isNotEmpty) {
      // Create archive
      final archive = AuditArchive(
        id: 'archive_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        entries: oldEntries,
        retentionPeriod: retentionPeriod,
        checksum: _calculateArchiveChecksum(oldEntries),
      );

      // Save archive
      await _saveAuditArchive(archive);

      // Remove from active log
      _auditLog.removeWhere((entry) => entry.timestamp.isBefore(cutoffDate));

      // Log archiving action
      await logEvent(
        action: 'AUDIT_ENTRIES_ARCHIVED',
        performedBy: 'SYSTEM',
        entityType: 'audit_archive',
        entityId: archive.id,
        details: {
          'archived_count': oldEntries.length,
          'retention_period_days': retentionPeriod.inDays,
        },
      );
    }
  }

  // Private helper methods

  String _generateAuditId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random =
        DateTime.now().microsecondsSinceEpoch.toString().substring(10);
    return 'AUDIT_${timestamp}_$random';
  }

  String _calculateChecksum(
    String action,
    String performedBy,
    String entityId,
    Map<String, dynamic>? details,
  ) {
    final data = '$action|$performedBy|$entityId|${json.encode(details ?? {})}';
    return sha256.convert(utf8.encode(data)).toString();
  }

  Future<void> _saveAuditEntry(AuditEntry entry) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final auditFile = File('${directory.path}/audit_log.jsonl');

      final entryJson = json.encode(entry.toJson()) + '\n';
      await auditFile.writeAsString(entryJson, mode: FileMode.append);
    } catch (e) {
      print('Failed to save audit entry: $e');
    }
  }

  Future<void> _loadAuditLog() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final auditFile = File('${directory.path}/audit_log.jsonl');

      if (await auditFile.exists()) {
        final lines = await auditFile.readAsLines();
        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            final entryJson = json.decode(line);
            _auditLog.add(AuditEntry.fromJson(entryJson));
          }
        }
      }
    } catch (e) {
      print('Failed to load audit log: $e');
    }
  }

  Future<void> _checkForSuspiciousActivity(AuditEntry entry) async {
    // Check for rapid successive actions
    final recentEntries = _auditLog
        .where((e) =>
            e.performedBy == entry.performedBy &&
            e.timestamp.isAfter(entry.timestamp.subtract(Duration(minutes: 5))))
        .toList();

    if (recentEntries.length > 10) {
      await logEvent(
        action: 'SUSPICIOUS_ACTIVITY_DETECTED',
        performedBy: 'SYSTEM',
        entityType: 'security',
        entityId: entry.performedBy,
        details: {
          'activity_type': 'rapid_actions',
          'action_count': recentEntries.length,
          'time_window_minutes': 5,
        },
        severity: AuditSeverity.warning,
      );
    }

    // Check for unusual hours
    final hour = entry.timestamp.hour;
    if (hour < 6 || hour > 22) {
      await logEvent(
        action: 'UNUSUAL_ACTIVITY_TIME',
        performedBy: 'SYSTEM',
        entityType: 'security',
        entityId: entry.performedBy,
        details: {
          'activity_hour': hour,
          'timestamp': entry.timestamp.toIso8601String(),
        },
        severity: AuditSeverity.info,
      );
    }
  }

  Future<void> _triggerAuditAlert(AuditEntry entry) async {
    // This would integrate with notification system
    print('Audit alert triggered for entry: ${entry.id}');
  }

  Future<void> _autoArchiveOldEntries() async {
    const retentionPeriod = Duration(days: 365); // 1 year retention
    await archiveOldEntries(retentionPeriod: retentionPeriod);
  }

  AuditSeverity _determineAnimalOperationSeverity(String operation) {
    switch (operation.toLowerCase()) {
      case 'delete':
      case 'euthanize':
        return AuditSeverity.critical;
      case 'treat':
      case 'vaccinate':
        return AuditSeverity.high;
      case 'update':
        return AuditSeverity.info;
      default:
        return AuditSeverity.info;
    }
  }

  bool _requiresTreatmentApproval(TreatmentRecord treatment) {
    // High-risk treatments require approval
    final highRiskDrugs = ['antibiotics', 'steroids', 'anesthetics'];
    return highRiskDrugs
        .any((drug) => treatment.drugName.toLowerCase().contains(drug));
  }

  Future<Map<String, dynamic>> _generateAuditSummary(
      List<AuditEntry> entries) async {
    final severityBreakdown = <String, int>{};
    final actionBreakdown = <String, int>{};
    final entityTypeBreakdown = <String, int>{};
    final userActivity = <String, int>{};
    final timeDistribution = <String, int>{};

    for (final entry in entries) {
      // Severity breakdown
      final severity = entry.severity.toString().split('.').last;
      severityBreakdown[severity] = (severityBreakdown[severity] ?? 0) + 1;

      // Action breakdown
      actionBreakdown[entry.action] = (actionBreakdown[entry.action] ?? 0) + 1;

      // Entity type breakdown
      entityTypeBreakdown[entry.entityType] =
          (entityTypeBreakdown[entry.entityType] ?? 0) + 1;

      // User activity
      userActivity[entry.performedBy] =
          (userActivity[entry.performedBy] ?? 0) + 1;

      // Time distribution
      final hour = entry.timestamp.hour;
      final timeSlot = '${hour ~/ 4 * 4}-${(hour ~/ 4 + 1) * 4}';
      timeDistribution[timeSlot] = (timeDistribution[timeSlot] ?? 0) + 1;
    }

    return {
      'total_entries': entries.length,
      'severity_breakdown': severityBreakdown,
      'action_breakdown': actionBreakdown,
      'entity_type_breakdown': entityTypeBreakdown,
      'user_activity': userActivity,
      'time_distribution': timeDistribution,
    };
  }

  Future<String> _saveAuditReport(AuditReport report) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'audit_report_${report.id}.json';
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(json.encode(report.toJson()));
    return file.path;
  }

  List<String> _checkSequenceGaps(List<AuditEntry> entries) {
    final violations = <String>[];
    // This would check for missing sequence numbers in a real implementation
    return violations;
  }

  Future<List<String>> _detectSuspiciousPatterns(
      List<AuditEntry> entries) async {
    final violations = <String>[];

    // Check for unusual login patterns
    final loginAttempts =
        entries.where((e) => e.action.contains('LOGIN')).toList();
    final failedLogins =
        loginAttempts.where((e) => e.details['success'] == false).toList();

    if (failedLogins.length > loginAttempts.length * 0.3) {
      violations.add('High rate of failed login attempts detected');
    }

    // Check for data export anomalies
    final exports = entries.where((e) => e.action == 'DATA_EXPORT').toList();
    final largeExports = exports.where((e) {
      final recordCount = (e.details['record_count'] as int?) ?? 0;
      return recordCount > 10000;
    }).toList();

    if (largeExports.isNotEmpty) {
      violations.add('Large data exports detected - verify legitimacy');
    }

    return violations;
  }

  String _calculateArchiveChecksum(List<AuditEntry> entries) {
    final data = entries.map((e) => e.checksum).join('|');
    return sha256.convert(utf8.encode(data)).toString();
  }

  Future<void> _saveAuditArchive(AuditArchive archive) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'audit_archive_${archive.id}.json';
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(json.encode(archive.toJson()));
  }
}

// Data Models

enum AuditSeverity {
  info,
  warning,
  high,
  critical,
}

enum ComplianceStatus {
  compliant,
  warning,
  nonCompliant,
}

class AuditEntry {
  final String id;
  final DateTime timestamp;
  final String action;
  final String performedBy;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> details;
  final AuditSeverity severity;
  final bool requiresApproval;
  final String checksum;

  AuditEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.performedBy,
    required this.entityType,
    required this.entityId,
    required this.details,
    required this.severity,
    required this.requiresApproval,
    required this.checksum,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'action': action,
        'performedBy': performedBy,
        'entityType': entityType,
        'entityId': entityId,
        'details': details,
        'severity': severity.toString(),
        'requiresApproval': requiresApproval,
        'checksum': checksum,
      };

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        action: json['action'],
        performedBy: json['performedBy'],
        entityType: json['entityType'],
        entityId: json['entityId'],
        details: json['details'] ?? {},
        severity: AuditSeverity.values.firstWhere(
          (e) => e.toString() == json['severity'],
          orElse: () => AuditSeverity.info,
        ),
        requiresApproval: json['requiresApproval'] ?? false,
        checksum: json['checksum'],
      );
}

class AuditReport {
  final String id;
  final DateTime generatedAt;
  final DateTime startDate;
  final DateTime endDate;
  final int totalEntries;
  final List<AuditEntry>? entries;
  final Map<String, dynamic> summary;

  AuditReport({
    required this.id,
    required this.generatedAt,
    required this.startDate,
    required this.endDate,
    required this.totalEntries,
    this.entries,
    required this.summary,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'generatedAt': generatedAt.toIso8601String(),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'totalEntries': totalEntries,
        'entries': entries?.map((e) => e.toJson()).toList(),
        'summary': summary,
      };
}

class AuditIntegrityReport {
  final DateTime verifiedAt;
  final int totalEntries;
  final List<String> violations;
  final bool isIntegrityMaintained;
  final Map<String, dynamic> verificationDetails;

  AuditIntegrityReport({
    required this.verifiedAt,
    required this.totalEntries,
    required this.violations,
    required this.isIntegrityMaintained,
    required this.verificationDetails,
  });
}

class AuditArchive {
  final String id;
  final DateTime createdAt;
  final List<AuditEntry> entries;
  final Duration retentionPeriod;
  final String checksum;

  AuditArchive({
    required this.id,
    required this.createdAt,
    required this.entries,
    required this.retentionPeriod,
    required this.checksum,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'entries': entries.map((e) => e.toJson()).toList(),
        'retentionPeriodDays': retentionPeriod.inDays,
        'checksum': checksum,
      };
}
