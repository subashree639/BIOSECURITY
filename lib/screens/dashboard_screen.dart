import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';
import '../models/farm.dart';
import '../models/assessment.dart';
import '../models/consultation.dart';
import '../services/animal_storage.dart';
import '../models/animal.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/offline_status_indicator.dart';
import '../widgets/emergency_quick_access.dart';
import '../widgets/quick_actions_dashboard.dart';
import 'login_screen.dart';
import 'risk_assessment_screen.dart';
import 'training_screen.dart';
import 'compliance_screen.dart';
import 'alert_screen.dart';
import 'health_monitoring_screen.dart';
import 'resource_library_screen.dart';
import 'farm_setup_screen.dart';
import 'farm_edit_screen.dart';
import 'veterinary_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Farm? _userFarm;
  Assessment? _lastAssessment;
  int _totalAnimals = 0;
  Map<String, int> _animalCounts = {};
  List<Map<String, dynamic>> _recentActivities = [];
  List<Consultation> _consultationHistory = [];
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.id;

    if (userId != null) {
      // Load user's farm
      final farms = await DatabaseHelper().getFarms();
      _userFarm = farms.firstWhere(
        (farm) => farm.createdBy == userId,
        orElse: () => Farm(
          ownerName: '',
          farmName: 'No Farm Setup',
          species: 'pig',
          size: 0,
          createdBy: userId,
        ),
      );

      // Load last assessment
      final assessments = await DatabaseHelper().getAssessments();
      if (assessments.isNotEmpty) {
        _lastAssessment = assessments
            .where((a) => a.farmId == _userFarm?.id)
            .fold<Assessment?>(null, (prev, curr) {
          if (prev == null || curr.createdAt.isAfter(prev.createdAt)) {
            return curr;
          }
          return prev;
        });
      }

      // Load animal counts
      final animalStorage = AnimalStorageService();
      _animalCounts = await animalStorage.getAnimalCountsByFarmer(userId.toString());
      _totalAnimals = _animalCounts.values.fold(0, (sum, count) => sum + count);

      // Load consultation history for farmer's animals
      final allAnimals = await animalStorage.getAllAnimals();
      final farmerAnimals = allAnimals.where((animal) => animal.farmerId == userId.toString()).toList();
      final animalIds = farmerAnimals.map((animal) => animal.id).toList();

      if (animalIds.isNotEmpty) {
        _consultationHistory = await DatabaseHelper().getConsultationsByAnimals(animalIds);
        // Sort by most recent first
        _consultationHistory.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
      }

      // Biosecurity-focused recent activities
      _recentActivities = [
        {
          'title': 'Biosecurity Assessment Completed',
          'subtitle': 'Farm scored 85% - Medium risk level',
          'time': '2 hours ago',
          'icon': Icons.assessment,
          'color': Colors.orange,
        },
        {
          'title': 'Vaccination Protocol Updated',
          'subtitle': 'Poultry vaccination schedule completed',
          'time': '1 day ago',
          'icon': Icons.medical_services,
          'color': Colors.green,
        },
        {
          'title': 'Disease Alert: Avian Influenza',
          'subtitle': 'Regional outbreak reported - 50km away',
          'time': '2 days ago',
          'icon': Icons.warning,
          'color': Colors.red,
        },
        {
          'title': 'Training Module Completed',
          'subtitle': 'Waste Management & Disinfection',
          'time': '3 days ago',
          'icon': Icons.school,
          'color': Colors.blue,
        },
        {
          'title': 'Compliance Check Passed',
          'subtitle': 'All regulatory requirements met',
          'time': '1 week ago',
          'icon': Icons.verified,
          'color': Colors.teal,
        },
      ];

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authService = Provider.of<AuthService>(context);
    final roleData = _getRoleData(authService.currentUser?.role ?? 'farmer');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade400.withOpacity(0.1),
              Colors.white,
              Colors.green.shade300.withOpacity(0.1),
              Colors.green.shade200.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating particles background
              _buildFloatingParticles(),

              // Main content
              Column(
                children: [
                  // App Bar
                  _buildPremiumAppBar(roleData),

                  // Dashboard Content
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadDashboardData,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Emergency Quick Access
                            if (authService.currentUser?.role == 'farmer' || authService.currentUser?.role == 'veterinarian')
                              FadeInDown(
                                duration: const Duration(milliseconds: 600),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const EmergencyQuickAccess(),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Header Section
                            FadeInUp(
                              duration: const Duration(milliseconds: 700),
                              child: _buildPremiumHeaderSection(roleData, authService),
                            ),

                            const SizedBox(height: 24),

                            // Quick Actions
                            FadeInUp(
                              duration: const Duration(milliseconds: 800),
                              child: const QuickActionsDashboard(),
                            ),

                            const SizedBox(height: 24),

                            // Farm Profile Section
                            if (_userFarm != null && _userFarm!.farmName != 'No Farm Setup')
                              FadeInUp(
                                duration: const Duration(milliseconds: 900),
                                child: _buildFarmProfileSection(roleData),
                              ),

                            const SizedBox(height: 24),

                            // Stats Section
                            FadeInUp(
                              duration: const Duration(milliseconds: 1000),
                              child: _buildStatsSection(roleData),
                            ),

                            const SizedBox(height: 24),

                            // Recent Activity
                            FadeInUp(
                              duration: const Duration(milliseconds: 1100),
                              child: _buildRecentActivitySection(),
                            ),

                            const SizedBox(height: 24),

                            // Consultation History (only for farmers)
                            if (authService.currentUser?.role == 'farmer' && _consultationHistory.isNotEmpty)
                              FadeInUp(
                                duration: const Duration(milliseconds: 1200),
                                child: _buildConsultationHistorySection(),
                              ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    // Handle navigation based on index
    switch (index) {
      case 0: // Home - already here
        break;
      case 1: // History - show veterinary consultation history
        _showHistoryScreen(context);
        break;
      case 2: // Assess
        _navigateToRiskAssessment(context);
        break;
      case 3: // Learn
        _navigateToTraining(context);
        break;
      case 4: // Alerts
        _navigateToAlerts(context);
        break;
      case 5: // More
        _showMoreMenu(context);
        break;
    }
  }

  void _showMoreMenu(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final role = authService.currentUser?.role ?? 'farmer';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'More Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildMoreMenuItem(
              context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () => Navigator.pop(context), // TODO: Navigate to settings
            ),
            _buildMoreMenuItem(
              context,
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () => Navigator.pop(context), // TODO: Navigate to help
            ),
            _buildMoreMenuItem(
              context,
              icon: Icons.backup,
              title: 'Backup & Restore',
              onTap: () => Navigator.pop(context), // TODO: Navigate to backup
            ),
            if (role == 'authority')
              _buildMoreMenuItem(
                context,
                icon: Icons.admin_panel_settings,
                title: 'Admin Panel',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to admin panel
                },
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreMenuItem(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
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

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      height: 120,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.grey.shade50.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFarmInfoCard(String title, List<String> details, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.grey.shade50.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...details.map((detail) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              detail,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPremiumActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.grey.shade50.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (activity['color'] as Color).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (activity['color'] as Color),
                  (activity['color'] as Color).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity['icon'],
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['subtitle'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              activity['time'],
              style: TextStyle(
                color: activity['color'],
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getRoleData(String role) {
    switch (role) {
      case 'farmer':
        return {
          'title': 'Farmer',
          'icon': Icons.agriculture,
          'color': const Color(0xFF4CAF50),
        };
      case 'veterinarian':
        return {
          'title': 'Veterinarian',
          'icon': Icons.local_hospital,
          'color': const Color(0xFF2196F3),
        };
      case 'extension_worker':
        return {
          'title': 'Extension Worker',
          'icon': Icons.people,
          'color': const Color(0xFFFF9800),
        };
      case 'authority':
        return {
          'title': 'Authority',
          'icon': Icons.security,
          'color': const Color(0xFF9C27B0),
        };
      default:
        return {
          'title': role,
          'icon': Icons.account_circle,
          'color': Theme.of(context).primaryColor,
        };
    }
  }

  List<String> _buildAnimalInfoList() {
    List<String> info = [];

    if (_animalCounts.isEmpty) {
      info.add('No animals registered');
      info.add('Add animals to track inventory');
    } else {
      info.add('Total: $_totalAnimals animals');

      // Show counts by species
      _animalCounts.forEach((species, count) {
        if (count > 0) {
          info.add('$species: $count');
        }
      });
    }

    return info;
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Floating Particles Background
  Widget _buildFloatingParticles() {
    return Positioned.fill(
      child: Stack(
        children: List.generate(15, (index) {
          return _buildFloatingParticle(index);
        }),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final colors = [
      Colors.green.shade200.withOpacity(0.3),
      Colors.green.shade300.withOpacity(0.25),
      Colors.blue.shade200.withOpacity(0.2),
      Colors.purple.shade200.withOpacity(0.2),
      Colors.orange.shade200.withOpacity(0.25),
    ];

    return AnimatedPositioned(
      duration: Duration(seconds: 10 + (index * 3)),
      curve: Curves.easeInOut,
      top: (index * 60.0) % (MediaQuery.of(context).size.height - 100),
      left: (index * 45.0) % (MediaQuery.of(context).size.width - 50),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✨ Premium Dashboard Experience!'),
              duration: const Duration(milliseconds: 1000),
              backgroundColor: Colors.green.shade700,
            ),
          );
        },
        child: AnimatedContainer(
          duration: Duration(seconds: 4 + (index % 3)),
          curve: Curves.easeInOut,
          width: 6 + (index % 5) * 3,
          height: 6 + (index % 5) * 3,
          decoration: BoxDecoration(
            color: colors[index % colors.length],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors[index % colors.length].withOpacity(0.6),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Premium Glassmorphism App Bar
  Widget _buildPremiumAppBar(Map<String, dynamic> roleData) {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (roleData['color'] as Color).withOpacity(0.95),
              (roleData['color'] as Color).withOpacity(0.85),
              (roleData['color'] as Color).withOpacity(0.75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: (roleData['color'] as Color).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row with icon and title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.dashboard,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Premium Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Advanced farm management system',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Bottom toolbar row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side - Role indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            roleData['icon'],
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            roleData['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right side - Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const OfflineStatusIndicator(),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.notifications, color: Colors.white, size: 18),
                            onPressed: () => _navigateToAlerts(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.white, size: 18),
                            onSelected: (value) => _handleMenuSelection(context, value),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'profile',
                                child: Row(
                                  children: [
                                    Icon(Icons.person, color: roleData['color']),
                                    const SizedBox(width: 10),
                                    const Text('Profile'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'settings',
                                child: Row(
                                  children: [
                                    Icon(Icons.settings, color: roleData['color']),
                                    const SizedBox(width: 10),
                                    const Text('Settings'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, color: roleData['color']),
                                    const SizedBox(width: 10),
                                    const Text('Logout'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Premium Header Section
  Widget _buildPremiumHeaderSection(Map<String, dynamic> roleData, AuthService authService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (roleData['color'] as Color).withOpacity(0.95),
            (roleData['color'] as Color).withOpacity(0.85),
            (roleData['color'] as Color).withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (roleData['color'] as Color).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Welcome message - centered
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  roleData['icon'],
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      authService.currentUser?.name ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Farm info - full width
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.agriculture,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _userFarm?.farmName ?? 'No Farm Configured',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Farmer ID (Phone Number) - for farmers
          if (authService.currentUser?.role == 'farmer')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: Colors.white.withOpacity(0.9),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Farmer ID: ${authService.currentUser?.mobileNumber ?? 'N/A'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Use this ID for veterinary consultations',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Farm Profile Section
  Widget _buildFarmProfileSection(Map<String, dynamic> roleData) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.8),
            Colors.grey.shade50.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade500,
                            Colors.green.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.business,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Farm Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (roleData['color'] as Color),
                            (roleData['color'] as Color).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton.icon(
                        onPressed: () => _editFarmProfile(context),
                        icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                        label: const Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      // Large screen - side by side
                      return Row(
                        children: [
                          Expanded(
                            child: _buildPremiumFarmInfoCard(
                              'Farm Details',
                              [
                                '🏢 Name: ${_userFarm!.farmName}',
                                '👤 Owner: ${_userFarm!.ownerName}',
                                '📍 Location: ${_userFarm!.locationText ?? "Not set"}',
                              ],
                              Icons.business,
                              roleData['color'],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildPremiumFarmInfoCard(
                              'Livestock Info',
                              _buildAnimalInfoList(),
                              Icons.pets,
                              Colors.teal,
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Small screen - stacked
                      return Column(
                        children: [
                          _buildPremiumFarmInfoCard(
                            'Farm Details',
                            [
                              '🏢 Name: ${_userFarm!.farmName}',
                              '👤 Owner: ${_userFarm!.ownerName}',
                              '📍 Location: ${_userFarm!.locationText ?? "Not set"}',
                            ],
                            Icons.business,
                            roleData['color'],
                          ),
                          const SizedBox(height: 16),
                          _buildPremiumFarmInfoCard(
                            'Livestock Info',
                            _buildAnimalInfoList(),
                            Icons.pets,
                            Colors.teal,
                          ),
                        ],
                      );
                    }
                  },
                ),
                if (_userFarm!.latitude != null && _userFarm!.longitude != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade50,
                          Colors.blue.shade100.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'GPS: ${_userFarm!.latitude!.toStringAsFixed(4)}, ${_userFarm!.longitude!.toStringAsFixed(4)}',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Stats Section
  Widget _buildStatsSection(Map<String, dynamic> roleData) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.grey.shade50.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade500, Colors.green.shade600],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Farm Analytics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final cardWidth = 100.0;
                final spacing = availableWidth > 600 ? 16.0 : 12.0;
                final cardsPerRow = ((availableWidth + spacing) / (cardWidth + spacing)).floor();
                final actualSpacing = cardsPerRow > 1 ? (availableWidth - (cardsPerRow * cardWidth)) / (cardsPerRow - 1) : 0.0;

                final statCards = [
                  _buildPremiumStatCard(
                    'Biosecurity Score',
                    _lastAssessment != null ? '85%' : 'Not Assessed',
                    Icons.security,
                    _getRiskColor(_lastAssessment?.riskLevel ?? 'Medium'),
                  ),
                  _buildPremiumStatCard(
                    'Compliance',
                    '98% Compliant',
                    Icons.verified_user,
                    Colors.green,
                  ),
                  _buildPremiumStatCard(
                    'Alerts',
                    '2 Active',
                    Icons.notifications_active,
                    Colors.orange,
                  ),
                  _buildPremiumStatCard(
                    'Health Check',
                    _lastAssessment != null
                        ? DateFormat('MMM dd').format(_lastAssessment!.createdAt)
                        : 'Pending',
                    Icons.monitor_heart,
                    roleData['color'],
                  ),
                  _buildPremiumStatCard(
                    'Training',
                    '7/10 Modules',
                    Icons.school,
                    Colors.blue,
                  ),
                  _buildPremiumStatCard(
                    'Animals',
                    _totalAnimals.toString(),
                    Icons.pets,
                    Colors.teal,
                  ),
                ];

                return Wrap(
                  spacing: actualSpacing > 0 ? actualSpacing : spacing,
                  runSpacing: availableWidth > 600 ? 16 : 12,
                  children: statCards,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Recent Activity Section
  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade500, Colors.purple.shade600],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.history,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ..._recentActivities.map((activity) => _buildPremiumActivityItem(activity)),
      ],
    );
  }

  // Consultation History Section
  Widget _buildConsultationHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade500, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Consultation History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showHistoryScreen(context),
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Show only the 3 most recent consultations
        ..._consultationHistory.take(3).map((consultation) => _buildConsultationHistoryItem(consultation)),
        if (_consultationHistory.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: TextButton.icon(
                onPressed: () => _showHistoryScreen(context),
                icon: const Icon(Icons.expand_more),
                label: Text('View ${_consultationHistory.length - 3} more consultations'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConsultationHistoryItem(Consultation consultation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.grey.shade50.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor(consultation.status),
                      _getStatusColor(consultation.status).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  consultation.species == 'pig' ? Icons.pets : Icons.egg,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consultation.animalName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Disease: ${consultation.disease}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(consultation.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  consultation.status,
                  style: TextStyle(
                    color: _getStatusColor(consultation.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                consultation.consultationDate,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.person,
                size: 14,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                'Dr. ${consultation.vetName}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (consultation.followUpDate.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.event,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  'Follow-up: ${consultation.followUpDate}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToRiskAssessment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RiskAssessmentScreen()),
    );
  }

  void _navigateToHealthMonitoring(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HealthMonitoringScreen()),
    );
  }

  void _navigateToTraining(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrainingScreen()),
    );
  }

  void _navigateToResources(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResourceLibraryScreen()),
    );
  }

  void _navigateToCompliance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ComplianceScreen()),
    );
  }

  void _navigateToRecords(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📝 Digital Record Keeping - Farm activity logs and compliance tracking')),
    );
  }

  void _navigateToAlerts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AlertScreen()),
    );
  }

  void _showHistoryScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VeterinaryHistoryScreen()),
    );
  }

  void _navigateToEmergency(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚑 Emergency Response - Outbreak protocols and emergency contacts')),
    );
  }

  void _editFarmProfile(BuildContext context) {
    if (_userFarm != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FarmEditScreen(farm: _userFarm!),
        ),
      ).then((_) {
        // Refresh dashboard data when returning from edit screen
        _loadDashboardData();
      });
    }
  }

  // Legacy methods for backward compatibility
  void _navigateToAssessment(BuildContext context) => _navigateToRiskAssessment(context);
  void _navigateToIncident(BuildContext context) => _navigateToRecords(context);
  void _navigateToReports(BuildContext context) => _navigateToCompliance(context);

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        // TODO: Navigate to Profile screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile - Coming Soon!')),
        );
        break;
      case 'settings':
        // TODO: Navigate to Settings screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings - Coming Soon!')),
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
              final userRole = authService.currentUser?.role ?? 'farmer';
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