class Consultation {
  final String id;
  final String animalId;
  final String animalName;
  final String species;
  final String disease;
  final String consultationDate;
  final String vetName;
  final String vetId;
  final String diagnosis;
  final String treatment;
  final String status;
  final String followUpDate;
  final String notes;
  final DateTime? createdAt;

  Consultation({
    required this.id,
    required this.animalId,
    required this.animalName,
    required this.species,
    required this.disease,
    required this.consultationDate,
    required this.vetName,
    required this.vetId,
    required this.diagnosis,
    required this.treatment,
    required this.status,
    required this.followUpDate,
    required this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animal_id': animalId,
      'animal_name': animalName,
      'species': species,
      'disease': disease,
      'consultation_date': consultationDate,
      'vet_name': vetName,
      'vet_id': vetId,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'status': status,
      'follow_up_date': followUpDate,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Consultation.fromMap(Map<String, dynamic> map) {
    return Consultation(
      id: map['id'],
      animalId: map['animal_id'],
      animalName: map['animal_name'],
      species: map['species'],
      disease: map['disease'],
      consultationDate: map['consultation_date'],
      vetName: map['vet_name'],
      vetId: map['vet_id'],
      diagnosis: map['diagnosis'],
      treatment: map['treatment'],
      status: map['status'],
      followUpDate: map['follow_up_date'],
      notes: map['notes'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Consultation copyWith({
    String? id,
    String? animalId,
    String? animalName,
    String? species,
    String? disease,
    String? consultationDate,
    String? vetName,
    String? vetId,
    String? diagnosis,
    String? treatment,
    String? status,
    String? followUpDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return Consultation(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      animalName: animalName ?? this.animalName,
      species: species ?? this.species,
      disease: disease ?? this.disease,
      consultationDate: consultationDate ?? this.consultationDate,
      vetName: vetName ?? this.vetName,
      vetId: vetId ?? this.vetId,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      status: status ?? this.status,
      followUpDate: followUpDate ?? this.followUpDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}