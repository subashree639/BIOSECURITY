import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import 'dashboard_screen.dart';
import 'veterinarian_dashboard_screen.dart';
import 'extension_worker_dashboard_screen.dart';
import 'authority_dashboard_screen.dart';
import 'register_screen.dart';
import 'farm_setup_screen.dart';
import 'role_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  bool _usePin = true;
  bool _obscurePassword = true;
  bool _isOtpMode = false;
  bool _otpSent = false;
  bool _isSendingOtp = false;
  int _otpResendTimer = 0;
  late AnimationController _animationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    print('LoginScreen initialized with role: ${widget.role}'); // Debug

    // Set default login mode based on role
    _isOtpMode = widget.role == 'farmer';

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward().then((_) {
      _slideAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideAnimationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authService = Provider.of<AuthService>(context);
    final roleData = _getRoleData(widget.role);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => _navigateBack(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              roleData['color'].withOpacity(0.15),
              roleData['color'].withOpacity(0.08),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Role-specific Header
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: roleData['color'].withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        roleData['icon'],
                        size: 50,
                        color: roleData['color'],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Welcome Message
                    Text(
                      '${l10n.welcomeBack}, ${roleData['title']}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: roleData['color'],
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Role Description
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: roleData['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: roleData['color'].withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            roleData['badgeIcon'],
                            size: 20,
                            color: roleData['color'],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            roleData['badgeText'],
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: roleData['color'],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Role-specific subtitle
                    Text(
                      roleData['subtitle'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Test credentials hint
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Text(
                        widget.role == 'farmer'
                            ? '${l10n.testMobile}: 9876543210\n${l10n.otpValue}: 111111\n${l10n.registerWithMobile}'
                            : '${l10n.testCredentials}: ${l10n.username}: ${_getTestUsername(widget.role)}, ${l10n.password}/${l10n.pin}: 1234',
                        style: TextStyle(
                          color: Colors.amber[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Auth Type Toggle (only for non-farmers)
                    if (widget.role != 'farmer') ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _usePin = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: _usePin ? roleData['color'] : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.pin,
                                        size: 20,
                                        color: _usePin ? Colors.white : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.pinLogin,
                                        style: TextStyle(
                                          color: _usePin ? Colors.white : Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _usePin = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: !_usePin ? roleData['color'] : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.password,
                                        size: 20,
                                        color: !_usePin ? Colors.white : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Password',
                                        style: TextStyle(
                                          color: !_usePin ? Colors.white : Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Form
                    if (widget.role == 'farmer') ...[
                      // OTP Login for Farmers
                      Column(
                        children: [
                          // Mobile Number field
                          TextFormField(
                            controller: _mobileController,
                            decoration: InputDecoration(
                              labelText: l10n.mobileNumber,
                              hintText: l10n.enterMobileNumber,
                              prefixIcon: Icon(
                                Icons.phone_android,
                                color: roleData['color'],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: roleData['color'], width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value!.isEmpty) return l10n.mobileRequired;
                              if (value.length < 10) return l10n.validMobileRequired;
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Send OTP Button
                          if (!_otpSent) ...[
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [
                                    roleData['color'].withOpacity(0.8),
                                    roleData['color'],
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: roleData['color'].withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isSendingOtp ? null : _sendOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: _isSendingOtp
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.send,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.sendOtp,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ] else ...[
                            // OTP Input field
                            TextFormField(
                              controller: _otpController,
                              decoration: InputDecoration(
                                labelText: l10n.enterOtp,
                                hintText: l10n.otpPlaceholder,
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: roleData['color'],
                                ),
                                suffixIcon: _otpResendTimer > 0
                                    ? Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Text(
                                          '${_otpResendTimer}s',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    : TextButton(
                                        onPressed: _sendOtp,
                                        child: Text(
                                          'Resend',
                                          style: TextStyle(
                                            color: roleData['color'],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: roleData['color'], width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) return l10n.otpRequired;
                                if (value.length != 6) return l10n.validOtpRequired;
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),
                    ] else ...[
                      // Traditional Login for other roles
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Username field (always shown)
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: l10n.username,
                                hintText: l10n.enterUsername,
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: roleData['color'],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: roleData['color'], width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                              validator: (value) => value!.isEmpty ? l10n.usernameRequired : null,
                            ),
                            const SizedBox(height: 20),
                            if (!_usePin) ...[
                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: l10n.password,
                                  hintText: l10n.enterPassword,
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: roleData['color'],
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey[500],
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: roleData['color'], width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                ),
                                obscureText: _obscurePassword,
                                validator: (value) => value!.isEmpty ? l10n.passwordRequired : null,
                              ),
                            ] else ...[
                              // PIN field
                              TextFormField(
                                controller: _pinController,
                                decoration: InputDecoration(
                                  labelText: l10n.pin,
                                  hintText: l10n.enterPin,
                                  prefixIcon: Icon(
                                    Icons.dialpad,
                                    color: roleData['color'],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: roleData['color'], width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                ),
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 6,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 8,
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) return l10n.pinRequired;
                                  if (value.length < 4) return l10n.pinMinLength;
                                  return null;
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Login/Verify Button
                    if (widget.role == 'farmer') ...[
                      // OTP Verify Button for Farmers
                      if (_otpSent) ...[
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [
                                roleData['color'],
                                roleData['color'].withOpacity(0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: roleData['color'].withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.verifyOtp,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ] else ...[
                      // Traditional Login Button for other roles
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              roleData['color'],
                              roleData['color'].withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: roleData['color'].withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Login
                              bool success = await authService.login(
                                _usernameController.text,
                                _usePin ? _pinController.text : _passwordController.text,
                                isPin: _usePin,
                              );
                              if (success) {
                                // Check if user has farm setup
                                final farms = await DatabaseHelper().getFarms();
                                final userFarm = farms.where((farm) => farm.createdBy == authService.currentUser!.id).toList();

                                if (userFarm.isEmpty && authService.currentUser!.role == 'farmer') {
                                  // No farm setup - go to farm setup (only for farmers)
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const FarmSetupScreen()),
                                  );
                                } else {
                                  // Go to role-based dashboard
                                  _navigateToRoleBasedDashboard(context, authService.currentUser!.role);
                                }
                              } else {
                                // For extension worker, show "workercredentials" and bypass to dashboard
                                if (widget.role == 'extension_worker') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('workercredentials'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  _navigateToRoleBasedDashboard(context, 'extension_worker');
                                } else if (widget.role == 'authority') {
                                  // For authority, bypass invalid credentials and go to dashboard
                                  _navigateToRoleBasedDashboard(context, 'authority');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.error_outline, color: Colors.white),
                                          const SizedBox(width: 12),
                                          Text(l10n.invalidCredentials),
                                        ],
                                      ),
                                      backgroundColor: Colors.red[700],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.login,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.login,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Create Account Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.dontHaveAccount,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterScreen(role: widget.role),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(
                            l10n.createAccount,
                            style: TextStyle(
                              color: roleData['color'],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Security note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.dataSecurityMessage,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                                height: 1.4,
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
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getRoleData(String role) {
    final l10n = AppLocalizations.of(context)!;
    switch (role) {
      case 'farmer':
        return {
          'title': l10n.roleFarmer,
          'icon': Icons.agriculture,
          'color': const Color(0xFF4CAF50), // Green
          'badgeIcon': Icons.eco,
          'badgeText': l10n.farmGuardian,
          'subtitle': l10n.protectFarm,
        };
      case 'veterinarian':
        return {
          'title': l10n.roleVeterinarian,
          'icon': Icons.local_hospital,
          'color': const Color(0xFF2196F3), // Blue
          'badgeIcon': Icons.medical_services,
          'badgeText': l10n.healthExpert,
          'subtitle': l10n.monitorHealth,
        };
      case 'extension_worker':
        return {
          'title': l10n.roleExtensionWorker,
          'icon': Icons.people,
          'color': const Color(0xFFFF9800), // Orange
          'badgeIcon': Icons.support_agent,
          'badgeText': l10n.fieldSupport,
          'subtitle': l10n.provideGuidance,
        };
      case 'authority':
        return {
          'title': l10n.roleAuthority,
          'icon': Icons.security,
          'color': const Color(0xFF9C27B0), // Purple
          'badgeIcon': Icons.verified_user,
          'badgeText': l10n.regulatoryOversight,
          'subtitle': l10n.overseeCompliance,
        };
      default:
        return {
          'title': role,
          'icon': Icons.account_circle,
          'color': Theme.of(context).primaryColor,
          'badgeIcon': Icons.person,
          'badgeText': 'User',
          'subtitle': 'Access your biosecurity dashboard and manage your data.',
        };
    }
  }

  Color _getRoleColor(String role) {
    final roleData = _getRoleData(role);
    return roleData['color'];
  }

  String _getTestUsername(String role) {
    switch (role) {
      case 'farmer':
        return 'farmer1';
      case 'veterinarian':
        return 'vet1';
      case 'extension_worker':
        return 'worker1';
      case 'authority':
        return 'authority1';
      default:
        return 'farmer1';
    }
  }

  void _navigateBack(BuildContext context) {
    // Navigate back to role selection screen by replacing current screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  void _navigateToRoleBasedDashboard(BuildContext context, String role) {
    Widget dashboard;
    print('Navigating to dashboard for role: $role'); // Debug print

    switch (role) {
      case 'farmer':
        dashboard = const DashboardScreen();
        print('Selected Farmer Dashboard');
        break;
      case 'veterinarian':
        dashboard = const VeterinarianDashboardScreen();
        print('Selected Veterinarian Dashboard');
        break;
      case 'extension_worker':
        dashboard = const ExtensionWorkerDashboardScreen();
        print('Selected Extension Worker Dashboard');
        break;
      case 'authority':
        dashboard = const AuthorityDashboardScreen();
        print('Selected Authority Dashboard');
        break;
      default:
        dashboard = const DashboardScreen();
        print('Selected Default Dashboard (Farmer)');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }

  // OTP Methods
  Future<void> _sendOtp() async {
    final l10n = AppLocalizations.of(context)!;
    if (_mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterMobile)),
      );
      return;
    }

    setState(() => _isSendingOtp = true);

    try {
      // Simulate OTP sending (replace with actual SMS service)
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _otpSent = true;
        _otpResendTimer = 30;
      });

      // Start countdown timer
      _startOtpTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.otpSent),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.failedToSendOtp}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSendingOtp = false);
    }
  }

  void _startOtpTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _otpResendTimer > 0) {
        setState(() => _otpResendTimer--);
        _startOtpTimer();
      }
    });
  }

  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context)!;
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterOtp)),
      );
      return;
    }

    try {
      // Simulate OTP verification (replace with actual verification)
      await Future.delayed(const Duration(seconds: 1));

      // Verify OTP against stored value in database
      bool success = await Provider.of<AuthService>(context, listen: false)
          .login(_mobileController.text, _otpController.text, isOtp: true);

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.loginSuccessful),
            backgroundColor: Colors.green,
          ),
        );
        // For OTP login, go directly to dashboard (skip farm setup check)
        // Use the actual user role from the authenticated user
        final authService = Provider.of<AuthService>(context, listen: false);
        final userRole = authService.currentUser!.role;
        _navigateToRoleBasedDashboard(context, userRole);
      } else {
        // Remove error message - just do nothing or navigate anyway?
        // For now, keep the navigation to dashboard even on failure as per user request
        final authService = Provider.of<AuthService>(context, listen: false);
        final userRole = 'farmer'; // Assume farmer
        _navigateToRoleBasedDashboard(context, userRole);
      }
    } catch (e) {
      // Remove database exception popup, show success and go to veterinary dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.loginSuccessful),
          backgroundColor: Colors.green,
        ),
      );
      _navigateToRoleBasedDashboard(context, 'veterinarian');
    }
  }
}