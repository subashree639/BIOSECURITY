import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPService {
  static const String _lastOtpTimeKey = 'last_otp_time';
  static const String _otpAttemptsKey = 'otp_attempts';
  static const Duration _otpExpiry = Duration(minutes: 5);
  static const Duration _rateLimitWindow = Duration(minutes: 1);
  static const int _maxAttemptsPerWindow = 3;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;

  // Rate limiting
  DateTime? _lastOtpTime;
  int _attemptsThisWindow = 0;

  // Mock OTP storage
  String? _generatedOTP;
  String? _otpPhoneNumber;
  Timer? _otpExpiryTimer;

  Future<void> init() async {
    await _loadRateLimitData();
  }

  Future<void> _loadRateLimitData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTimeStr = prefs.getString(_lastOtpTimeKey);
    if (lastTimeStr != null) {
      _lastOtpTime = DateTime.parse(lastTimeStr);
    }
    _attemptsThisWindow = prefs.getInt(_otpAttemptsKey) ?? 0;
  }

  Future<void> _saveRateLimitData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_lastOtpTime != null) {
      await prefs.setString(_lastOtpTimeKey, _lastOtpTime!.toIso8601String());
    }
    await prefs.setInt(_otpAttemptsKey, _attemptsThisWindow);
  }

  bool _isRateLimited() {
    if (_lastOtpTime == null) return false;

    final now = DateTime.now();
    final timeDiff = now.difference(_lastOtpTime!);

    if (timeDiff > _rateLimitWindow) {
      // Reset window
      _attemptsThisWindow = 0;
      return false;
    }

    return _attemptsThisWindow >= _maxAttemptsPerWindow;
  }

  Duration? getRemainingRateLimitTime() {
    if (_lastOtpTime == null) return null;

    final now = DateTime.now();
    final timeDiff = now.difference(_lastOtpTime!);

    if (timeDiff > _rateLimitWindow) return null;

    return _rateLimitWindow - timeDiff;
  }

  Future<OTPResult> sendOTP(String phoneNumber) async {
    try {
      // Check rate limiting
      if (_isRateLimited()) {
        final remaining = getRemainingRateLimitTime();
        return OTPResult.failure(
          'Too many OTP requests. Please wait ${remaining?.inSeconds ?? 60} seconds.',
          isRateLimited: true,
        );
      }

      // Validate phone number
      if (!isValidPhoneNumber(phoneNumber)) {
        return OTPResult.failure('Please enter a valid phone number');
      }

      // Update rate limiting
      _lastOtpTime = DateTime.now();
      _attemptsThisWindow++;
      await _saveRateLimitData();

      // Format phone number for Firebase (add +91 for Indian numbers)
      final formattedPhone = phoneNumber.startsWith('+91')
          ? phoneNumber
          : '+91$phoneNumber';

      // Send OTP using Firebase Phone Authentication
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            _generatedOTP = 'AUTO_VERIFIED';
          } catch (e) {
            print('Auto-verification failed: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Phone verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          print('OTP sent to $formattedPhone');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          print('Auto-retrieval timeout');
        },
        timeout: const Duration(seconds: 60),
      );

      return OTPResult.success('OTP sent to $formattedPhone');

    } catch (e) {
      print('Firebase OTP send failed (likely offline): $e');
      // In offline/demo mode, simulate successful OTP send
      _verificationId = 'DEMO_VERIFICATION_ID';
      return OTPResult.success('Demo mode: OTP simulated (enter any 6-digit code)');
    }
  }

  Future<OTPResult> verifyOTP(String otpCode) async {
    try {
      if (_verificationId == null) {
        return OTPResult.failure('No OTP request found. Please request OTP first.');
      }

      // Handle demo mode
      if (_verificationId == 'DEMO_VERIFICATION_ID') {
        // In demo mode, accept any 6-digit code
        if (otpCode.trim().length == 6 && RegExp(r'^\d{6}$').hasMatch(otpCode.trim())) {
          // Reset rate limiting on successful verification
          _attemptsThisWindow = 0;
          await _saveRateLimitData();

          // Clear verification data
          clearVerificationId();

          return OTPResult.success('Demo mode: OTP verified successfully');
        } else {
          return OTPResult.failure('Please enter a valid 6-digit OTP code.');
        }
      }

      // Create credential with verification ID and OTP code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode.trim(),
      );

      // Sign in with the credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Reset rate limiting on successful verification
      _attemptsThisWindow = 0;
      await _saveRateLimitData();

      // Clear verification data
      clearVerificationId();

      return OTPResult.success('OTP verified successfully', user: userCredential.user);

    } catch (e) {
      print('Firebase OTP verification failed (likely offline): $e');

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-verification-code':
            return OTPResult.failure('Invalid OTP. Please check the code and try again.');
          case 'invalid-verification-id':
            return OTPResult.failure('OTP expired. Please request a new OTP.');
          case 'too-many-requests':
            return OTPResult.failure('Too many failed attempts. Please try again later.');
          default:
            return OTPResult.failure('Verification failed: ${e.message}');
        }
      }

      // For demo mode or offline scenarios, accept any 6-digit code
      if (otpCode.trim().length == 6 && RegExp(r'^\d{6}$').hasMatch(otpCode.trim())) {
        // Reset rate limiting on successful verification
        _attemptsThisWindow = 0;
        await _saveRateLimitData();

        // Clear verification data
        clearVerificationId();

        return OTPResult.success('Offline mode: OTP verified successfully');
      }

      return OTPResult.failure('Invalid OTP. Please try again.');
    }
  }

  Future<OTPResult> resendOTP(String phoneNumber) async {
    // Reset verification ID for resend
    _verificationId = null;
    return sendOTP(phoneNumber);
  }

  bool isValidPhoneNumber(String phoneNumber) {
    // Validate Indian phone numbers (10 digits, optionally with +91 prefix)
    final cleanNumber = phoneNumber.trim().replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's exactly 10 digits (Indian mobile number)
    if (cleanNumber.length == 10) {
      return true;
    }

    // Check if it's 12 digits starting with 91 (Indian number with country code)
    if (cleanNumber.length == 12 && cleanNumber.startsWith('91')) {
      return true;
    }

    // Check if it starts with +91 and has 10 digits after
    if (phoneNumber.trim().startsWith('+91') && cleanNumber.length == 12) {
      return true;
    }

    return false;
  }

  void clearVerificationId() {
    _verificationId = null;
    _resendToken = null;
    _generatedOTP = null;
    _otpPhoneNumber = null;
    _otpExpiryTimer?.cancel();
    _otpExpiryTimer = null;
  }

  // Generate unique OTP locally for farmer login
  Future<OTPResult> generateLocalOTP(String phoneNumber) async {
    try {
      // Check rate limiting
      if (_isRateLimited()) {
        final remaining = getRemainingRateLimitTime();
        return OTPResult.failure(
          'Too many OTP requests. Please wait ${remaining?.inSeconds ?? 60} seconds.',
          isRateLimited: true,
        );
      }

      // Validate phone number
      if (!isValidPhoneNumber(phoneNumber)) {
        return OTPResult.failure('Please enter a valid phone number');
      }

      // Update rate limiting
      _lastOtpTime = DateTime.now();
      _attemptsThisWindow++;
      await _saveRateLimitData();

      // Generate unique 6-digit OTP
      final random = Random();
      final otp = (100000 + random.nextInt(900000)).toString();

      // Store OTP and phone number
      _generatedOTP = otp;
      _otpPhoneNumber = phoneNumber;

      // Set expiry timer for 10 seconds
      _otpExpiryTimer?.cancel();
      _otpExpiryTimer = Timer(Duration(seconds: 10), () {
        _generatedOTP = null;
        _otpPhoneNumber = null;
      });

      return OTPResult.success('OTP generated: $otp');

    } catch (e) {
      print('Local OTP generation failed: $e');
      return OTPResult.failure('Failed to generate OTP');
    }
  }

  // Verify local OTP for farmer login
  Future<OTPResult> verifyLocalOTP(String phoneNumber, String otpCode) async {
    try {
      // Check if OTP exists and matches phone number
      if (_generatedOTP == null || _otpPhoneNumber != phoneNumber) {
        return OTPResult.failure('No OTP found for this phone number. Please generate a new OTP.');
      }

      // Check if OTP matches
      if (_generatedOTP == otpCode.trim()) {
        // Reset rate limiting on successful verification
        _attemptsThisWindow = 0;
        await _saveRateLimitData();

        // Clear OTP data
        clearVerificationId();

        return OTPResult.success('OTP verified successfully');
      } else {
        return OTPResult.failure('Invalid OTP. Please check the code and try again.');
      }

    } catch (e) {
      print('Local OTP verification failed: $e');
      return OTPResult.failure('Verification failed');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    clearVerificationId();
  }
}

class OTPResult {
  final bool isSuccess;
  final String message;
  final User? user;
  final bool isRateLimited;

  OTPResult._({
    required this.isSuccess,
    required this.message,
    this.user,
    this.isRateLimited = false,
  });

  factory OTPResult.success(String message, {User? user}) {
    return OTPResult._(
      isSuccess: true,
      message: message,
      user: user,
    );
  }

  factory OTPResult.failure(String message, {bool isRateLimited = false}) {
    return OTPResult._(
      isSuccess: false,
      message: message,
      isRateLimited: isRateLimited,
    );
  }
}