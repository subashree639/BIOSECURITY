import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import for global auth and otpService instances
import 'qr_scanner_page.dart';
import 'voice_login_page.dart';

//
// Seller dashboard (kept simple)
//
class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  _SellerDashboardPageState createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _onlineVerification = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QRScannerPage(online: _onlineVerification),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.sellerDashboard),
        backgroundColor: Colors.indigo.shade700,
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'logout') {
                try {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Logging out...'),
                        ],
                      ),
                    ),
                  );

                  // Sign out from Firebase Auth
                  await otpService.signOut();
                  // Use the new comprehensive logout method
                  await auth.logout();
                  
                  // Close loading dialog
                  Navigator.of(context).pop();
                  
                  // Navigate to login page
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => VoiceLoginPage()),
                    (route) => false,
                  );
                } catch (e) {
                  // Close loading dialog if it's open
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e')),
                  );
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
                value: 'logout',
              )
            ],
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('Online Verification'),
              value: _onlineVerification,
              onChanged: (v) => setState(() => _onlineVerification = v),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _sellerCard(context, AppLocalizations.of(context)!.foodScanner, AppLocalizations.of(context)!.scanFoodQR, Icons.qr_code, _openScanner),
                  _sellerCard(context, AppLocalizations.of(context)!.animalScanner, AppLocalizations.of(context)!.scanAnimalTag, Icons.qr_code, _openScanner),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sellerCard(BuildContext ctx, String t, String s, IconData ic, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              CircleAvatar(radius: 28, backgroundColor: Colors.indigo.shade100, child: Icon(ic, size: 28, color: Colors.indigo.shade700)),
              SizedBox(height: 8),
              Text(t, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text(s, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
              Spacer(),
              Align(alignment: Alignment.bottomRight, child: Icon(Icons.chevron_right)),
            ],
          ),
        ),
      ),
    );
  }
}