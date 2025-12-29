import 'package:cloud_firestore/cloud_firestore.dart';

// Farmer Model - matches farmers collection
class Farmer {
  final String id;
  final String name;
  final String location;
  final int livestockCount;
  final double compliance;
  final String lastActivity;
  final String district;
  final String area;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Farmer({
    required this.id,
    required this.name,
    required this.location,
    required this.livestockCount,
    required this.compliance,
    required this.lastActivity,
    required this.district,
    required this.area,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'location': location,
        'livestock_count': livestockCount,
        'compliance': compliance,
        'last_activity': lastActivity,
        'district': district,
        'area': area,
        'created_at': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updated_at': updatedAt != null
            ? Timestamp.fromDate(updatedAt!)
            : FieldValue.serverTimestamp(),
      };

  static Farmer fromMap(Map<String, dynamic> map) => Farmer(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        location: map['location'] ?? '',
        livestockCount: map['livestock_count'] ?? 0,
        compliance: (map['compliance'] as num?)?.toDouble() ?? 0.0,
        lastActivity: map['last_activity'] ?? '',
        district: map['district'] ?? '',
        area: map['area'] ?? '',
        createdAt: map['created_at'] is Timestamp
            ? (map['created_at'] as Timestamp).toDate()
            : null,
        updatedAt: map['updated_at'] is Timestamp
            ? (map['updated_at'] as Timestamp).toDate()
            : null,
      );
}

// Livestock Model - matches livestock collection
class Livestock {
  final String id;
  final String type;
  final String ownerId;
  final String status;
  final String withdrawalStatus;
  final String? medication;
  final int daysLeft;
  final int? withdrawalDays;
  final String species;
  final double healthScore;
  final String mrlStatus;
  final String? lastDrug;
  final DateTime? withdrawalEnd;
  final DateTime? withdrawalStart;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Livestock({
    required this.id,
    required this.type,
    required this.ownerId,
    required this.status,
    required this.withdrawalStatus,
    this.medication,
    required this.daysLeft,
    this.withdrawalDays,
    required this.species,
    required this.healthScore,
    required this.mrlStatus,
    this.lastDrug,
    this.withdrawalEnd,
    this.withdrawalStart,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'owner_id': ownerId,
        'status': status,
        'withdrawal_status': withdrawalStatus,
        'medication': medication,
        'days_left': daysLeft,
        'withdrawal_days': withdrawalDays,
        'species': species,
        'healthScore': healthScore,
        'mrlStatus': mrlStatus,
        'lastDrug': lastDrug,
        'withdrawalEnd':
            withdrawalEnd != null ? Timestamp.fromDate(withdrawalEnd!) : null,
        'withdrawalStart': withdrawalStart != null
            ? Timestamp.fromDate(withdrawalStart!)
            : null,
        'created_at': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updated_at': updatedAt != null
            ? Timestamp.fromDate(updatedAt!)
            : FieldValue.serverTimestamp(),
      };

  static Livestock fromMap(Map<String, dynamic> map) => Livestock(
        id: map['id'] ?? '',
        type: map['type'] ?? '',
        ownerId: map['owner_id'] ?? '',
        status: map['status'] ?? 'Healthy',
        withdrawalStatus: map['withdrawal_status'] ?? 'Active',
        medication: map['medication'],
        daysLeft: map['days_left'] ?? 0,
        withdrawalDays: map['withdrawal_days'],
        species: map['species'] ?? '',
        healthScore: (map['healthScore'] as num?)?.toDouble() ?? 0.0,
        mrlStatus: map['mrlStatus'] ?? 'Compliant',
        lastDrug: map['lastDrug'],
        withdrawalEnd: map['withdrawalEnd'] is Timestamp
            ? (map['withdrawalEnd'] as Timestamp).toDate()
            : null,
        withdrawalStart: map['withdrawalStart'] is Timestamp
            ? (map['withdrawalStart'] as Timestamp).toDate()
            : null,
        createdAt: map['created_at'] is Timestamp
            ? (map['created_at'] as Timestamp).toDate()
            : null,
        updatedAt: map['updated_at'] is Timestamp
            ? (map['updated_at'] as Timestamp).toDate()
            : null,
      );
}

// District Model - matches districts collection
class District {
  final String name;
  final int farmers;
  final int vets;
  final int livestock;
  final double compliance;
  final List<String> areas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  District({
    required this.name,
    required this.farmers,
    required this.vets,
    required this.livestock,
    required this.compliance,
    required this.areas,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'farmers': farmers,
        'vets': vets,
        'livestock': livestock,
        'compliance': compliance,
        'areas': areas,
        'created_at': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updated_at': updatedAt != null
            ? Timestamp.fromDate(updatedAt!)
            : FieldValue.serverTimestamp(),
      };

  static District fromMap(Map<String, dynamic> map) => District(
        name: map['name'] ?? '',
        farmers: map['farmers'] ?? 0,
        vets: map['vets'] ?? 0,
        livestock: map['livestock'] ?? 0,
        compliance: (map['compliance'] as num?)?.toDouble() ?? 0.0,
        areas: List<String>.from(map['areas'] ?? []),
        createdAt: map['created_at'] is Timestamp
            ? (map['created_at'] as Timestamp).toDate()
            : null,
        updatedAt: map['updated_at'] is Timestamp
            ? (map['updated_at'] as Timestamp).toDate()
            : null,
      );
}

// Prescription Model - matches prescriptions collection
class Prescription {
  final String id;
  final String animalId;
  final String medication;
  final String veterinarian;
  final String issueDate;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Prescription({
    required this.id,
    required this.animalId,
    required this.medication,
    required this.veterinarian,
    required this.issueDate,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'animal_id': animalId,
        'medication': medication,
        'veterinarian': veterinarian,
        'issue_date': issueDate,
        'status': status,
        'created_at': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updated_at': updatedAt != null
            ? Timestamp.fromDate(updatedAt!)
            : FieldValue.serverTimestamp(),
      };

  static Prescription fromMap(Map<String, dynamic> map) => Prescription(
        id: map['id'] ?? '',
        animalId: map['animal_id'] ?? '',
        medication: map['medication'] ?? '',
        veterinarian: map['veterinarian'] ?? '',
        issueDate: map['issue_date'] ?? '',
        status: map['status'] ?? 'Active',
        createdAt: map['created_at'] is Timestamp
            ? (map['created_at'] as Timestamp).toDate()
            : null,
        updatedAt: map['updated_at'] is Timestamp
            ? (map['updated_at'] as Timestamp).toDate()
            : null,
      );
}

// Alert Model - matches alerts collection
class Alert {
  final String type;
  final String message;
  final String time;
  final String location;
  final String icon;
  final DateTime timestamp;
  final bool isRead;
  final String priority;
  final String? farmer;
  final String? vet;

  Alert({
    required this.type,
    required this.message,
    required this.time,
    required this.location,
    required this.icon,
    required this.timestamp,
    required this.isRead,
    required this.priority,
    this.farmer,
    this.vet,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'message': message,
        'time': time,
        'location': location,
        'icon': icon,
        'timestamp': Timestamp.fromDate(timestamp),
        'is_read': isRead,
        'priority': priority,
        'farmer': farmer,
        'vet': vet,
      };

  static Alert fromMap(Map<String, dynamic> map) => Alert(
        type: map['type'] ?? 'Info',
        message: map['message'] ?? '',
        time: map['time'] ?? '',
        location: map['location'] ?? '',
        icon: map['icon'] ?? 'fas fa-info-circle',
        timestamp: map['timestamp'] is Timestamp
            ? (map['timestamp'] as Timestamp).toDate()
            : DateTime.now(),
        isRead: map['is_read'] ?? false,
        priority: map['priority'] ?? 'medium',
        farmer: map['farmer'],
        vet: map['vet'],
      );
}

// KPIs Model - matches kpis collection (single document)
class KPIs {
  final int totalLivestock;
  final int activeWithdrawal;
  final double complianceRate;
  final int pendingReviews;
  final DateTime? lastUpdated;

  // Nested KPIs for different categories
  final KPIs? farmersKPIs;
  final KPIs? livestockKPIs;
  final KPIs? vetsKPIs;
  final KPIs? usersKPIs;
  final KPIs? translationsKPIs;

  KPIs({
    required this.totalLivestock,
    required this.activeWithdrawal,
    required this.complianceRate,
    required this.pendingReviews,
    this.lastUpdated,
    this.farmersKPIs,
    this.livestockKPIs,
    this.vetsKPIs,
    this.usersKPIs,
    this.translationsKPIs,
  });

  Map<String, dynamic> toMap() => {
        'total_livestock': totalLivestock,
        'active_withdrawal': activeWithdrawal,
        'compliance_rate': complianceRate,
        'pending_reviews': pendingReviews,
        'last_updated': lastUpdated != null
            ? Timestamp.fromDate(lastUpdated!)
            : FieldValue.serverTimestamp(),
        if (farmersKPIs != null) 'farmers': farmersKPIs!.toMap(),
        if (livestockKPIs != null) 'livestock': livestockKPIs!.toMap(),
        if (vetsKPIs != null) 'vets': vetsKPIs!.toMap(),
        if (usersKPIs != null) 'users': usersKPIs!.toMap(),
        if (translationsKPIs != null) 'translations': translationsKPIs!.toMap(),
      };

  static KPIs fromMap(Map<String, dynamic> map) => KPIs(
        totalLivestock: map['total_livestock'] ?? 0,
        activeWithdrawal: map['active_withdrawal'] ?? 0,
        complianceRate: (map['compliance_rate'] as num?)?.toDouble() ?? 0.0,
        pendingReviews: map['pending_reviews'] ?? 0,
        lastUpdated: map['last_updated'] is Timestamp
            ? (map['last_updated'] as Timestamp).toDate()
            : null,
        farmersKPIs:
            map['farmers'] != null ? KPIs.fromMap(map['farmers']) : null,
        livestockKPIs:
            map['livestock'] != null ? KPIs.fromMap(map['livestock']) : null,
        vetsKPIs: map['vets'] != null ? KPIs.fromMap(map['vets']) : null,
        usersKPIs: map['users'] != null ? KPIs.fromMap(map['users']) : null,
        translationsKPIs: map['translations'] != null
            ? KPIs.fromMap(map['translations'])
            : null,
      );
}

// Translations Model - matches translations collection (single document)
class Translations {
  final Map<String, String> en;
  final Map<String, String> hi;
  final Map<String, String> ta;

  Translations({
    required this.en,
    required this.hi,
    required this.ta,
  });

  Map<String, dynamic> toMap() => {
        'en': en,
        'hi': hi,
        'ta': ta,
      };

  static Translations fromMap(Map<String, dynamic> map) => Translations(
        en: Map<String, String>.from(map['en'] ?? {}),
        hi: Map<String, String>.from(map['hi'] ?? {}),
        ta: Map<String, String>.from(map['ta'] ?? {}),
      );

  Map<String, String> getTranslations(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return hi;
      case 'ta':
        return ta;
      default:
        return en;
    }
  }
}

// User Model - matches users collection
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String district;
  final String area;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.district,
    required this.area,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'district': district,
        'area': area,
        'created_at': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updated_at': updatedAt != null
            ? Timestamp.fromDate(updatedAt!)
            : FieldValue.serverTimestamp(),
      };

  static User fromMap(Map<String, dynamic> map) => User(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        role: map['role'] ?? '',
        district: map['district'] ?? '',
        area: map['area'] ?? '',
        createdAt: map['created_at'] is Timestamp
            ? (map['created_at'] as Timestamp).toDate()
            : null,
        updatedAt: map['updated_at'] is Timestamp
            ? (map['updated_at'] as Timestamp).toDate()
            : null,
      );
}

// Vet Model - matches vets collection
class Vet {
  final String id;
  final String name;
  final String email;
  final String licenseNumber;
  final String district;
  final String area;
  final String specialization;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Vet({
    required this.id,
    required this.name,
    required this.email,
    required this.licenseNumber,
    required this.district,
    required this.area,
    required this.specialization,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'license_number': licenseNumber,
        'district': district,
        'area': area,
        'specialization': specialization,
        'created_at': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updated_at': updatedAt != null
            ? Timestamp.fromDate(updatedAt!)
            : FieldValue.serverTimestamp(),
      };

  static Vet fromMap(Map<String, dynamic> map) => Vet(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        licenseNumber: map['license_number'] ?? '',
        district: map['district'] ?? '',
        area: map['area'] ?? '',
        specialization: map['specialization'] ?? '',
        createdAt: map['created_at'] is Timestamp
            ? (map['created_at'] as Timestamp).toDate()
            : null,
        updatedAt: map['updated_at'] is Timestamp
            ? (map['updated_at'] as Timestamp).toDate()
            : null,
      );
}
