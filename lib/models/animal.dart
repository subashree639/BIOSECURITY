class Animal {
  final String id;
  final String species;
  final String age;
  final String breed;
  final String? farmerId;
  final DateTime? createdAt;
  final String? photoPath;

  // Enhanced fields for comprehensive animal tracking
  final String? gender;
  final double? weight;
  final DateTime? birthDate;
  final String? healthStatus;
  final String? vaccinationStatus;
  final String? medicalHistory;
  final String? notes;
  final bool? isPregnant;
  final DateTime? lastVaccinationDate;
  final DateTime? nextVaccinationDate;
  final String? tagNumber;
  final String? motherId;
  final String? fatherId;

  Animal({
    required this.id,
    required this.species,
    required this.age,
    required this.breed,
    this.farmerId,
    this.createdAt,
    this.photoPath,
    this.gender,
    this.weight,
    this.birthDate,
    this.healthStatus,
    this.vaccinationStatus,
    this.medicalHistory,
    this.notes,
    this.isPregnant,
    this.lastVaccinationDate,
    this.nextVaccinationDate,
    this.tagNumber,
    this.motherId,
    this.fatherId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'species': species,
      'age': age,
      'breed': breed,
      'farmer_id': farmerId,
      'created_at': createdAt?.toIso8601String(),
      'photo_path': photoPath,
      'gender': gender,
      'weight': weight,
      'birth_date': birthDate?.toIso8601String(),
      'health_status': healthStatus,
      'vaccination_status': vaccinationStatus,
      'medical_history': medicalHistory,
      'notes': notes,
      'is_pregnant': isPregnant == true ? 1 : 0,
      'last_vaccination_date': lastVaccinationDate?.toIso8601String(),
      'next_vaccination_date': nextVaccinationDate?.toIso8601String(),
      'tag_number': tagNumber,
      'mother_id': motherId,
      'father_id': fatherId,
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'],
      species: map['species'],
      age: map['age'],
      breed: map['breed'],
      farmerId: map['farmer_id'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      photoPath: map['photo_path'],
      gender: map['gender'],
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      birthDate: map['birth_date'] != null ? DateTime.parse(map['birth_date']) : null,
      healthStatus: map['health_status'],
      vaccinationStatus: map['vaccination_status'],
      medicalHistory: map['medical_history'],
      notes: map['notes'],
      isPregnant: map['is_pregnant'] == 1,
      lastVaccinationDate: map['last_vaccination_date'] != null ? DateTime.parse(map['last_vaccination_date']) : null,
      nextVaccinationDate: map['next_vaccination_date'] != null ? DateTime.parse(map['next_vaccination_date']) : null,
      tagNumber: map['tag_number'],
      motherId: map['mother_id'],
      fatherId: map['father_id'],
    );
  }

  Animal copyWith({
    String? id,
    String? species,
    String? age,
    String? breed,
    String? farmerId,
    DateTime? createdAt,
    String? photoPath,
    String? gender,
    double? weight,
    DateTime? birthDate,
    String? healthStatus,
    String? vaccinationStatus,
    String? medicalHistory,
    String? notes,
    bool? isPregnant,
    DateTime? lastVaccinationDate,
    DateTime? nextVaccinationDate,
    String? tagNumber,
    String? motherId,
    String? fatherId,
  }) {
    return Animal(
      id: id ?? this.id,
      species: species ?? this.species,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      farmerId: farmerId ?? this.farmerId,
      createdAt: createdAt ?? this.createdAt,
      photoPath: photoPath ?? this.photoPath,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      birthDate: birthDate ?? this.birthDate,
      healthStatus: healthStatus ?? this.healthStatus,
      vaccinationStatus: vaccinationStatus ?? this.vaccinationStatus,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      notes: notes ?? this.notes,
      isPregnant: isPregnant ?? this.isPregnant,
      lastVaccinationDate: lastVaccinationDate ?? this.lastVaccinationDate,
      nextVaccinationDate: nextVaccinationDate ?? this.nextVaccinationDate,
      tagNumber: tagNumber ?? this.tagNumber,
      motherId: motherId ?? this.motherId,
      fatherId: fatherId ?? this.fatherId,
    );
  }
}