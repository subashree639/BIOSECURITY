import 'package:flutter/material.dart';
import '../widgets/google_sign_in_button.dart';
import '../services/auth_service.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({Key? key}) : super(key: key);

  @override
  _FirebaseTestScreenState createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    setState(() => _isLoading = true);
    try {
      final userInfo = await auth.getCurrentUserInfo();
      setState(() => _userInfo = userInfo);
    } catch (e) {
      print('Error checking user: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Security Test'),
        backgroundColor: Colors.green.shade700,
        actions: [
          if (_userInfo != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await auth.signOutFromGoogle();
                setState(() => _userInfo = null);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signed out successfully')),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _userInfo != null ? _buildUserProfile() : _buildSignInView(),
            ),
    );
  }

  Widget _buildSignInView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: const Icon(
            Icons.security,
            size: 80,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Firebase Security Test',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                '🔐 Security Features:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 8),
              const Text('• AES-256 Encryption for data'),
              const Text('• SHA-256 Hashing for passwords'),
              const Text('• Firebase Firestore storage'),
              const Text('• Google OAuth authentication'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SimpleGoogleSignInButton(
          onSignInSuccess: _checkCurrentUser,
          onSignInError: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sign-in failed. Check Firebase configuration.'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Test data will be encrypted and stored in Firebase',
          style: TextStyle(color: Colors.grey, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserProfile() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '🎉 Authentication Successful!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome, ${_userInfo!['name'] ?? 'User'}!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userInfo!['email'] ?? '',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  '🔒 Security Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSecurityItem('User Data', 'AES Encrypted', Colors.green),
                _buildSecurityItem('Authentication', 'Google OAuth', Colors.blue),
                _buildSecurityItem('Storage', 'Firebase Firestore', Colors.orange),
                _buildSecurityItem('Password Hashing', 'SHA-256 Ready', Colors.purple),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addSampleData,
            icon: const Icon(Icons.add),
            label: const Text('Add Test Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'This will add encrypted sample data to Firebase',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(String title, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSampleData() async {
    setState(() => _isLoading = true);

    try {
      // Add sample farmer data
      final farmerId = await auth.registerFarmerByVoice('9876543210');

      // Add sample vet data
      await auth.registerVet('Dr. Smith', 'securevetpass123', 'VET001');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Sample data added successfully!\nCheck Firebase Console to see encrypted data.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error adding data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}