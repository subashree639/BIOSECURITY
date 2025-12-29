import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore_models.dart';
import 'dart:async';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._();
  factory FirestoreService() => _instance;
  FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Connection status
  bool _isOnline = true;

  // Check if Firebase is accessible
  Future<bool> checkConnectivity() async {
    try {
      // Try a simple operation to check connectivity
      await _firestore.collection('test').doc('connectivity').get();
      _isOnline = true;
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' ||
          e.code == 'deadline-exceeded' ||
          e.code == 'cancelled') {
        _isOnline = false;
        print('Firebase connectivity check failed: ${e.message}');
        return false;
      }
      // Other errors might not be connectivity related
      _isOnline = true;
      return true;
    } catch (e) {
      _isOnline = false;
      print('Unexpected error during connectivity check: $e');
      return false;
    }
  }

  // Get current connection status
  bool get isOnline => _isOnline;

  // Retry utility for Firebase operations
  Future<T> _retryFirebaseOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } on FirebaseException catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          print(
              'Firebase operation failed after $maxRetries attempts: ${e.message}');
          rethrow;
        }

        // Check if it's a network-related error
        if (e.code == 'unavailable' ||
            e.code == 'deadline-exceeded' ||
            e.code == 'cancelled') {
          _isOnline = false;
          print(
              'Network error (attempt $attempt/$maxRetries): ${e.message}. Retrying in ${delay.inSeconds}s...');
          await Future.delayed(delay);
          delay *= 2; // Exponential backoff
        } else {
          // Non-network error, don't retry
          print('Non-network Firebase error: ${e.message}');
          rethrow;
        }
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          print('Operation failed after $maxRetries attempts: $e');
          rethrow;
        }
        print(
            'Unexpected error (attempt $attempt/$maxRetries): $e. Retrying in ${delay.inSeconds}s...');
        await Future.delayed(delay);
        delay *= 2;
      }
    }

    throw Exception('Retry logic failed unexpectedly');
  }

  // Collection references
  static const String farmersCollection = 'farmers';
  static const String livestockCollection = 'livestock';
  static const String districtsCollection = 'districts';
  static const String prescriptionsCollection = 'prescriptions';
  static const String alertsCollection = 'alerts';
  static const String kpisCollection = 'kpis';
  static const String translationsCollection = 'translations';
  static const String usersCollection = 'users';
  static const String vetsCollection = 'vets';

  // Farmers operations
  Future<void> saveFarmer(Farmer farmer) async {
    await _retryFirebaseOperation(() async {
      await _firestore
          .collection(farmersCollection)
          .doc(farmer.id)
          .set(farmer.toMap());
    });
  }

  Future<Farmer?> getFarmer(String farmerId) async {
    return await _retryFirebaseOperation(() async {
      final doc =
          await _firestore.collection(farmersCollection).doc(farmerId).get();
      return doc.exists ? Farmer.fromMap(doc.data()!) : null;
    });
  }

  Future<List<Farmer>> getFarmersByDistrict(String district) async {
    return await _retryFirebaseOperation(() async {
      final snapshot = await _firestore
          .collection(farmersCollection)
          .where('district', isEqualTo: district)
          .get();
      return snapshot.docs.map((doc) => Farmer.fromMap(doc.data())).toList();
    });
  }

  Future<List<Farmer>> getAllFarmers() async {
    return await _retryFirebaseOperation(() async {
      final snapshot = await _firestore.collection(farmersCollection).get();
      return snapshot.docs.map((doc) => Farmer.fromMap(doc.data())).toList();
    });
  }

  // Livestock operations
  Future<void> saveLivestock(Livestock livestock) async {
    await _retryFirebaseOperation(() async {
      await _firestore
          .collection(livestockCollection)
          .doc(livestock.id)
          .set(livestock.toMap());
    });
  }

  Future<Livestock?> getLivestock(String livestockId) async {
    return await _retryFirebaseOperation(() async {
      final doc = await _firestore
          .collection(livestockCollection)
          .doc(livestockId)
          .get();
      return doc.exists ? Livestock.fromMap(doc.data()!) : null;
    });
  }

  Future<List<Livestock>> getLivestockByOwner(String ownerId) async {
    return await _retryFirebaseOperation(() async {
      final snapshot = await _firestore
          .collection(livestockCollection)
          .where('owner_id', isEqualTo: ownerId)
          .get();
      return snapshot.docs.map((doc) => Livestock.fromMap(doc.data())).toList();
    });
  }

  Future<List<Livestock>> getLivestockInWithdrawal() async {
    return await _retryFirebaseOperation(() async {
      final snapshot = await _firestore
          .collection(livestockCollection)
          .where('withdrawal_status', isEqualTo: 'Active')
          .get();
      return snapshot.docs.map((doc) => Livestock.fromMap(doc.data())).toList();
    });
  }

  Future<List<Livestock>> getAllLivestock() async {
    return await _retryFirebaseOperation(() async {
      final snapshot = await _firestore.collection(livestockCollection).get();
      return snapshot.docs.map((doc) => Livestock.fromMap(doc.data())).toList();
    });
  }

  // Districts operations
  Future<void> saveDistrict(District district) async {
    await _retryFirebaseOperation(() async {
      await _firestore
          .collection(districtsCollection)
          .doc(district.name)
          .set(district.toMap());
    });
  }

  Future<District?> getDistrict(String districtName) async {
    return await _retryFirebaseOperation(() async {
      final doc = await _firestore
          .collection(districtsCollection)
          .doc(districtName)
          .get();
      return doc.exists ? District.fromMap(doc.data()!) : null;
    });
  }

  Future<List<District>> getAllDistricts() async {
    return await _retryFirebaseOperation(() async {
      final snapshot = await _firestore.collection(districtsCollection).get();
      return snapshot.docs.map((doc) => District.fromMap(doc.data())).toList();
    });
  }

  // Prescriptions operations
  Future<void> savePrescription(Prescription prescription) async {
    await _retryFirebaseOperation(() async {
      await _firestore
          .collection(prescriptionsCollection)
          .doc(prescription.id)
          .set(prescription.toMap());
    });
  }

  Future<Prescription?> getPrescription(String prescriptionId) async {
    return await _retryFirebaseOperation(() async {
      final doc = await _firestore
          .collection(prescriptionsCollection)
          .doc(prescriptionId)
          .get();
      return doc.exists ? Prescription.fromMap(doc.data()!) : null;
    });
  }

  Future<List<Prescription>> getPrescriptionsByAnimal(String animalId) async {
    return await _retryFirebaseOperation(() async {
      final snapshot = await _firestore
          .collection(prescriptionsCollection)
          .where('animal_id', isEqualTo: animalId)
          .orderBy('issue_date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Prescription.fromMap(doc.data()))
          .toList();
    });
  }

  Future<List<Prescription>> getAllPrescriptions() async {
    return await _retryFirebaseOperation(() async {
      final snapshot =
          await _firestore.collection(prescriptionsCollection).get();
      return snapshot.docs
          .map((doc) => Prescription.fromMap(doc.data()))
          .toList();
    });
  }

  // Alerts operations
  Future<void> createAlert(Alert alert) async {
    await _retryFirebaseOperation(() async {
      await _firestore.collection(alertsCollection).add(alert.toMap());
    });
  }

  Future<List<Alert>> getAlerts({bool unreadOnly = false}) async {
    return await _retryFirebaseOperation(() async {
      Query query = _firestore.collection(alertsCollection);
      if (unreadOnly) {
        query = query.where('is_read', isEqualTo: false);
      }
      final snapshot =
          await query.orderBy('timestamp', descending: true).limit(50).get();
      return snapshot.docs
          .map((doc) => Alert.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> markAlertAsRead(String alertId) async {
    await _retryFirebaseOperation(() async {
      // Since alerts are stored with auto-generated IDs, we need to find and update
      // This is a placeholder implementation - in practice, you'd need the document ID
      // For now, this method is incomplete and needs proper implementation
      print(
          'markAlertAsRead called with alertId: $alertId - implementation needed');
    });
  }

  // KPIs operations
  Future<void> updateKPIs(KPIs kpis) async {
    await _retryFirebaseOperation(() async {
      await _firestore
          .collection(kpisCollection)
          .doc('current')
          .set(kpis.toMap());
    });
  }

  Future<KPIs?> getKPIs() async {
    return await _retryFirebaseOperation(() async {
      final doc =
          await _firestore.collection(kpisCollection).doc('current').get();
      return doc.exists ? KPIs.fromMap(doc.data()!) : null;
    });
  }

  // Translations operations
  Future<void> updateTranslations(Translations translations) async {
    await _retryFirebaseOperation(() async {
      await _firestore
          .collection(translationsCollection)
          .doc('current')
          .set(translations.toMap());
    });
  }

  Future<Translations?> getTranslations() async {
    return await _retryFirebaseOperation(() async {
      final doc = await _firestore
          .collection(translationsCollection)
          .doc('current')
          .get();
      return doc.exists ? Translations.fromMap(doc.data()!) : null;
    });
  }

  // Users operations
  Future<void> saveUser(User user) async {
    await _retryFirebaseOperation(() async {
      await _firestore
          .collection(usersCollection)
          .doc(user.id)
          .set(user.toMap());
    });
  }

  Future<User?> getUser(String userId) async {
    return await _retryFirebaseOperation(() async {
      final doc =
          await _firestore.collection(usersCollection).doc(userId).get();
      return doc.exists ? User.fromMap(doc.data()!) : null;
    });
  }

  Future<List<User>> getUsersByDistrict(String district) async {
    return await _retryFirebaseOperation(() async {
      final snapshot = await _firestore
          .collection(usersCollection)
          .where('district', isEqualTo: district)
          .get();
      return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
    });
  }

  Future<List<User>> getAllUsers() async {
    return await _retryFirebaseOperation(() async {
      final snapshot = await _firestore.collection(usersCollection).get();
      return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
    });
  }

  // Vets operations
  Future<void> saveVet(Vet vet) async {
    await _retryFirebaseOperation(() async {
      await _firestore.collection(vetsCollection).doc(vet.id).set(vet.toMap());
    });
  }

  Future<Vet?> getVet(String vetId) async {
    return await _retryFirebaseOperation(() async {
      final doc = await _firestore.collection(vetsCollection).doc(vetId).get();
      return doc.exists ? Vet.fromMap(doc.data()!) : null;
    });
  }

  Future<List<Vet>> getVetsByDistrict(String district) async {
    return await _retryFirebaseOperation(() async {
      final snapshot = await _firestore
          .collection(vetsCollection)
          .where('district', isEqualTo: district)
          .get();
      return snapshot.docs.map((doc) => Vet.fromMap(doc.data())).toList();
    });
  }

  Future<List<Vet>> getAllVets() async {
    return await _retryFirebaseOperation(() async {
      final snapshot = await _firestore.collection(vetsCollection).get();
      return snapshot.docs.map((doc) => Vet.fromMap(doc.data())).toList();
    });
  }

  // Real-time listeners
  Stream<List<Farmer>> getFarmersStream() {
    return _firestore.collection(farmersCollection).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Farmer.fromMap(doc.data())).toList(),
        );
  }

  Stream<List<Livestock>> getLivestockStream() {
    return _firestore.collection(livestockCollection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Livestock.fromMap(doc.data()))
              .toList(),
        );
  }

  Stream<List<Alert>> getAlertsStream({bool unreadOnly = false}) {
    Query query = _firestore.collection(alertsCollection);
    if (unreadOnly) {
      query = query.where('is_read', isEqualTo: false);
    }
    return query
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Alert.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  Stream<KPIs?> getKPIsStream() {
    return _firestore
        .collection(kpisCollection)
        .doc('current')
        .snapshots()
        .map((doc) => doc.exists ? KPIs.fromMap(doc.data()!) : null);
  }

  Stream<List<User>> getUsersStream() {
    return _firestore.collection(usersCollection).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => User.fromMap(doc.data())).toList(),
        );
  }

  Stream<List<Vet>> getVetsStream() {
    return _firestore.collection(vetsCollection).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Vet.fromMap(doc.data())).toList(),
        );
  }

  // Utility methods
  Future<void> initializeDefaultData() async {
    // Initialize default translations if not exists
    final translations = await getTranslations();
    if (translations == null) {
      final defaultTranslations = Translations(
        en: {
          'dashboard': 'Dashboard',
          'farmers': 'Farmers',
          'livestock': 'Livestock',
          'withdrawal': 'Withdrawal Periods',
          'prescriptions': 'Prescriptions',
          'compliance': 'Compliance Reports',
          'alerts': 'Alerts',
          'audit': 'Audit Trail',
          'help': 'Help & Support',
          'dashboard-title': 'Dashboard Overview',
          'refresh': 'Refresh Data',
          'total-livestock': 'Total Livestock',
          'active-withdrawal': 'Active Withdrawal',
          'compliance-rate': 'Compliance Rate',
          'pending-reviews': 'Pending Reviews',
          'livestock-monitoring': 'Livestock Monitoring Overview',
          'district-compliance': 'Regional Compliance',
          'area-breakdown': 'Area-wise Compliance Breakdown',
          'active-periods': 'Active Withdrawal Periods',
          'recent-alerts': 'Recent Alerts',
          'loading': 'Loading...',
        },
        hi: {
          'dashboard': 'डैशबोर्ड',
          'farmers': 'किसान',
          'livestock': 'पशुधन',
          'withdrawal': 'निकासी अवधि',
          'prescriptions': 'नुस्खे',
          'compliance': 'अनुपालन रिपोर्ट',
          'alerts': 'अलर्ट',
          'audit': 'ऑडिट ट्रेल',
          'help': 'सहायता और समर्थन',
          'dashboard-title': 'डैशबोर्ड अवलोकन',
          'refresh': 'डेटा रिफ्रेश करें',
          'total-livestock': 'कुल पशुधन',
          'active-withdrawal': 'सक्रिय निकासी',
          'compliance-rate': 'अनुपालन दर',
          'pending-reviews': 'लंबित समीक्षाएं',
          'livestock-monitoring': 'पशुधन निगरानी अवलोकन',
          'district-compliance': 'क्षेत्रीय अनुपालन',
          'area-breakdown': 'क्षेत्रवार अनुपालन breakdown',
          'active-periods': 'सक्रिय निकासी अवधियां',
          'recent-alerts': 'हाल के अलर्ट',
          'loading': 'लोड हो रहा है...',
        },
        ta: {
          'dashboard': 'டாஷ்போர்டு',
          'farmers': 'விவசாயிகள்',
          'livestock': 'கால்நடை',
          'withdrawal': 'விலகல் காலங்கள்',
          'prescriptions': 'மருந்து பரிந்துரைகள்',
          'compliance': 'அனுபதிப்பு அறிக்கைகள்',
          'alerts': 'எச்சரிக்கைகள்',
          'audit': 'தணிக்கை பாதை',
          'help': 'உதவி மற்றும் ஆதரவு',
          'dashboard-title': 'டாஷ்போர்டு கண்ணோட்டம்',
          'refresh': 'தரவை புதுப்பிக்கவும்',
          'total-livestock': 'மொத்த கால்நடை',
          'active-withdrawal': 'செயலில் உள்ள விலகல்',
          'compliance-rate': 'அனுபதிப்பு விகிதம்',
          'pending-reviews': 'நிலுவையில் உள்ள மதிப்பீடுகள்',
          'livestock-monitoring': 'கால்நடை கண்காணிப்பு கண்ணோட்டம்',
          'district-compliance': 'பிராந்திய அனுபதிப்பு',
          'area-breakdown': 'பகுதி அடிப்படையில் அனுபதிப்பு முறிவு',
          'active-periods': 'செயலில் உள்ள விலகல் காலங்கள்',
          'recent-alerts': 'சமீபத்திய எச்சரிக்கைகள்',
          'loading': 'ஏற்றப்படுகிறது...',
        },
      );
      await updateTranslations(defaultTranslations);
    }

    // Initialize default KPIs if not exists
    final kpis = await getKPIs();
    if (kpis == null) {
      final defaultKPIs = KPIs(
        totalLivestock: 0,
        activeWithdrawal: 0,
        complianceRate: 0.0,
        pendingReviews: 0,
      );
      await updateKPIs(defaultKPIs);
    }
  }
}

final firestoreService = FirestoreService();
