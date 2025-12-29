import 'package:flutter_test/flutter_test.dart';
import 'package:abc_farm_frontend/services/security_service.dart';

void main() {
  group('Security Service Tests', () {
    test('SHA-256 Hashing', () {
      final hash1 = security.hashSHA256('test_password');
      final hash2 = security.hashSHA256('test_password');
      final hash3 = security.hashSHA256('different_password');

      expect(hash1, equals(hash2)); // Same input should produce same hash
      expect(hash1, isNot(equals(hash3))); // Different input should produce different hash
      expect(hash1.length, equals(64)); // SHA-256 produces 64 character hex string
    });

    test('Password Hashing with Salt', () {
      final hash1 = security.hashPassword('mypassword');
      final hash2 = security.hashPassword('mypassword');
      final hash3 = security.hashPassword('differentpassword');

      expect(hash1, isNot(equals(hash2))); // Different salts should produce different hashes
      expect(security.verifyPassword('mypassword', hash1), isTrue);
      expect(security.verifyPassword('mypassword', hash2), isTrue);
      expect(security.verifyPassword('wrongpassword', hash1), isFalse);
      expect(security.verifyPassword('mypassword', hash3), isFalse);
    });

    test('AES Encryption/Decryption', () {
      const plainText = 'This is a secret message';
      final encrypted = security.encryptData(plainText);
      final decrypted = security.decryptData(encrypted);

      expect(decrypted, equals(plainText));
      expect(encrypted, isNot(equals(plainText)));
    });

    test('Encryption produces same results for same input with same key/IV', () {
      const plainText = 'Same message';
      final encrypted1 = security.encryptData(plainText);
      final encrypted2 = security.encryptData(plainText);

      expect(encrypted1, equals(encrypted2)); // Same key and IV produce same result
    });
  });
}