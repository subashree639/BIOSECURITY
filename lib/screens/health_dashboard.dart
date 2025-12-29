import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/animal.dart';
import '../services/ai_service.dart';
import '../services/regulatory_service.dart';
import '../services/veterinary_network_service.dart';
import '../services/notification_service.dart';
import '../widgets/data_visualization.dart';

// Comprehensive Health Dashboard
class HealthDashboardScreen extends StatefulWidget {
  final List<Animal> farmAnimals;

  const HealthDashboardScreen({
    Key? key,
    required this.farmAnimals,
  }) : super(key: key);

  @override
  _HealthDashboardScreenState createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final AIService _aiService = AIService();
  final RegulatoryService _regulatoryService = RegulatoryService();
  final VeterinaryNetworkService _vetNetworkService = VeterinaryNetworkService();
  final NotificationService _notificationService = NotificationService();

  List<AITreatmentRecommendation> _aiRecommendations = [];
  Map<String, dynamic> _complianceData = {};
  List<Veterinarian> _nearbyVeterinarians = [];
  List<NotificationEvent> _recentNotifications = [];

  bool _isLoading = true;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeDashboard();
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeDashboard() async {
    setState(() => _isLoading = true);

    try {
      // Get current location for veterinary services
      _currentPosition = await _getCurrentLocation();

      // Load AI recommendations for all animals
      await _loadAIRecommendations();

      // Load compliance data
      await _loadComplianceData();

      // Load nearby veterinarians
      await _loadNearbyVeterinarians();

      // Load recent notifications
      await _loadRecentNotifications();

      // Schedule health monitoring notifications
      await _notificationService.scheduleHealthCheckNotifications(widget.farmAnimals);
      await _notificationService.scheduleTreatmentNotifications(widget.farmAnimals);
      await _notificationService.scheduleRegulatoryNotifications();

    } catch (e) {
      print('Error initializing dashboard: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<void> _loadAIRecommendations() async {
    _aiRecommendations.clear();

    for (final animal in widget.farmAnimals.take(5)) { // Limit to first 5 animals for performance
      try {
        final recommendations = await _aiService.getTreatmentRecommendations(
          animal,
          'General health assessment',
          null, // No image for now
        );
        _aiRecommendations.addAll(recommendations);
      } catch (e) {
        print('Error getting AI recommendations for ${animal.id}: $e');
      }
    }

    // Sort by confidence score
    _aiRecommendations.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
  }

  Future<void> _loadComplianceData() async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: 30));
      final endDate = DateTime.now();

      _complianceData = await _regulatoryService.trackAntibioticUsage(
        animals: widget.farmAnimals,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('Error loading compliance data: $e');
    }
  }

  Future<void> _loadNearbyVeterinarians() async {
    if (_currentPosition == null) return;

    try {
      _nearbyVeterinarians = await _vetNetworkService.findNearbyVeterinarians(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusKm: 50.0,
      );
    } catch (e) {
      print('Error loading nearby veterinarians: $e');
    }
  }

  Future<void> _loadRecentNotifications() async {
    try {
      _recentNotifications = await _notificationService.getNotificationHistory(limit: 10);
    } catch (e) {
      print('Error loading recent notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading ? _buildLoadingView() : _buildDashboardView(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
              strokeWidth: 6,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading Health Dashboard...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Analyzing your farm\'s health data',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Tab Bar
          _buildTabBar(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildHealthAnalyticsTab(),
                _buildComplianceTab(),
                _buildVeterinaryNetworkTab(),
                _buildNotificationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final healthyCount = widget.farmAnimals.where((a) => (a.healthScore ?? 0) >= 70).length;
    final totalAnimals = widget.farmAnimals.length;
    final healthPercentage = totalAnimals > 0 ? (healthyCount / totalAnimals) * 100 : 0;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farm Health Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${widget.farmAnimals.length} animals monitored',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: healthPercentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 6,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${healthPercentage.toStringAsFixed(1)}% animals healthy',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.green.shade700],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        tabs: [
          Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
          Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          Tab(icon: Icon(Icons.verified), text: 'Compliance'),
          Tab(icon: Icon(Icons.local_hospital), text: 'Network'),
          Tab(icon: Icon(Icons.notifications), text: 'Alerts'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Recommendations
          if (_aiRecommendations.isNotEmpty) ...[
            Text(
              'AI Treatment Recommendations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 16),
            ..._aiRecommendations.take(3).map((rec) => Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.smart_toy, color: Colors.blue.shade600),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rec.recommendedTreatment,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(rec.confidenceScore * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      rec.condition,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )),
            SizedBox(height: 24),
          ],

          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Emergency Vet',
                  Icons.emergency,
                  Colors.red.shade600,
                  () => _requestEmergencyVet(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Book Consultation',
                  Icons.calendar_today,
                  Colors.blue.shade600,
                  () => _bookConsultation(),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Compliance Report',
                  Icons.description,
                  Colors.green.shade600,
                  () => _generateComplianceReport(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Health Scan',
                  Icons.camera_alt,
                  Colors.purple.shade600,
                  () => _performHealthScan(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAnalyticsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Farm Health Overview
          FarmAnalyticsDashboard(animals: widget.farmAnimals),

          SizedBox(height: 24),

          // Individual Animal Health Cards
          Text(
            'Individual Animal Health',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16),
          ...widget.farmAnimals.take(3).map((animal) => Container(
            margin: EdgeInsets.only(bottom: 16),
            child: HealthDashboard(
              animal: animal,
              farmAnimals: widget.farmAnimals,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildComplianceTab() {
    final violations = _complianceData['violations'] as List<String>? ?? [];
    final complianceScore = (_complianceData['compliance_score'] as num?)?.toDouble() ?? 0.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compliance Score
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: complianceScore >= 80
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Compliance Score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: complianceScore / 100,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 12,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${complianceScore.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    complianceScore >= 80 ? 'Compliant' : 'Needs Attention',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Violations
          if (violations.isNotEmpty) ...[
            Text(
              'Compliance Violations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 16),
            ...violations.map((violation) => Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.red.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade600),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        violation,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],

          SizedBox(height: 24),

          // Generate Report Button
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade700],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade300,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _generateComplianceReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Generate Compliance Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVeterinaryNetworkTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nearby Veterinarians
          Text(
            'Nearby Veterinarians',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16),
          if (_nearbyVeterinarians.isEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.location_off, size: 48, color: Colors.grey.shade400),
                    SizedBox(height: 16),
                    Text(
                      'No veterinarians found nearby',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enable location services to find nearby vets',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._nearbyVeterinarians.take(3).map((vet) => Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            vet.name.split(' ').map((n) => n[0]).take(2).join(),
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vet.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              Text(
                                vet.specialty,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.green.shade600),
                              SizedBox(width: 4),
                              Text(
                                vet.rating.toString(),
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey.shade500),
                        SizedBox(width: 4),
                        Text(
                          '${vet.distance.toStringAsFixed(1)} km away',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () => _bookConsultationWithVet(vet),
                          child: Text(
                            'Book Now',
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),

          SizedBox(height: 24),

          // Emergency Services
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.red.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.emergency, color: Colors.red.shade600, size: 32),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Veterinary Services',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '24/7 emergency care for your animals',
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade600, Colors.red.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade300,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _requestEmergencyVet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Request Emergency Service',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16),
          if (_recentNotifications.isEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.notifications_none, size: 48, color: Colors.grey.shade400),
                    SizedBox(height: 16),
                    Text(
                      'No recent notifications',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._recentNotifications.map((notification) => Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getNotificationColor(notification.type),
                      ),
                      child: Icon(
                        _getNotificationIcon(notification.type),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            notification.message,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatTimestamp(notification.timestamp),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return Colors.red.shade600;
      case NotificationType.health:
        return Colors.orange.shade600;
      case NotificationType.treatment:
        return Colors.blue.shade600;
      case NotificationType.regulatory:
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return Icons.emergency;
      case NotificationType.health:
        return Icons.health_and_safety;
      case NotificationType.treatment:
        return Icons.medical_services;
      case NotificationType.regulatory:
        return Icons.verified;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Action handlers
  void _requestEmergencyVet() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services required for emergency services')),
      );
      return;
    }

    try {
      final emergencyResponse = await _vetNetworkService.requestEmergencyService(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        emergencyType: 'General Emergency',
        description: 'Emergency veterinary assistance requested',
        contactNumber: 'Emergency Contact',
      );

      await _notificationService.sendEmergencyAlert(
        title: 'Emergency Service Requested',
        message: 'Emergency veterinary service has been dispatched. ETA: ${emergencyResponse.estimatedArrivalTime.difference(DateTime.now()).inMinutes} minutes',
        priority: EmergencyPriority.critical,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Emergency service requested successfully'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to request emergency service'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _bookConsultation() {
    // Navigate to consultation booking screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Consultation booking feature coming soon')),
    );
  }

  void _bookConsultationWithVet(Veterinarian vet) {
    // Navigate to booking screen with selected vet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking consultation with ${vet.name}')),
    );
  }

  void _generateComplianceReport() async {
    try {
      final reportPath = await _regulatoryService.generateComplianceReport(
        animals: widget.farmAnimals,
        farmId: 'FARM_001', // This should come from user profile
        startDate: DateTime.now().subtract(Duration(days: 30)),
        endDate: DateTime.now(),
        reportType: 'monthly',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Compliance report generated successfully'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate compliance report'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _performHealthScan() {
    // Navigate to health scanning screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Health scanning feature coming soon')),
    );
  }
}