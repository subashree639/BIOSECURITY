import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/animal_storage.dart';
import '../data/medicine_data.dart';
import '../models/animal.dart';
import '../services/ai_service.dart';

class VetConsultFormPage extends StatefulWidget {
  final Animal animal;
  VetConsultFormPage({required this.animal});
  @override
  _VetConsultFormPageState createState() => _VetConsultFormPageState();
}

class _VetConsultFormPageState extends State<VetConsultFormPage>
    with TickerProviderStateMixin {
  // Existing controllers
  final _med = TextEditingController();
  final _dose = TextEditingController();
  final _notes = TextEditingController();
  final _withdrawalDays = TextEditingController(text: '7');
  final _storage = AnimalStorageService();

  // New controllers for enhanced consultation
  final _temperature = TextEditingController();
  final _heartRate = TextEditingController();
  final _respiratoryRate = TextEditingController();
  final _bodyConditionScore = TextEditingController();
  final _clinicalFindings = TextEditingController();
  final _diagnosis = TextEditingController();
  final _treatmentPlan = TextEditingController();
  final _followUpNotes = TextEditingController();
  final _costEstimate = TextEditingController();
  final _labTests = TextEditingController();

  // Services
  final AIService _aiService = AIService();
  final ImagePicker _imagePicker = ImagePicker();

  // State variables
  bool _saving = false;
  bool _analyzingImage = false;
  int _currentStep = 0;
  late TabController _tabController;

  // Existing variables
  String _selectedProductType = 'milk'; // 'milk', 'meat', 'eggs'
  int? _calculatedWithdrawalDays;
  double? _currentMRL;
  String? _mrlStatus;

  // New state variables
  String _selectedCondition = 'General Checkup';
  String _selectedUrgency = 'Routine';
  List<String> _selectedSymptoms = [];
  List<String> _selectedLabTests = [];
  List<File> _capturedImages = [];
  Map<String, dynamic> _aiAnalysis = {};
  bool _showAIRecommendations = false;

  // Default medicines with withdrawal periods
  final List<Map<String, dynamic>> _defaultMedicines = [
    {'name': 'Amoxicillin', 'dosage': '10', 'withdrawal': 7},
    {'name': 'Meloxicam', 'dosage': '0.5', 'withdrawal': 5},
    {'name': 'Albendazole', 'dosage': '7.5', 'withdrawal': 14},
    {'name': 'Ceftiofur', 'dosage': '1.1', 'withdrawal': 4},
    {'name': 'Florfenicol', 'dosage': '20', 'withdrawal': 28},
    {'name': 'Enrofloxacin', 'dosage': '2.5', 'withdrawal': 14},
    {'name': 'Tilmicosin', 'dosage': '10', 'withdrawal': 42},
    {'name': 'Tulathromycin', 'dosage': '2.5', 'withdrawal': 18},
    {'name': 'Procaine penicillin', 'dosage': '7', 'withdrawal': 10},
    {'name': 'Vitamin B Complex', 'dosage': '5-10', 'withdrawal': 0}
  ];

  // Consultation steps
  final List<String> _consultationSteps = [
    'Initial Assessment',
    'Clinical Examination',
    'Diagnosis & Treatment',
    'Prescription & Follow-up'
  ];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _consultationSteps.length, vsync: this);

    // Initialize existing data
    _med.text = widget.animal.lastDrug ?? '';
    _dose.text = widget.animal.lastDosage ?? '';
    _selectedProductType = widget.animal.productType ?? 'milk';

    // Load existing withdrawal data if available
    if (widget.animal.withdrawalDays != null) {
      _withdrawalDays.text = widget.animal.withdrawalDays.toString();
    }

    _calculateMRL();
  }

  @override
  void dispose() {
    _tabController.dispose();

    // Dispose existing controllers
    _med.dispose();
    _dose.dispose();
    _notes.dispose();
    _withdrawalDays.dispose();

    // Dispose new controllers
    _temperature.dispose();
    _heartRate.dispose();
    _respiratoryRate.dispose();
    _bodyConditionScore.dispose();
    _clinicalFindings.dispose();
    _diagnosis.dispose();
    _treatmentPlan.dispose();
    _followUpNotes.dispose();
    _costEstimate.dispose();
    _labTests.dispose();

    super.dispose();
  }

  void _calculateMRL() {
    final medicineName = _med.text.trim();
    if (medicineName.isEmpty) return;

    final animalMedicines = MEDICINES[widget.animal.species];
    if (animalMedicines == null || !animalMedicines.containsKey(medicineName)) {
      // If medicine not found, set default values
      setState(() {
        _calculatedWithdrawalDays = 7;
        _withdrawalDays.text = '7';
      });
      return;
    }

    final medicineSpecs = animalMedicines[medicineName]!;
    final withdrawalDays =
        getWithdrawalDays(medicineSpecs, _selectedProductType);

    setState(() {
      _calculatedWithdrawalDays =
          withdrawalDays ?? 7; // Default to 7 days if null
      _withdrawalDays.text = (withdrawalDays ?? 7).toString();
    });

    // Calculate current MRL
    final dosage = double.tryParse(_dose.text) ??
        medicineSpecs['dosage_mg_per_kg'] as double? ??
        0.0;
    final daysElapsed = widget.animal.withdrawalStart != null
        ? DateTime.now()
            .difference(DateTime.parse(widget.animal.withdrawalStart!))
            .inDays
        : 0;

    final mrl = computeMRL(dosage, daysElapsed, withdrawalDays);

    String status = 'Unknown';
    if (daysElapsed >= (withdrawalDays ?? 0) && (withdrawalDays ?? 0) > 0) {
      status = 'Safe to Consume';
    } else {
      status = mrl > safeThreshold ? 'Unsafe to Consume' : 'Safe to Consume';
    }

    setState(() {
      _currentMRL = mrl;
      _mrlStatus = status;
    });
  }

  // Image capture methods
  Future<void> _captureImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (image != null) {
        setState(() {
          _capturedImages.add(File(image.path));
        });
        await _analyzeImage(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    }
  }

  Future<void> _analyzeImage(File image) async {
    setState(() => _analyzingImage = true);
    try {
      // Mock AI analysis for now - replace with actual AI service when available
      await Future.delayed(Duration(seconds: 2)); // Simulate processing time
      final mockAnalysis = {
        'findings':
            'Image analysis completed. No visible abnormalities detected in the captured image.',
        'confidence': 0.85,
        'recommendations':
            'Continue monitoring the animal. Consider follow-up examination if symptoms persist.'
      };
      setState(() {
        _aiAnalysis = mockAnalysis;
        _showAIRecommendations = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI analysis failed: $e')),
      );
    } finally {
      setState(() => _analyzingImage = false);
    }
  }

  // Symptom selection methods
  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
    });
  }

  // Lab test selection methods
  void _toggleLabTest(String test) {
    setState(() {
      if (_selectedLabTests.contains(test)) {
        _selectedLabTests.remove(test);
      } else {
        _selectedLabTests.add(test);
      }
    });
  }

  // Get AI recommendations
  Future<void> _getAIRecommendations() async {
    if (_selectedSymptoms.isEmpty && _clinicalFindings.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please add symptoms or clinical findings first')),
      );
      return;
    }

    setState(() => _analyzingImage = true);
    try {
      // Mock AI recommendations for now - replace with actual AI service when available
      await Future.delayed(Duration(seconds: 2)); // Simulate processing time
      final mockRecommendations = {
        'recommendations':
            'Based on the symptoms (${_selectedSymptoms.join(', ')}), consider the following:\n\n'
                '1. Clinical examination suggests ${_selectedCondition.toLowerCase()}\n'
                '2. Recommended diagnostic tests: ${_selectedLabTests.isNotEmpty ? _selectedLabTests.join(', ') : 'Basic blood work'}\n'
                '3. Treatment approach: Supportive care with monitoring\n'
                '4. Follow-up: Re-evaluate in 48-72 hours\n\n'
                'Note: This is a preliminary assessment. Please consult with senior veterinarian for complex cases.',
        'confidence': 0.78,
        'urgency': _selectedUrgency
      };
      setState(() {
        _aiAnalysis = mockRecommendations;
        _showAIRecommendations = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get AI recommendations: $e')),
      );
    } finally {
      setState(() => _analyzingImage = false);
    }
  }

  Future<void> _save() async {
    if (_med.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Enter medicine')));
      return;
    }
    setState(() => _saving = true);

    final withdrawalDays = int.tryParse(_withdrawalDays.text) ?? 7;
    final withdrawalEnd =
        DateTime.now().add(Duration(days: withdrawalDays)).toIso8601String();
    final now = DateTime.now();

    final animals = await _storage.loadAnimals();
    final idx = animals.indexWhere((a) => a.id == widget.animal.id);
    if (idx != -1) {
      final a = animals[idx];

      // Create comprehensive treatment record
      final treatmentRecord = TreatmentRecord(
        drugName: _med.text.trim(),
        dosage: _dose.text.trim(),
        dateAdministered: now,
        administeredBy:
            auth.vets[auth.currentId]?['username'] ?? auth.currentId ?? 'vet',
        condition: _selectedCondition,
        notes: _buildComprehensiveNotes(),
        cost: double.tryParse(_costEstimate.text),
        outcome:
            _diagnosis.text.isNotEmpty ? 'Diagnosed: ${_diagnosis.text}' : null,
      );

      // Create health note for clinical findings
      final healthNote = HealthNote(
        note: _clinicalFindings.text,
        dateCreated: now,
        createdBy:
            auth.vets[auth.currentId]?['username'] ?? auth.currentId ?? 'vet',
        category: 'clinical_examination',
        severity: _selectedUrgency == 'Emergency'
            ? 5
            : _selectedUrgency == 'Urgent'
                ? 4
                : 3,
        tags: _selectedSymptoms,
      );

      final updated = Animal(
        id: a.id,
        species: a.species,
        age: a.age,
        breed: a.breed,
        lastDrug: _med.text.trim(),
        lastDosage: _dose.text.trim(),
        withdrawalStart: now.toIso8601String(),
        withdrawalEnd: withdrawalEnd,
        productType: _selectedProductType,
        withdrawalDays: withdrawalDays,
        currentMRL: _currentMRL,
        mrlStatus: _mrlStatus,
        vetId: auth.currentId,
        vetUsername: auth.vets[auth.currentId]?['username'],
        farmerId: a.farmerId,
        treatmentHistory: [...(a.treatmentHistory ?? []), treatmentRecord],
        healthNotes: [...(a.healthNotes ?? []), healthNote],
      );

      animals[idx] = updated;
      await _storage.saveAnimals(animals);

      // Record treatment to blockchain
      await _storage.recordTreatment(
        treatmentRecord,
        widget.animal.id,
        performedBy:
            auth.vets[auth.currentId]?['username'] ?? auth.currentId ?? 'vet',
      );

      // Record health check to blockchain
      await _storage.recordHealthCheck(
        updated,
        performedBy:
            auth.vets[auth.currentId]?['username'] ?? auth.currentId ?? 'vet',
      );

      // Consultation saved successfully
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Comprehensive consultation saved to animal record and blockchain')));
    Navigator.of(context).pop({
      'drug': _med.text.trim(),
      'dosage': _dose.text.trim(),
      'days': withdrawalDays,
      'productType': _selectedProductType,
      'mrl': _currentMRL,
      'status': _mrlStatus,
      'diagnosis': _diagnosis.text,
      'treatmentPlan': _treatmentPlan.text,
    });
  }

  String _buildComprehensiveNotes() {
    final notes = StringBuffer();

    if (_clinicalFindings.text.isNotEmpty) {
      notes.writeln('Clinical Findings: ${_clinicalFindings.text}');
    }

    if (_diagnosis.text.isNotEmpty) {
      notes.writeln('Diagnosis: ${_diagnosis.text}');
    }

    if (_treatmentPlan.text.isNotEmpty) {
      notes.writeln('Treatment Plan: ${_treatmentPlan.text}');
    }

    if (_selectedSymptoms.isNotEmpty) {
      notes.writeln('Symptoms: ${_selectedSymptoms.join(', ')}');
    }

    if (_selectedLabTests.isNotEmpty) {
      notes.writeln('Recommended Lab Tests: ${_selectedLabTests.join(', ')}');
    }

    if (_followUpNotes.text.isNotEmpty) {
      notes.writeln('Follow-up: ${_followUpNotes.text}');
    }

    if (_notes.text.isNotEmpty) {
      notes.writeln('Additional Notes: ${_notes.text}');
    }

    return notes.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${AppLocalizations.of(context)!.consult} • ${widget.animal.id}'),
        backgroundColor: Colors.teal.shade700,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _consultationSteps.map((step) => Tab(text: step)).toList(),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Step 1: Initial Assessment
          _buildInitialAssessmentTab(),

          // Step 2: Clinical Examination
          _buildClinicalExaminationTab(),

          // Step 3: Diagnosis & Treatment
          _buildDiagnosisTreatmentTab(),

          // Step 4: Prescription & Follow-up
          _buildPrescriptionFollowUpTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _save,
        backgroundColor: Colors.teal.shade700,
        icon: _saving
            ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Icon(Icons.save),
        label: Text(_saving ? 'Saving...' : 'Save Consultation'),
      ),
    );
  }

  Widget _buildInitialAssessmentTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animal Overview Card
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Animal Overview',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child:
                              _buildInfoRow('Species', widget.animal.species)),
                      Expanded(
                          child: _buildInfoRow('Breed', widget.animal.breed)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildInfoRow('Age', widget.animal.age)),
                      Expanded(child: _buildInfoRow('ID', widget.animal.id)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Consultation Details
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Consultation Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),

                  // Condition Type
                  Text('Condition Type',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCondition,
                    items: [
                      'General Checkup',
                      'Vaccination',
                      'Mastitis',
                      'Respiratory Infection',
                      'Digestive Issues',
                      'Reproductive Problems',
                      'Lameness',
                      'Skin Conditions',
                      'Parasitic Infection',
                      'Metabolic Disorders',
                      'Emergency',
                      'Other'
                    ]
                        .map((condition) => DropdownMenuItem(
                              value: condition,
                              child: Text(condition),
                            ))
                        .toList(),
                    onChanged: (value) => setState(
                        () => _selectedCondition = value ?? 'General Checkup'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Urgency Level
                  Text('Urgency Level',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Column(
                    children: ['Routine', 'Urgent', 'Emergency']
                        .map((urgency) => RadioListTile<String>(
                              title: Text(urgency),
                              value: urgency,
                              groupValue: _selectedUrgency,
                              onChanged: (value) => setState(
                                  () => _selectedUrgency = value ?? 'Routine'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Symptoms Selection
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Presenting Symptoms',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Fever',
                      'Loss of Appetite',
                      'Weight Loss',
                      'Diarrhea',
                      'Coughing',
                      'Lameness',
                      'Swelling',
                      'Discharge',
                      'Pain',
                      'Lethargy',
                      'Vomiting',
                      'Difficulty Breathing',
                      'Skin Lesions',
                      'Abnormal Behavior'
                    ]
                        .map((symptom) => FilterChip(
                              label: Text(symptom),
                              selected: _selectedSymptoms.contains(symptom),
                              onSelected: (_) => _toggleSymptom(symptom),
                              selectedColor: Colors.teal.shade100,
                              checkmarkColor: Colors.teal.shade700,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalExaminationTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vital Signs
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.monitor_heart, color: Colors.red.shade600),
                      SizedBox(width: 8),
                      Text('Vital Signs',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _temperature,
                          decoration: InputDecoration(
                            labelText: 'Temperature (°C)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.thermostat),
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _heartRate,
                          decoration: InputDecoration(
                            labelText: 'Heart Rate (bpm)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.favorite),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _respiratoryRate,
                          decoration: InputDecoration(
                            labelText: 'Respiratory Rate',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.air),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _bodyConditionScore,
                          decoration: InputDecoration(
                            labelText: 'Body Condition Score (1-5)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.score),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Clinical Findings
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medical_services, color: Colors.blue.shade600),
                      SizedBox(width: 8),
                      Text('Clinical Examination Findings',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _clinicalFindings,
                    decoration: InputDecoration(
                      labelText: 'Detailed clinical findings...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Image Capture
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.camera_alt, color: Colors.green.shade600),
                      SizedBox(width: 8),
                      Text('Image Documentation',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Spacer(),
                      ElevatedButton.icon(
                        onPressed: _analyzingImage ? null : _captureImage,
                        icon: _analyzingImage
                            ? CircularProgressIndicator(strokeWidth: 2)
                            : Icon(Icons.camera),
                        label: Text(_analyzingImage ? 'Analyzing' : 'Capture'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (_capturedImages.isNotEmpty) ...[
                    Text('Captured Images:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _capturedImages
                          .map((image) => Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  image: DecorationImage(
                                    image: FileImage(image),
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  if (_showAIRecommendations && _aiAnalysis.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Analysis Results',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800)),
                          SizedBox(height: 8),
                          Text(_aiAnalysis['findings'] ?? 'Analysis completed'),
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
    );
  }

  Widget _buildDiagnosisTreatmentTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Diagnosis
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_hospital, color: Colors.purple.shade600),
                      SizedBox(width: 8),
                      Text('Diagnosis',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _diagnosis,
                    decoration: InputDecoration(
                      labelText: 'Enter diagnosis...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Treatment Plan
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.healing, color: Colors.orange.shade600),
                      SizedBox(width: 8),
                      Text('Treatment Plan',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _treatmentPlan,
                    decoration: InputDecoration(
                      labelText: 'Detailed treatment plan...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Lab Tests Recommendation
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recommended Lab Tests',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Blood Count',
                      'Biochemistry',
                      'Urine Analysis',
                      'Fecal Examination',
                      'Microbiology',
                      'Parasitology',
                      'Radiology',
                      'Ultrasound',
                      'Biopsy'
                    ]
                        .map((test) => FilterChip(
                              label: Text(test),
                              selected: _selectedLabTests.contains(test),
                              onSelected: (_) => _toggleLabTest(test),
                              selectedColor: Colors.purple.shade100,
                              checkmarkColor: Colors.purple.shade700,
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _labTests,
                    decoration: InputDecoration(
                      labelText: 'Additional lab test recommendations...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // AI Recommendations Button
          Center(
            child: ElevatedButton.icon(
              onPressed: _analyzingImage ? null : _getAIRecommendations,
              icon: _analyzingImage
                  ? CircularProgressIndicator(strokeWidth: 2)
                  : Icon(Icons.smart_toy),
              label: Text(_analyzingImage
                  ? 'Getting AI Recommendations...'
                  : 'Get AI Recommendations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),

          if (_showAIRecommendations && _aiAnalysis.isNotEmpty) ...[
            SizedBox(height: 16),
            Card(
              elevation: 4,
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Recommendations',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800)),
                    SizedBox(height: 12),
                    Text(_aiAnalysis['recommendations'] ??
                        'AI analysis completed'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrescriptionFollowUpTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medicine Selection
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prescription',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),

                  // Medicine Selection
                  Text('Medicine',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _med.text.isNotEmpty ? _med.text : null,
                    decoration: InputDecoration(
                      labelText: 'Select medicine',
                      border: OutlineInputBorder(),
                      hintText: 'Choose from default medicines',
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text('Custom medicine (type below)'),
                      ),
                      ..._defaultMedicines
                          .map((medicine) => DropdownMenuItem<String>(
                                value: medicine['name'],
                                child: Text(medicine['name']),
                              )),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _med.text = value;
                          if (value.isNotEmpty) {
                            final selectedMedicine =
                                _defaultMedicines.firstWhere(
                              (med) => med['name'] == value,
                              orElse: () => {'withdrawal': 7},
                            );
                            _withdrawalDays.text =
                                selectedMedicine['withdrawal'].toString();
                          }
                        });
                        _calculateMRL();
                      }
                    },
                  ),
                  SizedBox(height: 8),
                  if (_med.text.isEmpty ||
                      !_defaultMedicines.any((med) => med['name'] == _med.text))
                    TextField(
                      controller: _med,
                      decoration: InputDecoration(
                        labelText: 'Enter custom medicine name',
                        border: OutlineInputBorder(),
                        hintText: 'Type medicine name',
                      ),
                      onChanged: (_) => _calculateMRL(),
                    ),

                  SizedBox(height: 16),

                  // Dosage
                  TextField(
                    controller: _dose,
                    decoration: InputDecoration(
                      labelText: 'Dosage (mg/kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _calculateMRL(),
                  ),

                  SizedBox(height: 16),

                  // Withdrawal Period
                  TextField(
                    controller: _withdrawalDays,
                    decoration: InputDecoration(
                      labelText: 'Withdrawal Period (days)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  SizedBox(height: 16),

                  // Cost Estimate
                  TextField(
                    controller: _costEstimate,
                    decoration: InputDecoration(
                      labelText: 'Estimated Cost (₹)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // MRL Information
          if (_currentMRL != null) ...[
            Card(
              elevation: 4,
              color: Colors.teal.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.show_chart, color: Colors.teal.shade700),
                        SizedBox(width: 8),
                        Text('MRL Information',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow('Current MRL',
                        '${_currentMRL!.toStringAsFixed(3)} units'),
                    _buildInfoRow('Status', _mrlStatus ?? 'Unknown'),
                    if (_calculatedWithdrawalDays != null)
                      _buildInfoRow(
                          'Withdrawal Days', '$_calculatedWithdrawalDays'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
          ],

          // Follow-up
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.follow_the_signs,
                          color: Colors.indigo.shade600),
                      SizedBox(width: 8),
                      Text('Follow-up & Notes',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _followUpNotes,
                    decoration: InputDecoration(
                      labelText: 'Follow-up instructions...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _notes,
                    decoration: InputDecoration(
                      labelText: 'Additional notes...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
