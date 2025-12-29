class User {
  int? id;
  String name;
  String role; // farmer, veterinarian, extension_worker, authority
  String? mobileNumber;
  String? email;
  String? vetId;
  String? hashPassword;
  String? pinHash;
  String? otp; // OTP for mobile verification
  bool biometricEnabled;
  DateTime createdAt;
  DateTime? lastLogin;

  User({
    this.id,
    required this.name,
    required this.role,
    this.mobileNumber,
    this.email,
    this.vetId,
    this.hashPassword,
    this.pinHash,
    this.otp,
    this.biometricEnabled = false,
    required this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'mobile_number': mobileNumber,
      'email': email,
      'vet_id': vetId,
      'hash_password': hashPassword,
      'pin_hash': pinHash,
      'otp': otp,
      'biometric_enabled': biometricEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      mobileNumber: map['mobile_number'],
      email: map['email'],
      vetId: map['vet_id'],
      hashPassword: map['hash_password'],
      pinHash: map['pin_hash'],
      otp: map['otp'],
      biometricEnabled: map['biometric_enabled'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      lastLogin: map['last_login'] != null ? DateTime.parse(map['last_login']) : null,
    );
  }
}