import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';
import '../models/farm.dart';
import '../models/animal.dart';
import '../models/consultation.dart';
import '../services/animal_storage.dart';

class IndiaMapScreen extends StatefulWidget {
  const IndiaMapScreen({super.key});

  @override
  State<IndiaMapScreen> createState() => _IndiaMapScreenState();
}

class _IndiaMapScreenState extends State<IndiaMapScreen> {
  MapController? _mapController;
  List<Marker> _markers = [];
  List<CircleMarker> _circleMarkers = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  // India center coordinates
  static const latlong.LatLng _indiaCenter = latlong.LatLng(20.5937, 78.9629);

  final List<String> _filterOptions = ['all', 'farms', 'animals', 'diseases'];

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser != null) {
        print('Loading map data for user: ${currentUser.role}');
        await _loadFarmMarkers();
        await _loadAnimalMarkers();
        await _loadDiseaseMarkers();
        print('Map data loaded successfully. Markers: ${_markers.length}, Circles: ${_circleMarkers.length}');
      } else {
        print('No current user found for map data');
      }
    } catch (e) {
      print('Error loading map data: $e');
      // Don't rethrow, just log and continue
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFarmMarkers() async {
    try {
      final farms = await DatabaseHelper().getFarms();

      for (final farm in farms) {
        if (farm.latitude != null && farm.longitude != null) {
          final marker = Marker(
            point: latlong.LatLng(farm.latitude!, farm.longitude!),
            child: GestureDetector(
              onTap: () => _showFarmDetails(farm),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          );

          _markers.add(marker);
        }
      }
    } catch (e) {
      print('Error loading farm markers: $e');
    }
  }

  Future<void> _loadAnimalMarkers() async {
    try {
      final animalStorage = AnimalStorageService();
      final animals = await animalStorage.getAllAnimals();

      for (final animal in animals) {
        // For demo purposes, we'll place animals near their farms
        // In a real app, animals would have their own GPS coordinates
        final farms = await DatabaseHelper().getFarms();
        final farm = farms.firstWhere(
          (f) => f.createdBy.toString() == animal.farmerId,
          orElse: () => Farm(
            ownerName: '',
            farmName: 'Unknown Farm',
            species: animal.species,
            size: 0,
            createdBy: -1,
          ),
        );

        if (farm.latitude != null && farm.longitude != null) {
          // Add some random offset for animal markers
          final offset = 0.001; // ~100 meters
          final position = latlong.LatLng(
            farm.latitude! + (animal.id.hashCode % 10 - 5) * offset,
            farm.longitude! + (animal.id.hashCode % 10 - 5) * offset,
          );

          final marker = Marker(
            point: position,
            child: GestureDetector(
              onTap: () => _showAnimalDetails(animal, farm),
              child: Container(
                decoration: BoxDecoration(
                  color: animal.species == 'pig' ? Colors.orange : Colors.cyan,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  animal.species == 'pig' ? Icons.pets : Icons.egg,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          );

          _markers.add(marker);
        }
      }
    } catch (e) {
      print('Error loading animal markers: $e');
    }
  }

  Future<void> _loadDiseaseMarkers() async {
    try {
      final consultations = await DatabaseHelper().getConsultations();

      // Group consultations by location to show disease hotspots
      final diseaseClusters = <String, List<Consultation>>{};

      for (final consultation in consultations) {
        // Find farm location for this consultation
        final farms = await DatabaseHelper().getFarms();
        final farm = farms.firstWhere(
          (f) => f.createdBy.toString() == consultation.animalId.split('_')[0], // Extract farmer ID
          orElse: () => Farm(
            ownerName: '',
            farmName: 'Unknown Farm',
            species: consultation.species,
            size: 0,
            createdBy: -1,
          ),
        );

        if (farm.latitude != null && farm.longitude != null) {
          final locationKey = '${farm.latitude!.toStringAsFixed(2)}_${farm.longitude!.toStringAsFixed(2)}';

          if (!diseaseClusters.containsKey(locationKey)) {
            diseaseClusters[locationKey] = [];
          }
          diseaseClusters[locationKey]!.add(consultation);
        }
      }

      // Add sample disease outbreak data for Tamil Nadu and other regions
      final sampleDiseaseData = [
        {
          'position': const latlong.LatLng(13.0827, 80.2707), // Chennai, Tamil Nadu
          'disease': 'Avian Influenza',
          'affectedAnimals': 150,
          'species': 'poultry',
          'description': 'H5N1 outbreak in commercial poultry farm'
        },
        {
          'position': const latlong.LatLng(10.7905, 78.7047), // Tiruchirappalli, Tamil Nadu
          'disease': 'Swine Fever',
          'affectedAnimals': 75,
          'species': 'pig',
          'description': 'Classical swine fever outbreak'
        },
        {
          'position': const latlong.LatLng(11.0168, 76.9558), // Coimbatore, Tamil Nadu
          'disease': 'Foot and Mouth Disease',
          'affectedAnimals': 200,
          'species': 'pig',
          'description': 'FMD outbreak affecting multiple farms'
        },
        {
          'position': const latlong.LatLng(12.9716, 77.5946), // Bangalore, Karnataka
          'disease': 'Newcastle Disease',
          'affectedAnimals': 120,
          'species': 'poultry',
          'description': 'Velogenic Newcastle disease outbreak'
        },
        {
          'position': const latlong.LatLng(28.6139, 77.2090), // Delhi
          'disease': 'Avian Influenza',
          'affectedAnimals': 300,
          'species': 'poultry',
          'description': 'H5N8 outbreak in urban poultry'
        },
        {
          'position': const latlong.LatLng(19.0760, 72.8777), // Mumbai, Maharashtra
          'disease': 'Swine Fever',
          'affectedAnimals': 90,
          'species': 'pig',
          'description': 'African swine fever detected'
        },
      ];

      // Create disease outbreak markers from real data
      diseaseClusters.forEach((locationKey, consultations) {
        final coords = locationKey.split('_');
        final position = latlong.LatLng(double.parse(coords[0]), double.parse(coords[1]));

        final diseaseCount = consultations.length;
        final mainDisease = consultations.first.disease;

        final marker = Marker(
          point: position,
          child: GestureDetector(
            onTap: () => _showDiseaseOutbreakDetails(consultations, position),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );

        _markers.add(marker);

        // Temporarily disable danger zone circles to ensure map visibility
        // TODO: Re-enable with proper zoom-level conditional rendering
        // final circleMarker = CircleMarker(
        //   point: position,
        //   radius: 3000,
        //   color: Colors.red.withOpacity(0.08),
        //   borderColor: Colors.red.withOpacity(0.3),
        //   borderStrokeWidth: 1,
        // );
        // _circleMarkers.add(circleMarker);
      });

      // Create sample disease outbreak markers
      for (final diseaseData in sampleDiseaseData) {
        final position = diseaseData['position'] as latlong.LatLng;
        final disease = diseaseData['disease'] as String;
        final affectedAnimals = diseaseData['affectedAnimals'] as int;
        final species = diseaseData['species'] as String;
        final description = diseaseData['description'] as String;

        final marker = Marker(
          point: position,
          child: GestureDetector(
            onTap: () => _showSampleDiseaseDetails(disease, affectedAnimals, species, description, position),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.warning,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        );

        _markers.add(marker);

        // Temporarily disable danger zone circles to ensure map visibility
        // TODO: Re-enable with proper zoom-level conditional rendering
        // final circleMarker = CircleMarker(
        //   point: position,
        //   radius: 1000,
        //   color: Colors.red.withOpacity(0.03),
        //   borderColor: Colors.red.withOpacity(0.1),
        //   borderStrokeWidth: 1,
        // );
        // _circleMarkers.add(circleMarker);
      }
    } catch (e) {
      print('Error loading disease markers: $e');
    }
  }

  void _showFarmDetails(Farm farm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    farm.farmName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Owner', farm.ownerName),
            _buildInfoRow('Species', farm.species),
            _buildInfoRow('Size', '${farm.size} animals'),
            if (farm.locationText != null)
              _buildInfoRow('Location', farm.locationText!),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnimalDetails(Animal animal, Farm farm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    animal.species == 'pig' ? Icons.pets : Icons.egg,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Animal ID: ${animal.id}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Breed', animal.breed),
            _buildInfoRow('Species', animal.species),
            _buildInfoRow('Health Status', animal.healthStatus ?? 'Unknown'),
            _buildInfoRow('Farm', farm.farmName),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSampleDiseaseDetails(String disease, int affectedAnimals, String species, String description, latlong.LatLng position) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.warning, color: Colors.red),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Disease Outbreak Alert',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.coronavirus, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        disease,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Affected Animals', '$affectedAnimals ${species}s'),
                  _buildInfoRow('Species', species),
                  _buildInfoRow('Description', description),
                  _buildInfoRow('Location', '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close Alert'),
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

  void _showDiseaseOutbreakDetails(List<Consultation> consultations, latlong.LatLng position) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.warning, color: Colors.red),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Disease Outbreak Alert',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${consultations.length} reported cases in this area',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: consultations.length,
                itemBuilder: (context, index) {
                  final consultation = consultations[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consultation.disease,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Animal: ${consultation.animalName}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Vet: ${consultation.vetName} (${consultation.vetId})',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Date: ${consultation.consultationDate}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _filterMarkers(String filter) {
    setState(() {
      _selectedFilter = filter;
      // In a real implementation, you would filter the markers based on the selected filter
      // For now, we'll just update the UI state
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.map,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'India Disease Map',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onSelected: _filterMarkers,
            itemBuilder: (context) => _filterOptions.map((filter) {
              return PopupMenuItem(
                value: filter,
                child: Text(
                  filter == 'all' ? 'Show All' :
                  filter == 'farms' ? 'Farms Only' :
                  filter == 'animals' ? 'Animals Only' :
                  'Disease Outbreaks Only',
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: _isLoading
          ? Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading disease map...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _buildMapOrPlaceholder(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController?.move(_indiaCenter, 5.0);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.center_focus_strong),
        tooltip: 'Center on India',
      ),
    );
  }

  Widget _buildMapOrPlaceholder() {
    print('Building OSM map widget. Markers: ${_markers.length}, IsLoading: $_isLoading');

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _indiaCenter,
        initialZoom: 5.0,
        maxZoom: 18.0,
        minZoom: 3.0,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.dfm',
        ),
        MarkerLayer(
          markers: _markers,
        ),
        CircleLayer(
          circles: _circleMarkers,
        ),
      ],
    );
  }

}