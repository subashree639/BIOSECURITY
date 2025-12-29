import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';
import '../models/farm.dart';
import 'login_screen.dart';
import 'training_screen.dart';
import 'compliance_screen.dart';
import 'alert_screen.dart';

class ExtensionWorkerDashboardScreen extends StatefulWidget {
  const ExtensionWorkerDashboardScreen({super.key});

  @override
  State<ExtensionWorkerDashboardScreen> createState() => _ExtensionWorkerDashboardScreenState();
}

class _ExtensionWorkerDashboardScreenState extends State<ExtensionWorkerDashboardScreen> {
  List<Farm> _assignedFarms = [];
  int _totalFarmers = 0;
  int _trainingSessions = 0;
  int _complianceChecks = 0;
  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final farms = await DatabaseHelper().getFarms();

    setState(() {
      _assignedFarms = farms; // Mock - in real app would filter by assigned extension worker
      _totalFarmers = farms.length;
      _trainingSessions = 15; // Mock data
      _complianceChecks = 8; // Mock data

      // Mock recent activities for extension worker
      _recentActivities = [
        {
          'title': 'Training Session Completed',
          'subtitle': 'Biosecurity basics - 25 farmers attended',
          'time': '2 hours ago',
          'icon': Icons.school,
          'color': Colors.blue,
        },
        {
          'title': 'Farm Visit Scheduled',
          'subtitle': 'Farm #456 - Compliance assessment',
          'time': '4 hours ago',
          'icon': Icons.calendar_today,
          'color': Colors.green,
        },
        {
          'title': 'Resource Distribution',
          'subtitle': 'Delivered vaccination guides to 10 farms',
          'time': '1 day ago',
          'icon': Icons.inventory,
          'color': Colors.orange,
        },
        {
          'title': 'Farmer Support Call',
          'subtitle': 'Assisted with disease reporting protocol',
          'time': '2 days ago',
          'icon': Icons.support_agent,
          'color': Colors.teal,
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
        backgroundColor: const Color(0xFFFF9800), // Orange for extension worker
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.people, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Extension Worker Dashboard',
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
                    Icon(Icons.person, color: const Color(0xFFFF9800)),
                    const SizedBox(width: 10),
                    const Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: const Color(0xFFFF9800)),
                    const SizedBox(width: 10),
                    const Text('Settings'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: const Color(0xFFFF9800)),
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
                  color: Color(0xFFFF9800),
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
                            Icons.people,
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
                                authService.currentUser?.name ?? 'Extension Worker',
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
                            Icons.support_agent,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Field Support & Education Specialist',
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

              // Extension Services Hub
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extension Services Hub',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Training & Education Section
                    _buildSectionHeader('Training & Education', Icons.school, Colors.blue),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            'Conduct Training',
                            'Lead farmer education sessions',
                            Icons.group,
                            Colors.blue,
                            () => _navigateToTraining(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFeatureCard(
                            'Resource Distribution',
                            'Provide educational materials',
                            Icons.inventory,
                            Colors.teal,
                            () => _navigateToResources(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Farm Support Section
                    _buildSectionHeader('Farm Support & Monitoring', Icons.business, Colors.green),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            'Farm Visits',
                            'Schedule and conduct farm assessments',
                            Icons.calendar_today,
                            Colors.green,
                            () => _navigateToFarmVisits(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFeatureCard(
                            'Compliance Monitoring',
                            'Track farmer compliance',
                            Icons.checklist,
                            Colors.orange,
                            () => _navigateToCompliance(context),
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
                      'Extension Work Summary',
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
                            'Farmers Supported',
                            _totalFarmers.toString(),
                            Icons.people,
                            const Color(0xFFFF9800),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            'Training Sessions',
                            _trainingSessions.toString(),
                            Icons.school,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            'Compliance Checks',
                            _complianceChecks.toString(),
                            Icons.verified,
                            Colors.green,
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
                      'Recent Extension Activities',
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

  void _navigateToTraining(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrainingScreen()),
    );
  }

  void _navigateToResources(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📚 Resource Distribution - Educational materials and guides')),
    );
  }

  void _navigateToFarmVisits(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🏭 Farm Visits - Schedule and conduct farm assessments')),
    );
  }

  void _navigateToCompliance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ComplianceScreen()),
    );
  }

  void _navigateToAlerts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AlertScreen()),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Extension Worker Profile - Coming Soon!')),
        );
        break;
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Extension Worker Settings - Coming Soon!')),
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
              final userRole = authService.currentUser?.role ?? 'extension_worker';
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