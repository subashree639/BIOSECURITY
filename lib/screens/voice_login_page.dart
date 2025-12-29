import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../main.dart'; // Import for global auth and otpService instances
import '../screens/farmer_dashboard.dart';
import '../screens/vet_dashboard.dart';
import '../screens/seller_dashboard.dart';
import 'registration_pages.dart';
import '../l10n/app_localizations.dart';

//
// VoiceLoginPage — extended UI, farmer mobile OTP & registration choices
//
class VoiceLoginPage extends StatefulWidget {
  @override
  _VoiceLoginPageState createState() => _VoiceLoginPageState();
}

class _VoiceLoginPageState extends State<VoiceLoginPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _listening = false;
  String _farmerStatus = "";
  String _vetStatus = "";
  String _sellerStatus = "";

  late AnimationController _pulseController;

  final _vetUser = TextEditingController();
  final _vetPass = TextEditingController();
  final _vetId = TextEditingController();

  final _sellerPhone = TextEditingController();
  final _sellerOtp = TextEditingController();
  bool _sellerOtpSent = false;

  final _farmerPhone = TextEditingController();
  final _farmerOtp = TextEditingController();
  bool _farmerOtpSent = false;
  String? _displayedOtp;
  Timer? _otpDisplayTimer;
  int _otpCountdown = 0;

  @override
  void initState() {
    super.initState();
    auth.init();
    _pulseController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1200))
          ..repeat(reverse: true);
    // Initialize localized strings after context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        final localizations = AppLocalizations.of(context)!;
        setState(() {
          _farmerStatus = localizations.tapMicSayPassphrase;
          _vetStatus = localizations.pleaseEnterLoginDetails;
          _sellerStatus = localizations.pleaseEnterPhoneNumber;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _vetUser.dispose();
    _vetPass.dispose();
    _vetId.dispose();
    _sellerPhone.dispose();
    _sellerOtp.dispose();
    _farmerPhone.dispose();
    _farmerOtp.dispose();
    _otpDisplayTimer?.cancel();
    super.dispose();
  }

  void _startFarmerListening() async {
    final localizations = AppLocalizations.of(context)!;
    setState(() {
      _listening = true;
      _farmerStatus = localizations.listening;
    });

    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _listening = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Please use the registration page to register as a farmer with your mobile number.')));
    setState(() {
      _farmerStatus =
          'Please use the registration page to register as a farmer with your mobile number.';
    });
  }

  void _vetLogin() async {
    final localizations = AppLocalizations.of(context)!;
    final u = _vetUser.text.trim();
    final p = _vetPass.text.trim();
    final id = _vetId.text.trim();
    if (u.isEmpty || p.isEmpty || id.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(localizations.fillAllFields)));
      return;
    }
    setState(() => _vetStatus = localizations.verifying);

    try {
      // Force refresh vet data from Firebase to ensure we have latest credentials
      await auth.refreshVetData();

      // Check if any vets are registered
      final hasVets = await auth.hasRegisteredVets();
      if (!hasVets) {
        setState(() => _vetStatus = 'No vets registered yet');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "No veterinary accounts found. Please register first using the 'New to App? Register as Vet' button."),
          duration: Duration(seconds: 5),
        ));
        return;
      }

      // Debug: Print available vets
      final vetIds = await auth.getRegisteredVetIds();
      print('Available vet IDs: $vetIds');

      final ok = await auth.verifyVet(u, p, id);
      if (ok) {
        print('Vet login successful, setting current user: vet:$id');
        await auth.setCurrent('vet', id);
        setState(() => _vetStatus = 'Login successful!');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Welcome back, $u!")));
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => VetDashboardPage()));
      } else {
        setState(() => _vetStatus = localizations.invalidVetCredentials);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(localizations.invalidVetCredentials),
          duration: Duration(seconds: 5),
        ));
      }
    } catch (e) {
      setState(() => _vetStatus = 'Login failed: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login failed: $e")));
    }
  }

  void _sendSellerOtp() async {
    final localizations = AppLocalizations.of(context)!;
    final phoneNumber = _sellerPhone.text.trim();

    // Validate phone number format (Indian numbers only, no country code needed)
    if (!otpService.isValidPhoneNumber(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.enterValidMobile)),
      );
      return;
    }

    setState(() => _sellerStatus = 'Sending OTP...');

    final result = await otpService.sendOTP(phoneNumber);

    if (result.isSuccess) {
      _sellerOtpSent = true;
      setState(() => _sellerStatus = localizations.otpSent);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.otpSentTo(phoneNumber))),
      );
    } else {
      setState(() => _sellerStatus = 'Failed to send OTP');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _verifySellerOtp() async {
    final localizations = AppLocalizations.of(context)!;
    final otpCode = _sellerOtp.text.trim();

    if (otpCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.enterOTP)),
      );
      return;
    }

    setState(() => _sellerStatus = 'Verifying OTP...');

    final result = await otpService.verifyOTP(otpCode);

    if (result.isSuccess) {
      // OTP verified successfully with Firebase Auth
      final phoneNumber = _sellerPhone.text.trim();
      await auth.setCurrent('seller', phoneNumber);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),
      );

      // Navigate to seller dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SellerDashboardPage()),
      );
    } else {
      setState(() => _sellerStatus = 'OTP verification failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _sendFarmerOtp() async {
    final localizations = AppLocalizations.of(context)!;
    final phoneNumber = _farmerPhone.text.trim();

    // Validate phone number format (Indian numbers only, no country code needed)
    if (!otpService.isValidPhoneNumber(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.enterValidMobile)),
      );
      return;
    }

    setState(() => _farmerStatus = 'Generating OTP...');

    final result = await otpService.generateLocalOTP(phoneNumber);

    if (result.isSuccess) {
      _farmerOtpSent = true;
      // Extract OTP from result message (format: "OTP generated: 123456")
      final otpMatch =
          RegExp(r'OTP generated: (\d{6})').firstMatch(result.message);
      if (otpMatch != null) {
        _displayedOtp = otpMatch.group(1);
        _otpCountdown = 10;

        // Start countdown timer
        _otpDisplayTimer?.cancel();
        _otpDisplayTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            _otpCountdown--;
            if (_otpCountdown <= 0) {
              _displayedOtp = null;
              timer.cancel();
            }
          });
        });

        setState(
            () => _farmerStatus = 'OTP displayed for $_otpCountdown seconds');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'OTP generated and displayed. Enter it within 10 seconds.')),
      );
    } else {
      setState(() => _farmerStatus = 'Failed to generate OTP');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _verifyFarmerOtp() async {
    final localizations = AppLocalizations.of(context)!;
    final otpCode = _farmerOtp.text.trim();
    final phoneNumber = _farmerPhone.text.trim();

    if (otpCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.enterOTP)),
      );
      return;
    }

    setState(() => _farmerStatus = 'Verifying OTP...');

    final result = await otpService.verifyLocalOTP(phoneNumber, otpCode);

    if (result.isSuccess) {
      // OTP verified successfully
      await auth.setCurrent('farmer', phoneNumber);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),
      );

      // Navigate to farmer dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardPage()),
      );
    } else {
      setState(() => _farmerStatus = 'OTP verification failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  Widget _farmerTab() {
    final localizations = AppLocalizations.of(context)!;
    Widget otpWidget;
    if (!_farmerOtpSent) {
      otpWidget = Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _sendFarmerOtp,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: EdgeInsets.symmetric(vertical: 14)),
              child: Text(localizations.sendOTP,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      );
    } else {
      otpWidget = Column(
        children: [
          TextField(
              controller: _farmerOtp,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.sms),
                  hintText: localizations.enterOTP)),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _verifyFarmerOtp,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: EdgeInsets.symmetric(vertical: 12)),
                  child: Text(localizations.verifyLogin,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: _sendFarmerOtp,
            child: Text(localizations.resendOTP,
                style: TextStyle(
                    color: Colors.green.shade700, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
          )
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 8),
          Text(
            localizations.farmer,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Colors.green.shade800,
              shadows: [
                Shadow(
                  color: Colors.green.shade200.withOpacity(0.5),
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (ctx, child) {
              final t = _pulseController.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Background ripple effects
                  if (_listening) ...[
                    // Simplified single ripple effect
                    Transform.scale(
                      scale: 1.0 + 0.3 * math.sin(2 * math.pi * t),
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green.shade300.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Main microphone button
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _listening
                            ? [
                                Colors.red.shade400,
                                Colors.red.shade600,
                                Colors.red.shade800,
                              ]
                            : [
                                Colors.green.shade400,
                                Colors.green.shade600,
                                Colors.green.shade800,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_listening ? Colors.red : Colors.green)
                              .withOpacity(0.4),
                          blurRadius: 25,
                          spreadRadius: 5,
                          offset: Offset(0, 8),
                        ),
                        BoxShadow(
                          color: (_listening ? Colors.red : Colors.green)
                              .withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _startFarmerListening,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _listening ? Icons.mic : Icons.mic_none,
                                color: Colors.white,
                                size: 32,
                              ),
                              if (_listening) ...[
                                SizedBox(height: 2),
                                Container(
                                  width: 20,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(1.5),
                                  ),
                                  child: AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) {
                                      return LinearProgressIndicator(
                                        value:
                                            (math.sin(2 * math.pi * t) + 1) / 2,
                                        backgroundColor: Colors.transparent,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white.withOpacity(0.9),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Listening indicator
                  if (_listening)
                    Positioned(
                      bottom: -10,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade300.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Listening...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(height: 12),
          Text(_farmerStatus),
          SizedBox(height: 16),

          // Mobile login box
          Card(
            margin: EdgeInsets.symmetric(horizontal: 20),
            elevation: 3,
            color: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [Colors.white, Colors.grey.shade50]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      localizations.loginWithMobile,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.5,
                        color: Colors.green.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                        controller: _farmerPhone,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            hintText: localizations.enterMobileNumber)),
                    SizedBox(height: 12),
                    // Display OTP if available
                    if (_displayedOtp != null) ...[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.orange.shade300, width: 2),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Your OTP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _displayedOtp!,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                                letterSpacing: 4,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Expires in: $_otpCountdown seconds',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
                    otpWidget
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 12),

          // *** NEW: separated and bold Register button placed under the mobile card for clarity ***
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => FarmerRegisterChoicePage())),
              icon: Icon(Icons.how_to_reg, color: Colors.green.shade700),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  localizations.newToApp,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green.shade700),
                ),
              ),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.green.shade700),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vetTab() {
    final localizations = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            localizations.veterinaryLogin,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
              color: Colors.teal.shade800,
              height: 1.0,
              shadows: [
                Shadow(
                  color: Colors.teal.shade200.withOpacity(0.5),
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.medical_services, color: Colors.teal.shade700),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Please enter your login details',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 0.5,
                            color: Colors.teal.shade800,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _vetUser,
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.person, color: Colors.teal.shade600),
                        labelText: localizations.username,
                        labelStyle: TextStyle(color: Colors.black87),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _vetPass,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.lock, color: Colors.teal.shade600),
                        labelText: localizations.password,
                        labelStyle: TextStyle(color: Colors.black87),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _vetId,
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.badge, color: Colors.teal.shade600),
                        labelText: localizations.vetIdRegNo,
                        labelStyle: TextStyle(color: Colors.black87),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade600, Colors.teal.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.shade300,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _vetLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        localizations.loginAsVet,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (_) => VetRegisterChoicePage()))
                        .then((_) => auth.init()),
                    child: Text(
                      localizations.newToAppRegisterVet,
                      style: TextStyle(
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  AnimatedOpacity(
                    opacity: _vetStatus.isNotEmpty ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _vetStatus,
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sellerTab() {
    final localizations = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            localizations.seller,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
              color: Colors.indigo.shade800,
              height: 1.0,
              shadows: [
                Shadow(
                  color: Colors.indigo.shade200.withOpacity(0.5),
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone_android, color: Colors.indigo.shade700),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          localizations.loginWithMobile,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 0.5,
                            color: Colors.indigo.shade800,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _sellerPhone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.phone, color: Colors.indigo.shade600),
                        hintText: localizations.enterMobileNumber,
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (!_sellerOtpSent)
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade600,
                            Colors.indigo.shade700
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.shade300,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _sendSellerOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          localizations.sendOTP,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _sellerOtp,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.sms,
                                  color: Colors.indigo.shade600),
                              hintText: localizations.enterOTP,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.indigo.shade600,
                                Colors.indigo.shade700
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.shade300,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _verifySellerOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              localizations.verifyLogin,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextButton(
                          onPressed: _sendSellerOtp,
                          child: Text(
                            localizations.resendOTP,
                            style: TextStyle(
                              color: Colors.indigo.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: _sellerStatus.isNotEmpty ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _sellerStatus,
                        style: TextStyle(
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentTab() {
    if (_currentIndex == 0) return _farmerTab();
    if (_currentIndex == 1) return _vetTab();
    return _sellerTab();
  }

  Widget _buildSimpleNavItem(
      int index, IconData icon, String label, Color themeColor) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
              _farmerOtpSent = false;
              _sellerOtpSent = false;
              _displayedOtp = null;
              _otpCountdown = 0;
              _otpDisplayTimer?.cancel();
            });
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simple icon container
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? themeColor.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? themeColor : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? themeColor : Colors.grey.shade600,
                  size: 16,
                ),
              ),

              SizedBox(height: 2),

              // Simple text with flexible layout
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? themeColor : Colors.grey.shade600,
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFF1F5F9),
              Color(0xFFE2E8F0),
              Color(0xFFF8FAFC),
            ],
            stops: [0.0, 0.4, 0.8, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF16A34A),
                      Color(0xFF15803D),
                      Color(0xFF166534),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF16A34A).withOpacity(0.2),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        localizations.appTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          height: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.language, color: Colors.white),
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/language'),
                          tooltip: 'Change Language',
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3), width: 1),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              cacheWidth: 40,
                              cacheHeight: 40,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _currentTab(),
                ),
              ),
              // Liquid Glass Effect Bottom Navigation
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSimpleNavItem(0, Icons.person,
                              localizations.farmer, Colors.green),
                          _buildSimpleNavItem(1, Icons.medical_services,
                              localizations.vet, Colors.teal),
                          _buildSimpleNavItem(2, Icons.storefront,
                              localizations.seller, Colors.indigo),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
