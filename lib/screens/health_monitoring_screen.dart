import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';

class HealthMonitoringScreen extends StatefulWidget {
  const HealthMonitoringScreen({super.key});

  @override
  State<HealthMonitoringScreen> createState() => _HealthMonitoringScreenState();
}

class _HealthMonitoringScreenState extends State<HealthMonitoringScreen> {
  final List<Map<String, dynamic>> _healthRecords = [
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'daily_check',
      'status': 'normal',
      'notes': 'All animals appear healthy. No signs of illness.',
      'mortality': 0,
      'feedIntake': 'normal',
      'waterConsumption': 'normal',
      'behavior': 'normal',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'type': 'daily_check',
      'status': 'warning',
      'notes': 'Reduced feed intake observed in 3 poultry. Monitoring closely.',
      'mortality': 0,
      'feedIntake': 'reduced',
      'waterConsumption': 'normal',
      'behavior': 'lethargic',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'type': 'veterinary_visit',
      'status': 'normal',
      'notes': 'Routine veterinary checkup completed. All vaccinations up to date.',
      'mortality': 0,
      'feedIntake': 'normal',
      'waterConsumption': 'normal',
      'behavior': 'normal',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'type': 'mortality_incident',
      'status': 'critical',
      'notes': '2 poultry deaths reported. Cause under investigation. Isolation protocols activated.',
      'mortality': 2,
      'feedIntake': 'normal',
      'waterConsumption': 'normal',
      'behavior': 'normal',
    },
  ];

  final Map<String, dynamic> _currentHealthMetrics = {
    'totalAnimals': 500,
    'healthyAnimals': 495,
    'sickAnimals': 3,
    'mortalityRate': 0.4,
    'feedEfficiency': 92.5,
    'waterQuality': 'good',
    'temperature': 28.5,
    'humidity': 65.0,
  };

  @override
  Widget build(BuildContext context) {
    final healthScore = _calculateHealthScore();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Health Monitoring'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddHealthRecordDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Overview Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Overall Farm Health',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildHealthMetric('Healthy', '${_currentHealthMetrics['healthyAnimals']}', Colors.white),
                      _buildHealthMetric('Sick', '${_currentHealthMetrics['sickAnimals']}', Colors.orange.shade200),
                      _buildHealthMetric('Mortality Rate', '${_currentHealthMetrics['mortalityRate']}%', Colors.red.shade200),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Health Score: ${healthScore.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Current Metrics Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMetricCard('Feed Efficiency', '${_currentHealthMetrics['feedEfficiency']}%', Icons.restaurant, Colors.blue),
                  _buildMetricCard('Water Quality', _currentHealthMetrics['waterQuality'], Icons.water_drop, Colors.cyan),
                  _buildMetricCard('Temperature', '${_currentHealthMetrics['temperature']}°C', Icons.thermostat, Colors.orange),
                  _buildMetricCard('Humidity', '${_currentHealthMetrics['humidity']}%', Icons.opacity, Colors.teal),
                ],
              ),
            ),

            // Health Records
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Health Records',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._healthRecords.map((record) => _buildHealthRecordCard(record)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRecordCard(Map<String, dynamic> record) {
    final statusColor = _getStatusColor(record['status']);
    final statusIcon = _getStatusIcon(record['status']);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getRecordTypeName(record['type']),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(record['date']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record['status'].toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (record['mortality'] > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Mortality: ${record['mortality']} animal(s)',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              record['notes'],
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _buildIndicator('Feed', record['feedIntake']),
                _buildIndicator('Water', record['waterConsumption']),
                _buildIndicator('Behavior', record['behavior']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(String label, String status) {
    final color = _getIndicatorColor(status);
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'normal':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'normal':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'critical':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getIndicatorColor(String status) {
    switch (status) {
      case 'normal':
        return Colors.green;
      case 'reduced':
      case 'lethargic':
        return Colors.orange;
      case 'poor':
      case 'abnormal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getRecordTypeName(String type) {
    switch (type) {
      case 'daily_check':
        return 'Daily Health Check';
      case 'veterinary_visit':
        return 'Veterinary Visit';
      case 'mortality_incident':
        return 'Mortality Incident';
      default:
        return type;
    }
  }

  double _calculateHealthScore() {
    final healthy = _currentHealthMetrics['healthyAnimals'];
    final total = _currentHealthMetrics['totalAnimals'];
    final mortalityRate = _currentHealthMetrics['mortalityRate'];
    final feedEfficiency = _currentHealthMetrics['feedEfficiency'];

    // Calculate weighted score
    double score = (healthy / total) * 100; // Health percentage
    score -= mortalityRate * 10; // Penalize mortality
    score += (feedEfficiency - 80) * 0.5; // Bonus for good feed efficiency

    return score.clamp(0, 100);
  }

  void _showAddHealthRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Health Record'),
        content: const Text('Health record entry form would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Health record added successfully!')),
              );
            },
            child: const Text('Add Record'),
          ),
        ],
      ),
    );
  }
}