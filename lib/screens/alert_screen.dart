import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _alerts = [
    {
      'id': 1,
      'type': 'disease_outbreak',
      'title': 'Avian Influenza Alert',
      'message': 'H5N1 avian influenza detected in poultry farms within 50km radius. Implement immediate biosecurity measures.',
      'severity': 'critical',
      'location': 'District A, 45km away',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'acknowledged': false,
      'actions': ['Quarantine affected areas', 'Increase surveillance', 'Contact veterinarian'],
    },
    {
      'id': 2,
      'type': 'health_monitoring',
      'title': 'Abnormal Mortality Rate',
      'message': 'Mortality rate increased by 15% in the last 24 hours. Immediate investigation required.',
      'severity': 'high',
      'location': 'Your Farm',
      'date': DateTime.now().subtract(const Duration(hours: 6)),
      'acknowledged': false,
      'actions': ['Check water quality', 'Inspect feed', 'Isolate sick animals'],
    },
    {
      'id': 3,
      'type': 'compliance_reminder',
      'title': 'Vaccination Due',
      'message': 'Routine vaccination schedule is due for completion within 7 days.',
      'severity': 'medium',
      'location': 'Your Farm',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'acknowledged': true,
      'actions': ['Schedule vaccination', 'Prepare vaccine inventory'],
    },
    {
      'id': 4,
      'type': 'weather_alert',
      'title': 'Heavy Rainfall Warning',
      'message': 'Heavy rainfall expected. Ensure proper drainage and monitor for water contamination.',
      'severity': 'medium',
      'location': 'Regional',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'acknowledged': true,
      'actions': ['Check drainage systems', 'Monitor water sources'],
    },
    {
      'id': 5,
      'type': 'market_update',
      'title': 'Price Volatility Alert',
      'message': 'Feed prices increased by 12% in the last week. Consider bulk purchasing.',
      'severity': 'low',
      'location': 'Market',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'acknowledged': false,
      'actions': ['Review feed inventory', 'Contact suppliers'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unacknowledgedCount = _alerts.where((alert) => !alert['acknowledged']).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Alerts & Monitoring'),
        backgroundColor: Colors.red,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All (${_alerts.length})'),
            Tab(text: 'Active ($unacknowledgedCount)'),
            Tab(text: 'Archived'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlertList(_alerts),
          _buildAlertList(_alerts.where((alert) => !alert['acknowledged']).toList()),
          _buildAlertList(_alerts.where((alert) => alert['acknowledged']).toList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmergencyContacts(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.emergency),
        tooltip: 'Emergency Contacts',
      ),
    );
  }

  Widget _buildAlertList(List<Map<String, dynamic>> alerts) {
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No alerts found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final severityColor = _getSeverityColor(alert['severity']);
    final severityIcon = _getSeverityIcon(alert['severity']);
    final timeAgo = _getTimeAgo(alert['date']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: alert['acknowledged'] ? 1 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alert['acknowledged'] ? Colors.transparent : severityColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showAlertDetails(context, alert),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with severity and time
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      severityIcon,
                      color: severityColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: alert['acknowledged'] ? Colors.grey[600] : Colors.black87,
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!alert['acknowledged'])
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: severityColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        alert['severity'].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    alert['location'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Message preview
              Text(
                alert['message'],
                style: TextStyle(
                  fontSize: 14,
                  color: alert['acknowledged'] ? Colors.grey[500] : Colors.black87,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Actions
              if (!alert['acknowledged'])
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _acknowledgeAlert(alert['id']),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: severityColor),
                        ),
                        child: Text(
                          'Acknowledge',
                          style: TextStyle(color: severityColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _takeAction(context, alert),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: severityColor,
                        ),
                        child: const Text('Take Action'),
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

  void _showAlertDetails(BuildContext context, Map<String, dynamic> alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final severityColor = _getSeverityColor(alert['severity']);

        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSeverityIcon(alert['severity']),
                      color: severityColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy • hh:mm a').format(alert['date']),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Location and severity
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    alert['location'],
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      alert['severity'].toUpperCase(),
                      style: TextStyle(
                        color: severityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Full message
              Text(
                alert['message'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Recommended actions
              if (alert['actions'] != null && alert['actions'].isNotEmpty) ...[
                const Text(
                  'Recommended Actions:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...alert['actions'].map<Widget>((action) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: severityColor)),
                        Expanded(
                          child: Text(
                            action,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 24),

              // Action buttons
              if (!alert['acknowledged'])
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _acknowledgeAlert(alert['id']);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: severityColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Acknowledge Alert',
                          style: TextStyle(color: severityColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _takeAction(context, alert);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: severityColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Take Action'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  void _acknowledgeAlert(int alertId) {
    setState(() {
      final alert = _alerts.firstWhere((a) => a['id'] == alertId);
      alert['acknowledged'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert acknowledged')),
    );
  }

  void _takeAction(BuildContext context, Map<String, dynamic> alert) {
    // Navigate to appropriate screen based on alert type
    switch (alert['type']) {
      case 'disease_outbreak':
        // Navigate to emergency response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening Emergency Response Protocol...')),
        );
        break;
      case 'health_monitoring':
        // Navigate to health monitoring
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening Health Monitoring...')),
        );
        break;
      case 'compliance_reminder':
        // Navigate to compliance
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening Compliance Tracker...')),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action taken for alert')),
        );
    }
  }

  void _showEmergencyContacts(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildEmergencyContact('Veterinary Emergency', '+91-1800-VET-HELP', Icons.local_hospital),
            _buildEmergencyContact('Disease Control Authority', '+91-1800-DISEASE', Icons.security),
            _buildEmergencyContact('Farm Support Hotline', '+91-1800-FARM-HELP', Icons.support_agent),
            _buildEmergencyContact('Local Police', '100', Icons.local_police),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContact(String title, String number, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.red),
      ),
      title: Text(title),
      subtitle: Text(number),
      trailing: IconButton(
        icon: const Icon(Icons.call, color: Colors.green),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Calling $number...')),
          );
        },
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow[700]!;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'critical':
        return Icons.error;
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.notifications;
      default:
        return Icons.notifications_none;
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}