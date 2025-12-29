import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'security_service.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Store user data securely in Firestore
      await _storeUserData(userCredential.user!, 'google');

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Sign out from Google and Firebase
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Store user data securely in Firestore
  Future<void> _storeUserData(User user, String provider) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);

      final userData = {
        'uid': security.encryptData(user.uid),
        'email': security.encryptData(user.email ?? ''),
        'displayName': security.encryptData(user.displayName ?? ''),
        'photoURL': security.encryptData(user.photoURL ?? ''),
        'provider': security.encryptData(provider),
        'lastSignIn': DateTime.now().toIso8601String(),
        'createdAt': user.metadata.creationTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
      };

      await userDoc.set(userData, SetOptions(merge: true));
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUser == null) return null;

      final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();

      if (!userDoc.exists) return null;

      final data = userDoc.data()!;
      return {
        'uid': security.decryptData(data['uid']),
        'email': security.decryptData(data['email']),
        'displayName': security.decryptData(data['displayName']),
        'photoURL': security.decryptData(data['photoURL']),
        'provider': security.decryptData(data['provider']),
        'lastSignIn': data['lastSignIn'],
        'createdAt': data['createdAt'],
      };
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user profile securely
  Future<Map<String, String>?> getUserProfile() async {
    try {
      final userData = await getUserData();
      if (userData == null) return null;

      return {
        'name': userData['displayName'],
        'email': userData['email'],
        'photo': userData['photoURL'],
        'provider': userData['provider'],
      };
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
}

final googleAuth = GoogleAuthService();