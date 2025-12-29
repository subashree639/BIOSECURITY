import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/farm.dart';
import '../models/animal.dart';
import '../models/user.dart';
import '../models/consultation.dart';
import '../services/animal_storage.dart';
import '../services/auth_service.dart';

class DiseaseInfo {
  final String name;
  final String cause;
  final String symptoms;

  const DiseaseInfo({
    required this.name,
    required this.cause,
    required this.symptoms,
  });
}

class AnimalConsultationScreen extends StatefulWidget {
  const AnimalConsultationScreen({super.key});

  @override
  State<AnimalConsultationScreen> createState() => _AnimalConsultationScreenState();
}

class _AnimalConsultationScreenState extends State<AnimalConsultationScreen> with TickerProviderStateMixin {
  final _phoneNumberController = TextEditingController();
  String _selectedSpecies = '';
  Farm? _selectedFarm;
  List<Animal> _farmAnimals = [];
  List<Consultation> _animalConsultations = [];
  bool _isSearching = false;
  bool _isLoadingAnimals = false;
  bool _isLoadingConsultations = false;
  late TabController _tabController;

  // Consultation form controllers
  final _diseaseController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedStatus = 'Under Treatment';
  DateTime _followUpDate = DateTime.now().add(const Duration(days: 7));

  final List<String> _speciesOptions = ['pig', 'poultry'];
  final List<String> _statusOptions = ['Under Treatment', 'Recovered', 'Vaccinated', 'Resolved'];

  // Disease data
  final List<DiseaseInfo> _pigDiseases = const [
    DiseaseInfo(
      name: 'Swine Fever (Classical or African)',
      cause: 'Virus',
      symptoms: 'High fever, red skin patches, death',
    ),
    DiseaseInfo(
      name: 'Foot and Mouth Disease (FMD)',
      cause: 'Virus',
      symptoms: 'Blisters on mouth and feet, drooling',
    ),
    DiseaseInfo(
      name: 'Porcine Reproductive and Respiratory Syndrome (PRRS)',
      cause: 'Virus',
      symptoms: 'Breathing issues, abortions',
    ),
    DiseaseInfo(
      name: 'Swine Dysentery',
      cause: 'Bacteria',
      symptoms: 'Severe diarrhea with blood',
    ),
    DiseaseInfo(
      name: 'Leptospirosis',
      cause: 'Bacteria',
      symptoms: 'Fever, kidney damage, abortions',
    ),
    DiseaseInfo(
      name: 'Mange',
      cause: 'Parasite (mites)',
      symptoms: 'Itchy skin, hair loss',
    ),
  ];

  final List<DiseaseInfo> _poultryDiseases = const [
    DiseaseInfo(
      name: 'Newcastle Disease',
      cause: 'Virus',
      symptoms: 'Twisted neck, breathing issues, sudden death',
    ),
    DiseaseInfo(
      name: 'Avian Influenza (Bird Flu)',
      cause: 'Virus',
      symptoms: 'Swollen head, diarrhea, drop in egg production',
    ),
    DiseaseInfo(
      name: 'Marek\'s Disease',
      cause: 'Virus',
      symptoms: 'Paralysis of legs/wings',
    ),
    DiseaseInfo(
      name: 'Coccidiosis',
      cause: 'Parasite',
      symptoms: 'Blood in droppings, weakness',
    ),
    DiseaseInfo(
      name: 'Fowl Pox',
      cause: 'Virus',
      symptoms: 'Scabs on comb/wattles',
    ),
    DiseaseInfo(
      name: 'Salmonellosis',
      cause: 'Bacteria',
      symptoms: 'Diarrhea, weakness',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _diseaseController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Animal Consultation',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medical_services,
              color: Color(0xFF2196F3),
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step 1: Phone Number Search
              _buildStepHeader('Step 1: Find Farmer', Icons.search, 1),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Enter Phone Number',
                        hintText: 'e.g., 8072098201, 9876543210',
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Color(0xFF2196F3),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSearching ? null : _searchFarmer,
                        icon: _isSearching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(_isSearching ? 'Searching...' : 'Search Farmer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Farm Info Display
              if (_selectedFarm != null) ...[
                const SizedBox(height: 24),
                _buildFarmInfoCard(),
              ],

              // Step 2: Species Selection
              if (_selectedFarm != null) ...[
                const SizedBox(height: 24),
                _buildStepHeader('Step 2: Select Species', Icons.pets, 2),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSpeciesCard('Pig', 'Sus scrofa domesticus', Icons.pets, 'pig', Colors.pink),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSpeciesCard('Poultry', 'Gallus gallus domesticus', Icons.egg, 'poultry', Colors.amber),
                    ),
                  ],
                ),
              ],

              // Step 3: Animal Consultation
              if (_selectedFarm != null && _selectedSpecies.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildStepHeader('Step 3: Consult Animals', Icons.medical_services, 3),
                const SizedBox(height: 16),
                if (_isLoadingAnimals)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_farmAnimals.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: const Center(
                      child: Text(
                        'No animals found for this species',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else
                  _buildAnimalsList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(String title, IconData icon, int stepNumber) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2196F3),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$stepNumber',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFarmInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Farmer Found',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Farm: ${_selectedFarm!.farmName}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Owner: ${_selectedFarm!.ownerName}',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Text(
            'Location: ${_selectedFarm!.locationText ?? "Not specified"}',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesCard(String title, String subtitle, IconData icon, String species, Color color) {
    final isSelected = _selectedSpecies == species;
    return GestureDetector(
      onTap: () => _selectSpecies(species),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _farmAnimals.length,
      itemBuilder: (context, index) {
        return _buildAnimalCard(_farmAnimals[index]);
      },
    );
  }

  Widget _buildAnimalCard(Animal animal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 2,
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
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pets,
                  color: Color(0xFF2196F3),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${animal.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Breed: ${animal.breed}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getHealthColor(animal.healthStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  animal.healthStatus ?? 'Unknown',
                  style: TextStyle(
                    color: _getHealthColor(animal.healthStatus),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tab Bar for Disease, History, and Consult
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.coronavirus, size: 16),
                      SizedBox(width: 4),
                      Text('Disease', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 16),
                      SizedBox(width: 4),
                      Text('History', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medical_services, size: 16),
                      SizedBox(width: 4),
                      Text('Consult', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Tab Content
          SizedBox(
            height: 500, // Increased height for tab content
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDiseaseTab(animal),
                _buildHistoryTab(animal),
                _buildConsultationTab(animal),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseTab(Animal animal) {
    final diseases = animal.species == 'pig' ? _pigDiseases : _poultryDiseases;
    final speciesName = animal.species == 'pig' ? 'Pigs' : 'Poultry';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(
                animal.species == 'pig' ? Icons.pets : Icons.egg,
                color: Colors.blue[700],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Common Diseases in $speciesName',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: diseases.length,
            itemBuilder: (context, index) {
              final disease = diseases[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disease.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Cause: ${disease.cause}',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Symptoms: ${disease.symptoms}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(Animal animal) {
    // Load consultations if not already loaded
    if (_animalConsultations.isEmpty && !_isLoadingConsultations) {
      _loadAnimalConsultations(animal.id);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.history,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Medical History',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingConsultations)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_animalConsultations.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No consultation history available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _animalConsultations.length,
              itemBuilder: (context, index) {
                final consultation = _animalConsultations[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Consultation',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(consultation.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              consultation.status,
                              style: TextStyle(
                                color: _getStatusColor(consultation.status),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Disease: ${consultation.disease}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      if (consultation.diagnosis.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Diagnosis: ${consultation.diagnosis}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                      if (consultation.treatment.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Treatment: ${consultation.treatment}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
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
                            consultation.vetName,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (consultation.followUpDate.isNotEmpty) ...[
                        const SizedBox(height: 4),
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
              },
            ),
          ),
      ],
    );
  }

  Widget _buildConsultationTab(Animal animal) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Consultation Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  animal.species == 'pig' ? Icons.pets : Icons.egg,
                  color: Colors.blue[700],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Consultation for ${animal.tagNumber ?? 'Animal #${animal.id}'}',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Disease Field with Autocomplete
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              final diseases = animal.species == 'pig' ? _pigDiseases : _poultryDiseases;
              final diseaseNames = diseases.map((d) => d.name).toList();

              return diseaseNames.where((String option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              _diseaseController.text = selection;
            },
            fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
              // Sync with our controller
              fieldTextEditingController.text = _diseaseController.text;
              fieldTextEditingController.addListener(() {
                _diseaseController.text = fieldTextEditingController.text;
              });

              return TextFormField(
                controller: fieldTextEditingController,
                focusNode: fieldFocusNode,
                decoration: InputDecoration(
                  labelText: 'Disease/Symptoms',
                  hintText: 'Enter diagnosed disease or symptoms',
                  prefixIcon: const Icon(Icons.coronavirus, color: Colors.red),
                  suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 2,
              );
            },
            optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 200, maxWidth: double.infinity),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: index < options.length - 1
                                  ? Border(bottom: BorderSide(color: Colors.grey[100]!))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.coronavirus, color: Colors.red, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Diagnosis Field
          TextFormField(
            controller: _diagnosisController,
            decoration: InputDecoration(
              labelText: 'Diagnosis',
              hintText: 'Detailed diagnosis description',
              prefixIcon: const Icon(Icons.medical_services, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          // Treatment Field
          TextFormField(
            controller: _treatmentController,
            decoration: InputDecoration(
              labelText: 'Treatment Plan',
              hintText: 'Prescribed treatment and medications',
              prefixIcon: const Icon(Icons.healing, color: Colors.green),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          // Status Dropdown
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Status',
              prefixIcon: const Icon(Icons.flag, color: Colors.orange),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: _statusOptions.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Follow-up Date
          InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _followUpDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (pickedDate != null) {
                setState(() {
                  _followUpDate = pickedDate;
                });
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Follow-up Date',
                prefixIcon: const Icon(Icons.calendar_today, color: Colors.purple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              child: Text(
                '${_followUpDate.day}/${_followUpDate.month}/${_followUpDate.year}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notes Field
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Additional Notes',
              hintText: 'Any additional observations or recommendations',
              prefixIcon: const Icon(Icons.note, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 24),

          // Save Consultation Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _saveConsultation(animal),
              icon: const Icon(Icons.save),
              label: const Text('Save Consultation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveConsultation(Animal animal) async {
    if (_diseaseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the disease/symptoms'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final vet = authService.currentUser;

      // Create consultation record
      final consultation = Consultation(
        id: 'CONS${DateTime.now().millisecondsSinceEpoch}',
        animalId: animal.id,
        animalName: animal.tagNumber ?? 'Animal #${animal.id}',
        species: animal.species,
        disease: _diseaseController.text.trim(),
        consultationDate: DateTime.now().toString().split(' ')[0],
        vetName: vet?.name ?? 'Unknown Vet',
        vetId: vet?.id.toString() ?? 'VET_UNKNOWN',
        diagnosis: _diagnosisController.text.trim(),
        treatment: _treatmentController.text.trim(),
        status: _selectedStatus,
        followUpDate: _followUpDate.toString().split(' ')[0],
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Save to database
      await DatabaseHelper().insertConsultation(consultation);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Consultation saved for ${animal.tagNumber ?? 'Animal #${animal.id}'}'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _diseaseController.clear();
      _diagnosisController.clear();
      _treatmentController.clear();
      _notesController.clear();
      setState(() {
        _selectedStatus = 'Under Treatment';
        _followUpDate = DateTime.now().add(const Duration(days: 7));
      });

      // Refresh consultations list
      await _loadAnimalConsultations(animal.id);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving consultation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildConsultButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _searchFarmer() async {
    if (_phoneNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      // First, find the user by phone number
      final users = await DatabaseHelper().getUsers();
      final user = users.firstWhere(
        (u) => u.mobileNumber == _phoneNumberController.text.trim(),
        orElse: () => User(name: '', role: '', createdAt: DateTime.now()),
      );

      if (user.id != null) {
        // Now find the farm associated with this user
        final farms = await DatabaseHelper().getFarms();
        final farm = farms.firstWhere(
          (f) => f.createdBy == user.id,
          orElse: () => Farm(
            ownerName: '',
            farmName: 'Not Found',
            species: '',
            size: 0,
            createdBy: -1,
          ),
        );

        if (farm.createdBy != -1) {
          setState(() {
            _selectedFarm = farm;
            _selectedSpecies = ''; // Reset species selection
            _farmAnimals = []; // Reset animals
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found farm: ${farm.farmName}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() => _selectedFarm = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Farm not found for this phone number'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() => _selectedFarm = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching farmer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _selectSpecies(String species) {
    setState(() {
      _selectedSpecies = species;
      _farmAnimals = [];
    });
    _loadFarmAnimals();
  }

  Future<void> _loadFarmAnimals() async {
    if (_selectedFarm == null || _selectedSpecies.isEmpty) return;

    setState(() => _isLoadingAnimals = true);

    try {
      final animalStorage = AnimalStorageService();
      final allAnimals = await animalStorage.getAllAnimals();

      // Filter animals by farmer and species
      final farmAnimals = allAnimals.where((animal) {
        // Check if animal belongs to this farmer (you might need to adjust this logic)
        // For now, we'll show all animals of the selected species
        return animal.species == _selectedSpecies;
      }).toList();

      setState(() => _farmAnimals = farmAnimals);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading animals: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoadingAnimals = false);
    }
  }

  Future<void> _loadAnimalConsultations(String animalId) async {
    setState(() => _isLoadingConsultations = true);

    try {
      final consultations = await DatabaseHelper().getConsultationsByAnimal(animalId);
      setState(() => _animalConsultations = consultations);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading consultations: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoadingConsultations = false);
    }
  }


  Color _getHealthColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'sick':
        return Colors.red;
      case 'recovering':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'recovered':
        return Colors.green;
      case 'under treatment':
        return Colors.orange;
      case 'vaccinated':
        return Colors.blue;
      case 'resolved':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}