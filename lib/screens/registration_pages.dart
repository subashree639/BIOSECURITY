import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import for global auth and otpService instances
import '../widgets/registration_translations.dart';
import '../widgets/multilingual_address_input.dart' as mai;

//
// Farmer register CHOICE page — pick Voice or Mobile
//
class FarmerRegisterChoicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register as Farmer', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.green.shade700,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Column(
            children: [
              Container(
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
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF16A34A).withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Color(0xFF16A34A).withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                      ),
                      child: Center(
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Flexible(
                      child: Text(
                         'Welcome to Farmer Registration',
                         style: TextStyle(
                           color: Colors.white,
                           fontSize: 18,
                           fontWeight: FontWeight.w700,
                           letterSpacing: 0.8,
                           height: 1.3,
                           shadows: [
                             Shadow(
                               color: Colors.black.withOpacity(0.3),
                               offset: Offset(1, 1),
                               blurRadius: 2,
                             ),
                           ],
                         ),
                         overflow: TextOverflow.ellipsis,
                         maxLines: 2,
                       ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _methodCard(context, 'Voice Registration', 'Register using voice biometrics for secure access', Icons.mic, () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => FarmerVoiceEnrollPage()));
                    }),
                    SizedBox(height: 12),
                    _methodCard(context, 'Mobile Registration', 'Register using your mobile number with OTP verification', Icons.phone, () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => FarmerRegisterByPhonePage()));
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _methodCard(BuildContext ctx, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: Color(0xFF16A34A).withOpacity(0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Color(0xFFF8FAFC),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFDCFCE7),
                        Color(0xFFF0FDF4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Color(0xFF16A34A).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(icon, color: Color(0xFF16A34A), size: 28),
                ),
                SizedBox(width: 16),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
// Farmer voice enroll (enhanced "facelock-like" simulated UI)
//
class FarmerVoiceEnrollPage extends StatefulWidget {
  @override
  _FarmerVoiceEnrollPageState createState() => _FarmerVoiceEnrollPageState();
}
class _FarmerVoiceEnrollPageState extends State<FarmerVoiceEnrollPage> with SingleTickerProviderStateMixin {
  bool _recording = false;
  String? _generatedId;
  late AnimationController _ringController;
  final _mobile = TextEditingController();
  final _farmLocation = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(vsync: this, duration: Duration(milliseconds: 1600))..repeat();
  }

  @override
  void dispose() {
    _ringController.dispose();
    _mobile.dispose();
    _farmLocation.dispose();
    super.dispose();
  }

  void _startEnroll() async {
    final mobile = _mobile.text.trim();
    if (mobile.isEmpty || !otpService.isValidPhoneNumber(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid 10-digit mobile number')));
      return;
    }
    if (!mounted) return;
    setState(() { _recording = true; _generatedId = null; });
    // simulate multi-step enrollment with progress feedback
    await Future.delayed(Duration(seconds: 1));
    for (int step = 1; step <= 3; step++) {
      if (!mounted) return;
      setState(() {});
      await Future.delayed(Duration(seconds: 1));
    }
    final id = await auth.registerFarmerByVoice(mobile);
    if (!mounted) return;
    // Farmer stays on registration page - no automatic login
    setState(() { _recording = false; _generatedId = id; });

    // Farmer stays on registration page - no automatic navigation
  }

  @override
  Widget build(BuildContext context) {
    final ring = AnimatedBuilder(
      animation: _ringController,
      builder: (ctx, child) {
        final t = _ringController.value;
        final scale1 = 1.0 + 0.12 * math.sin(2 * math.pi * t);
        final scale2 = 1.0 + 0.24 * math.sin(2 * math.pi * (t + 0.33));
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(scale: scale2, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.shade100.withOpacity(0.25)))),
            Transform.scale(scale: scale1, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.shade100.withOpacity(0.45)))),
            Container(width: 72, height: 72, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.shade700), child: Icon(_recording ? Icons.mic : Icons.mic_none, color: Colors.white, size: 36)),
          ],
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text('Voice Enrollment', style: TextStyle(fontSize: 18)), backgroundColor: Colors.green.shade700),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Voice Enrollment (simulated)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
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
            Center(child: ring),
            SizedBox(height: 12),
            TextField(
              controller: _mobile,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone, size: 20),
                hintText: 'Enter your mobile number (e.g., 9876543210)',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green.shade400, width: 2),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              _recording
                ? 'Recording your voice — hold still and speak the phrase when prompted.'
                : _generatedId == null
                  ? 'Enter your mobile number and tap ENROLL to start voice capture. You will be asked to say a short phrase three times.'
                  : 'Enrollment complete — your Farmer ID is:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: Colors.green.shade800,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 12),
            if (_generatedId != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200, width: 1),
                ),
                child: SelectableText(
                  _generatedId!,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.green.shade800,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 16),
            if (!_recording && _generatedId == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: ElevatedButton(
                      onPressed: _startEnroll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Enroll Voice',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Flexible(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            if (_recording)
              Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Processing enrollment...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            if (_generatedId != null)
              Column(children: [
                SizedBox(height: 10),
                Text(
                  'Registration successful! You can now log in from the main screen.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                  child: Text('Back to Registration Options'),
                ),
                SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => setState(() { _generatedId = null; }),
                  child: Text('Register Another Farmer'),
                ),
              ]),
          ],
        ),
      ),
    );
  }
}

//
// Farmer mobile registration page
//
class FarmerRegisterByPhonePage extends StatefulWidget {
  @override
  _FarmerRegisterByPhonePageState createState() => _FarmerRegisterByPhonePageState();
}
class _FarmerRegisterByPhonePageState extends State<FarmerRegisterByPhonePage> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _farmLocation = TextEditingController();
  bool _otpSent = false;
  bool _registering = false;
  bool _sendingOtp = false;

  String? _generatedOtp;
  String? _displayedOtp;
  Timer? _otpDisplayTimer;
  int _otpCountdown = 0;

  void _sendOtp() async {
    final phoneNumber = _phone.text.trim();

    // Validate phone number format (Indian numbers only, no country code needed)
    if (!otpService.isValidPhoneNumber(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 10-digit mobile number (e.g., 9876543210)')),
      );
      return;
    }

    setState(() => _sendingOtp = true);

    // Generate local OTP to display on screen
    final otpResult = await otpService.generateLocalOTP(phoneNumber);

    if (otpResult.isSuccess) {
      // Extract OTP from the success message
      final message = otpResult.message;
      final otpMatch = RegExp(r'OTP generated: (\d{6})').firstMatch(message);
      if (otpMatch != null) {
        _generatedOtp = otpMatch.group(1);
        _displayedOtp = _generatedOtp;
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

        setState(() => _otpSent = true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP generated and displayed. Enter it within 10 seconds.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate OTP. Please try again.'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(otpResult.message),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }

    setState(() => _sendingOtp = false);
  }

  Future<void> _verifyAndRegister() async {
    final otpCode = _otp.text.trim();

    if (otpCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }

    final phone = _phone.text.trim();

    setState(() => _registering = true);

    final result = await otpService.verifyLocalOTP(phone, otpCode);

    if (result.isSuccess) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => FarmerAddressEntryPage(phone: phone)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }

    setState(() => _registering = false);
  }

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    _farmLocation.dispose();
    _otpDisplayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.registerByMobile),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone, size: 20),
                  hintText: 'Enter 10-digit mobile number (e.g., 9876543210)',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green.shade400, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Display OTP if available
              if (_displayedOtp != null) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300, width: 2),
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
              if (!_otpSent)
                ElevatedButton(
                  onPressed: _sendingOtp ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: _sendingOtp
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text(RegistrationTranslations.getText('sendOTP', mai.Language.english), overflow: TextOverflow.ellipsis),
                          ],
                        )
                      : Text(RegistrationTranslations.getText('sendOTP', mai.Language.english), overflow: TextOverflow.ellipsis),
                )
              else
                Column(
                  children: [
                    TextField(
                      controller: _otp,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.sms, size: 20),
                        labelText: RegistrationTranslations.getText('otpLabel', mai.Language.english),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _registering ? null : _verifyAndRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                              ),
                              child: _registering
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                      SizedBox(width: 8),
                                      Text(RegistrationTranslations.getText('verifyLogin', mai.Language.english), overflow: TextOverflow.ellipsis),
                                    ],
                                  )
                                : Text(RegistrationTranslations.getText('verifyLogin', mai.Language.english), overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _sendingOtp ? null : _sendOtp,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: Colors.green.shade700, width: 1.5),
                              ),
                              child: Text(RegistrationTranslations.getText('resendOTP', mai.Language.english), overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

//
// Farmer Address Entry Page
//
class FarmerAddressEntryPage extends StatefulWidget {
  final String phone;

  const FarmerAddressEntryPage({required this.phone});

  @override
  _FarmerAddressEntryPageState createState() => _FarmerAddressEntryPageState();
}

class _FarmerAddressEntryPageState extends State<FarmerAddressEntryPage> {
   final _name = TextEditingController();
   final _age = TextEditingController();
   String _gender = 'Male'; // Default gender
   final _aadhar = TextEditingController();
   final _farmId = TextEditingController();
   final _doorNo = TextEditingController();
   final _street = TextEditingController();
   final _city = TextEditingController();
   final _district = TextEditingController();
   final _pincode = TextEditingController();
   final _state = TextEditingController();
   bool _registering = false;

  void _completeRegistration() async {
    final name = _name.text.trim();
    final age = _age.text.trim();
    final aadhar = _aadhar.text.trim();
    final farmId = _farmId.text.trim();
    final doorNo = _doorNo.text.trim();
    final street = _street.text.trim();
    final city = _city.text.trim();
    final district = _district.text.trim();

    final doorNoVal = _doorNo.text.trim();
    final streetVal = _street.text.trim();
    final cityVal = _city.text.trim();
    final districtVal = _district.text.trim();
    final pincodeVal = _pincode.text.trim();
    final stateVal = _state.text.trim();

    if (name.isEmpty || age.isEmpty || aadhar.isEmpty || farmId.isEmpty ||
        doorNoVal.isEmpty || streetVal.isEmpty || cityVal.isEmpty || districtVal.isEmpty ||
        pincodeVal.isEmpty || stateVal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    // Validate pincode (6 digits)
    if (pincodeVal.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pincodeVal)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid 6-digit pincode')));
      return;
    }

    // Validate age
    final ageNum = int.tryParse(age);
    if (ageNum == null || ageNum < 3 || ageNum > 100) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid age (3-100)')));
      return;
    }

    // Validate Aadhar (16 digits)
    if (aadhar.length != 16 || !RegExp(r'^\d{16}$').hasMatch(aadhar)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid 16-digit Aadhar number')));
      return;
    }

    setState(() => _registering = true);

    try {
      // Construct farm location from address components
      final farmLocation = [doorNoVal, streetVal, cityVal, districtVal, pincodeVal, stateVal]
          .where((component) => component.trim().isNotEmpty)
          .join(', ');

      // Use mobile number as farmer ID
      final farmerId = widget.phone;

      // Save farmer details to Firebase
      final farmerDetails = {
        'farmerId': farmerId,
        'phoneNumber': widget.phone,
        'registeredAt': DateTime.now().toIso8601String(),
        'name': name,
        'age': ageNum,
        'gender': _gender,
        'aadhar': aadhar,
        'farmId': farmId,
        'area': '', // Can be updated later
        'compliance': 'pending', // Default compliance status
        'area': cityVal,
        'district': districtVal,
        'pincode': pincodeVal,
        'state': stateVal,
        'last_activity': DateTime.now().toIso8601String(),
        'livestock_count': 0, // Will be updated when animals are added
        'location': farmLocation,
      };

      // Save farmer profile to Firebase
      final profile = {
        'doorNo': doorNo,
        'streetName': street,
        'city': city,
        'district': district,
      };

      await auth.saveFarmerDetails(widget.phone, farmerDetails);
      await auth.saveFarmerProfile(widget.phone, profile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Farmer registration successful!'),
            ],
          ),
          backgroundColor: Color(0xFF16A34A),
          duration: Duration(seconds: 3),
        ),
      );
      await Future.delayed(Duration(seconds: 2));
      // Navigate back to main screen
      Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration error: $e')));
    } finally {
      setState(() => _registering = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _aadhar.dispose();
    _farmId.dispose();
    _doorNo.dispose();
    _street.dispose();
    _city.dispose();
    _district.dispose();
    _pincode.dispose();
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Details'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Details Section
                      _buildSectionCard(
                        title: 'Personal Details',
                        icon: Icons.person,
                        child: Column(
                          children: [
                            // Name Field
                            TextField(
                              controller: _name,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Age Field
                            TextField(
                              controller: _age,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Age',
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Gender Selection
                            DropdownButtonFormField<String>(
                              initialValue: _gender,
                              items: [
                                DropdownMenuItem(
                                  value: 'Male',
                                  child: Text('Male'),
                                ),
                                DropdownMenuItem(
                                  value: 'Female',
                                  child: Text('Female'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _gender = value!;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your gender';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Verification Section
                      _buildSectionCard(
                        title: 'Verification',
                        icon: Icons.verified,
                        child: Column(
                          children: [
                            // Aadhar Number Field
                            TextField(
                              controller: _aadhar,
                              keyboardType: TextInputType.number,
                              maxLength: 16,
                              decoration: InputDecoration(
                                labelText: 'Aadhar Number (16 digits)',
                                prefixIcon: Icon(Icons.credit_card),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                counterText: '',
                              ),
                            ),
                            SizedBox(height: 16),

                            // Farm ID Field
                            TextField(
                              controller: _farmId,
                              decoration: InputDecoration(
                                labelText: 'Farm ID',
                                prefixIcon: Icon(Icons.agriculture),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Address Section
                      _buildSectionCard(
                        title: 'Farm Address',
                        icon: Icons.location_on,
                        child: Column(
                          children: [
                            // Door No Field
                            TextField(
                              controller: _doorNo,
                              decoration: InputDecoration(
                                labelText: 'Door No',
                                prefixIcon: Icon(Icons.door_front_door),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Street Field
                            TextField(
                              controller: _street,
                              decoration: InputDecoration(
                                labelText: 'Street Name',
                                prefixIcon: Icon(Icons.streetview),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // City Field
                            TextField(
                              controller: _city,
                              decoration: InputDecoration(
                                labelText: 'City/Town',
                                prefixIcon: Icon(Icons.location_city),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Pincode Field
                            TextField(
                              controller: _pincode,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: InputDecoration(
                                labelText: 'Pincode',
                                prefixIcon: Icon(Icons.pin_drop),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                counterText: '',
                              ),
                            ),
                            SizedBox(height: 16),

                            // District Field
                            TextField(
                              controller: _district,
                              decoration: InputDecoration(
                                labelText: 'District',
                                prefixIcon: Icon(Icons.map),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // State Field
                            TextField(
                              controller: _state,
                              decoration: InputDecoration(
                                labelText: 'State',
                                prefixIcon: Icon(Icons.flag),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Complete Registration Button
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _registering ? null : _completeRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _registering
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Complete Registration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.green.shade700, size: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

//
// Vet registration choice
//
class VetRegisterChoicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                      Color(0xFF0EA5E9),
                      Color(0xFF0284C7),
                      Color(0xFF0369A1),
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
                      color: Color(0xFF0EA5E9).withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Color(0xFF0EA5E9).withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.registerVet,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Welcome Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0EA5E9),
                      Color(0xFF0284C7),
                      Color(0xFF0369A1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF0EA5E9).withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Color(0xFF0EA5E9).withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                      ),
                      child: Center(
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.registerAsVetDoctor,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.useProfessionalCredentials,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Registration Options
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _methodCard(
                      context,
                      AppLocalizations.of(context)!.registerWithCredentials,
                      AppLocalizations.of(context)!.createUsernamePasswordVetId,
                      Icons.medical_services,
                      Color(0xFF0EA5E9),
                      () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VetRegisterPage())),
                    ),
                    SizedBox(height: 16),
                    _methodCard(
                      context,
                      AppLocalizations.of(context)!.contactSupport,
                      AppLocalizations.of(context)!.enterpriseOnboarding,
                      Icons.support_agent,
                      Color(0xFF6366F1),
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Contact support (placeholder)'),
                          backgroundColor: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _methodCard(BuildContext ctx, String title, String subtitle, IconData icon, Color brandColor, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: brandColor.withOpacity(0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Color(0xFFF8FAFC),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        brandColor.withOpacity(0.2),
                        brandColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: brandColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(icon, color: brandColor, size: 30),
                ),
                SizedBox(width: 20),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Color(0xFF94A3B8),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VetRegisterPage extends StatefulWidget {
  @override
  _VetRegisterPageState createState() => _VetRegisterPageState();
}

class _VetRegisterPageState extends State<VetRegisterPage> with TickerProviderStateMixin {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _vetid = TextEditingController();
  bool _saving = false;
  bool _scanningVetId = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _user.dispose();
    _pass.dispose();
    _vetid.dispose();
    super.dispose();
  }

  Future<void> _scanVetId() async {
    setState(() => _scanningVetId = true);
    try {
      // Navigate to camera scanner
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CameraScannerPage(
            title: 'Scan Vet ID',
            onScanResult: (String scannedText) {
              setState(() {
                _vetid.text = scannedText;
              });
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to scan Vet ID: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      setState(() => _scanningVetId = false);
    }
  }


  Future<void> _register() async {
    final u = _user.text.trim();
    final p = _pass.text.trim();
    final id = _vetid.text.trim();

    if (u.isEmpty || p.isEmpty || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange.shade600,
        ),
      );
      return;
    }

    if (p.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.orange.shade600,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      print('Registering vet: username=$u, vetId=$id');
      await auth.registerVet(u, p, id);
      // Refresh vet data to ensure the new vet is available for login
      await auth.refreshVetData();
      print('Vet registration completed successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Veterinary registration successful!'),
            ],
          ),
          backgroundColor: Color(0xFF16A34A),
          duration: Duration(seconds: 3),
        ),
      );
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Custom App Bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0EA5E9),
                          Color(0xFF0284C7),
                          Color(0xFF0369A1),
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
                          color: Color(0xFF0EA5E9).withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Color(0xFF0EA5E9).withOpacity(0.15),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.veterinaryRegistration,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Form Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF0EA5E9),
                                  Color(0xFF0284C7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF0EA5E9).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.medical_services,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Flexible(
                                  child: Text(
                                    'Create Your Veterinary Account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                      height: 1.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // Username Field
                          _buildInputCard(
                            title: 'Username',
                            hint: 'Enter your username',
                            controller: _user,
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username is required';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 16),

                          // Password Field
                          _buildInputCard(
                            title: 'Password',
                            hint: 'Create a secure password',
                            controller: _pass,
                            icon: Icons.lock,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 16),

                          // Vet ID Field with Camera Scan
                          _buildScanInputCard(
                            title: 'Veterinary ID',
                            hint: 'Scan or enter your Vet ID',
                            controller: _vetid,
                            icon: Icons.badge,
                            scanIcon: Icons.camera_alt,
                            onScanPressed: _scanVetId,
                            isScanning: _scanningVetId,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vet ID is required';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 16),

                          SizedBox(height: 32),

                          // Register Button
                          Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF16A34A),
                                  Color(0xFF15803D),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF16A34A).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _saving ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: _saving
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Creating Account...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person_add, size: 24, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(context)!.registerVet,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Clear Data Button (for troubleshooting)
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.shade300, width: 1.5),
                            ),
                            child: TextButton.icon(
                              onPressed: () async {
                                // Show confirmation dialog
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text('Clear All Data'),
                                    content: Text('This will clear all stored data and allow you to start fresh. Are you sure?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: Text('Clear Data'),
                                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await auth.clearAllData();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('All data cleared. You can now register fresh.')),
                                  );
                                }
                              },
                              icon: Icon(Icons.delete_forever, color: Colors.red.shade600),
                              label: Text(
                                'Clear All Data & Start Fresh',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 6,
      shadowColor: Color(0xFF0EA5E9).withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF8FAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF0EA5E9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Color(0xFF0EA5E9), size: 20),
                  ),
                  SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: controller,
                obscureText: obscureText,
                decoration: InputDecoration(
                  hintText: hint,
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
                validator: validator,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanInputCard({
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required IconData scanIcon,
    required VoidCallback onScanPressed,
    required bool isScanning,
    String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 6,
      shadowColor: Color(0xFF0EA5E9).withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF8FAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF0EA5E9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Color(0xFF0EA5E9), size: 20),
                  ),
                  SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.2,
                    ),
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF16A34A),
                          Color(0xFF15803D),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF16A34A).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: isScanning ? null : onScanPressed,
                      icon: isScanning
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(scanIcon, color: Colors.white, size: 20),
                      tooltip: 'Scan $title',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
                validator: validator,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Camera Scanner Page for Text Recognition
class CameraScannerPage extends StatefulWidget {
  final String title;
  final Function(String) onScanResult;

  const CameraScannerPage({
    Key? key,
    required this.title,
    required this.onScanResult,
  }) : super(key: key);

  @override
  _CameraScannerPageState createState() => _CameraScannerPageState();
}

class _CameraScannerPageState extends State<CameraScannerPage> {
  late MobileScannerController cameraController;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Color(0xFF0EA5E9),
        actions: [
          IconButton(
            icon: Icon(Icons.flashlight_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  widget.onScanResult(barcode.rawValue!);
                  Navigator.of(context).pop();
                  break;
                }
              }
            },
          ),
          // Scanner overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
              child: Container(
                width: 250,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Position ${widget.title.toLowerCase()} within the frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Corner brackets
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 75,
            left: MediaQuery.of(context).size.width / 2 - 125,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white, width: 4),
                  left: BorderSide(color: Colors.white, width: 4),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 75,
            right: MediaQuery.of(context).size.width / 2 - 125,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white, width: 4),
                  right: BorderSide(color: Colors.white, width: 4),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height / 2 - 75,
            left: MediaQuery.of(context).size.width / 2 - 125,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white, width: 4),
                  left: BorderSide(color: Colors.white, width: 4),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height / 2 - 75,
            right: MediaQuery.of(context).size.width / 2 - 125,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white, width: 4),
                  right: BorderSide(color: Colors.white, width: 4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}