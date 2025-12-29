import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart'; // Import for global auth and otpService instances
import '../models/animal.dart';
import '../models/firestore_models.dart' as firestore;
import '../services/animal_storage.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';
import '../services/image_analysis_service.dart';
import 'consult_animals_page.dart';
import 'vet_consult_form.dart';
import 'voice_login_page.dart';

//
// Vet Dashboard (shows Vet ID in header and consultation count)
//
class VetDashboardPage extends StatefulWidget {
  const VetDashboardPage({super.key});
  @override
  _VetDashboardPageState createState() => _VetDashboardPageState();
}

class _VetDashboardPageState extends State<VetDashboardPage>
    with TickerProviderStateMixin {
  final AnimalStorageService _storage = AnimalStorageService();
  final AIService _aiService = AIService();
  final ImageAnalysisService _imageAnalysisService = ImageAnalysisService();
  final FirestoreService _firestoreService = FirestoreService();
  List<Animal> _animals = [];
  bool _loading = true;
  String? _vetId;

  // Firestore data
  List<firestore.Prescription> _prescriptionsData = [];
  List<firestore.Livestock> _livestockData = [];
  firestore.KPIs? _kpisData;

  // New features state
  bool _emergencyMode = false;
  late AnimationController _emergencyController;
  late Animation<double> _emergencyAnimation;

  // AI Features
  bool _aiLoading = false;
  List<Map<String, dynamic>> _aiInsights = [];

  // Analytics data
  int _todayConsultations = 0;
  int _weekConsultations = 0;
  int _monthConsultations = 0;
  Map<String, int> _medicineUsage = {};
  List<String> _recentFarmers = [];

  // Dosage calculator
  final _animalWeightController = TextEditingController();
  final _medicineDoseController = TextEditingController();
  String _selectedMedicine = '';
  double _calculatedDose = 0.0;

  // Prescription templates
  final List<Map<String, dynamic>> _prescriptionTemplates = [
    {
      'name': 'Antibiotic Treatment',
      'medicine': 'Amoxicillin',
      'dosage': '10 mg/kg',
      'duration': '5 days',
      'withdrawal': '7 days'
    },
    {
      'name': 'Anti-inflammatory',
      'medicine': 'Meloxicam',
      'dosage': '0.5 mg/kg',
      'duration': '3 days',
      'withdrawal': '5 days'
    },
    {
      'name': 'Deworming',
      'medicine': 'Albendazole',
      'dosage': '7.5 mg/kg',
      'duration': '1 day',
      'withdrawal': '14 days'
    },
    {
      'name': 'Pain Relief',
      'medicine': 'Ceftiofur',
      'dosage': '1.1 mg/kg',
      'duration': '3-5 days',
      'withdrawal': '4 days'
    },
    {
      'name': 'Respiratory Treatment',
      'medicine': 'Florfenicol',
      'dosage': '20 mg/kg',
      'duration': '3 days',
      'withdrawal': '28 days'
    },
    {
      'name': 'Antibiotic Injection',
      'medicine': 'Enrofloxacin',
      'dosage': '2.5 mg/kg',
      'duration': '3-5 days',
      'withdrawal': '14 days'
    },
    {
      'name': 'Respiratory Antibiotic',
      'medicine': 'Tilmicosin',
      'dosage': '10 mg/kg',
      'duration': '3 days',
      'withdrawal': '42 days'
    },
    {
      'name': 'Long-acting Antibiotic',
      'medicine': 'Tulathromycin',
      'dosage': '2.5 mg/kg',
      'duration': 'Single dose',
      'withdrawal': '18 days'
    },
    {
      'name': 'Mastitis Treatment',
      'medicine': 'Procaine penicillin',
      'dosage': '7 mg/kg',
      'duration': '2-3 days',
      'withdrawal': '10 days'
    },
    {
      'name': 'Metabolic Support',
      'medicine': 'Vitamin B Complex',
      'dosage': '5-10 mL',
      'duration': '5-7 days',
      'withdrawal': '0 days'
    }
  ];

  @override
  void initState() {
    super.initState();
    _init();
    _emergencyController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _emergencyAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _emergencyController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emergencyController.dispose();
    _animalWeightController.dispose();
    _medicineDoseController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await auth.init();
    final curId = auth.currentType == 'vet' ? auth.currentId : null;
    final a = await _storage.loadAnimals();
    final vetAnimals = a.where((animal) => animal.vetId == curId).toList();

    // Calculate analytics
    _calculateAnalytics(vetAnimals);

    // Load Firestore data
    await _loadFirestoreData();

    setState(() {
      _vetId = curId;
      _animals = vetAnimals;
      _loading = false;
    });
  }

  void _calculateAnalytics(List<Animal> animals) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(Duration(days: 7));
    final monthAgo = today.subtract(Duration(days: 30));

    _todayConsultations = animals.where((a) {
      if (a.withdrawalStart == null) return false;
      final consultDate = DateTime.parse(a.withdrawalStart!);
      return consultDate.isAfter(today) || consultDate.isAtSameMomentAs(today);
    }).length;

    _weekConsultations = animals.where((a) {
      if (a.withdrawalStart == null) return false;
      final consultDate = DateTime.parse(a.withdrawalStart!);
      return consultDate.isAfter(weekAgo);
    }).length;

    _monthConsultations = animals.where((a) {
      if (a.withdrawalStart == null) return false;
      final consultDate = DateTime.parse(a.withdrawalStart!);
      return consultDate.isAfter(monthAgo);
    }).length;

    // Medicine usage statistics
    _medicineUsage.clear();
    for (var animal in animals) {
      if (animal.lastDrug != null) {
        _medicineUsage[animal.lastDrug!] =
            (_medicineUsage[animal.lastDrug!] ?? 0) + 1;
      }
    }

    // Recent farmers
    final farmerSet = <String>{};
    for (var animal in animals) {
      if (animal.farmerId != null) {
        farmerSet.add(animal.farmerId!);
      }
    }
    _recentFarmers = farmerSet.take(5).toList();
  }

  Future<void> _loadFirestoreData() async {
    try {
      // Load prescriptions
      _prescriptionsData = await _firestoreService.getAllPrescriptions();

      // Load livestock data
      _livestockData = await _firestoreService.getAllLivestock();

      // Load KPIs
      _kpisData = await _firestoreService.getKPIs();

      // Set up real-time listeners
      _setupRealtimeListeners();
    } catch (e) {
      print('Error loading Firestore data: $e');
    }
  }

  void _setupRealtimeListeners() {
    // Listen to prescriptions changes
    _firestoreService.getLivestockStream().listen((prescriptions) {
      if (mounted) {
        setState(() {
          _prescriptionsData = prescriptions
              .map((p) => firestore.Prescription(
                    id: 'RX-${p.id}',
                    animalId: p.id,
                    medication: p.medication ?? 'Unknown',
                    veterinarian:
                        'Dr. Default Vet', // This should come from actual vet data
                    issueDate:
                        p.createdAt?.toIso8601String().split('T')[0] ?? '',
                    status: 'Active',
                  ))
              .toList();
        });
      }
    });

    // Listen to livestock changes
    _firestoreService.getLivestockStream().listen((livestock) {
      if (mounted) {
        setState(() {
          _livestockData = livestock;
        });
      }
    });

    // Listen to KPI changes
    _firestoreService.getKPIsStream().listen((kpis) {
      if (mounted) {
        setState(() {
          _kpisData = kpis;
        });
      }
    });
  }

  void _calculateDosage() {
    final weight = double.tryParse(_animalWeightController.text);
    final dosePerKg = double.tryParse(_medicineDoseController.text);

    if (weight != null && dosePerKg != null && weight > 0) {
      setState(() {
        _calculatedDose = weight * dosePerKg;
      });
    }
  }

  void _toggleEmergencyMode() {
    setState(() {
      _emergencyMode = !_emergencyMode;
    });
    if (_emergencyMode) {
      _emergencyController.forward();
    } else {
      _emergencyController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.medical_services, color: Colors.white),
              SizedBox(width: 8),
              Text('Vet Dashboard'),
            ],
          ),
          backgroundColor:
              _emergencyMode ? Colors.red.shade700 : Colors.teal.shade700,
          elevation: _emergencyMode ? 8 : 4,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: _emergencyMode ? Colors.red.shade300 : Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.search), text: 'Consult'),
              Tab(icon: Icon(Icons.assignment), text: 'Prescriptions'),
              Tab(icon: Icon(Icons.science), text: 'Tools'),
              Tab(icon: Icon(Icons.history), text: 'History'),
            ],
          ),
          actions: [
            // Emergency Mode Toggle
            AnimatedBuilder(
              animation: _emergencyAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _emergencyMode ? _emergencyAnimation.value : 1.0,
                  child: IconButton(
                    icon: Icon(
                      _emergencyMode
                          ? Icons.emergency
                          : Icons.emergency_outlined,
                      color:
                          _emergencyMode ? Colors.red.shade300 : Colors.white,
                    ),
                    onPressed: _toggleEmergencyMode,
                    tooltip: _emergencyMode
                        ? 'Exit Emergency Mode'
                        : 'Enter Emergency Mode',
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'logout') {
                  try {
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => AlertDialog(
                        content: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('Logging out...'),
                          ],
                        ),
                      ),
                    );

                    // Sign out from Firebase Auth
                    await otpService.signOut();
                    // Use the new comprehensive logout method
                    await auth.logout();

                    // Close loading dialog
                    Navigator.of(context).pop();

                    // Navigate to login page
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => VoiceLoginPage()),
                      (route) => false,
                    );
                  } catch (e) {
                    // Close loading dialog if it's open
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $e')),
                    );
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                  value: 'logout',
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 18),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                  value: 'settings',
                ),
              ],
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _emergencyMode
                  ? [Colors.red.shade50, Colors.white]
                  : [Colors.teal.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: _loading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                  children: [
                    _buildDashboardTab(),
                    _buildConsultTab(),
                    _buildPrescriptionsTab(),
                    _buildToolsTab(),
                    _buildHistoryTab(),
                  ],
                ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context)
              .push(
                MaterialPageRoute(builder: (_) => ConsultAnimalsPage()),
              )
              .then((_) => _init()),
          icon: Icon(Icons.search),
          label: Text('Find Animals'),
          backgroundColor:
              _emergencyMode ? Colors.red.shade600 : Colors.teal.shade600,
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency Banner
          if (_emergencyMode) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade600, Colors.red.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade200,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.emergency, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMERGENCY MODE ACTIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Priority consultations enabled',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: _toggleEmergencyMode,
                  ),
                ],
              ),
            ),
          ],

          // Welcome Header
          _buildWelcomeCard(),

          SizedBox(height: 20),

          // Analytics Cards
          Text(
            'Consultation Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          SizedBox(height: 12),
          _buildAnalyticsGrid(),

          SizedBox(height: 20),

          // Firestore Data Overview
          if (_prescriptionsData.isNotEmpty ||
              _livestockData.isNotEmpty ||
              _kpisData != null) ...[
            Text(
              'System Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            SizedBox(height: 12),
            _buildFirestoreOverviewGrid(),
            SizedBox(height: 20),
          ],

          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          SizedBox(height: 12),
          _buildQuickActionsGrid(),

          SizedBox(height: 20),

          // Recent Activity
          if (_recentFarmers.isNotEmpty) ...[
            Text(
              'Recent Farmers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            SizedBox(height: 12),
            _buildRecentFarmersList(),
          ],
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade400, Colors.teal.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.shade200,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 32,
              ),
            ),
            SizedBox(width: 16),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, Doctor!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Vet ID: ${_vetId ?? 'Unknown'}',
                    style: TextStyle(
                      color: Colors.teal.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ready to provide excellent care today?',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildAnalyticsCard(
          'Today',
          _todayConsultations.toString(),
          Icons.today,
          Colors.blue,
        ),
        _buildAnalyticsCard(
          'This Week',
          _weekConsultations.toString(),
          Icons.calendar_view_week,
          Colors.green,
        ),
        _buildAnalyticsCard(
          'This Month',
          _monthConsultations.toString(),
          Icons.calendar_month,
          Colors.orange,
        ),
        _buildAnalyticsCard(
          'Total Cases',
          _animals.length.toString(),
          Icons.medical_services,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildFirestoreOverviewGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        if (_prescriptionsData.isNotEmpty)
          _buildAnalyticsCard(
            'Total Prescriptions',
            _prescriptionsData.length.toString(),
            Icons.assignment,
            Colors.indigo,
          ),
        if (_livestockData.isNotEmpty)
          _buildAnalyticsCard(
            'System Livestock',
            _livestockData.length.toString(),
            Icons.pets,
            Colors.teal,
          ),
        if (_kpisData != null)
          _buildAnalyticsCard(
            'Active Withdrawal',
            _kpisData!.activeWithdrawal.toString(),
            Icons.schedule,
            Colors.orange,
          ),
        if (_kpisData != null)
          _buildAnalyticsCard(
            'Compliance Rate',
            '${_kpisData!.complianceRate.toStringAsFixed(1)}%',
            Icons.verified,
            Colors.green,
          ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildActionCard(
          'Consult Animals',
          'Search and treat animals',
          Icons.search,
          Colors.teal,
          () => Navigator.of(context)
              .push(
                MaterialPageRoute(builder: (_) => ConsultAnimalsPage()),
              )
              .then((_) => _init()),
        ),
        _buildActionCard(
          'Dosage Calculator',
          'Calculate medicine doses',
          Icons.calculate,
          Colors.blue,
          () => _showDosageCalculator(),
        ),
        _buildActionCard(
          'Prescription Templates',
          'Quick prescription setup',
          Icons.assignment,
          Colors.green,
          () => _showPrescriptionTemplates(),
        ),
        _buildActionCard(
          'Emergency Mode',
          _emergencyMode ? 'Exit emergency' : 'Enter emergency',
          _emergencyMode ? Icons.emergency : Icons.emergency_outlined,
          _emergencyMode ? Colors.red : Colors.orange,
          _toggleEmergencyMode,
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFarmersList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Colors.teal.shade600),
                SizedBox(width: 8),
                Text(
                  'Recent Farmer Consultations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ..._recentFarmers.map((farmerId) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Icon(Icons.person, color: Colors.teal.shade600),
                  ),
                  title: Text('Farmer ID: $farmerId'),
                  subtitle: Text('Recent consultation'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Could navigate to farmer details or search for their animals
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Farmer: $farmerId')),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Section
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Find Animals to Consult',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                              builder: (_) => ConsultAnimalsPage()),
                        )
                        .then((_) => _init()),
                    icon: Icon(Icons.search),
                    label: Text('Search Animals'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Recent Consultations
          Expanded(
            child: _animals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medical_services,
                            size: 64, color: Colors.grey.shade400),
                        SizedBox(height: 16),
                        Text(
                          'No consultations yet',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade600),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start by searching for animals to consult',
                          style: TextStyle(color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _animals.length,
                    itemBuilder: (ctx, i) {
                      final a = _animals[i];
                      final inWithdrawal = a.withdrawalEnd != null &&
                          DateTime.now()
                              .isBefore(DateTime.parse(a.withdrawalEnd!));

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: inWithdrawal
                                  ? Colors.orange.shade100
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.medical_services,
                              color: inWithdrawal
                                  ? Colors.orange.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                          title: Text('${a.species} - ${a.breed} (${a.id})'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Farmer: ${a.farmerId ?? 'Unknown'}'),
                              Text(
                                'Medicine: ${a.lastDrug ?? 'None'} • ${inWithdrawal ? 'In withdrawal' : 'Safe'}',
                                style: TextStyle(
                                  color: inWithdrawal
                                      ? Colors.orange.shade700
                                      : Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        VetConsultFormPage(animal: a)),
                              )
                              .then((_) => _init()),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Veterinary Tools',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          SizedBox(height: 20),

          // AI Treatment Assistant
          _buildAITreatmentAssistantCard(),

          SizedBox(height: 20),

          // Dosage Calculator
          _buildDosageCalculatorCard(),

          SizedBox(height: 20),

          // Prescription Templates
          _buildPrescriptionTemplatesCard(),

          SizedBox(height: 20),

          // Medicine Usage Statistics
          if (_medicineUsage.isNotEmpty) ...[
            _buildMedicineStatsCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildDosageCalculatorCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: Colors.blue.shade600, size: 28),
                SizedBox(width: 12),
                Text(
                  'Dosage Calculator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _animalWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Animal Weight (kg)',
                prefixIcon:
                    Icon(Icons.monitor_weight, color: Colors.blue.shade600),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => _calculateDosage(),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _medicineDoseController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Dose per kg (mg)',
                prefixIcon: Icon(Icons.science, color: Colors.blue.shade600),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => _calculateDosage(),
            ),
            SizedBox(height: 16),
            if (_calculatedDose > 0) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Calculated Dose',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${_calculatedDose.toStringAsFixed(2)} mg',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionTemplatesCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, color: Colors.green.shade600, size: 28),
                SizedBox(width: 12),
                Text(
                  'Prescription Templates',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ..._prescriptionTemplates.map((template) => Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.medical_services,
                          color: Colors.green.shade700),
                    ),
                    title: Text(template['name']),
                    subtitle:
                        Text('${template['medicine']} • ${template['dosage']}'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () => _applyPrescriptionTemplate(template),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAITreatmentAssistantCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.smart_toy, color: Colors.blue.shade600, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'AI Treatment Assistant',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Get AI-powered treatment recommendations and health insights for your patients',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: _aiLoading ? null : _getAIInsights,
                      icon: Icon(Icons.psychology),
                      label: Text('Get AI Insights',
                          overflow: TextOverflow.ellipsis),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Flexible(
                    child: OutlinedButton.icon(
                      onPressed: () => _showImageAnalysisDialog(),
                      icon: Icon(Icons.camera_alt),
                      label: Text('Analyze Image',
                          overflow: TextOverflow.ellipsis),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green.shade600),
                        foregroundColor: Colors.green.shade600,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_aiInsights.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  'Latest AI Insights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 8),
                ..._aiInsights.take(3).map((insight) => Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.lightbulb,
                              color: Colors.blue.shade700),
                        ),
                        title: Text(insight['title'] ?? 'AI Insight'),
                        subtitle: Text(insight['description'] ?? ''),
                        isThreeLine: true,
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineStatsCard() {
    final sortedMedicines = _medicineUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.purple.shade600, size: 28),
                SizedBox(width: 12),
                Text(
                  'Medicine Usage Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...sortedMedicines.take(5).map((entry) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.key,
                          style: TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${entry.value} cases',
                          style: TextStyle(
                            color: Colors.purple.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: _animals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                  SizedBox(height: 16),
                  Text(
                    'No consultation history',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _animals.length,
              itemBuilder: (ctx, i) {
                final a = _animals[i];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.history, color: Colors.grey.shade700),
                    ),
                    title: Text('${a.species} - ${a.breed} (${a.id})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Farmer: ${a.farmerId ?? 'Unknown'}'),
                        Text(
                          'Consulted: ${a.withdrawalStart != null ? DateTime.parse(a.withdrawalStart!).toLocal().toString().split(' ')[0] : 'Unknown'}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        if (a.lastDrug != null)
                          Text(
                            'Treatment: ${a.lastDrug}',
                            style: TextStyle(
                                color: Colors.teal.shade600,
                                fontWeight: FontWeight.w500),
                          ),
                      ],
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () => _showConsultationDetails(a),
                  ),
                );
              },
            ),
    );
  }

  void _showDosageCalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: Colors.blue.shade600),
                SizedBox(width: 12),
                Text(
                  'Dosage Calculator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _animalWeightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Animal Weight (kg)',
                        prefixIcon: Icon(Icons.monitor_weight),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _calculateDosage(),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _medicineDoseController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Dose per kg (mg)',
                        prefixIcon: Icon(Icons.science),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _calculateDosage(),
                    ),
                    SizedBox(height: 20),
                    if (_calculatedDose > 0) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Recommended Dose',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${_calculatedDose.toStringAsFixed(2)} mg',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Administer as prescribed',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontSize: 14,
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
          ],
        ),
      ),
    );
  }

  void _showPrescriptionTemplates() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, color: Colors.green.shade600),
                SizedBox(width: 12),
                Text(
                  'Prescription Templates',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _prescriptionTemplates.length,
                itemBuilder: (ctx, i) {
                  final template = _prescriptionTemplates[i];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.medical_services,
                            color: Colors.green.shade700),
                      ),
                      title: Text(
                        template['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Medicine: ${template['medicine']}'),
                          Text(
                              'Dosage: ${template['dosage']} • Duration: ${template['duration']}'),
                          Text('Withdrawal: ${template['withdrawal']}'),
                        ],
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _applyPrescriptionTemplate(template),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyPrescriptionTemplate(Map<String, dynamic> template) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Template "${template['name']}" applied'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _getAIInsights() async {
    if (_animals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No patient data available for AI analysis')),
      );
      return;
    }

    setState(() => _aiLoading = true);

    try {
      final insights = await _aiService.getVeterinaryInsights(_animals);
      setState(() {
        _aiInsights = insights;
        _aiLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI insights updated successfully')),
      );
    } catch (e) {
      setState(() => _aiLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get AI insights: $e')),
      );
    }
  }

  void _showImageAnalysisDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.camera, color: Colors.green.shade600),
            SizedBox(width: 8),
            Text('Image Analysis'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload an image of the animal for AI-powered health assessment',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => _performImageAnalysis(),
                      icon: Icon(Icons.photo_library),
                      label: Text('Choose from Gallery',
                          overflow: TextOverflow.ellipsis),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _performImageAnalysis() async {
    Navigator.pop(context); // Close dialog

    setState(() => _aiLoading = true);

    try {
      // Simulate image analysis (in real implementation, this would use camera/gallery picker)
      await Future.delayed(Duration(seconds: 2));

      final analysis =
          await _imageAnalysisService.analyzeImage('sample_image_path');

      setState(() => _aiLoading = false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Image Analysis Results'),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health Assessment: ${analysis['healthScore'] ?? '85'}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'AI Observations:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...(analysis['observations'] as List<dynamic>? ?? [])
                      .map((obs) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green.shade600, size: 16),
                                SizedBox(width: 8),
                                Flexible(
                                    child: Text(obs.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2)),
                              ],
                            ),
                          )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _aiLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image analysis failed: $e')),
      );
    }
  }

  Widget _buildPrescriptionsTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.assignment,
                      color: Colors.indigo.shade600, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prescription Management',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'View and manage all prescriptions in the system',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Prescriptions List
          Expanded(
            child: _prescriptionsData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment,
                            size: 64, color: Colors.grey.shade400),
                        SizedBox(height: 16),
                        Text(
                          'No prescriptions found',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade600),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Prescriptions will appear here when created',
                          style: TextStyle(color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _prescriptionsData.length,
                    itemBuilder: (ctx, i) {
                      final prescription = _prescriptionsData[i];
                      final isVerified = prescription.status == 'Verified';

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isVerified
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.assignment,
                              color: isVerified
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                          title: Text('Prescription ${prescription.id}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Animal: ${prescription.animalId}'),
                              Text('Medicine: ${prescription.medication}'),
                              Text(
                                  'Vet: ${prescription.veterinarian} • Status: ${prescription.status}'),
                            ],
                          ),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () => _showPrescriptionDetails(prescription),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showPrescriptionDetails(firestore.Prescription prescription) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                      child: Text('Prescription Details',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close))
                ],
              ),
              SizedBox(height: 16),

              // Status Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: prescription.status == 'Verified'
                        ? [Colors.green.shade100, Colors.green.shade50]
                        : [Colors.orange.shade100, Colors.orange.shade50],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: prescription.status == 'Verified'
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      prescription.status == 'Verified'
                          ? Icons.verified
                          : Icons.pending,
                      color: prescription.status == 'Verified'
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${prescription.status}',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prescription Information
                      Text('Prescription Information',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800)),
                      SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              ListTile(
                                leading:
                                    CircleAvatar(child: Icon(Icons.assignment)),
                                title: Text('Prescription ID'),
                                subtitle: Text(prescription.id),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading: CircleAvatar(
                                    child: Icon(Icons.medical_services)),
                                title: Text('Medication'),
                                subtitle: Text(prescription.medication),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading:
                                    CircleAvatar(child: Icon(Icons.person)),
                                title: Text('Veterinarian'),
                                subtitle: Text(prescription.veterinarian),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading: CircleAvatar(
                                    child: Icon(Icons.calendar_today)),
                                title: Text('Issue Date'),
                                subtitle: Text(prescription.issueDate),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Animal Information
                      Text('Animal Information',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800)),
                      SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(child: Icon(Icons.pets)),
                                title: Text('Animal ID'),
                                subtitle: Text(prescription.animalId),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Action buttons
                      Container(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close),
                          label: Text('Close'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade400),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConsultationDetails(Animal a) {
    final isInWithdrawal = a.withdrawalEnd != null &&
        DateTime.now().isBefore(DateTime.parse(a.withdrawalEnd!));

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                      child: Text('Consultation Details',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close))
                ],
              ),
              SizedBox(height: 16),

              // Status Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isInWithdrawal
                        ? [Colors.orange.shade100, Colors.orange.shade50]
                        : [Colors.green.shade100, Colors.green.shade50],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isInWithdrawal
                        ? Colors.orange.shade300
                        : Colors.green.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isInWithdrawal ? Icons.warning : Icons.check_circle,
                      color: isInWithdrawal
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consultation Status',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            isInWithdrawal
                                ? 'Active - Withdrawal Period'
                                : 'Completed - Safe to Consume',
                            style: TextStyle(
                              fontSize: 12,
                              color: isInWithdrawal
                                  ? Colors.orange.shade700
                                  : Colors.green.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animal Information
                      Text('Animal Information',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800)),
                      SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(child: Icon(Icons.pets)),
                                title: Text('Animal ID'),
                                subtitle: Text(a.id),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading:
                                    CircleAvatar(child: Icon(Icons.category)),
                                title: Text('Species & Breed'),
                                subtitle: Text('${a.species} - ${a.breed}'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading: CircleAvatar(
                                    child: Icon(Icons.calendar_today)),
                                title: Text('Age'),
                                subtitle: Text(a.age),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Prescription Details
                      Text('Prescription Details',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800)),
                      SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                    child: Icon(Icons.medical_services)),
                                title: Text('Medicine'),
                                subtitle: Text(a.lastDrug ?? 'None'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading: CircleAvatar(child: Icon(Icons.scale)),
                                title: Text('Dosage'),
                                subtitle:
                                    Text('${a.lastDosage ?? 'N/A'} mg/kg'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              if (a.withdrawalDays != null)
                                ListTile(
                                  leading:
                                      CircleAvatar(child: Icon(Icons.schedule)),
                                  title: Text('Withdrawal Period'),
                                  subtitle: Text('${a.withdrawalDays} days'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              if (a.withdrawalStart != null)
                                ListTile(
                                  leading: CircleAvatar(
                                      child: Icon(Icons.access_time)),
                                  title: Text('Consultation Date'),
                                  subtitle: Text(
                                      DateTime.parse(a.withdrawalStart!)
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0]),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              if (a.withdrawalEnd != null)
                                ListTile(
                                  leading:
                                      CircleAvatar(child: Icon(Icons.flag)),
                                  title: Text('Withdrawal Ends'),
                                  subtitle: Text(
                                      DateTime.parse(a.withdrawalEnd!)
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0]),
                                  contentPadding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Farmer Information
                      SizedBox(height: 16),
                      Text('Farmer Information',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800)),
                      SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              ListTile(
                                leading:
                                    CircleAvatar(child: Icon(Icons.person)),
                                title: Text('Farmer ID'),
                                subtitle: Text(a.farmerId ?? 'Unknown'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Action buttons
                      Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        VetConsultFormPage(animal: a)),
                              )
                              .then((_) => _init()),
                          icon: Icon(Icons.edit),
                          label: Text('Update Consultation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close),
                          label: Text('Close'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade400),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
