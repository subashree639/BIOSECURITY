import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';
import '../models/farm.dart';
import '../models/assessment.dart';
import 'login_screen.dart';
import 'compliance_screen.dart';
import 'alert_screen.dart';
import 'training_screen.dart';

class AuthorityDashboardScreen extends StatefulWidget {
  const AuthorityDashboardScreen({super.key});

  @override
  State<AuthorityDashboardScreen> createState() => _AuthorityDashboardScreenState();
}

class _AuthorityDashboardScreenState extends State<AuthorityDashboardScreen> {
  List<Farm> _allFarms = [];
  List<Assessment> _allAssessments = [];
  int _totalFarms = 0;
  int _compliantFarms = 0;
  int _nonCompliantFarms = 0;
  int _activeAlerts = 0;
  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final farms = await DatabaseHelper().getFarms();
    final assessments = await DatabaseHelper().getAssessments();

    setState(() {
      _allFarms = farms;
      _allAssessments = assessments;
      _totalFarms = farms.length;
      _compliantFarms = assessments.where((a) => a.riskLevel.toLowerCase() == 'low').length;
      _nonCompliantFarms = assessments.where((a) => a.riskLevel.toLowerCase() == 'high').length;
      _activeAlerts = 12; // Mock data - would come from alerts table

      // Mock recent activities for authority
      _recentActivities = [
        {
          'title': 'Regulatory Inspection Completed',
          'subtitle': 'Farm #789 - Full compliance verified',
          'time': '1 hour ago',
          'icon': Icons.verified,
          'color': Colors.green,
        },
        {
          'title': 'Outbreak Containment Order',
          'subtitle': 'Issued quarantine for affected farms',
          'time': '3 hours ago',
          'icon': Icons.warning,
          'color': Colors.red,
        },
        {
          'title': 'Policy Update Released',
          'subtitle': 'New biosecurity guidelines published',
          'time': '1 day ago',
          'icon': Icons.policy,
          'color': Colors.blue,
        },
        {
          'title': 'License Renewal Processed',
          'subtitle': '25 veterinary licenses renewed',
          'time': '2 days ago',
          'icon': Icons.badge,
          'color': Colors.orange,
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0), // Purple for authority
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.security, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Authority Dashboard',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => _navigateToAlerts(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuSelection(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: const Color(0xFF9C27B0)),
                    const SizedBox(width: 10),
                    const Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: const Color(0xFF9C27B0)),
                    const SizedBox(width: 10),
                    const Text('Settings'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: const Color(0xFF9C27B0)),
                    const SizedBox(width: 10),
                    const Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF9C27B0),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.security,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                authService.currentUser?.name ?? 'Authority',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_user,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Regulatory Authority & Oversight',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Regulatory Oversight Hub
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Regulatory Oversight Hub',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Compliance & Monitoring Section
                    _buildSectionHeader('Compliance & Monitoring', Icons.verified, Colors.green),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            'Compliance Audits',
                            'Conduct regulatory inspections',
                            Icons.search,
                            Colors.green,
                            () => _navigateToComplianceAudits(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFeatureCard(
                            'License Management',
                            'Issue and renew licenses',
                            Icons.badge,
                            Colors.blue,
                            () => _navigateToLicenses(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Emergency Response Section
                    _buildSectionHeader('Emergency Response & Policy', Icons.warning, Colors.red),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            'Outbreak Management',
                            'Coordinate emergency responses',
                            Icons.emergency,
                            Colors.red,
                            () => _navigateToAlerts(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFeatureCard(
                            'Policy Updates',
                            'Publish regulatory guidelines',
                            Icons.policy,
                            Colors.orange,
                            () => _navigateToPolicies(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Training & Education Section
                    _buildSectionHeader('Training & Capacity Building', Icons.school, Colors.teal),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            'Professional Training',
                            'Certify veterinarians & workers',
                            Icons.group,
                            Colors.teal,
                            () => _navigateToTraining(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFeatureCard(
                            'System Administration',
                            'Manage platform settings',
                            Icons.admin_panel_settings,
                            Colors.purple,
                            () => _navigateToAdmin(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Regulatory Oversight Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Farms',
                            _totalFarms.toString(),
                            Icons.business,
                            const Color(0xFF9C27B0),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            'Compliant Farms',
                            _compliantFarms.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            'Non-Compliant',
                            _nonCompliantFarms.toString(),
                            Icons.error,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Active Alerts',
                            _activeAlerts.toString(),
                            Icons.notifications_active,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            'Licenses Issued',
                            '156',
                            Icons.badge,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            'Inspections',
                            '89',
                            Icons.search,
                            Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Recent Activity
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Regulatory Activities',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 15),
                    ..._recentActivities.map((activity) => _buildActivityItem(activity)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activity['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity['icon'],
              color: activity['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity['subtitle'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'],
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToComplianceAudits(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ComplianceScreen()),
    );
  }

  void _navigateToLicenses(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📋 License Management - Issue and renew veterinary licenses')),
    );
  }

  void _navigateToAlerts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AlertScreen()),
    );
  }

  void _navigateToPolicies(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📄 Policy Updates - Publish regulatory guidelines and updates')),
    );
  }

  void _navigateToTraining(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrainingScreen()),
    );
  }

  void _navigateToAdmin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚙️ System Administration - Manage platform settings and users')),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authority Profile - Coming Soon!')),
        );
        break;
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authority Settings - Coming Soon!')),
        );
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final authService = Provider.of<AuthService>(context, listen: false);
              final userRole = authService.currentUser?.role ?? 'authority';
              authService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginScreen(role: userRole)),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}