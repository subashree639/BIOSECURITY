import 'package:flutter/material.dart';
import '../services/alert_service.dart';
import '../services/animal_storage.dart';
import '../services/firestore_service.dart';
import '../models/firestore_models.dart' as firestore;
import '../l10n/app_localizations.dart';

class AlertsDashboard extends StatefulWidget {
  const AlertsDashboard({Key? key}) : super(key: key);

  @override
  _AlertsDashboardState createState() => _AlertsDashboardState();
}

class _AlertsDashboardState extends State<AlertsDashboard> {
  final AlertService _alertService = AlertService();
  final AnimalStorageService _storage = AnimalStorageService();
  final FirestoreService _firestoreService = FirestoreService();
  List<firestore.Alert> _firestoreAlerts = [];
  List<Alert> _localAlerts = [];
  bool _loading = true;
  String _filterType = 'all';
  String _filterPriority = 'all'; // low, medium, high

  @override
  void initState() {
    super.initState();
    _loadAlerts();
    _listenToAlertStreams();
  }

  void _listenToAlertStreams() {
    // Listen to local alerts
    _alertService.alertStream.listen((alert) {
      _loadAlerts();
    });

    // Listen to Firestore alerts in real-time
    _firestoreService.getAlertsStream().listen((firestoreAlerts) {
      setState(() {
        _firestoreAlerts = firestoreAlerts;
      });
    });
  }

  Future<void> _loadAlerts() async {
    setState(() => _loading = true);

    // Load both local and Firestore alerts
    final localAlerts = _alertService.getActiveAlerts();
    final firestoreAlerts = await _firestoreService.getAlerts();

    setState(() {
      _localAlerts = localAlerts;
      _firestoreAlerts = firestoreAlerts;
      _loading = false;
    });
  }

  List<dynamic> get _filteredAlerts {
    // Combine both local and Firestore alerts
    final allAlerts = [..._localAlerts, ..._firestoreAlerts];

    return allAlerts.where((alert) {
      if (_filterType != 'all') {
        if (alert is Alert && alert.type != _filterType) return false;
        if (alert is firestore.Alert && alert.type != _filterType) return false;
      }
      if (_filterPriority != 'all') {
        if (alert is firestore.Alert && alert.priority != _filterPriority)
          return false;
        // Local alerts don't have priority, so they pass through
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.complianceAlerts),
        backgroundColor: Colors.red.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAlerts,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(),
                _buildStatistics(),
                Expanded(
                  child: _buildAlertsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _filterType,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'all',
                        child:
                            Text('All Types', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'Warning',
                        child:
                            Text('Warning', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'Critical',
                        child:
                            Text('Critical', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'Info',
                        child: Text('Info', overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (value) =>
                      setState(() => _filterType = value ?? 'all'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: _filterPriority,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'all',
                        child: Text('All Priorities',
                            overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'low',
                        child: Text('Low', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'medium',
                        child: Text('Medium', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'high',
                        child: Text('High', overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (value) =>
                      setState(() => _filterPriority = value ?? 'all'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final localStats = _alertService.getAlertStatistics();
    final totalAlerts = _localAlerts.length + _firestoreAlerts.length;
    final unreadFirestore = _firestoreAlerts.where((a) => !a.isRead).length;
    final unreadLocal = localStats['unread_alerts'] as int;
    final totalUnread = unreadLocal + unreadFirestore;
    final criticalCount = _firestoreAlerts
            .where((a) => a.priority == 'high')
            .length +
        _localAlerts.where((a) => a.severity == AlertSeverity.critical).length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Alerts',
              totalAlerts.toString(),
              Icons.notifications,
              Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Unread',
              totalUnread.toString(),
              Icons.notifications_active,
              totalUnread > 0 ? Colors.red : Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'High Priority',
              criticalCount.toString(),
              Icons.dangerous,
              Colors.red.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsList() {
    final filteredAlerts = _filteredAlerts;

    if (filteredAlerts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off,
                size: 72,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.noAlertsFound,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.allComplianceChecksPassing,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredAlerts.length,
      itemBuilder: (context, index) {
        final alert = filteredAlerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildAlertCard(dynamic alert) {
    // Handle both local Alert and Firestore Alert types
    late String title;
    late String message;
    late String time;
    late String location;
    late String iconClass;
    late DateTime timestamp;
    late bool isRead;
    late Color borderColor;
    late Color backgroundColor;
    late IconData icon;
    late String priorityText;

    if (alert is firestore.Alert) {
      title = '${alert.type}: ${alert.message.split(' ').take(3).join(' ')}...';
      message = alert.message;
      time = alert.time;
      location = alert.location;
      iconClass = alert.icon;
      timestamp = alert.timestamp;
      isRead = alert.isRead;
      priorityText = alert.priority;

      // Set colors based on priority
      switch (alert.priority) {
        case 'high':
          borderColor = Colors.red;
          backgroundColor = Colors.red.shade50;
          icon = Icons.error;
          break;
        case 'medium':
          borderColor = Colors.orange;
          backgroundColor = Colors.orange.shade50;
          icon = Icons.warning;
          break;
        default:
          borderColor = Colors.blue;
          backgroundColor = Colors.blue.shade50;
          icon = Icons.info;
      }
    } else if (alert is Alert) {
      title = alert.title;
      message = alert.message;
      time = _formatTimestamp(alert.timestamp);
      location = 'Local System';
      iconClass = 'local';
      timestamp = alert.timestamp;
      isRead = alert.isRead;
      priorityText = alert.severity.displayName(context);

      borderColor = alert.severity.color;
      backgroundColor = alert.severity.color.withOpacity(0.1);
      icon = alert.severity.icon;
    } else {
      return SizedBox.shrink(); // Unknown alert type
    }

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: backgroundColor,
                    radius: 20,
                    child: Icon(
                      icon,
                      color: borderColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Location: $location',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      priorityText,
                      style: TextStyle(
                        color: borderColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: 6),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                  if (!isRead) ...[
                    SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  Spacer(),
                  TextButton.icon(
                    onPressed: () => _markAlertAsRead(alert),
                    icon: Icon(
                      isRead ? Icons.visibility : Icons.visibility_off,
                      size: 16,
                    ),
                    label: Text(isRead ? 'Read' : 'Mark as Read',
                        style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      minimumSize: Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _dismissAlert(alert),
                    icon: Icon(Icons.close, size: 16),
                    label: Text('Dismiss', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      minimumSize: Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return AppLocalizations.of(context)!.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return AppLocalizations.of(context)!.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return AppLocalizations.of(context)!.minutesAgo(difference.inMinutes);
    } else {
      return AppLocalizations.of(context)!.justNow;
    }
  }

  void _markAlertAsRead(dynamic alert) {
    if (alert is Alert) {
      _alertService.markAlertAsRead(alert.id);
      setState(() {
        alert.isRead = true;
      });
    } else if (alert is firestore.Alert) {
      // For Firestore alerts, we would need to update the document
      // For now, just refresh the data
      _loadAlerts();
    }
  }

  void _dismissAlert(dynamic alert) {
    if (alert is Alert) {
      _alertService.dismissAlert(alert.id);
    } else if (alert is firestore.Alert) {
      // For Firestore alerts, we would need to delete or mark as dismissed
      // For now, just refresh the data
    }
    _loadAlerts();
  }
}
