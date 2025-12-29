import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../qr_certificate_service.dart';
import '../services/animal_storage.dart';
import '../models/animal.dart';

//
// QR Scanner Page
//
class QRScannerPage extends StatefulWidget {
  final bool online;
  const QRScannerPage({super.key, required this.online});

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  MobileScannerController? _mobileScannerController;
  bool _isScanning = false;
  String _scanResult = '';
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_mobileScannerController == null) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _mobileScannerController!.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _mobileScannerController!.stop();
        break;
    }
  }

  Future<void> _initializeScanner() async {
    try {
      _mobileScannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
      setState(() {});
    } catch (e) {
      print('Error initializing scanner: $e');
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _scanResult = barcode.rawValue!;
          _hasScanned = true;
          _isScanning = false;
        });
        _processScan(_scanResult);
        break;
      }
    }
  }

  void _processScan(String data) async {
    try {
      final cert = qrService.parseCertificate(data);
      if (cert != null) {
        // Get animal details to check withdrawal status
        final storage = AnimalStorageService();
        final animals = await storage.loadAnimals();
        final animal = animals.firstWhere(
          (a) => a.id == cert.animalId,
          orElse: () => Animal(
            id: '',
            species: '',
            age: '',
            breed: '',
            farmerId: '',
          ),
        );

        if (animal.id.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Animal not found in database')),
          );
          return;
        }

        // Check if animal is in withdrawal period
        final isInWithdrawal = animal.withdrawalEnd != null &&
            DateTime.now().isBefore(DateTime.parse(animal.withdrawalEnd!));

        // Show big graphical alert based on status
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with status
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isInWithdrawal ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isInWithdrawal ? Icons.warning : Icons.check_circle,
                          color: isInWithdrawal ? Colors.red.shade700 : Colors.green.shade700,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          isInWithdrawal
                              ? '⚠️ ANIMAL IN WITHDRAWAL\nNOT SAFE TO CONSUME'
                              : '✅ SAFE TO CONSUME',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isInWithdrawal ? Colors.red.shade900 : Colors.green.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isInWithdrawal) ...[
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Text(
                              '⚠️ WARNING: Do not consume products from this animal until the withdrawal period ends.',
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Certificate details
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Certificate Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Animal info
                        _buildDetailCard(
                          'Animal Information',
                          Icons.pets,
                          Colors.blue,
                          [
                            _buildDetailRow('Animal ID', cert.animalId),
                            _buildDetailRow('Species', animal.species),
                            _buildDetailRow('Breed', animal.breed),
                            _buildDetailRow('Age', animal.age),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Certificate info
                        _buildDetailCard(
                          'Certificate Information',
                          Icons.verified,
                          Colors.green,
                          [
                            _buildDetailRow('Generated Date', cert.issuedAt.toLocal().toString().split(' ')[0]),
                            _buildDetailRow('Valid Until', cert.expiresAt.toLocal().toString().split(' ')[0]),
                            _buildDetailRow('Farmer ID', animal.farmerId ?? 'Unknown'),
                          ],
                        ),

                        // Withdrawal info if applicable
                        if (animal.withdrawalEnd != null) ...[
                          SizedBox(height: 16),
                          _buildDetailCard(
                            'Withdrawal Information',
                            isInWithdrawal ? Icons.schedule : Icons.check_circle_outline,
                            isInWithdrawal ? Colors.orange : Colors.green,
                            [
                              _buildDetailRow('Status', isInWithdrawal ? 'Active' : 'Completed'),
                              _buildDetailRow('Withdrawal Ends', DateTime.parse(animal.withdrawalEnd!).toLocal().toString().split(' ')[0]),
                              if (animal.withdrawalDays != null)
                                _buildDetailRow('Withdrawal Period', '${animal.withdrawalDays} days'),
                              if (animal.lastDrug != null)
                                _buildDetailRow('Medicine', animal.lastDrug!),
                            ],
                          ),
                        ],

                        SizedBox(height: 20),

                        // Action buttons
                        Row(
                          children: [
                            Flexible(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Close', overflow: TextOverflow.ellipsis),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Flexible(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _scanResult = '';
                                    _hasScanned = false;
                                    _isScanning = false;
                                  });
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(Icons.qr_code_scanner),
                                label: Text('Scan Again', overflow: TextOverflow.ellipsis),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid certificate')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing certificate')),
      );
    }
  }

  Widget _buildDetailCard(String title, IconData icon, Color color, List<Widget> details) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...details,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade900,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mobileScannerController?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.online ? 'Online Verification' : 'Offline Scan'),
        backgroundColor: Colors.indigo.shade700,
        actions: [
          if (_mobileScannerController != null)
            IconButton(
              icon: Icon(_mobileScannerController!.torchEnabled ? Icons.flash_on : Icons.flash_off),
              onPressed: () => _mobileScannerController!.toggleTorch(),
            ),
          IconButton(
            icon: Icon(Icons.flip_camera_android),
            onPressed: () => _mobileScannerController?.switchCamera(),
          ),
        ],
      ),
      body: _mobileScannerController == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MobileScanner(
                  controller: _mobileScannerController!,
                  onDetect: _onDetect,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Position QR code here',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_scanResult.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text('Scanned:', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text(_scanResult, textAlign: TextAlign.center),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => setState(() {
                                  _scanResult = '';
                                  _hasScanned = false;
                                  _isScanning = false;
                                }),
                                child: Text('Scan Again'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}