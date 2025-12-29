import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class ComplianceScreen extends StatefulWidget {
  const ComplianceScreen({super.key});

  @override
  State<ComplianceScreen> createState() => _ComplianceScreenState();
}

class _ComplianceScreenState extends State<ComplianceScreen> {
  final List<Map<String, dynamic>> _complianceRequirements = [
    {
      'category': 'Physical Barriers',
      'requirements': [
        {'item': 'Perimeter fence', 'status': 'compliant', 'lastChecked': '2024-01-15'},
        {'item': 'Gate security', 'status': 'compliant', 'lastChecked': '2024-01-15'},
        {'item': 'Controlled entry points', 'status': 'partial', 'lastChecked': '2024-01-10'},
      ],
    },
    {
      'category': 'Visitor Management',
      'requirements': [
        {'item': 'Visitor log maintained', 'status': 'compliant', 'lastChecked': '2024-01-20'},
        {'item': 'Visitor biosecurity briefing', 'status': 'compliant', 'lastChecked': '2024-01-20'},
        {'item': 'Vehicle disinfection', 'status': 'non_compliant', 'lastChecked': '2024-01-05'},
      ],
    },
    {
      'category': 'Staff Training',
      'requirements': [
        {'item': 'Biosecurity training completed', 'status': 'compliant', 'lastChecked': '2024-01-12'},
        {'item': 'Annual refresher training', 'status': 'pending', 'lastChecked': null},
        {'item': 'Emergency response training', 'status': 'compliant', 'lastChecked': '2024-01-08'},
      ],
    },
    {
      'category': 'Cleaning & Disinfection',
      'requirements': [
        {'item': 'Daily cleaning schedule', 'status': 'compliant', 'lastChecked': '2024-01-20'},
        {'item': 'Disinfectant stock adequate', 'status': 'compliant', 'lastChecked': '2024-01-18'},
        {'item': 'Equipment sterilization', 'status': 'partial', 'lastChecked': '2024-01-15'},
      ],
    },
    {
      'category': 'Disease Monitoring',
      'requirements': [
        {'item': 'Daily health checks', 'status': 'compliant', 'lastChecked': '2024-01-20'},
        {'item': 'Mortality records', 'status': 'compliant', 'lastChecked': '2024-01-20'},
        {'item': 'Veterinary consultation', 'status': 'pending', 'lastChecked': null},
      ],
    },
    {
      'category': 'Record Keeping',
      'requirements': [
        {'item': 'Vaccination records', 'status': 'compliant', 'lastChecked': '2024-01-18'},
        {'item': 'Feed supplier records', 'status': 'compliant', 'lastChecked': '2024-01-16'},
        {'item': 'Chemical usage logs', 'status': 'partial', 'lastChecked': '2024-01-10'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final complianceStats = _calculateComplianceStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compliance Dashboard'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportComplianceReport(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compliance Overview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Overall Compliance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: (complianceStats['percentage'] ?? 0) / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${complianceStats['percentage']}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Compliant',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('${complianceStats['compliant']}', 'Compliant', Colors.green),
                      _buildStatItem('${complianceStats['partial']}', 'Partial', Colors.orange),
                      _buildStatItem('${complianceStats['nonCompliant']}', 'Issues', Colors.red),
                    ],
                  ),
                ],
              ),
            ),

            // Compliance Categories
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compliance Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._complianceRequirements.map((category) => _buildCategoryCard(category)),
                ],
              ),
            ),

            // Action Items
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Action Required',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildActionItem('Complete annual refresher training for all staff'),
                  _buildActionItem('Schedule veterinary consultation for health monitoring'),
                  _buildActionItem('Update vehicle disinfection protocols'),
                  _buildActionItem('Complete chemical usage log documentation'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final requirements = category['requirements'] as List<Map<String, dynamic>>;
    final categoryStats = _calculateCategoryStats(requirements);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(categoryStats).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(category['category']),
                color: _getCategoryColor(categoryStats),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['category'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${categoryStats['compliant']}/${requirements.length} compliant',
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
                color: _getCategoryColor(categoryStats).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getCategoryStatus(categoryStats),
                style: TextStyle(
                  color: _getCategoryColor(categoryStats),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        children: requirements.map<Widget>((req) => _buildRequirementItem(req)).toList(),
      ),
    );
  }

  Widget _buildRequirementItem(Map<String, dynamic> requirement) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStatusColor(requirement['status']),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requirement['item'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (requirement['lastChecked'] != null)
                  Text(
                    'Last checked: ${requirement['lastChecked']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _getStatusText(requirement['status']),
            style: TextStyle(
              color: _getStatusColor(requirement['status']),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.orange)),
          Expanded(
            child: Text(
              action,
              style: TextStyle(color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateComplianceStats() {
    int total = 0;
    int compliant = 0;
    int partial = 0;
    int nonCompliant = 0;

    for (var category in _complianceRequirements) {
      for (var req in category['requirements']) {
        total++;
        switch (req['status']) {
          case 'compliant':
            compliant++;
            break;
          case 'partial':
            partial++;
            break;
          case 'non_compliant':
          case 'pending':
            nonCompliant++;
            break;
        }
      }
    }

    return {
      'total': total,
      'compliant': compliant,
      'partial': partial,
      'nonCompliant': nonCompliant,
      'percentage': ((compliant / total) * 100).round(),
    };
  }

  Map<String, int> _calculateCategoryStats(List<Map<String, dynamic>> requirements) {
    int compliant = 0;
    int partial = 0;
    int nonCompliant = 0;

    for (var req in requirements) {
      switch (req['status']) {
        case 'compliant':
          compliant++;
          break;
        case 'partial':
          partial++;
          break;
        case 'non_compliant':
        case 'pending':
          nonCompliant++;
          break;
      }
    }

    return {
      'compliant': compliant,
      'partial': partial,
      'nonCompliant': nonCompliant,
    };
  }

  Color _getCategoryColor(Map<String, int> stats) {
    double score = stats['compliant']! / (stats['compliant']! + stats['partial']! + stats['nonCompliant']!);
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getCategoryStatus(Map<String, int> stats) {
    double score = stats['compliant']! / (stats['compliant']! + stats['partial']! + stats['nonCompliant']!);
    if (score >= 0.8) return 'GOOD';
    if (score >= 0.6) return 'FAIR';
    return 'NEEDS WORK';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'compliant':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'non_compliant':
      case 'pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'compliant':
        return '✓ Compliant';
      case 'partial':
        return '~ Partial';
      case 'non_compliant':
        return '✗ Issue';
      case 'pending':
        return '⏳ Pending';
      default:
        return status;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Physical Barriers':
        return Icons.fence;
      case 'Visitor Management':
        return Icons.people;
      case 'Staff Training':
        return Icons.school;
      case 'Cleaning & Disinfection':
        return Icons.cleaning_services;
      case 'Disease Monitoring':
        return Icons.monitor_heart;
      case 'Record Keeping':
        return Icons.folder;
      default:
        return Icons.checklist;
    }
  }

  void _exportComplianceReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compliance report exported successfully! 📄')),
    );
  }
}