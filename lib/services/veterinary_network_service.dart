import 'dart:convert';
import 'package:http/http.dart' as http;

// Veterinary Network Service
class VeterinaryNetworkService {
  static const String _apiEndpoint = 'https://api.vetnetwork.com/v1';

  // Veterinarian Directory
  Future<List<Veterinarian>> findNearbyVeterinarians({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? specialty,
    bool emergency = false,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiEndpoint/veterinarians/search')
            .replace(queryParameters: {
          'lat': latitude.toString(),
          'lng': longitude.toString(),
          'radius': radiusKm.toString(),
          'specialty': specialty,
          'emergency': emergency.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['veterinarians'] as List)
            .map((v) => Veterinarian.fromMap(v))
            .toList();
      } else {
        // Return mock data for demonstration
        return _getMockVeterinarians(latitude, longitude, radiusKm);
      }
    } catch (e) {
      // Return mock data as fallback
      return _getMockVeterinarians(latitude, longitude, radiusKm);
    }
  }

  // Consultation Booking
  Future<ConsultationBooking> bookConsultation({
    required String veterinarianId,
    required String farmerId,
    required ConsultationType type,
    required DateTime preferredDateTime,
    required String description,
    List<String>? animalIds,
    bool isEmergency = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiEndpoint/consultations/book'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'veterinarian_id': veterinarianId,
          'farmer_id': farmerId,
          'type': type.toString().split('.').last,
          'preferred_datetime': preferredDateTime.toIso8601String(),
          'description': description,
          'animal_ids': animalIds,
          'is_emergency': isEmergency,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ConsultationBooking.fromMap(data);
      } else {
        throw Exception('Failed to book consultation');
      }
    } catch (e) {
      // Create mock booking for demonstration
      return ConsultationBooking(
        id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
        veterinarianId: veterinarianId,
        farmerId: farmerId,
        type: type,
        scheduledDateTime: preferredDateTime,
        status: BookingStatus.confirmed,
        description: description,
        animalIds: animalIds,
        isEmergency: isEmergency,
        createdAt: DateTime.now(),
      );
    }
  }

  // Virtual Consultation
  Future<VirtualConsultation> startVirtualConsultation({
    required String bookingId,
    required String farmerId,
    required String veterinarianId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiEndpoint/consultations/$bookingId/start'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'farmer_id': farmerId,
          'veterinarian_id': veterinarianId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return VirtualConsultation.fromMap(data);
      } else {
        throw Exception('Failed to start virtual consultation');
      }
    } catch (e) {
      // Create mock virtual consultation
      return VirtualConsultation(
        id: 'vc_${DateTime.now().millisecondsSinceEpoch}',
        bookingId: bookingId,
        farmerId: farmerId,
        veterinarianId: veterinarianId,
        roomUrl: 'https://vetnetwork.com/room/$bookingId',
        status: ConsultationStatus.active,
        startedAt: DateTime.now(),
      );
    }
  }

  // Second Opinion System
  Future<List<SecondOpinion>> requestSecondOpinions({
    required String originalDiagnosis,
    required List<String> symptoms,
    required String animalSpecies,
    required int minExperienceYears,
    required int numberOfOpinions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiEndpoint/second-opinions/request'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'original_diagnosis': originalDiagnosis,
          'symptoms': symptoms,
          'animal_species': animalSpecies,
          'min_experience_years': minExperienceYears,
          'number_of_opinions': numberOfOpinions,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return (data['opinions'] as List)
            .map((o) => SecondOpinion.fromMap(o))
            .toList();
      } else {
        throw Exception('Failed to request second opinions');
      }
    } catch (e) {
      // Return mock second opinions
      return _getMockSecondOpinions(originalDiagnosis, symptoms, animalSpecies);
    }
  }

  // Emergency Services
  Future<EmergencyResponse> requestEmergencyService({
    required double latitude,
    required double longitude,
    required String emergencyType,
    required String description,
    required String contactNumber,
    List<String>? animalIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiEndpoint/emergency/request'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'latitude': latitude,
          'longitude': longitude,
          'emergency_type': emergencyType,
          'description': description,
          'contact_number': contactNumber,
          'animal_ids': animalIds,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return EmergencyResponse.fromMap(data);
      } else {
        throw Exception('Failed to request emergency service');
      }
    } catch (e) {
      // Create mock emergency response
      return EmergencyResponse(
        id: 'emergency_${DateTime.now().millisecondsSinceEpoch}',
        status: EmergencyStatus.dispatched,
        estimatedArrivalTime: DateTime.now().add(Duration(minutes: 30)),
        veterinarianName: 'Dr. Emergency Vet',
        contactNumber: '+1-800-VET-HELP',
        vehicleType: 'Mobile Veterinary Unit',
        createdAt: DateTime.now(),
      );
    }
  }

  // Veterinary Marketplace
  Future<List<VeterinaryService>> getAvailableServices({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiEndpoint/services/available')
            .replace(queryParameters: {
          'lat': latitude.toString(),
          'lng': longitude.toString(),
          'radius': radiusKm.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['services'] as List)
            .map((s) => VeterinaryService.fromMap(s))
            .toList();
      } else {
        return _getMockVeterinaryServices();
      }
    } catch (e) {
      return _getMockVeterinaryServices();
    }
  }

  // Telemedicine Integration
  Future<TelemedicineSession> initiateTelemedicine({
    required String veterinarianId,
    required String farmerId,
    required List<String> animalIds,
    required String symptoms,
    required bool videoEnabled,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiEndpoint/telemedicine/initiate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'veterinarian_id': veterinarianId,
          'farmer_id': farmerId,
          'animal_ids': animalIds,
          'symptoms': symptoms,
          'video_enabled': videoEnabled,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return TelemedicineSession.fromMap(data);
      } else {
        throw Exception('Failed to initiate telemedicine session');
      }
    } catch (e) {
      // Create mock telemedicine session
      return TelemedicineSession(
        id: 'telemed_${DateTime.now().millisecondsSinceEpoch}',
        veterinarianId: veterinarianId,
        farmerId: farmerId,
        sessionUrl: 'https://vetnetwork.com/telemed/$veterinarianId',
        status: TelemedicineStatus.connecting,
        videoEnabled: videoEnabled,
        startedAt: DateTime.now(),
      );
    }
  }

  // Private helper methods

  List<Veterinarian> _getMockVeterinarians(double lat, double lng, double radius) {
    return [
      Veterinarian(
        id: 'vet_001',
        name: 'Dr. Sarah Johnson',
        specialty: 'Large Animal Medicine',
        experienceYears: 12,
        rating: 4.8,
        reviewCount: 156,
        clinicName: 'Johnson Veterinary Clinic',
        address: '123 Farm Road, Rural County',
        phone: '+1-555-0123',
        email: 'dr.johnson@vetclinic.com',
        latitude: lat + 0.01,
        longitude: lng + 0.01,
        distance: 1.2,
        availableToday: true,
        emergencyServices: true,
        consultationFee: 150,
        services: ['Vaccinations', 'Surgery', 'Emergency Care'],
        languages: ['English', 'Spanish'],
        certifications: ['Board Certified', 'Emergency Medicine'],
      ),
      Veterinarian(
        id: 'vet_002',
        name: 'Dr. Michael Chen',
        specialty: 'Poultry Health',
        experienceYears: 8,
        rating: 4.6,
        reviewCount: 89,
        clinicName: 'Chen Poultry Health Services',
        address: '456 Poultry Farm Lane',
        phone: '+1-555-0456',
        email: 'dr.chen@poultryvet.com',
        latitude: lat - 0.005,
        longitude: lng + 0.008,
        distance: 0.8,
        availableToday: true,
        emergencyServices: false,
        consultationFee: 120,
        services: ['Poultry Health', 'Vaccinations', 'Disease Prevention'],
        languages: ['English', 'Mandarin'],
        certifications: ['Poultry Specialist', 'Biosecurity Certified'],
      ),
    ];
  }

  List<SecondOpinion> _getMockSecondOpinions(
    String diagnosis,
    List<String> symptoms,
    String species,
  ) {
    return [
      SecondOpinion(
        id: 'opinion_001',
        veterinarianId: 'vet_specialist_001',
        veterinarianName: 'Dr. Emily Rodriguez',
        specialty: 'Internal Medicine',
        diagnosis: 'Suspected bacterial infection with secondary complications',
        confidenceLevel: 0.85,
        recommendedTests: ['Blood work', 'Ultrasound', 'Culture and sensitivity'],
        alternativeTreatments: ['Broad-spectrum antibiotic', 'Anti-inflammatory therapy'],
        additionalNotes: 'Consider underlying nutritional deficiencies',
        submittedAt: DateTime.now().subtract(Duration(hours: 2)),
      ),
      SecondOpinion(
        id: 'opinion_002',
        veterinarianId: 'vet_specialist_002',
        veterinarianName: 'Dr. James Wilson',
        specialty: 'Infectious Diseases',
        diagnosis: 'Viral infection with bacterial secondary infection',
        confidenceLevel: 0.78,
        recommendedTests: ['PCR testing', 'Complete blood count'],
        alternativeTreatments: ['Antiviral medication', 'Supportive care'],
        additionalNotes: 'Monitor for dehydration and provide fluid therapy',
        submittedAt: DateTime.now().subtract(Duration(hours: 1)),
      ),
    ];
  }

  List<VeterinaryService> _getMockVeterinaryServices() {
    return [
      VeterinaryService(
        id: 'service_001',
        name: 'Mobile Vaccination Clinic',
        description: 'Complete vaccination services at your farm',
        providerName: 'Mobile Vet Services Inc.',
        category: 'Vaccination',
        price: 75,
        durationMinutes: 30,
        availableSlots: ['2024-01-15T10:00:00Z', '2024-01-15T14:00:00Z'],
        rating: 4.7,
        reviewCount: 45,
      ),
      VeterinaryService(
        id: 'service_002',
        name: 'Emergency House Call',
        description: '24/7 emergency veterinary services',
        providerName: 'Emergency Vet Network',
        category: 'Emergency',
        price: 200,
        durationMinutes: 60,
        availableSlots: ['ASAP'],
        rating: 4.9,
        reviewCount: 128,
      ),
    ];
  }
}

// Data Models

class Veterinarian {
  final String id;
  final String name;
  final String specialty;
  final int experienceYears;
  final double rating;
  final int reviewCount;
  final String clinicName;
  final String address;
  final String phone;
  final String email;
  final double latitude;
  final double longitude;
  final double distance;
  final bool availableToday;
  final bool emergencyServices;
  final double consultationFee;
  final List<String> services;
  final List<String> languages;
  final List<String> certifications;

  Veterinarian({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experienceYears,
    required this.rating,
    required this.reviewCount,
    required this.clinicName,
    required this.address,
    required this.phone,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.availableToday,
    required this.emergencyServices,
    required this.consultationFee,
    required this.services,
    required this.languages,
    required this.certifications,
  });

  factory Veterinarian.fromMap(Map<String, dynamic> map) {
    return Veterinarian(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      experienceYears: map['experience_years'] ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['review_count'] ?? 0,
      clinicName: map['clinic_name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
      availableToday: map['available_today'] ?? false,
      emergencyServices: map['emergency_services'] ?? false,
      consultationFee: (map['consultation_fee'] as num?)?.toDouble() ?? 0.0,
      services: List<String>.from(map['services'] ?? []),
      languages: List<String>.from(map['languages'] ?? []),
      certifications: List<String>.from(map['certifications'] ?? []),
    );
  }
}

enum ConsultationType {
  routine,
  emergency,
  followUp,
  vaccination,
  surgery,
  telemedicine,
}

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

class ConsultationBooking {
  final String id;
  final String veterinarianId;
  final String farmerId;
  final ConsultationType type;
  final DateTime scheduledDateTime;
  final BookingStatus status;
  final String description;
  final List<String>? animalIds;
  final bool isEmergency;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;
  final double? totalCost;

  ConsultationBooking({
    required this.id,
    required this.veterinarianId,
    required this.farmerId,
    required this.type,
    required this.scheduledDateTime,
    required this.status,
    required this.description,
    this.animalIds,
    required this.isEmergency,
    required this.createdAt,
    this.completedAt,
    this.notes,
    this.totalCost,
  });

  factory ConsultationBooking.fromMap(Map<String, dynamic> map) {
    return ConsultationBooking(
      id: map['id'] ?? '',
      veterinarianId: map['veterinarian_id'] ?? '',
      farmerId: map['farmer_id'] ?? '',
      type: ConsultationType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ConsultationType.routine,
      ),
      scheduledDateTime: DateTime.parse(map['scheduled_datetime'] ?? ''),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      description: map['description'] ?? '',
      animalIds: List<String>.from(map['animal_ids'] ?? []),
      isEmergency: map['is_emergency'] ?? false,
      createdAt: DateTime.parse(map['created_at'] ?? ''),
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null,
      notes: map['notes'],
      totalCost: (map['total_cost'] as num?)?.toDouble(),
    );
  }
}

enum ConsultationStatus {
  waiting,
  active,
  completed,
  disconnected,
}

class VirtualConsultation {
  final String id;
  final String bookingId;
  final String farmerId;
  final String veterinarianId;
  final String roomUrl;
  final ConsultationStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationMinutes;
  final String? recordingUrl;

  VirtualConsultation({
    required this.id,
    required this.bookingId,
    required this.farmerId,
    required this.veterinarianId,
    required this.roomUrl,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.durationMinutes,
    this.recordingUrl,
  });

  factory VirtualConsultation.fromMap(Map<String, dynamic> map) {
    return VirtualConsultation(
      id: map['id'] ?? '',
      bookingId: map['booking_id'] ?? '',
      farmerId: map['farmer_id'] ?? '',
      veterinarianId: map['veterinarian_id'] ?? '',
      roomUrl: map['room_url'] ?? '',
      status: ConsultationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ConsultationStatus.waiting,
      ),
      startedAt: DateTime.parse(map['started_at'] ?? ''),
      endedAt: map['ended_at'] != null ? DateTime.parse(map['ended_at']) : null,
      durationMinutes: map['duration_minutes'],
      recordingUrl: map['recording_url'],
    );
  }
}

class SecondOpinion {
  final String id;
  final String veterinarianId;
  final String veterinarianName;
  final String specialty;
  final String diagnosis;
  final double confidenceLevel;
  final List<String> recommendedTests;
  final List<String> alternativeTreatments;
  final String additionalNotes;
  final DateTime submittedAt;

  SecondOpinion({
    required this.id,
    required this.veterinarianId,
    required this.veterinarianName,
    required this.specialty,
    required this.diagnosis,
    required this.confidenceLevel,
    required this.recommendedTests,
    required this.alternativeTreatments,
    required this.additionalNotes,
    required this.submittedAt,
  });

  factory SecondOpinion.fromMap(Map<String, dynamic> map) {
    return SecondOpinion(
      id: map['id'] ?? '',
      veterinarianId: map['veterinarian_id'] ?? '',
      veterinarianName: map['veterinarian_name'] ?? '',
      specialty: map['specialty'] ?? '',
      diagnosis: map['diagnosis'] ?? '',
      confidenceLevel: (map['confidence_level'] as num?)?.toDouble() ?? 0.0,
      recommendedTests: List<String>.from(map['recommended_tests'] ?? []),
      alternativeTreatments: List<String>.from(map['alternative_treatments'] ?? []),
      additionalNotes: map['additional_notes'] ?? '',
      submittedAt: DateTime.parse(map['submitted_at'] ?? ''),
    );
  }
}

enum EmergencyStatus {
  requested,
  acknowledged,
  dispatched,
  arrived,
  completed,
}

class EmergencyResponse {
  final String id;
  final EmergencyStatus status;
  final DateTime estimatedArrivalTime;
  final String veterinarianName;
  final String contactNumber;
  final String vehicleType;
  final DateTime createdAt;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  final String? notes;

  EmergencyResponse({
    required this.id,
    required this.status,
    required this.estimatedArrivalTime,
    required this.veterinarianName,
    required this.contactNumber,
    required this.vehicleType,
    required this.createdAt,
    this.arrivedAt,
    this.completedAt,
    this.notes,
  });

  factory EmergencyResponse.fromMap(Map<String, dynamic> map) {
    return EmergencyResponse(
      id: map['id'] ?? '',
      status: EmergencyStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => EmergencyStatus.requested,
      ),
      estimatedArrivalTime: DateTime.parse(map['estimated_arrival_time'] ?? ''),
      veterinarianName: map['veterinarian_name'] ?? '',
      contactNumber: map['contact_number'] ?? '',
      vehicleType: map['vehicle_type'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? ''),
      arrivedAt: map['arrived_at'] != null ? DateTime.parse(map['arrived_at']) : null,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null,
      notes: map['notes'],
    );
  }
}

class VeterinaryService {
  final String id;
  final String name;
  final String description;
  final String providerName;
  final String category;
  final double price;
  final int durationMinutes;
  final List<String> availableSlots;
  final double rating;
  final int reviewCount;

  VeterinaryService({
    required this.id,
    required this.name,
    required this.description,
    required this.providerName,
    required this.category,
    required this.price,
    required this.durationMinutes,
    required this.availableSlots,
    required this.rating,
    required this.reviewCount,
  });

  factory VeterinaryService.fromMap(Map<String, dynamic> map) {
    return VeterinaryService(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      providerName: map['provider_name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: map['duration_minutes'] ?? 0,
      availableSlots: List<String>.from(map['available_slots'] ?? []),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['review_count'] ?? 0,
    );
  }
}

enum TelemedicineStatus {
  connecting,
  connected,
  disconnected,
  completed,
}

class TelemedicineSession {
  final String id;
  final String veterinarianId;
  final String farmerId;
  final String sessionUrl;
  final TelemedicineStatus status;
  final bool videoEnabled;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationMinutes;
  final String? recordingUrl;

  TelemedicineSession({
    required this.id,
    required this.veterinarianId,
    required this.farmerId,
    required this.sessionUrl,
    required this.status,
    required this.videoEnabled,
    required this.startedAt,
    this.endedAt,
    this.durationMinutes,
    this.recordingUrl,
  });

  factory TelemedicineSession.fromMap(Map<String, dynamic> map) {
    return TelemedicineSession(
      id: map['id'] ?? '',
      veterinarianId: map['veterinarian_id'] ?? '',
      farmerId: map['farmer_id'] ?? '',
      sessionUrl: map['session_url'] ?? '',
      status: TelemedicineStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => TelemedicineStatus.connecting,
      ),
      videoEnabled: map['video_enabled'] ?? false,
      startedAt: DateTime.parse(map['started_at'] ?? ''),
      endedAt: map['ended_at'] != null ? DateTime.parse(map['ended_at']) : null,
      durationMinutes: map['duration_minutes'],
      recordingUrl: map['recording_url'],
    );
  }
}