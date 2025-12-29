// Enhanced Animal Model with Comprehensive Health Records
class Animal {
  final String id;
  final String species;
  final String age;
  final String breed;
  final String? farmerId;

  // Basic Treatment Data
  final String? lastDrug;
  final String? lastDosage;
  final String? withdrawalStart;
  final String? withdrawalEnd;
  final String? productType;
  final int? withdrawalDays;
  final double? currentMRL;
  final String? mrlStatus;
  final String? vetId;
  final String? vetUsername;

  // Digital Health Records
  final List<VaccinationRecord>? vaccinationHistory;
  final List<TreatmentRecord>? treatmentHistory;
  final List<HealthNote>? healthNotes;
  final List<WeightRecord>? weightHistory;
  final List<DevelopmentMilestone>? developmentMilestones;

  // Reproductive Management
  final ReproductiveData? reproductiveData;
  final List<PregnancyRecord>? pregnancyHistory;
  final List<OffspringRecord>? offspringRecords;

  // Genetic Information
  final GeneticProfile? geneticProfile;
  final List<String>? healthPredispositions;
  final List<String>? breedCharacteristics;

  // Geographic & Environmental Data
  final LocationData? currentLocation;
  final List<LocationHistory>? locationHistory;
  final EnvironmentalData? environmentalData;

  // Image Data for AI Analysis
  final List<String>? imageUrls; // URLs to stored images
  final String? profileImageUrl;
  final List<ImageAnalysisResult>? imageAnalysisResults;

  // Audit & Compliance
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? lastModifiedBy;
  final List<AuditEntry>? auditTrail;
  final ComplianceData? complianceData;

  // AI & Analytics
  final List<String>? predictedHealthRisks;
  final Map<String, dynamic>? healthPatterns;
  final double? healthScore; // 0-100 health score
  final List<AITreatmentRecommendation>? aiRecommendations;

  Animal({
    required this.id,
    required this.species,
    required this.age,
    required this.breed,
    this.farmerId,
    this.lastDrug,
    this.lastDosage,
    this.withdrawalStart,
    this.withdrawalEnd,
    this.productType,
    this.withdrawalDays,
    this.currentMRL,
    this.mrlStatus,
    this.vetId,
    this.vetUsername,
    this.vaccinationHistory,
    this.treatmentHistory,
    this.healthNotes,
    this.weightHistory,
    this.developmentMilestones,
    this.reproductiveData,
    this.pregnancyHistory,
    this.offspringRecords,
    this.geneticProfile,
    this.healthPredispositions,
    this.breedCharacteristics,
    this.currentLocation,
    this.locationHistory,
    this.environmentalData,
    this.imageUrls,
    this.profileImageUrl,
    this.imageAnalysisResults,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.createdBy,
    this.lastModifiedBy,
    this.auditTrail,
    this.complianceData,
    this.predictedHealthRisks,
    this.healthPatterns,
    this.healthScore,
    this.aiRecommendations,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'species': species,
    'age': age,
    'breed': breed,
    'farmerId': farmerId,
    'lastDrug': lastDrug,
    'lastDosage': lastDosage,
    'withdrawalStart': withdrawalStart,
    'withdrawalEnd': withdrawalEnd,
    'productType': productType,
    'withdrawalDays': withdrawalDays,
    'currentMRL': currentMRL,
    'mrlStatus': mrlStatus,
    'vetId': vetId,
    'vetUsername': vetUsername,
    'vaccinationHistory': vaccinationHistory?.map((v) => v.toMap()).toList(),
    'treatmentHistory': treatmentHistory?.map((t) => t.toMap()).toList(),
    'healthNotes': healthNotes?.map((n) => n.toMap()).toList(),
    'weightHistory': weightHistory?.map((w) => w.toMap()).toList(),
    'developmentMilestones': developmentMilestones?.map((m) => m.toMap()).toList(),
    'reproductiveData': reproductiveData?.toMap(),
    'pregnancyHistory': pregnancyHistory?.map((p) => p.toMap()).toList(),
    'offspringRecords': offspringRecords?.map((o) => o.toMap()).toList(),
    'geneticProfile': geneticProfile?.toMap(),
    'healthPredispositions': healthPredispositions,
    'breedCharacteristics': breedCharacteristics,
    'currentLocation': currentLocation?.toMap(),
    'locationHistory': locationHistory?.map((l) => l.toMap()).toList(),
    'environmentalData': environmentalData?.toMap(),
    'imageUrls': imageUrls,
    'profileImageUrl': profileImageUrl,
    'imageAnalysisResults': imageAnalysisResults?.map((i) => i.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'createdBy': createdBy,
    'lastModifiedBy': lastModifiedBy,
    'auditTrail': auditTrail?.map((a) => a.toMap()).toList(),
    'complianceData': complianceData?.toMap(),
    'predictedHealthRisks': predictedHealthRisks,
    'healthPatterns': healthPatterns,
    'healthScore': healthScore,
    'aiRecommendations': aiRecommendations?.map((r) => r.toMap()).toList(),
  };

  static Animal fromMap(Map<String, dynamic> m) => Animal(
    id: m['id'] ?? '',
    species: m['species'] ?? '',
    age: m['age'] ?? '',
    breed: m['breed'] ?? '',
    farmerId: m['farmerId'],
    lastDrug: m['lastDrug'],
    lastDosage: m['lastDosage'],
    withdrawalStart: m['withdrawalStart'],
    withdrawalEnd: m['withdrawalEnd'],
    productType: m['productType'],
    withdrawalDays: m['withdrawalDays'] as int?,
    currentMRL: m['currentMRL'] as double?,
    mrlStatus: m['mrlStatus'],
    vetId: m['vetId'],
    vetUsername: m['vetUsername'],
    vaccinationHistory: (m['vaccinationHistory'] as List<dynamic>?)?.map((v) => VaccinationRecord.fromMap(v)).toList(),
    treatmentHistory: (m['treatmentHistory'] as List<dynamic>?)?.map((t) => TreatmentRecord.fromMap(t)).toList(),
    healthNotes: (m['healthNotes'] as List<dynamic>?)?.map((n) => HealthNote.fromMap(n)).toList(),
    weightHistory: (m['weightHistory'] as List<dynamic>?)?.map((w) => WeightRecord.fromMap(w)).toList(),
    developmentMilestones: (m['developmentMilestones'] as List<dynamic>?)?.map((d) => DevelopmentMilestone.fromMap(d)).toList(),
    reproductiveData: m['reproductiveData'] != null ? ReproductiveData.fromMap(m['reproductiveData']) : null,
    pregnancyHistory: (m['pregnancyHistory'] as List<dynamic>?)?.map((p) => PregnancyRecord.fromMap(p)).toList(),
    offspringRecords: (m['offspringRecords'] as List<dynamic>?)?.map((o) => OffspringRecord.fromMap(o)).toList(),
    geneticProfile: m['geneticProfile'] != null ? GeneticProfile.fromMap(m['geneticProfile']) : null,
    healthPredispositions: (m['healthPredispositions'] as List<dynamic>?)?.cast<String>(),
    breedCharacteristics: (m['breedCharacteristics'] as List<dynamic>?)?.cast<String>(),
    currentLocation: m['currentLocation'] != null ? LocationData.fromMap(m['currentLocation']) : null,
    locationHistory: (m['locationHistory'] as List<dynamic>?)?.map((l) => LocationHistory.fromMap(l)).toList(),
    environmentalData: m['environmentalData'] != null ? EnvironmentalData.fromMap(m['environmentalData']) : null,
    imageUrls: (m['imageUrls'] as List<dynamic>?)?.cast<String>(),
    profileImageUrl: m['profileImageUrl'],
    imageAnalysisResults: (m['imageAnalysisResults'] as List<dynamic>?)?.map((i) => ImageAnalysisResult.fromMap(i)).toList(),
    createdAt: m['createdAt'] != null ? DateTime.parse(m['createdAt']) : null,
    updatedAt: m['updatedAt'] != null ? DateTime.parse(m['updatedAt']) : null,
    createdBy: m['createdBy'],
    lastModifiedBy: m['lastModifiedBy'],
    auditTrail: (m['auditTrail'] as List<dynamic>?)?.map((a) => AuditEntry.fromMap(a)).toList(),
    complianceData: m['complianceData'] != null ? ComplianceData.fromMap(m['complianceData']) : null,
    predictedHealthRisks: (m['predictedHealthRisks'] as List<dynamic>?)?.cast<String>(),
    healthPatterns: m['healthPatterns'],
    healthScore: m['healthScore'] as double?,
    aiRecommendations: (m['aiRecommendations'] as List<dynamic>?)?.map((r) => AITreatmentRecommendation.fromMap(r)).toList(),
  );

  // Helper methods
  Animal copyWith({
    String? id,
    String? species,
    String? age,
    String? breed,
    String? farmerId,
    String? lastDrug,
    String? lastDosage,
    String? withdrawalStart,
    String? withdrawalEnd,
    String? productType,
    int? withdrawalDays,
    double? currentMRL,
    String? mrlStatus,
    String? vetId,
    String? vetUsername,
    List<VaccinationRecord>? vaccinationHistory,
    List<TreatmentRecord>? treatmentHistory,
    List<HealthNote>? healthNotes,
    List<WeightRecord>? weightHistory,
    List<DevelopmentMilestone>? developmentMilestones,
    ReproductiveData? reproductiveData,
    List<PregnancyRecord>? pregnancyHistory,
    List<OffspringRecord>? offspringRecords,
    GeneticProfile? geneticProfile,
    List<String>? healthPredispositions,
    List<String>? breedCharacteristics,
    LocationData? currentLocation,
    List<LocationHistory>? locationHistory,
    EnvironmentalData? environmentalData,
    List<String>? imageUrls,
    String? profileImageUrl,
    List<ImageAnalysisResult>? imageAnalysisResults,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? lastModifiedBy,
    List<AuditEntry>? auditTrail,
    ComplianceData? complianceData,
    List<String>? predictedHealthRisks,
    Map<String, dynamic>? healthPatterns,
    double? healthScore,
    List<AITreatmentRecommendation>? aiRecommendations,
  }) {
    return Animal(
      id: id ?? this.id,
      species: species ?? this.species,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      farmerId: farmerId ?? this.farmerId,
      lastDrug: lastDrug ?? this.lastDrug,
      lastDosage: lastDosage ?? this.lastDosage,
      withdrawalStart: withdrawalStart ?? this.withdrawalStart,
      withdrawalEnd: withdrawalEnd ?? this.withdrawalEnd,
      productType: productType ?? this.productType,
      withdrawalDays: withdrawalDays ?? this.withdrawalDays,
      currentMRL: currentMRL ?? this.currentMRL,
      mrlStatus: mrlStatus ?? this.mrlStatus,
      vetId: vetId ?? this.vetId,
      vetUsername: vetUsername ?? this.vetUsername,
      vaccinationHistory: vaccinationHistory ?? this.vaccinationHistory,
      treatmentHistory: treatmentHistory ?? this.treatmentHistory,
      healthNotes: healthNotes ?? this.healthNotes,
      weightHistory: weightHistory ?? this.weightHistory,
      developmentMilestones: developmentMilestones ?? this.developmentMilestones,
      reproductiveData: reproductiveData ?? this.reproductiveData,
      pregnancyHistory: pregnancyHistory ?? this.pregnancyHistory,
      offspringRecords: offspringRecords ?? this.offspringRecords,
      geneticProfile: geneticProfile ?? this.geneticProfile,
      healthPredispositions: healthPredispositions ?? this.healthPredispositions,
      breedCharacteristics: breedCharacteristics ?? this.breedCharacteristics,
      currentLocation: currentLocation ?? this.currentLocation,
      locationHistory: locationHistory ?? this.locationHistory,
      environmentalData: environmentalData ?? this.environmentalData,
      imageUrls: imageUrls ?? this.imageUrls,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      imageAnalysisResults: imageAnalysisResults ?? this.imageAnalysisResults,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      auditTrail: auditTrail ?? this.auditTrail,
      complianceData: complianceData ?? this.complianceData,
      predictedHealthRisks: predictedHealthRisks ?? this.predictedHealthRisks,
      healthPatterns: healthPatterns ?? this.healthPatterns,
      healthScore: healthScore ?? this.healthScore,
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
    );
  }

  // Computed properties
  bool get isHealthy => healthScore != null && healthScore! >= 70;
  bool get hasActiveTreatment => withdrawalEnd != null && DateTime.now().isBefore(DateTime.parse(withdrawalEnd!));
  bool get isPregnant => reproductiveData?.isPregnant ?? false;
  int get ageInMonths => int.tryParse(age.split(' ')[0]) ?? 0;
  double get latestWeight => weightHistory?.isNotEmpty == true ? weightHistory!.last.weight : 0.0;
}

// Supporting Data Classes

class VaccinationRecord {
  final String vaccineName;
  final DateTime dateAdministered;
  final String administeredBy;
  final DateTime? nextDueDate;
  final String? batchNumber;
  final String? notes;

  VaccinationRecord({
    required this.vaccineName,
    required this.dateAdministered,
    required this.administeredBy,
    this.nextDueDate,
    this.batchNumber,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'vaccineName': vaccineName,
    'dateAdministered': dateAdministered.toIso8601String(),
    'administeredBy': administeredBy,
    'nextDueDate': nextDueDate?.toIso8601String(),
    'batchNumber': batchNumber,
    'notes': notes,
  };

  static VaccinationRecord fromMap(Map<String, dynamic> m) => VaccinationRecord(
    vaccineName: m['vaccineName'] ?? '',
    dateAdministered: DateTime.parse(m['dateAdministered']),
    administeredBy: m['administeredBy'] ?? '',
    nextDueDate: m['nextDueDate'] != null ? DateTime.parse(m['nextDueDate']) : null,
    batchNumber: m['batchNumber'],
    notes: m['notes'],
  );
}

class TreatmentRecord {
  final String drugName;
  final String dosage;
  final DateTime dateAdministered;
  final String administeredBy;
  final String condition;
  final String? notes;
  final double? cost;
  final String? outcome;

  TreatmentRecord({
    required this.drugName,
    required this.dosage,
    required this.dateAdministered,
    required this.administeredBy,
    required this.condition,
    this.notes,
    this.cost,
    this.outcome,
  });

  Map<String, dynamic> toMap() => {
    'drugName': drugName,
    'dosage': dosage,
    'dateAdministered': dateAdministered.toIso8601String(),
    'administeredBy': administeredBy,
    'condition': condition,
    'notes': notes,
    'cost': cost,
    'outcome': outcome,
  };

  static TreatmentRecord fromMap(Map<String, dynamic> m) => TreatmentRecord(
    drugName: m['drugName'] ?? '',
    dosage: m['dosage'] ?? '',
    dateAdministered: DateTime.parse(m['dateAdministered']),
    administeredBy: m['administeredBy'] ?? '',
    condition: m['condition'] ?? '',
    notes: m['notes'],
    cost: m['cost'] as double?,
    outcome: m['outcome'],
  );
}

class HealthNote {
  final String note;
  final DateTime dateCreated;
  final String createdBy;
  final String category; // 'general', 'symptom', 'behavior', 'diet'
  final int severity; // 1-5 scale
  final List<String>? tags;

  HealthNote({
    required this.note,
    required this.dateCreated,
    required this.createdBy,
    required this.category,
    required this.severity,
    this.tags,
  });

  Map<String, dynamic> toMap() => {
    'note': note,
    'dateCreated': dateCreated.toIso8601String(),
    'createdBy': createdBy,
    'category': category,
    'severity': severity,
    'tags': tags,
  };

  static HealthNote fromMap(Map<String, dynamic> m) => HealthNote(
    note: m['note'] ?? '',
    dateCreated: DateTime.parse(m['dateCreated']),
    createdBy: m['createdBy'] ?? '',
    category: m['category'] ?? 'general',
    severity: m['severity'] ?? 1,
    tags: (m['tags'] as List<dynamic>?)?.cast<String>(),
  );
}

class WeightRecord {
  final double weight;
  final DateTime dateRecorded;
  final String recordedBy;
  final String unit; // 'kg', 'lbs'
  final String? notes;

  WeightRecord({
    required this.weight,
    required this.dateRecorded,
    required this.recordedBy,
    this.unit = 'kg',
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'weight': weight,
    'dateRecorded': dateRecorded.toIso8601String(),
    'recordedBy': recordedBy,
    'unit': unit,
    'notes': notes,
  };

  static WeightRecord fromMap(Map<String, dynamic> m) => WeightRecord(
    weight: (m['weight'] as num).toDouble(),
    dateRecorded: DateTime.parse(m['dateRecorded']),
    recordedBy: m['recordedBy'] ?? '',
    unit: m['unit'] ?? 'kg',
    notes: m['notes'],
  );
}

class DevelopmentMilestone {
  final String milestone;
  final DateTime dateAchieved;
  final String recordedBy;
  final String category; // 'physical', 'behavioral', 'reproductive'
  final String? notes;

  DevelopmentMilestone({
    required this.milestone,
    required this.dateAchieved,
    required this.recordedBy,
    required this.category,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'milestone': milestone,
    'dateAchieved': dateAchieved.toIso8601String(),
    'recordedBy': recordedBy,
    'category': category,
    'notes': notes,
  };

  static DevelopmentMilestone fromMap(Map<String, dynamic> m) => DevelopmentMilestone(
    milestone: m['milestone'] ?? '',
    dateAchieved: DateTime.parse(m['dateAchieved']),
    recordedBy: m['recordedBy'] ?? '',
    category: m['category'] ?? 'physical',
    notes: m['notes'],
  );
}

class ReproductiveData {
  final bool isPregnant;
  final DateTime? lastHeatDate;
  final DateTime? expectedDueDate;
  final int? parity; // Number of previous pregnancies
  final String? reproductiveStatus; // 'cycling', 'pregnant', 'lactating', 'dry'
  final DateTime? lastCalvingDate;
  final int? daysInMilk;

  ReproductiveData({
    required this.isPregnant,
    this.lastHeatDate,
    this.expectedDueDate,
    this.parity,
    this.reproductiveStatus,
    this.lastCalvingDate,
    this.daysInMilk,
  });

  Map<String, dynamic> toMap() => {
    'isPregnant': isPregnant,
    'lastHeatDate': lastHeatDate?.toIso8601String(),
    'expectedDueDate': expectedDueDate?.toIso8601String(),
    'parity': parity,
    'reproductiveStatus': reproductiveStatus,
    'lastCalvingDate': lastCalvingDate?.toIso8601String(),
    'daysInMilk': daysInMilk,
  };

  static ReproductiveData fromMap(Map<String, dynamic> m) => ReproductiveData(
    isPregnant: m['isPregnant'] ?? false,
    lastHeatDate: m['lastHeatDate'] != null ? DateTime.parse(m['lastHeatDate']) : null,
    expectedDueDate: m['expectedDueDate'] != null ? DateTime.parse(m['expectedDueDate']) : null,
    parity: m['parity'] as int?,
    reproductiveStatus: m['reproductiveStatus'],
    lastCalvingDate: m['lastCalvingDate'] != null ? DateTime.parse(m['lastCalvingDate']) : null,
    daysInMilk: m['daysInMilk'] as int?,
  );
}

class PregnancyRecord {
  final DateTime conceptionDate;
  final DateTime? dueDate;
  final DateTime? calvingDate;
  final int? numberOfOffspring;
  final String? outcome; // 'successful', 'aborted', 'stillborn'
  final String? sireId;
  final String? notes;

  PregnancyRecord({
    required this.conceptionDate,
    this.dueDate,
    this.calvingDate,
    this.numberOfOffspring,
    this.outcome,
    this.sireId,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'conceptionDate': conceptionDate.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'calvingDate': calvingDate?.toIso8601String(),
    'numberOfOffspring': numberOfOffspring,
    'outcome': outcome,
    'sireId': sireId,
    'notes': notes,
  };

  static PregnancyRecord fromMap(Map<String, dynamic> m) => PregnancyRecord(
    conceptionDate: DateTime.parse(m['conceptionDate']),
    dueDate: m['dueDate'] != null ? DateTime.parse(m['dueDate']) : null,
    calvingDate: m['calvingDate'] != null ? DateTime.parse(m['calvingDate']) : null,
    numberOfOffspring: m['numberOfOffspring'] as int?,
    outcome: m['outcome'],
    sireId: m['sireId'],
    notes: m['notes'],
  );
}

class OffspringRecord {
  final String offspringId;
  final DateTime birthDate;
  final String gender;
  final double? birthWeight;
  final String? status; // 'alive', 'dead', 'sold'
  final String? notes;

  OffspringRecord({
    required this.offspringId,
    required this.birthDate,
    required this.gender,
    this.birthWeight,
    this.status,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'offspringId': offspringId,
    'birthDate': birthDate.toIso8601String(),
    'gender': gender,
    'birthWeight': birthWeight,
    'status': status,
    'notes': notes,
  };

  static OffspringRecord fromMap(Map<String, dynamic> m) => OffspringRecord(
    offspringId: m['offspringId'] ?? '',
    birthDate: DateTime.parse(m['birthDate']),
    gender: m['gender'] ?? '',
    birthWeight: m['birthWeight'] as double?,
    status: m['status'],
    notes: m['notes'],
  );
}

class GeneticProfile {
  final String? dnaProfile;
  final Map<String, double>? geneticMarkers;
  final List<String>? inheritedTraits;
  final String? parentageInfo;
  final DateTime? lastGeneticTest;

  GeneticProfile({
    this.dnaProfile,
    this.geneticMarkers,
    this.inheritedTraits,
    this.parentageInfo,
    this.lastGeneticTest,
  });

  Map<String, dynamic> toMap() => {
    'dnaProfile': dnaProfile,
    'geneticMarkers': geneticMarkers,
    'inheritedTraits': inheritedTraits,
    'parentageInfo': parentageInfo,
    'lastGeneticTest': lastGeneticTest?.toIso8601String(),
  };

  static GeneticProfile fromMap(Map<String, dynamic> m) => GeneticProfile(
    dnaProfile: m['dnaProfile'],
    geneticMarkers: (m['geneticMarkers'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toDouble())),
    inheritedTraits: (m['inheritedTraits'] as List<dynamic>?)?.cast<String>(),
    parentageInfo: m['parentageInfo'],
    lastGeneticTest: m['lastGeneticTest'] != null ? DateTime.parse(m['lastGeneticTest']) : null,
  );
}

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final String? farmName;
  final String? enclosureId;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.farmName,
    this.enclosureId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'farmName': farmName,
    'enclosureId': enclosureId,
    'timestamp': timestamp.toIso8601String(),
  };

  static LocationData fromMap(Map<String, dynamic> m) => LocationData(
    latitude: (m['latitude'] as num).toDouble(),
    longitude: (m['longitude'] as num).toDouble(),
    address: m['address'],
    farmName: m['farmName'],
    enclosureId: m['enclosureId'],
    timestamp: DateTime.parse(m['timestamp']),
  );
}

class LocationHistory {
  final LocationData location;
  final String activity; // 'grazing', 'resting', 'treatment', etc.
  final DateTime timestamp;

  LocationHistory({
    required this.location,
    required this.activity,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'location': location.toMap(),
    'activity': activity,
    'timestamp': timestamp.toIso8601String(),
  };

  static LocationHistory fromMap(Map<String, dynamic> m) => LocationHistory(
    location: LocationData.fromMap(m['location']),
    activity: m['activity'] ?? '',
    timestamp: DateTime.parse(m['timestamp']),
  );
}

class EnvironmentalData {
  final double? temperature;
  final double? humidity;
  final double? airQuality;
  final String? weatherCondition;
  final DateTime timestamp;

  EnvironmentalData({
    this.temperature,
    this.humidity,
    this.airQuality,
    this.weatherCondition,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'temperature': temperature,
    'humidity': humidity,
    'airQuality': airQuality,
    'weatherCondition': weatherCondition,
    'timestamp': timestamp.toIso8601String(),
  };

  static EnvironmentalData fromMap(Map<String, dynamic> m) => EnvironmentalData(
    temperature: m['temperature'] as double?,
    humidity: m['humidity'] as double?,
    airQuality: m['airQuality'] as double?,
    weatherCondition: m['weatherCondition'],
    timestamp: DateTime.parse(m['timestamp']),
  );
}

class ImageAnalysisResult {
  final String imageUrl;
  final DateTime analysisDate;
  final Map<String, dynamic> analysisData;
  final String? conditionDetected;
  final double? confidenceScore;
  final List<String>? recommendations;

  ImageAnalysisResult({
    required this.imageUrl,
    required this.analysisDate,
    required this.analysisData,
    this.conditionDetected,
    this.confidenceScore,
    this.recommendations,
  });

  Map<String, dynamic> toMap() => {
    'imageUrl': imageUrl,
    'analysisDate': analysisDate.toIso8601String(),
    'analysisData': analysisData,
    'conditionDetected': conditionDetected,
    'confidenceScore': confidenceScore,
    'recommendations': recommendations,
  };

  static ImageAnalysisResult fromMap(Map<String, dynamic> m) => ImageAnalysisResult(
    imageUrl: m['imageUrl'] ?? '',
    analysisDate: DateTime.parse(m['analysisDate']),
    analysisData: m['analysisData'] ?? {},
    conditionDetected: m['conditionDetected'],
    confidenceScore: m['confidenceScore'] as double?,
    recommendations: (m['recommendations'] as List<dynamic>?)?.cast<String>(),
  );
}

class AuditEntry {
  final String action;
  final String performedBy;
  final DateTime timestamp;
  final Map<String, dynamic>? details;
  final String? ipAddress;
  final String? userAgent;

  AuditEntry({
    required this.action,
    required this.performedBy,
    required this.timestamp,
    this.details,
    this.ipAddress,
    this.userAgent,
  });

  Map<String, dynamic> toMap() => {
    'action': action,
    'performedBy': performedBy,
    'timestamp': timestamp.toIso8601String(),
    'details': details,
    'ipAddress': ipAddress,
    'userAgent': userAgent,
  };

  static AuditEntry fromMap(Map<String, dynamic> m) => AuditEntry(
    action: m['action'] ?? '',
    performedBy: m['performedBy'] ?? '',
    timestamp: DateTime.parse(m['timestamp']),
    details: m['details'],
    ipAddress: m['ipAddress'],
    userAgent: m['userAgent'],
  );
}

class ComplianceData {
  final bool isCompliant;
  final DateTime? lastInspectionDate;
  final String? inspectorName;
  final List<String>? violations;
  final List<String>? certifications;
  final DateTime? nextInspectionDue;
  final Map<String, dynamic>? complianceScores;

  ComplianceData({
    required this.isCompliant,
    this.lastInspectionDate,
    this.inspectorName,
    this.violations,
    this.certifications,
    this.nextInspectionDue,
    this.complianceScores,
  });

  Map<String, dynamic> toMap() => {
    'isCompliant': isCompliant,
    'lastInspectionDate': lastInspectionDate?.toIso8601String(),
    'inspectorName': inspectorName,
    'violations': violations,
    'certifications': certifications,
    'nextInspectionDue': nextInspectionDue?.toIso8601String(),
    'complianceScores': complianceScores,
  };

  static ComplianceData fromMap(Map<String, dynamic> m) => ComplianceData(
    isCompliant: m['isCompliant'] ?? true,
    lastInspectionDate: m['lastInspectionDate'] != null ? DateTime.parse(m['lastInspectionDate']) : null,
    inspectorName: m['inspectorName'],
    violations: (m['violations'] as List<dynamic>?)?.cast<String>(),
    certifications: (m['certifications'] as List<dynamic>?)?.cast<String>(),
    nextInspectionDue: m['nextInspectionDue'] != null ? DateTime.parse(m['nextInspectionDue']) : null,
    complianceScores: m['complianceScores'],
  );
}

class AITreatmentRecommendation {
  final String recommendationId;
  final String condition;
  final String recommendedTreatment;
  final String dosage;
  final double confidenceScore;
  final DateTime generatedAt;
  final List<String>? alternativeTreatments;
  final String? reasoning;
  final Map<String, dynamic>? supportingData;

  AITreatmentRecommendation({
    required this.recommendationId,
    required this.condition,
    required this.recommendedTreatment,
    required this.dosage,
    required this.confidenceScore,
    required this.generatedAt,
    this.alternativeTreatments,
    this.reasoning,
    this.supportingData,
  });

  Map<String, dynamic> toMap() => {
    'recommendationId': recommendationId,
    'condition': condition,
    'recommendedTreatment': recommendedTreatment,
    'dosage': dosage,
    'confidenceScore': confidenceScore,
    'generatedAt': generatedAt.toIso8601String(),
    'alternativeTreatments': alternativeTreatments,
    'reasoning': reasoning,
    'supportingData': supportingData,
  };

  static AITreatmentRecommendation fromMap(Map<String, dynamic> m) => AITreatmentRecommendation(
    recommendationId: m['recommendationId'] ?? '',
    condition: m['condition'] ?? '',
    recommendedTreatment: m['recommendedTreatment'] ?? '',
    dosage: m['dosage'] ?? '',
    confidenceScore: (m['confidenceScore'] as num).toDouble(),
    generatedAt: DateTime.parse(m['generatedAt']),
    alternativeTreatments: (m['alternativeTreatments'] as List<dynamic>?)?.cast<String>(),
    reasoning: m['reasoning'],
    supportingData: m['supportingData'],
  );
}