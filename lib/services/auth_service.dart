import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'security_service.dart';
import 'google_auth_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _farmersCollection = 'farmers';
  static const _livestockCollection = 'livestock';
  static const _districtsCollection = 'districts';
  static const _prescriptionsCollection = 'prescriptions';
  static const _alertsCollection = 'alerts';
  static const _kpisCollection = 'kpis';
  static const _translationsCollection = 'translations';
  static const _auditTrailCollection = 'events';
  static const _vetsCollection = 'vets';
  static const _currentUserDoc = 'current_user';

  Map<String, Map<String, String>> _vets = {};
  String? currentType;
  String? currentId;

  Future<void> init() async {
    try {
      await Firebase.initializeApp();
      print('Firebase initialized successfully');

      // Load data from Firebase
      await _loadVetsFromFirestore();
      await _loadCurrentUserFromFirestore();

      // If Firebase loading failed, try SharedPreferences backup
      if (currentType == null || currentId == null) {
        print(
            'Firebase current user loading failed, trying SharedPreferences backup');
        await _loadCurrentUserFromSharedPreferences();
      }
    } catch (e) {
      print('Firebase initialization failed: $e');
      print('Running in offline/demo mode');

      // Try to load from SharedPreferences as fallback
      await _loadCurrentUserFromSharedPreferences();

      // Initialize with demo data if no saved data
      if (currentType == null || currentId == null) {
        print('No saved user data found, initializing demo mode');
        // Don't set any current user - let user login manually
      }
    }

    // Debug: Print current state
    print('Auth initialized - Current user: $currentType:$currentId');
    print('Vets loaded: ${_vets.length}');
  }

  // Method to refresh vet data from Firebase
  Future<void> refreshVetData() async {
    await _loadVetsFromFirestore();
  }

  Future<void> _loadVetsFromFirestore() async {
    try {
      final snapshot = await _firestore.collection(_vetsCollection).get();
      _vets.clear();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final vetId = doc.id;
        try {
          final username = security.decryptData(data['username']);
          final passwordHash = data['passwordHash'];
          _vets[vetId] = {'username': username, 'passwordHash': passwordHash};
        } catch (e) {
          // If decryption fails, try using data as-is (might be stored unencrypted)
          print('Decryption failed for vet data, trying raw data: $e');
          final username = data['username'] ?? '';
          final passwordHash = data['passwordHash'] ?? '';
          if (username.isNotEmpty && passwordHash.isNotEmpty) {
            _vets[vetId] = {'username': username, 'passwordHash': passwordHash};
          }
        }
      }
      // Save to SharedPreferences as backup
      await _saveVetsToSharedPreferences();
    } catch (e) {
      print('Error loading vets from Firestore (likely offline): $e');
      // Try loading from SharedPreferences backup
      await _loadVetsFromSharedPreferences();
    }
  }

  Future<void> _loadCurrentUserFromFirestore() async {
    try {
      final doc =
          await _firestore.collection('users').doc(_currentUserDoc).get();
      if (doc.exists) {
        final data = doc.data()!;
        print('Current user document exists with data: $data');
        try {
          currentType = security.decryptData(data['type']);
          currentId = security.decryptData(data['id']);
          print('Successfully loaded current user: $currentType:$currentId');
        } catch (e) {
          // If decryption fails, try using data as-is (might be stored unencrypted)
          print('Decryption failed for current user data, trying raw data: $e');
          currentType = data['type'];
          currentId = data['id'];
          print('Loaded current user with raw data: $currentType:$currentId');
        }
      } else {
        print('Current user document does not exist');
      }
    } catch (e) {
      print('Error loading current user from Firestore (likely offline): $e');
      // Don't throw - allow app to continue in offline mode
    }
  }

  Future<void> _loadCurrentUserFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final type = prefs.getString('current_user_type');
      final id = prefs.getString('current_user_id');

      if (type != null && id != null && type.isNotEmpty && id.isNotEmpty) {
        currentType = type;
        currentId = id;
        print(
            'Loaded current user from SharedPreferences: $currentType:$currentId');
      } else {
        print('No current user data found in SharedPreferences');
      }
    } catch (e) {
      print('Error loading current user from SharedPreferences: $e');
    }
  }

  Future<void> _saveVetsToSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vetsJson = jsonEncode(_vets);
      await prefs.setString('vets_data', vetsJson);
      print('Vets data saved to SharedPreferences');
    } catch (e) {
      print('Error saving vets to SharedPreferences: $e');
    }
  }

  Future<void> _loadVetsFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vetsJson = prefs.getString('vets_data');
      if (vetsJson != null && vetsJson.isNotEmpty) {
        final vetsMap = jsonDecode(vetsJson) as Map<String, dynamic>;
        _vets = vetsMap.map((key, value) =>
            MapEntry(key, Map<String, String>.from(value as Map)));
        print('Loaded vets from SharedPreferences: ${_vets.length} vets');
      } else {
        print('No vets data found in SharedPreferences');
      }
    } catch (e) {
      print('Error loading vets from SharedPreferences: $e');
    }
  }

  Future<void> _saveVets() async {
    // Save to SharedPreferences first
    await _saveVetsToSharedPreferences();

    try {
      final batch = _firestore.batch();
      // Clear existing vets
      final existingVets = await _firestore.collection(_vetsCollection).get();
      for (final doc in existingVets.docs) {
        batch.delete(doc.reference);
      }
      // Add current vets
      for (final entry in _vets.entries) {
        final docRef = _firestore.collection(_vetsCollection).doc(entry.key);
        batch.set(docRef, {
          'username': security.encryptData(entry.value['username']!),
          'passwordHash': entry.value['passwordHash']!,
        });
      }
      await batch.commit();
      print('Vets saved to Firestore successfully');
    } catch (e) {
      print('Error saving vets to Firestore (likely offline): $e');
      print('Data will be available locally but not synced to cloud');
      // Don't throw - allow app to continue in offline mode
    }
  }

  Future<void> setCurrent(String type, String id) async {
    print('Setting current user: $type:$id');
    currentType = type;
    currentId = id;

    // Save to SharedPreferences as backup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_type', type);
    await prefs.setString('current_user_id', id);
    print('Saved current user to SharedPreferences: $type:$id');

    if (type.isEmpty && id.isEmpty) {
      // Clear the current user document when logging out
      try {
        await _firestore.collection('users').doc(_currentUserDoc).delete();
        print('Cleared current user from Firebase');
      } catch (e) {
        print('Error clearing current user from Firebase (likely offline): $e');
      }
      await prefs.remove('current_user_type');
      await prefs.remove('current_user_id');
      print('Cleared current user from SharedPreferences');
    } else {
      try {
        final data = {
          'type': security.encryptData(type),
          'id': security.encryptData(id),
        };
        await _firestore.collection('users').doc(_currentUserDoc).set(data);
        print('Saved current user to Firebase: $data');
      } catch (e) {
        print('Error saving current user to Firebase (likely offline): $e');
        print('User session will be maintained locally via SharedPreferences');
      }
    }
  }

  Future<void> logout() async {
    // Clear local state
    currentType = null;
    currentId = null;

    // Clear Firestore current user document
    try {
      await _firestore.collection('users').doc(_currentUserDoc).delete();
      print('Cleared current user from Firebase');
    } catch (e) {
      print('Error clearing current user from Firestore (likely offline): $e');
    }

    // Clear SharedPreferences backup
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_type');
      await prefs.remove('current_user_id');
      print('Cleared current user from SharedPreferences');
    } catch (e) {
      print('Error clearing current user from SharedPreferences: $e');
    }

    // Sign out from Google if signed in
    if (isGoogleSignedIn) {
      await signOutFromGoogle();
    }
  }

  bool idExists(String id) => _vets.containsKey(id);

  Future<String> registerFarmerByVoice(String mobileNumber) async {
    // Use mobile number as farmer ID
    final id = mobileNumber;

    // Save minimal farmer data to Firebase
    final farmerDetails = {
      'farmerId': id,
      'phoneNumber': mobileNumber,
      'registeredAt': DateTime.now().toIso8601String(),
      'name': '',
      'area': '',
      'compliance': 'pending',
      'last_activity': DateTime.now().toIso8601String(),
      'livestock_count': 0,
      'location': '',
    };

    await saveFarmerDetails(mobileNumber, farmerDetails);

    return id;
  }

  String _randomDigits(int n) {
    final r = Random();
    String s = '';
    for (var i = 0; i < n; i++) s += r.nextInt(10).toString();
    return s;
  }

  Future<void> registerVet(
      String username, String password, String vetId) async {
    final passwordHash = security.hashPassword(password);
    _vets[vetId] = {'username': username, 'passwordHash': passwordHash};
    await _saveVets();
  }

  Future<bool> verifyVet(String username, String password, String vetId) async {
    // Ensure vets are loaded from Firebase first
    await _loadVetsFromFirestore();

    // If no vets loaded from Firebase, try SharedPreferences backup
    if (_vets.isEmpty) {
      print('No vets loaded from Firebase, trying SharedPreferences backup');
      await _loadVetsFromSharedPreferences();
    }

    final rec = _vets[vetId];
    if (rec == null) {
      print(
          'Vet ID $vetId not found in database. Available vets: ${_vets.keys.toList()}');
      return false;
    }

    final storedUsername = rec['username'];
    final storedPasswordHash = rec['passwordHash'];

    if (storedUsername == null || storedPasswordHash == null) {
      print(
          'Invalid vet record for ID $vetId: missing username or password hash');
      return false;
    }

    final usernameMatch = storedUsername == username;
    final passwordMatch = security.verifyPassword(password, storedPasswordHash);

    if (!usernameMatch) {
      print(
          'Username mismatch for vet ID $vetId. Expected: $storedUsername, Got: $username');
    }

    if (!passwordMatch) {
      print('Password verification failed for vet ID $vetId');
    }

    return usernameMatch && passwordMatch;
  }

  Map<String, Map<String, String>> get vets => _vets;

  // Method to check if any vets are registered
  Future<bool> hasRegisteredVets() async {
    await _loadVetsFromFirestore();
    return _vets.isNotEmpty;
  }

  // Method to get list of registered vet IDs
  Future<List<String>> getRegisteredVetIds() async {
    await _loadVetsFromFirestore();
    return _vets.keys.toList();
  }

  // Method to clear all data (for troubleshooting)
  Future<void> clearAllData() async {
    try {
      // Clear local data
      _vets.clear();
      currentType = null;
      currentId = null;

      // Clear Firebase data
      final batch = _firestore.batch();

      // Clear vets
      final vets = await _firestore.collection(_vetsCollection).get();
      for (final doc in vets.docs) {
        batch.delete(doc.reference);
      }

      // Clear current user
      batch.delete(_firestore.collection('users').doc(_currentUserDoc));

      await batch.commit();
      print('All data cleared successfully');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  // Debug method to inspect Firebase data
  Future<void> debugFirebaseData() async {
    try {
      print('=== FIREBASE DATA DEBUG ===');

      // Check vets
      final vets = await _firestore.collection(_vetsCollection).get();
      print('Vets collection: ${vets.docs.length} documents');
      for (final doc in vets.docs) {
        print('Vet doc ${doc.id}: ${doc.data()}');
      }

      // Check current user
      final currentUser =
          await _firestore.collection('users').doc(_currentUserDoc).get();
      print('Current user exists: ${currentUser.exists}');
      if (currentUser.exists) {
        print('Current user data: ${currentUser.data()}');
      }

      print('=== END DEBUG ===');
    } catch (e) {
      print('Error in debug: $e');
    }
  }

  // Google Sign-In Integration
  Future<UserCredential?> signInWithGoogle() async {
    return await googleAuth.signInWithGoogle();
  }

  Future<void> signOutFromGoogle() async {
    await googleAuth.signOut();
  }

  bool get isGoogleSignedIn => googleAuth.isSignedIn;

  User? get googleCurrentUser => googleAuth.currentUser;

  Future<Map<String, String>?> getGoogleUserProfile() async {
    return await googleAuth.getUserProfile();
  }

  // Listen to Google auth state changes
  Stream<User?> get googleAuthStateChanges => googleAuth.authStateChanges;

  // Combined authentication check
  bool get isAuthenticated {
    return isGoogleSignedIn || currentId != null;
  }

  // Get current authenticated user info
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    if (isGoogleSignedIn) {
      final profile = await getGoogleUserProfile();
      if (profile != null) {
        return {
          'type': 'google',
          'name': profile['name'],
          'email': profile['email'],
          'photo': profile['photo'],
          'provider': profile['provider'],
        };
      }
    } else if (currentId != null && currentType != null) {
      return {
        'type': currentType,
        'id': currentId,
      };
    }
    return null;
  }

  // Save farmer details to Firebase (phone number is the document ID)
  Future<void> saveFarmerDetails(
      String phoneNumber, Map<String, dynamic> farmerDetails) async {
    try {
      // Add timestamps
      farmerDetails['created_at'] = FieldValue.serverTimestamp();
      farmerDetails['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_farmersCollection)
          .doc(phoneNumber)
          .set(farmerDetails);
      print(
          'Farmer details saved to Firebase farmers collection for phone: $phoneNumber');
    } catch (e) {
      print('Error saving farmer details to Firebase: $e');
      // Don't throw - allow app to continue
    }
  }

  // Save farmer profile to Firebase (merged into farmers document)
  Future<void> saveFarmerProfile(
      String phoneNumber, Map<String, dynamic> profile) async {
    try {
      // Add updated timestamp
      profile['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_farmersCollection)
          .doc(phoneNumber)
          .set(profile, SetOptions(merge: true));
      print(
          'Farmer profile saved to Firebase farmers collection for phone: $phoneNumber');
    } catch (e) {
      print('Error saving farmer profile to Firebase: $e');
      // Don't throw - allow app to continue
    }
  }

  // Get farmer data from Firebase (from farmers collection)
  Future<Map<String, dynamic>?> getFarmerData(String phoneNumber) async {
    try {
      final doc = await _firestore
          .collection(_farmersCollection)
          .doc(phoneNumber)
          .get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      print('Error getting farmer data from Firebase: $e');
    }
    return null;
  }

  // Save animal data to Firebase (livestock collection)
  Future<void> saveAnimalData(String phoneNumber, String animalId,
      Map<String, dynamic> animalData) async {
    try {
      // Add timestamps and owner reference
      animalData['owner_id'] = phoneNumber;
      animalData['created_at'] = FieldValue.serverTimestamp();
      animalData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_livestockCollection)
          .doc(animalId)
          .set(animalData);
      print(
          'Animal data saved to Firebase livestock collection for animal: $animalId');
    } catch (e) {
      print('Error saving animal data to Firebase: $e');
      // Don't throw - allow app to continue
    }
  }

  // Get animal data from Firebase (from livestock collection filtered by owner_id)
  Future<List<Map<String, dynamic>>> getFarmerAnimals(
      String phoneNumber) async {
    try {
      final snapshot = await _firestore
          .collection(_livestockCollection)
          .where('owner_id', isEqualTo: phoneNumber)
          .get();
      return snapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Error loading animal data from Firebase: $e');
      return [];
    }
  }

  // Get farmer profile information including farm location
  Future<Map<String, dynamic>?> getFarmerProfileWithLocation(
      String farmerId) async {
    // Since we reverted to simple structure, return null for now
    return null;
  }

  // Prescriptions collection methods
  Future<void> savePrescription(Map<String, dynamic> prescriptionData) async {
    try {
      prescriptionData['created_at'] = FieldValue.serverTimestamp();
      prescriptionData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_prescriptionsCollection)
          .add(prescriptionData);
      print('Prescription saved to Firebase');
    } catch (e) {
      print('Error saving prescription to Firebase: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPrescriptionsForAnimal(
      String animalId) async {
    try {
      final snapshot = await _firestore
          .collection(_prescriptionsCollection)
          .where('animal_id', isEqualTo: animalId)
          .orderBy('issue_date', descending: true)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting prescriptions from Firebase: $e');
      return [];
    }
  }

  // Alerts collection methods
  Future<void> createAlert(Map<String, dynamic> alertData) async {
    try {
      alertData['timestamp'] = FieldValue.serverTimestamp();
      alertData['is_read'] = false;

      await _firestore.collection(_alertsCollection).add(alertData);
      print('Alert created in Firebase');
    } catch (e) {
      print('Error creating alert in Firebase: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAlerts(
      {bool unreadOnly = false}) async {
    try {
      Query query = _firestore.collection(_alertsCollection);
      if (unreadOnly) {
        query = query.where('is_read', isEqualTo: false);
      }
      final snapshot =
          await query.orderBy('timestamp', descending: true).limit(50).get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting alerts from Firebase: $e');
      return [];
    }
  }

  // KPIs collection methods
  Future<void> updateKPIs(Map<String, dynamic> kpiData) async {
    try {
      kpiData['last_updated'] = FieldValue.serverTimestamp();

      await _firestore.collection(_kpisCollection).doc('current').set(kpiData);
      print('KPIs updated in Firebase');
    } catch (e) {
      print('Error updating KPIs in Firebase: $e');
    }
  }

  Future<Map<String, dynamic>?> getKPIs() async {
    try {
      final doc =
          await _firestore.collection(_kpisCollection).doc('current').get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting KPIs from Firebase: $e');
      return null;
    }
  }

  // Translations collection methods
  Future<void> updateTranslations(
      String language, Map<String, dynamic> translations) async {
    try {
      await _firestore
          .collection(_translationsCollection)
          .doc('current')
          .set({language: translations}, SetOptions(merge: true));
      print('Translations updated in Firebase for language: $language');
    } catch (e) {
      print('Error updating translations in Firebase: $e');
    }
  }

  Future<Map<String, dynamic>?> getTranslations() async {
    try {
      final doc = await _firestore
          .collection(_translationsCollection)
          .doc('current')
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting translations from Firebase: $e');
      return null;
    }
  }

  // Audit trail collection methods
  Future<void> logAuditEvent(Map<String, dynamic> auditData) async {
    try {
      auditData['timestamp'] = FieldValue.serverTimestamp();

      String entityType = auditData['entity_type'];
      await _firestore
          .collection(_auditTrailCollection)
          .doc(entityType)
          .collection('actions')
          .add(auditData);
      print('Audit event logged to Firebase under events/$entityType/actions');
    } catch (e) {
      print('Error logging audit event to Firebase: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAuditTrail(
      {String? entityType, String? entityId, int limit = 100}) async {
    try {
      if (entityType != null) {
        Query query = _firestore
            .collection(_auditTrailCollection)
            .doc(entityType)
            .collection('actions');
        if (entityId != null) {
          query = query.where('entity_id', isEqualTo: entityId);
        }
        final snapshot = await query
            .orderBy('timestamp', descending: true)
            .limit(limit)
            .get();
        return snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      } else {
        // Hierarchical structure requires entityType to query
        print(
            'getAuditTrail requires entityType for hierarchical audit trail structure');
        return [];
      }
    } catch (e) {
      print('Error getting audit trail from Firebase: $e');
      return [];
    }
  }

  // Districts collection methods
  Future<void> saveDistrict(Map<String, dynamic> districtData) async {
    try {
      districtData['created_at'] = FieldValue.serverTimestamp();
      districtData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_districtsCollection)
          .doc(districtData['id'])
          .set(districtData);
      print('District saved to Firebase: ${districtData['id']}');
    } catch (e) {
      print('Error saving district to Firebase: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDistricts() async {
    try {
      final snapshot = await _firestore.collection(_districtsCollection).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting districts from Firebase: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDistrict(String districtId) async {
    try {
      final doc = await _firestore
          .collection(_districtsCollection)
          .doc(districtId)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting district from Firebase: $e');
      return null;
    }
  }
}

final auth = AuthService();
