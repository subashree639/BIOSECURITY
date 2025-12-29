import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart' as qr_flutter;
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import for global auth, otpService, and qrService instances
import '../models/animal.dart';
import '../models/firestore_models.dart' as firestore;
import '../services/animal_storage.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';
import '../services/image_analysis_service.dart';
import 'add_animal_page.dart';
import 'animal_database_page.dart';
import 'guides_page.dart';
import 'mrl_graph_page.dart';
import 'voice_login_page.dart';
import 'analytics_dashboard.dart';
import 'alerts_dashboard.dart';
import '../services/alert_service.dart' as local_alert;

//
// Farmer Dashboard (shows Farmer ID in header and animals count)
//
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final AnimalStorageService _storage = AnimalStorageService();
  final AIService _aiService = AIService();
  final ImageAnalysisService _imageAnalysisService = ImageAnalysisService();
  final local_alert.AlertService _alertService = local_alert.AlertService();
  final FirestoreService _firestoreService = FirestoreService();
  List<Animal> _animals = [];
  bool _loading = true;
  String? _farmerId;
  List<firestore.Alert> _withdrawalAlerts = [];
  firestore.Farmer? _farmerData;
  firestore.KPIs? _kpisData;
  List<firestore.Livestock> _livestockData = [];
  List<firestore.Prescription> _prescriptionsData = [];
  String? _farmLocation;
  String? _city;
  String? _state;
  String? _district;
  String? _mobile;
  List<String> _locationComponents = [];

  // AI Features
  List<Map<String, dynamic>> _aiRecommendations = [];
  bool _aiLoading = false;

  // For animals tab
  List<Animal> _allAnimals = [];
  List<Animal> _filteredAnimals = [];
  String _q = '';
  String? _filterSpecies;
  String? _filterStatus;
  final speciesOptions = [
    'Cow',
    'Buffalo',
    'Goat',
    'Sheep',
    'Pig',
    'Poultry',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await auth.init();
    final curId = auth.currentType == 'farmer' ? auth.currentId : null;
    final a = await _storage.loadAnimals();
    if (mounted) {
      setState(() {
        _farmerId = curId;
        _animals = a.where((animal) => animal.farmerId == curId).toList();
        _allAnimals = _animals;
        _applyFilter();
        _loading = false;
      });
    }
    // Load withdrawal alerts after animals are loaded
    await _loadWithdrawalAlerts();
    // Load farm location
    await _loadFarmLocation();
    // Load Firestore data
    await _loadFirestoreData();
  }

  Future<void> _loadWithdrawalAlerts() async {
    final allAlerts = _alertService.getActiveAlerts();
    final withdrawalAlerts = allAlerts
        .where((alert) =>
            alert.type == local_alert.AlertService.WITHDRAWAL_WARNING ||
            alert.type == local_alert.AlertService.WITHDRAWAL_EXPIRED ||
            alert.type == local_alert.AlertService.WITHDRAWAL_STATUS)
        .toList();

    if (mounted) {
      setState(() {
        _withdrawalAlerts = withdrawalAlerts
            .map((alert) => firestore.Alert(
                  type: alert.type,
                  message: alert.message,
                  time: _getTimeAgo(alert.timestamp),
                  location: 'Farm',
                  icon: 'fas fa-exclamation-triangle',
                  timestamp: alert.timestamp,
                  isRead: alert.isRead,
                  priority: _getPriorityFromSeverity(alert.severity),
                  farmer: _farmerId,
                  vet: null,
                ))
            .toList();
      });
    }
  }

  Future<void> _loadFarmLocation() async {
    if (_farmerId != null) {
      try {
        // Load farmer data from Firebase
        final farmerData = await auth.getFarmerData(_farmerId!);
        if (mounted && farmerData != null) {
          setState(() {
            _farmLocation = farmerData['location']; // Farm location field
            _city = farmerData['area']; // City from address
            _state = farmerData['state']; // State from address
            _district = farmerData['district']; // District from address
            _mobile = farmerData['mobile']; // Mobile from address

            // Parse location field to extract components: doorNo, street, city, district, pincode, state
            // Display only: doorNo, street, city, pincode (exclude district and state)
            if (_farmLocation != null && _farmLocation!.isNotEmpty) {
              final allComponents =
                  _farmLocation!.split(',').map((part) => part.trim()).toList();
              // Take components 0, 1, 2, 4 (doorNo, street, city, pincode) and exclude district (3) and state (5)
              _locationComponents = [];
              if (allComponents.length > 0 && allComponents[0].isNotEmpty)
                _locationComponents.add(allComponents[0]); // doorNo
              if (allComponents.length > 1 && allComponents[1].isNotEmpty)
                _locationComponents.add(allComponents[1]); // street
              if (allComponents.length > 2 && allComponents[2].isNotEmpty)
                _locationComponents.add(allComponents[2]); // city
              if (allComponents.length > 4 && allComponents[4].isNotEmpty)
                _locationComponents.add(allComponents[4]); // pincode
            } else {
              _locationComponents = [];
            }
          });
        }
      } catch (e) {
        print('Error loading farm location: $e');
      }
    }
  }

  Future<void> _loadFirestoreData() async {
    if (_farmerId != null) {
      try {
        // Load farmer data from Firestore
        _farmerData = await _firestoreService.getFarmer(_farmerId!);

        // Load livestock data for this farmer
        _livestockData =
            await _firestoreService.getLivestockByOwner(_farmerId!);

        // Load prescriptions for farmer's animals
        _prescriptionsData = [];
        for (final livestock in _livestockData) {
          final prescriptions =
              await _firestoreService.getPrescriptionsByAnimal(livestock.id);
          _prescriptionsData.addAll(prescriptions);
        }

        // Load KPIs
        _kpisData = await _firestoreService.getKPIs();

        if (mounted) {
          setState(() {});
        }

        // Set up real-time listeners
        _setupRealtimeListeners();
      } catch (e) {
        print('Error loading Firestore data: $e');
      }
    }
  }

  void _setupRealtimeListeners() {
    if (_farmerId != null) {
      // Listen to farmer data changes
      _firestoreService.getFarmersStream().listen((farmers) {
        final farmer = farmers.where((f) => f.id == _farmerId).firstOrNull;
        if (mounted && farmer != null) {
          setState(() {
            _farmerData = farmer;
          });
        }
      });

      // Listen to livestock data changes for this farmer
      _firestoreService.getLivestockStream().listen((livestock) {
        final farmerLivestock =
            livestock.where((l) => l.ownerId == _farmerId).toList();
        if (mounted) {
          setState(() {
            _livestockData = farmerLivestock;
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
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getPriorityFromSeverity(local_alert.AlertSeverity severity) {
    switch (severity) {
      case local_alert.AlertSeverity.critical:
        return 'high';
      case local_alert.AlertSeverity.high:
        return 'high';
      case local_alert.AlertSeverity.medium:
        return 'medium';
      case local_alert.AlertSeverity.low:
        return 'low';
      default:
        return 'medium';
    }
  }

  void _applyFilter() {
    final q = _q.trim().toLowerCase();
    _filteredAnimals = _allAnimals.where((a) {
      final mq = q.isEmpty ||
          a.id.toLowerCase().contains(q) ||
          a.species.toLowerCase().contains(q) ||
          a.breed.toLowerCase().contains(q);
      final ms = _filterSpecies == null || _filterSpecies == a.species;
      final mstatus = _filterStatus == null ||
          _filterStatus == 'all' ||
          (_filterStatus == 'withdrawal' && _inWithdrawal(a)) ||
          (_filterStatus == 'safe' && !_inWithdrawal(a));
      return mq && ms && mstatus;
    }).toList();
  }

  Future<void> _deleteAnimal(String animalId) async {
    // Load the full animal list to find the correct index in storage
    final allAnimals = await _storage.loadAnimals();
    final indexInStorage =
        allAnimals.indexWhere((animal) => animal.id == animalId);
    if (indexInStorage != -1) {
      await _storage.deleteAnimalAt(indexInStorage);
      await _init();
    }
  }

  Future<void> _getAIRecommendations() async {
    if (_animals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.addAnimalsFirstAi)),
      );
      return;
    }

    setState(() => _aiLoading = true);

    try {
      // Get AI recommendations based on farm animals
      final recommendations =
          await _aiService.getTreatmentRecommendationsForList(_animals);

      setState(() {
        _aiRecommendations = recommendations;
        _aiLoading = false;
      });

      // Show AI recommendations dialog
      _showAIRecommendationsDialog();
    } catch (e) {
      setState(() => _aiLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .failedToGetAiRecommendations(e.toString()))),
      );
    }
  }

  void _showAIRecommendationsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.blue.shade600),
            SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.aiTreatmentRecommendations),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: 400),
          child: _aiRecommendations.isEmpty
              ? Center(
                  child: Text(
                      AppLocalizations.of(context)!.noSpecificRecommendations))
              : ListView.builder(
                  itemCount: _aiRecommendations.length,
                  itemBuilder: (ctx, i) {
                    final rec = _aiRecommendations[i];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.medical_services,
                              color: Colors.blue.shade700),
                        ),
                        title: Text(rec['title'] ?? 'Recommendation'),
                        subtitle: Text(rec['description'] ?? ''),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => Navigator.pop(context),
                      ),
                    );
                  },
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
  }

  Future<void> _showAIHealthAnalysis(Animal animal) async {
    setState(() => _aiLoading = true);

    try {
      // Get AI health analysis for this specific animal
      final analysis = await _aiService.analyzeAnimalHealth(animal);

      setState(() => _aiLoading = false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.green.shade600),
              SizedBox(width: 8),
              Expanded(
                child: Text(AppLocalizations.of(context)!.aiHealthAnalysis),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health Score
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.show_chart,
                              color: Colors.green.shade700, size: 32),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.healthScore,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                                Text(
                                  '${analysis['healthScore'] ?? 85}%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // AI Recommendations
                  Text(
                    AppLocalizations.of(context)!.aiRecommendations,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 8),

                  ...(analysis['recommendations'] as List<dynamic>? ?? [])
                      .map((rec) => Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Icon(Icons.lightbulb,
                                    color: Colors.blue.shade700),
                              ),
                              title: Text(rec['title'] ?? 'Recommendation'),
                              subtitle: Text(rec['description'] ?? ''),
                              isThreeLine: true,
                            ),
                          )),

                  // Preventive Care
                  if (analysis['preventiveCare'] != null) ...[
                    SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.preventiveCare,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    ...(analysis['preventiveCare'] as List<dynamic>)
                        .map((care) => Card(
                              margin: EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange.shade100,
                                  child: Icon(Icons.shield,
                                      color: Colors.orange.shade700),
                                ),
                                title:
                                    Text(care['title'] ?? 'Preventive Measure'),
                                subtitle: Text(care['description'] ?? ''),
                              ),
                            )),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.share),
              label: Text(AppLocalizations.of(context)!.shareWithVet),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _aiLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .failedToAnalyzeHealth(e.toString()))),
      );
    }
  }

  bool _inWithdrawal(Animal a) {
    if (a.withdrawalEnd == null) return false;
    try {
      return DateTime.now().isBefore(DateTime.parse(a.withdrawalEnd!));
    } catch (_) {
      return false;
    }
  }

  void _showAnimalDetails(Animal a) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(18.0),
        child: Wrap(
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(AppLocalizations.of(context)!.animalDetails,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close))
              ],
            ),
            SizedBox(height: 8),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.vpn_key)),
              title: Text(AppLocalizations.of(context)!.id),
              subtitle: Text(a.id),
            ),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.pets)),
              title: Text(AppLocalizations.of(context)!.species),
              subtitle: Text(a.species),
            ),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.info)),
              title: Text(AppLocalizations.of(context)!.breed),
              subtitle: Text(a.breed),
            ),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.calendar_today)),
              title: Text(AppLocalizations.of(context)!.age),
              subtitle: Text(a.age),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Delete Animal'),
                        content: Text(
                            'Are you sure you want to delete this animal? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (confirmed) {
                  await _deleteAnimal(a.id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text(AppLocalizations.of(context)!.deletedMessage)));
                }
              },
              icon: Icon(Icons.delete),
              label: Text(AppLocalizations.of(context)!.deleteAnimal),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animalCount = _animals.length;
    final inWithdrawal = _animals.where((a) {
      if (a.withdrawalEnd == null) return false;
      try {
        final end = DateTime.parse(a.withdrawalEnd!);
        return DateTime.now().isBefore(end);
      } catch (_) {
        return false;
      }
    }).length;

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.farmerDashboard),
          backgroundColor: Colors.green.shade700,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Container(
              color: Colors.green.shade700,
              child: TabBar(
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelPadding: EdgeInsets.zero,
                tabs: [
                  Tab(
                      child: Padding(
                          padding:
                              EdgeInsets.only(right: 12, top: 8, bottom: 8),
                          child: Text(AppLocalizations.of(context)!.home))),
                  Tab(
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(AppLocalizations.of(context)!.animals))),
                  Tab(
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(
                              AppLocalizations.of(context)!.prescriptions))),
                  Tab(
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(AppLocalizations.of(context)!.qrCodes))),
                  Tab(
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child:
                              Text(AppLocalizations.of(context)!.analytics))),
                  Tab(
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(AppLocalizations.of(context)!.alerts))),
                  Tab(
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text('History'))),
                ],
              ),
            ),
          ),
          actions: [
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
                            Text(AppLocalizations.of(context)!.loggingOut),
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
                )
              ],
            )
          ],
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Home tab
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Card(
                              elevation: 4,
                              color: Colors.transparent,
                              child: Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        Colors.white,
                                        Colors.green.shade50
                                      ]),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                                radius: 30,
                                                backgroundColor:
                                                    Colors.green.shade100,
                                                child: Icon(Icons.person,
                                                    color:
                                                        Colors.green.shade700)),
                                            SizedBox(width: 12),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                  Text('Farmer ID',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[700],
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  SizedBox(height: 6),
                                                  Text(_farmerId ?? 'Guest',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Colors
                                                              .green.shade800)),
                                                  SizedBox(height: 8),
                                                  if (_mobile != null &&
                                                      _mobile!.isNotEmpty)
                                                    Text('Mobile: $_mobile',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700],
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  // Location information prominently displayed
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.green.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      border: Border.all(
                                                          color: Colors
                                                              .green.shade200,
                                                          width: 1),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.location_on,
                                                            size: 16,
                                                            color: Colors.green
                                                                .shade700),
                                                        SizedBox(width: 6),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              if (_state !=
                                                                      null &&
                                                                  _state!
                                                                      .isNotEmpty)
                                                                Text('State: $_state',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green
                                                                            .shade800,
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w600)),
                                                              if (_district !=
                                                                      null &&
                                                                  _district!
                                                                      .isNotEmpty)
                                                                Text(
                                                                    'District: $_district',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green
                                                                            .shade800,
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w600)),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 6),
                                                  Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .animalsCount(
                                                              animalCount,
                                                              inWithdrawal),
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[700]))
                                                ])),
                                            IconButton(
                                                icon: Icon(Icons.pets),
                                                onPressed: () => Navigator.of(
                                                        context)
                                                    .push(MaterialPageRoute(
                                                        builder: (_) =>
                                                            AnimalDatabasePage()))
                                                    .then((_) => _init()))
                                          ])))),
                          SizedBox(height: 12),
                          // Farm Address Section
                          if (_locationComponents.isNotEmpty)
                            Card(
                              elevation: 4,
                              color: Colors.transparent,
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      Colors.white,
                                      Colors.green.shade50
                                    ]),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                          radius: 24,
                                          backgroundColor:
                                              Colors.green.shade100,
                                          child: Icon(Icons.location_on,
                                              color: Colors.green.shade700)),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Farm Location',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[800])),
                                            SizedBox(height: 4),
                                            Text(_locationComponents.join(', '),
                                                style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (_farmLocation != null &&
                              _farmLocation!.isNotEmpty)
                            SizedBox(height: 12),

                          // Compliance and Livestock Statistics from Firestore
                          if (_farmerData != null ||
                              _livestockData.isNotEmpty ||
                              _kpisData != null)
                            Card(
                              elevation: 4,
                              color: Colors.transparent,
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      Colors.white,
                                      Colors.blue.shade50
                                    ]),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.analytics,
                                              color: Colors.blue.shade700),
                                          SizedBox(width: 8),
                                          Text('Farm Statistics',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade800)),
                                        ],
                                      ),
                                      SizedBox(height: 16),

                                      // Farmer Compliance
                                      if (_farmerData != null) ...[
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildStatCard(
                                                'Compliance Rate',
                                                '${_farmerData!.compliance.toStringAsFixed(1)}%',
                                                Icons.verified,
                                                _farmerData!.compliance >= 90
                                                    ? Colors.green
                                                    : _farmerData!.compliance >=
                                                            70
                                                        ? Colors.orange
                                                        : Colors.red,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: _buildStatCard(
                                                'Livestock Count',
                                                _farmerData!.livestockCount
                                                    .toString(),
                                                Icons.pets,
                                                Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                      ],

                                      // Livestock Health Statistics
                                      if (_livestockData.isNotEmpty) ...[
                                        Text('Livestock Health Overview',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700)),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildStatCard(
                                                'Healthy',
                                                _livestockData
                                                    .where((l) =>
                                                        l.status == 'Healthy')
                                                    .length
                                                    .toString(),
                                                Icons.health_and_safety,
                                                Colors.green,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: _buildStatCard(
                                                'In Treatment',
                                                _livestockData
                                                    .where((l) =>
                                                        l.status ==
                                                        'Under Treatment')
                                                    .length
                                                    .toString(),
                                                Icons.medical_services,
                                                Colors.orange,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: _buildStatCard(
                                                'In Withdrawal',
                                                _livestockData
                                                    .where((l) =>
                                                        l.withdrawalStatus ==
                                                        'Active')
                                                    .length
                                                    .toString(),
                                                Icons.schedule,
                                                Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                      ],

                                      // Overall KPIs
                                      if (_kpisData != null) ...[
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey.shade200),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              _buildMiniStat(
                                                  'Total Livestock',
                                                  _kpisData!.totalLivestock
                                                      .toString()),
                                              _buildMiniStat(
                                                  'Active Withdrawal',
                                                  _kpisData!.activeWithdrawal
                                                      .toString()),
                                              _buildMiniStat('Compliance',
                                                  '${_kpisData!.complianceRate.toStringAsFixed(1)}%'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (_farmerData != null ||
                              _livestockData.isNotEmpty ||
                              _kpisData != null)
                            SizedBox(height: 12),

                          // Withdrawal Alerts Banner
                          if (_withdrawalAlerts.isNotEmpty)
                            _buildWithdrawalAlertsBanner(),
                          if (_withdrawalAlerts.isNotEmpty)
                            SizedBox(height: 12),
                          // Quick Actions Grid
                          GridView.count(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount:
                                  MediaQuery.of(context).size.width > 700
                                      ? 4
                                      : 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              children: [
                                _dashCard(
                                    AppLocalizations.of(context)!.addAnimal,
                                    AppLocalizations.of(context)!.addNewAnimal,
                                    Icons.add,
                                    () => Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (_) => AddAnimalPage()))
                                        .then((_) => _init())),
                                _dashCard(
                                    AppLocalizations.of(context)!.guides,
                                    AppLocalizations.of(context)!
                                        .withdrawalDosingGuides,
                                    Icons.help,
                                    () => Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (_) => GuidesPage()))
                                        .then((_) => _init())),
                                _dashCard(
                                    AppLocalizations.of(context)!
                                        .aiVetAssistant,
                                    AppLocalizations.of(context)!
                                        .aiTreatmentRecommendationsDesc,
                                    Icons.smart_toy,
                                    _aiLoading ? null : _getAIRecommendations),
                                _dashCard(
                                    'Debug DB',
                                    'Print database structure to console',
                                    Icons.bug_report, () async {
                                  await _storage.printDatabaseStructure();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Database structure printed to console')),
                                  );
                                }),
                              ]),
                        ],
                      ),
                    ),
                  ),
                  // Animals tab
                  _buildAnimalsSubTab(_filteredAnimals, 'No animals yet'),
                  // Prescriptions tab
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: _buildPrescriptionsTab(),
                  ),

                  // QR Codes tab
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: _buildQRCodesTab(),
                  ),

                  // Analytics tab
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: AnalyticsDashboard(),
                  ),

                  // Alerts tab
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: AlertsDashboard(),
                  ),

                  // History tab
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: _animals.isEmpty
                        ? Center(
                            child: Text(
                                AppLocalizations.of(context)!.noAnimalsYet))
                        : ListView.builder(
                            itemCount: _animals.length,
                            itemBuilder: (ctx, i) {
                              final a = _animals[i];
                              return Card(
                                elevation: 3,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading:
                                      CircleAvatar(child: Icon(Icons.pets)),
                                  title: Text(
                                      '${a.species} - ${a.breed} (${a.id})'),
                                  subtitle: Text(AppLocalizations.of(context)!
                                      .ageAddedToDatabase(a.age)),
                                  trailing: Icon(Icons.history),
                                  onTap: () => _showAnimalDetails(a),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.green.shade700,
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => AddAnimalPage()))
              .then((_) => _init()),
        ),
      ),
    );
  }

  Widget _buildWithdrawalAlertsBanner() {
    final criticalAlerts =
        _withdrawalAlerts.where((alert) => alert.priority == 'high').length;
    final warningAlerts = _withdrawalAlerts
        .where(
            (alert) => alert.priority == 'high' || alert.priority == 'medium')
        .length;

    return Card(
      elevation: 6,
      color: criticalAlerts > 0 ? Colors.red.shade50 : Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: criticalAlerts > 0
                ? Colors.red.shade300
                : Colors.orange.shade300,
            width: 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    criticalAlerts > 0 ? Icons.warning : Icons.info,
                    color: criticalAlerts > 0
                        ? Colors.red.shade700
                        : Colors.orange.shade700,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Withdrawal Status Alert',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: criticalAlerts > 0
                                ? Colors.red.shade900
                                : Colors.orange.shade900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${_withdrawalAlerts.length} animal(s) currently in withdrawal period',
                          style: TextStyle(
                            fontSize: 14,
                            color: criticalAlerts > 0
                                ? Colors.red.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _withdrawalAlerts.clear()),
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    tooltip: 'Dismiss banner',
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  if (criticalAlerts > 0) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$criticalAlerts Critical',
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                  if (warningAlerts > 0) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$warningAlerts Warning',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      // Navigate to alerts tab
                      DefaultTabController.of(context)
                          .animateTo(5); // Alerts tab index
                    },
                    icon: Icon(Icons.visibility, size: 16),
                    label: Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: criticalAlerts > 0
                          ? Colors.red.shade700
                          : Colors.orange.shade700,
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

  Widget _dashCard(String t, String s, IconData ic, VoidCallback? onTap) {
    return Card(
      elevation: 4,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 140, // Fixed height to prevent overflow
        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [Colors.white, Colors.green.shade50]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.green.shade100,
                    child: Icon(ic, color: Colors.green.shade700)),
                SizedBox(height: 8),
                Text(t,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center),
                SizedBox(height: 4),
                Expanded(
                  child: Text(
                    s,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(Icons.chevron_right,
                        color: Colors.grey[400], size: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToTab(int index) {
    DefaultTabController.of(context).animateTo(index);
  }

  Widget _buildAnimalsSubTab(List<Animal> animals, String emptyMessage) {
    return Padding(
        padding: EdgeInsets.all(12),
        child: Column(children: [
          TextField(
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, size: 20),
                  hintText: AppLocalizations.of(context)!.searchAnimals,
                  hintStyle: TextStyle(fontSize: 14),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
              onChanged: (v) {
                setState(() => _q = v);
                _applyFilter();
              }),
          SizedBox(height: 8),
          SizedBox(
              height: 44,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                SizedBox(width: 8),
                ChoiceChip(
                    label: Text(AppLocalizations.of(context)!.all),
                    selected: _filterSpecies == null,
                    onSelected: (_) {
                      setState(() => _filterSpecies = null);
                      _applyFilter();
                    }),
                SizedBox(width: 8),
                ...speciesOptions
                    .map((s) => Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                            label: Text(s),
                            selected: _filterSpecies == s,
                            onSelected: (sel) {
                              setState(() => _filterSpecies = sel ? s : null);
                              _applyFilter();
                            })))
                    .toList()
              ])),
          SizedBox(height: 8),
          SizedBox(
              height: 44,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                SizedBox(width: 8),
                ChoiceChip(
                    label: Text(AppLocalizations.of(context)!.allStatus),
                    selected: _filterStatus == null,
                    onSelected: (_) {
                      setState(() => _filterStatus = null);
                      _applyFilter();
                    }),
                SizedBox(width: 8),
                ChoiceChip(
                    label: Text(AppLocalizations.of(context)!.withdrawalStatus),
                    selected: _filterStatus == 'withdrawal',
                    onSelected: (_) {
                      setState(() => _filterStatus = 'withdrawal');
                      _applyFilter();
                    }),
                SizedBox(width: 8),
                ChoiceChip(
                    label: Text(AppLocalizations.of(context)!.safeStatus),
                    selected: _filterStatus == 'safe',
                    onSelected: (_) {
                      setState(() => _filterStatus = 'safe');
                      _applyFilter();
                    }),
              ])),
          SizedBox(height: 8),
          Expanded(
              child: animals.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(Icons.pets, size: 70, color: Colors.grey[400]),
                          SizedBox(height: 12),
                          Text(emptyMessage,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          if (emptyMessage == 'No animals yet')
                            Text(AppLocalizations.of(context)!
                                .tapAddCreateAnimals)
                        ]))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 900
                                  ? 3
                                  : (MediaQuery.of(context).size.width > 600
                                      ? 2
                                      : 1),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.95),
                      itemCount: animals.length,
                      itemBuilder: (ctx, i) {
                        final a = animals[i];
                        final inW = _inWithdrawal(a);
                        return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        CircleAvatar(
                                            radius: 24,
                                            backgroundColor:
                                                Colors.green.shade50,
                                            child: Icon(Icons.pets,
                                                color: Colors.green.shade700)),
                                        SizedBox(width: 10),
                                        Expanded(
                                            child: Text(a.id,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        if (a.lastDrug != null)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            constraints:
                                                BoxConstraints(maxWidth: 110),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: inW
                                                    ? [
                                                        Colors.orange.shade100,
                                                        Colors.orange.shade50
                                                      ]
                                                    : [
                                                        Colors.green.shade100,
                                                        Colors.green.shade50
                                                      ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: inW
                                                    ? Colors.orange.shade300
                                                    : Colors.green.shade300,
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: (inW
                                                          ? Colors.orange
                                                          : Colors.green)
                                                      .withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                    color: inW
                                                        ? Colors.orange.shade200
                                                        : Colors.green.shade200,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    inW
                                                        ? Icons
                                                            .warning_amber_rounded
                                                        : Icons
                                                            .check_circle_rounded,
                                                    color: inW
                                                        ? Colors.orange.shade800
                                                        : Colors.green.shade800,
                                                    size: 12,
                                                  ),
                                                ),
                                                SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    inW
                                                        ? 'In Withdrawal'
                                                        : 'Safe',
                                                    style: TextStyle(
                                                      color: inW
                                                          ? Colors
                                                              .orange.shade900
                                                          : Colors
                                                              .green.shade900,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ]),
                                      SizedBox(height: 10),
                                      Text(AppLocalizations.of(context)!.breed,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600])),
                                      SizedBox(height: 4),
                                      Text(a.breed,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      SizedBox(height: 8),
                                      Text(
                                          AppLocalizations.of(context)!
                                              .ageWithValue(a.age),
                                          style: TextStyle(
                                              color: Colors.grey[700])),
                                      Spacer(),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TextButton.icon(
                                                onPressed: () =>
                                                    _showAnimalDetails(a),
                                                icon: Icon(Icons.visibility,
                                                    size: 16),
                                                label: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .viewButton,
                                                    style: TextStyle(
                                                        fontSize: 12))),
                                            TextButton.icon(
                                                onPressed: () =>
                                                    _showAIHealthAnalysis(a),
                                                icon: Icon(Icons.smart_toy,
                                                    size: 16,
                                                    color: Colors.blue),
                                                label: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .aiButton,
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 12))),
                                            TextButton.icon(
                                                onPressed: () async {
                                                  final confirmed =
                                                      await showDialog<bool>(
                                                            context: context,
                                                            builder: (_) =>
                                                                AlertDialog(
                                                              title: Text(
                                                                  'Delete Animal'),
                                                              content: Text(
                                                                  'Are you sure you want to delete this animal? This action cannot be undone.'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context,
                                                                          false),
                                                                  child: Text(
                                                                      'Cancel'),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context,
                                                                          true),
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red
                                                                            .shade600,
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                                  child: Text(
                                                                      'Delete'),
                                                                ),
                                                              ],
                                                            ),
                                                          ) ??
                                                          false;

                                                  if (confirmed) {
                                                    await _deleteAnimal(a.id);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .deletedMessage)));
                                                  }
                                                },
                                                icon: Icon(Icons.delete,
                                                    size: 16,
                                                    color: Colors.red),
                                                label: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .deleteButton,
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 12)))
                                          ])
                                    ])));
                      }))
        ]));
  }

  Widget _buildPrescriptionsTab() {
    final prescriptions = _animals.where((a) => a.lastDrug != null).toList();

    if (prescriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 72, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noDigitalPrescriptions,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.prescriptionsWillAppearHere,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Group prescriptions by status
    final activePrescriptions =
        prescriptions.where((a) => _inWithdrawal(a)).toList();
    final completedPrescriptions = prescriptions
        .where((a) => !_inWithdrawal(a) && a.withdrawalEnd != null)
        .toList();
    final otherPrescriptions =
        prescriptions.where((a) => a.withdrawalEnd == null).toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Tab bar for prescription status
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 60, // Fixed height for consistent tab sizing
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              isScrollable: false,
              tabAlignment: TabAlignment.fill,
              indicator: BoxDecoration(
                color: Colors.teal.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade700,
              labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  height: 50, // Fixed tab height
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Active',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13)),
                      SizedBox(height: 2),
                      Text('${activePrescriptions.length}',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
                Tab(
                  height: 50, // Fixed tab height
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Completed',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13)),
                      SizedBox(height: 2),
                      Text('${completedPrescriptions.length}',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
                Tab(
                  height: 50, // Fixed tab height
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('All',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13)),
                      SizedBox(height: 2),
                      Text('${prescriptions.length}',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab bar view
          Expanded(
            child: TabBarView(
              children: [
                _buildPrescriptionList(
                    activePrescriptions, 'No active prescriptions'),
                _buildPrescriptionList(
                    completedPrescriptions, 'No completed prescriptions'),
                _buildPrescriptionList(prescriptions, 'No prescriptions found'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionList(
      List<Animal> prescriptions, String emptyMessage) {
    if (prescriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
            SizedBox(height: 12),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: prescriptions.length,
      itemBuilder: (ctx, i) {
        final animal = prescriptions[i];
        final isInWithdrawal = _inWithdrawal(animal);
        final latestTreatment = animal.treatmentHistory?.isNotEmpty == true
            ? animal.treatmentHistory!.last
            : null;
        final latestHealthNote = animal.healthNotes?.isNotEmpty == true
            ? animal.healthNotes!.last
            : null;

        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => _showEnhancedPrescriptionDetails(animal),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isInWithdrawal
                      ? Colors.orange.shade200
                      : Colors.green.shade200,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with animal info and status
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: isInWithdrawal
                              ? Colors.orange.shade50
                              : Colors.green.shade50,
                          child: Icon(
                            Icons.pets,
                            color: isInWithdrawal
                                ? Colors.orange.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${animal.species} - ${animal.breed}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'ID: ${animal.id}',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                              ),
                              if (latestTreatment?.condition != null)
                                Text(
                                  latestTreatment!.condition,
                                  style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                        ),
                        // Status badge
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isInWithdrawal
                                ? Colors.orange.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isInWithdrawal
                                  ? Colors.orange.shade300
                                  : Colors.green.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isInWithdrawal
                                    ? Icons.warning
                                    : Icons.check_circle,
                                color: isInWithdrawal
                                    ? Colors.orange.shade700
                                    : Colors.green.shade700,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                isInWithdrawal
                                    ? 'In Withdrawal'
                                    : 'Safe to Use',
                                style: TextStyle(
                                  color: isInWithdrawal
                                      ? Colors.orange.shade700
                                      : Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Medicine and dosage
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.medical_services,
                              color: Colors.blue.shade700),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  animal.lastDrug ?? 'N/A',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${animal.lastDosage ?? 'N/A'} mg/kg',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          if (latestTreatment?.cost != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '₹${latestTreatment!.cost!.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    // Withdrawal and MRL info
                    if (animal.withdrawalEnd != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoChip(
                              'Withdrawal',
                              '${animal.withdrawalDays ?? 0} days',
                              Icons.schedule,
                              isInWithdrawal ? Colors.orange : Colors.green,
                            ),
                          ),
                          Expanded(
                            child: _buildInfoChip(
                              'Ends',
                              DateTime.parse(animal.withdrawalEnd!)
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                              Icons.event,
                              isInWithdrawal ? Colors.orange : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (animal.currentMRL != null)
                        _buildInfoChip(
                          'Current MRL',
                          '${animal.currentMRL!.toStringAsFixed(3)} units',
                          Icons.show_chart,
                          animal.mrlStatus == 'Safe to Consume'
                              ? Colors.green
                              : Colors.red,
                        ),
                    ],

                    SizedBox(height: 12),

                    // Clinical summary
                    if (latestHealthNote != null ||
                        latestTreatment?.notes != null) ...[
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.medical_information,
                                    size: 16, color: Colors.grey.shade700),
                                SizedBox(width: 6),
                                Text(
                                  'Clinical Summary',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              latestHealthNote?.note ??
                                  latestTreatment?.notes ??
                                  'No clinical notes available',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                    ],

                    // Vet info and actions
                    Row(
                      children: [
                        if (animal.vetUsername != null) ...[
                          Icon(Icons.person, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            'Dr. ${animal.vetUsername}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          SizedBox(width: 16),
                        ],
                        Spacer(),
                        TextButton.icon(
                          onPressed: () =>
                              _showEnhancedPrescriptionDetails(animal),
                          icon: Icon(Icons.visibility, size: 16),
                          label: Text('View Details'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue.shade700,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                        if (animal.currentMRL != null)
                          IconButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => MRLGraphPage(animal: animal)),
                            ),
                            icon: Icon(Icons.show_chart, size: 20),
                            color: Colors.blue.shade700,
                            tooltip: 'View MRL Graph',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(
      String label, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color.shade700),
          SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEnhancedPrescriptionDetails(Animal animal) {
    final isInWithdrawal = _inWithdrawal(animal);
    final latestTreatment = animal.treatmentHistory?.isNotEmpty == true
        ? animal.treatmentHistory!.last
        : null;
    final latestHealthNote = animal.healthNotes?.isNotEmpty == true
        ? animal.healthNotes!.last
        : null;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                      child: Text('Complete Consultation Details',
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
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isInWithdrawal
                                ? 'Active Treatment'
                                : 'Treatment Completed',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (animal.withdrawalEnd != null)
                            Text(
                              isInWithdrawal
                                  ? 'Withdrawal period active until ${DateTime.parse(animal.withdrawalEnd!).toLocal().toString().split(' ')[0]}'
                                  : 'Safe to use products since ${DateTime.parse(animal.withdrawalEnd!).toLocal().toString().split(' ')[0]}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isInWithdrawal
                                    ? Colors.orange.shade700
                                    : Colors.green.shade700,
                              ),
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
                      _buildDetailSection(
                        'Animal Information',
                        Icons.pets,
                        Colors.blue,
                        [
                          _buildDetailRowEnhanced('Animal ID', animal.id),
                          _buildDetailRowEnhanced('Species & Breed',
                              '${animal.species} - ${animal.breed}'),
                          _buildDetailRowEnhanced('Age', animal.age),
                          if (animal.latestWeight > 0)
                            _buildDetailRowEnhanced('Current Weight',
                                '${animal.latestWeight.toStringAsFixed(1)} kg'),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Latest Treatment Details
                      if (latestTreatment != null) ...[
                        _buildDetailSection(
                          'Latest Treatment',
                          Icons.medical_services,
                          Colors.teal,
                          [
                            _buildDetailRowEnhanced(
                                'Medicine', latestTreatment.drugName),
                            _buildDetailRowEnhanced(
                                'Dosage', '${latestTreatment.dosage} mg/kg'),
                            _buildDetailRowEnhanced(
                                'Condition Treated', latestTreatment.condition),
                            _buildDetailRowEnhanced(
                                'Date Administered',
                                latestTreatment.dateAdministered
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0]),
                            _buildDetailRowEnhanced('Prescribed By',
                                'Dr. ${latestTreatment.administeredBy}'),
                            if (latestTreatment.cost != null)
                              _buildDetailRowEnhanced('Cost',
                                  '₹${latestTreatment.cost!.toStringAsFixed(0)}'),
                            if (latestTreatment.outcome != null)
                              _buildDetailRowEnhanced(
                                  'Outcome', latestTreatment.outcome!),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],

                      // Clinical Findings
                      if (latestHealthNote != null) ...[
                        _buildDetailSection(
                          'Clinical Examination',
                          Icons.medical_information,
                          Colors.purple,
                          [
                            _buildDetailRowEnhanced(
                                'Category',
                                latestHealthNote.category
                                    .replaceAll('_', ' ')
                                    .toUpperCase()),
                            _buildDetailRowEnhanced('Severity',
                                'Level ${latestHealthNote.severity}/5'),
                            _buildDetailRowEnhanced(
                                'Date Recorded',
                                latestHealthNote.dateCreated
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0]),
                            _buildDetailRowEnhanced('Recorded By',
                                'Dr. ${latestHealthNote.createdBy}'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clinical Findings:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                latestHealthNote.note,
                                style: TextStyle(color: Colors.purple.shade700),
                              ),
                              if (latestHealthNote.tags != null &&
                                  latestHealthNote.tags!.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Text(
                                  'Symptoms: ${latestHealthNote.tags!.join(', ')}',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.purple.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                      ],

                      // Treatment Notes
                      if (latestTreatment?.notes != null &&
                          latestTreatment!.notes!.isNotEmpty) ...[
                        _buildDetailSection(
                          'Treatment Notes',
                          Icons.note,
                          Colors.indigo,
                          [],
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.indigo.shade200),
                          ),
                          child: Text(
                            latestTreatment.notes!,
                            style: TextStyle(color: Colors.indigo.shade700),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],

                      // Withdrawal & MRL Information
                      if (animal.withdrawalEnd != null ||
                          animal.currentMRL != null) ...[
                        _buildDetailSection(
                          'Safety & Compliance',
                          Icons.shield,
                          Colors.green,
                          [
                            if (animal.withdrawalDays != null)
                              _buildDetailRowEnhanced('Withdrawal Period',
                                  '${animal.withdrawalDays} days'),
                            if (animal.withdrawalStart != null)
                              _buildDetailRowEnhanced(
                                  'Started',
                                  DateTime.parse(animal.withdrawalStart!)
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0]),
                            if (animal.withdrawalEnd != null)
                              _buildDetailRowEnhanced(
                                  'Ends',
                                  DateTime.parse(animal.withdrawalEnd!)
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0]),
                            if (animal.currentMRL != null)
                              _buildDetailRowEnhanced('Current MRL',
                                  '${animal.currentMRL!.toStringAsFixed(3)} units'),
                            if (animal.mrlStatus != null)
                              _buildDetailRowEnhanced(
                                  'MRL Status', animal.mrlStatus!),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],

                      // Treatment History Summary
                      if (animal.treatmentHistory != null &&
                          animal.treatmentHistory!.length > 1) ...[
                        _buildDetailSection(
                          'Treatment History',
                          Icons.history,
                          Colors.grey,
                          [
                            _buildDetailRowEnhanced('Total Treatments',
                                '${animal.treatmentHistory!.length}'),
                            _buildDetailRowEnhanced(
                                'First Treatment',
                                animal.treatmentHistory!.first.dateAdministered
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0]),
                            _buildDetailRowEnhanced(
                                'Last Treatment',
                                animal.treatmentHistory!.last.dateAdministered
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0]),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],

                      // Veterinary Information
                      _buildDetailSection(
                        'Veterinary Information',
                        Icons.person,
                        Colors.blue,
                        [
                          if (animal.vetUsername != null)
                            _buildDetailRowEnhanced('Consulting Veterinarian',
                                'Dr. ${animal.vetUsername}'),
                          if (animal.vetId != null)
                            _buildDetailRowEnhanced('Vet ID', animal.vetId!),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        MRLGraphPage(animal: animal)),
                              ),
                              icon: Icon(Icons.show_chart),
                              label: Text('View MRL Graph'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Could add share functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Consultation details ready for sharing')),
                                );
                              },
                              icon: Icon(Icons.share),
                              label: Text('Share'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
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

  Widget _buildDetailSection(
      String title, IconData icon, MaterialColor color, List<Widget> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color.shade700, size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(children: details),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowEnhanced(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodesTab() {
    if (_animals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code, size: 72, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noAnimalsAvailableMessage,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.addAnimalsToGenerateQrMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.qr_code_scanner,
                  color: Colors.blue.shade700, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.qrCertificateGeneratorTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.generateQrCodesDesc,
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

        // Date selector for QR generation
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey.shade600),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.qrGenerationDateLabel(
                      DateTime.now().toLocal().toString().split(' ')[0]),
                  style: TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  DateTime.now().toLocal().toString().split(' ')[0],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

        // Animals list for QR generation
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: _animals.length,
            itemBuilder: (ctx, i) {
              final animal = _animals[i];
              final isInWithdrawal = _inWithdrawal(animal);

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isInWithdrawal
                          ? Colors.orange.shade300
                          : Colors.green.shade300,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animal header with status
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: isInWithdrawal
                                  ? Colors.orange.shade100
                                  : Colors.green.shade100,
                              child: Icon(
                                Icons.pets,
                                color: isInWithdrawal
                                    ? Colors.orange.shade700
                                    : Colors.green.shade700,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .speciesBreedDisplay(
                                            animal.species, animal.breed),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .idDisplay(animal.id),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Status indicator
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              constraints: BoxConstraints(maxWidth: 120),
                              decoration: BoxDecoration(
                                color: isInWithdrawal
                                    ? Colors.orange.shade100
                                    : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isInWithdrawal
                                      ? Colors.orange.shade300
                                      : Colors.green.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isInWithdrawal
                                        ? Icons.warning
                                        : Icons.check_circle,
                                    color: isInWithdrawal
                                        ? Colors.orange.shade700
                                        : Colors.green.shade700,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      isInWithdrawal ? 'In Withdrawal' : 'Safe',
                                      style: TextStyle(
                                        color: isInWithdrawal
                                            ? Colors.orange.shade900
                                            : Colors.green.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12),

                        // Withdrawal info if applicable
                        if (animal.withdrawalEnd != null) ...[
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isInWithdrawal
                                  ? Colors.orange.shade50
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isInWithdrawal
                                    ? Colors.orange.shade200
                                    : Colors.green.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isInWithdrawal
                                      ? Icons.schedule
                                      : Icons.check_circle_outline,
                                  color: isInWithdrawal
                                      ? Colors.orange.shade700
                                      : Colors.green.shade700,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isInWithdrawal
                                            ? AppLocalizations.of(context)!
                                                .withdrawalPeriodActiveMessage
                                            : AppLocalizations.of(context)!
                                                .withdrawalPeriodCompletedMessage,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isInWithdrawal
                                              ? Colors.orange.shade900
                                              : Colors.green.shade900,
                                        ),
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .endsDateDisplay(DateTime.parse(
                                                    animal.withdrawalEnd!)
                                                .toLocal()
                                                .toString()
                                                .split(' ')[0]),
                                        style: TextStyle(
                                          color: isInWithdrawal
                                              ? Colors.orange.shade700
                                              : Colors.green.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                        ],

                        // Generate QR button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _generateAnimalQR(animal, isInWithdrawal),
                            icon: Icon(Icons.qr_code),
                            label: Text(AppLocalizations.of(context)!
                                .generateQrCertificateButton),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInWithdrawal
                                  ? Colors.orange.shade600
                                  : Colors.green.shade600,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _generateAnimalQR(Animal animal, bool isInWithdrawal) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.generatingQrCertificateMessage),
          ],
        ),
      ),
    );

    try {
      // Ensure QR service is initialized
      await qrService.init();

      // Generate certificate with current date
      final cert = qrService.generateCertificate(animal);

      // Close loading dialog
      Navigator.pop(context);

      // Show QR code with safety status
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.qr_code,
                color: isInWithdrawal
                    ? Colors.orange.shade700
                    : Colors.green.shade700,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.qrCertificateGeneratedTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Safety status alert
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isInWithdrawal
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isInWithdrawal
                          ? Colors.red.shade300
                          : Colors.green.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isInWithdrawal ? Icons.warning : Icons.check_circle,
                        color: isInWithdrawal
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                        size: 48,
                      ),
                      SizedBox(height: 8),
                      Text(
                        isInWithdrawal
                            ? AppLocalizations.of(context)!
                                .animalInWithdrawalWarning
                            : AppLocalizations.of(context)!
                                .safeToConsumeMessage,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isInWithdrawal
                              ? Colors.red.shade900
                              : Colors.green.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isInWithdrawal) ...[
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!
                              .doNotConsumeProductsWarning,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // QR Code
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: CustomPaint(
                    painter: qr_flutter.QrPainter(
                      data: cert.toJson(),
                      version: qr_flutter.QrVersions.auto,
                      errorCorrectionLevel: qr_flutter.QrErrorCorrectLevel.M,
                    ),
                    size: Size(200, 200),
                  ),
                ),

                SizedBox(height: 12),

                // Certificate details
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Certificate Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildDetailRow('Animal ID', animal.id),
                      _buildDetailRow(
                          'Species', '${animal.species} - ${animal.breed}'),
                      _buildDetailRow('Farmer ID', _farmerId ?? 'Unknown'),
                      _buildDetailRow('Generated Date',
                          DateTime.now().toLocal().toString().split(' ')[0]),
                      _buildDetailRow('Valid Until',
                          cert.expiresAt.toLocal().toString().split(' ')[0]),
                      if (animal.withdrawalEnd != null)
                        _buildDetailRow(
                          'Withdrawal Ends',
                          DateTime.parse(animal.withdrawalEnd!)
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Could add share functionality here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('QR Certificate ready for sharing')),
                );
              },
              icon: Icon(Icons.share),
              label: Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to generate QR certificate: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color.shade700, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color.shade900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
