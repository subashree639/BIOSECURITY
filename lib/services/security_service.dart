import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecurityService {
  static final SecurityService _instance = SecurityService._();
  factory SecurityService() => _instance;
  SecurityService._();

  // SHA-256 Hashing
  String hashSHA256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // AES Encryption Key (In production, this should be securely stored/generated)
  final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  final _iv = encrypt.IV.fromUtf8(
      'fixed16chariv123'); // Fixed IV for consistent encryption/decryption

  // AES Encryption
  String encryptAES(String plainText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  // AES Decryption
  String decryptAES(String encryptedText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }

  // Hash password with salt (for better security)
  String hashPassword(String password, {String? salt}) {
    final saltValue = salt ?? _generateSalt();
    final saltedPassword = password + saltValue;
    final hash = hashSHA256(saltedPassword);
    return '$hash:$saltValue'; // Store hash:salt together
  }

  // Verify password against stored hash
  bool verifyPassword(String password, String storedHash) {
    final parts = storedHash.split(':');
    if (parts.length != 2) return false;
    final hash = parts[0];
    final salt = parts[1];
    final computedHash = hashSHA256(password + salt);
    return computedHash == hash;
  }

  // Generate a random salt
  String _generateSalt() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return hashSHA256(random).substring(0, 16); // Use first 16 chars as salt
  }

  // Encrypt sensitive data before storing
  String encryptData(String data) {
    return encryptAES(data);
  }

  // Decrypt data when retrieving
  String decryptData(String encryptedData) {
    return decryptAES(encryptedData);
  }
}

final security = SecurityService();
