import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/signers/rsa_signer.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'models/animal.dart';

class AnimalCertificate {
  final String animalId;
  final String species;
  final String breed;
  final String? lastDrug;
  final String? withdrawalEnd;
  final double? currentMRL;
  final String? mrlStatus;
  final String signature;
  final DateTime issuedAt;
  final DateTime expiresAt;

  AnimalCertificate({
    required this.animalId,
    required this.species,
    required this.breed,
    this.lastDrug,
    this.withdrawalEnd,
    this.currentMRL,
    this.mrlStatus,
    required this.signature,
    required this.issuedAt,
    required this.expiresAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'animalId': animalId,
      'species': species,
      'breed': breed,
      'lastDrug': lastDrug,
      'withdrawalEnd': withdrawalEnd,
      'currentMRL': currentMRL,
      'mrlStatus': mrlStatus,
      'signature': signature,
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  static AnimalCertificate fromMap(Map<String, dynamic> map) {
    return AnimalCertificate(
      animalId: map['animalId'],
      species: map['species'],
      breed: map['breed'],
      lastDrug: map['lastDrug'],
      withdrawalEnd: map['withdrawalEnd'],
      currentMRL: map['currentMRL'],
      mrlStatus: map['mrlStatus'],
      signature: map['signature'],
      issuedAt: DateTime.parse(map['issuedAt']),
      expiresAt: DateTime.parse(map['expiresAt']),
    );
  }

  String toJson() => jsonEncode(toMap());

  static AnimalCertificate fromJson(String json) => fromMap(jsonDecode(json));
}

extension AnimalCertificateExtension on AnimalCertificate {
  AnimalCertificate copyWith({String? signature}) {
    return AnimalCertificate(
      animalId: animalId,
      species: species,
      breed: breed,
      lastDrug: lastDrug,
      withdrawalEnd: withdrawalEnd,
      currentMRL: currentMRL,
      mrlStatus: mrlStatus,
      signature: signature ?? this.signature,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
    );
  }
}

class QRCertificateService {
  static const _privateKeyKey = 'private_key';
  static const _publicKeyKey = 'public_key';
  static const _revokedKey = 'revoked_animals';
  static const _cacheKey = 'verification_cache';

  RSAPrivateKey? _privateKey;
  RSAPublicKey? _publicKey;
  Set<String> _revoked = {};
  Map<String, bool> _cache = {};

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final privPem = prefs.getString(_privateKeyKey);
    final pubPem = prefs.getString(_publicKeyKey);
    if (privPem == null || pubPem == null) {
      // Generate new key pair
      final keyGen = RSAKeyGenerator();
      final secureRandom = FortunaRandom();
      secureRandom.seed(KeyParameter(Uint8List(32))); // insecure for demo
      final params = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64);
      keyGen.init(ParametersWithRandom(params, secureRandom));
      final pair = keyGen.generateKeyPair();
      _privateKey = pair.privateKey as RSAPrivateKey;
      _publicKey = pair.publicKey as RSAPublicKey;
      // Save as JSON
      final privJson = _encodePrivateKey(_privateKey!);
      final pubJson = _encodePublicKey(_publicKey!);
      await prefs.setString(_privateKeyKey, privJson);
      await prefs.setString(_publicKeyKey, pubJson);
    } else {
      _privateKey = _decodePrivateKey(privPem);
      _publicKey = _decodePublicKey(pubPem);
    }
    final revokedJson = prefs.getString(_revokedKey);
    if (revokedJson != null) {
      _revoked = Set.from(jsonDecode(revokedJson));
    }
    final cacheJson = prefs.getString(_cacheKey);
    if (cacheJson != null) {
      _cache = Map<String, bool>.from(jsonDecode(cacheJson));
    }
  }

  // JSON encoding/decoding - for demo
  String _encodePrivateKey(RSAPrivateKey key) {
    return jsonEncode({
      'modulus': key.modulus.toString(),
      'privateExponent': key.privateExponent.toString(),
      'p': key.p.toString(),
      'q': key.q.toString(),
    });
  }

  RSAPrivateKey _decodePrivateKey(String json) {
    final m = jsonDecode(json);
    return RSAPrivateKey(
      BigInt.parse(m['modulus']),
      BigInt.parse(m['privateExponent']),
      BigInt.parse(m['p']),
      BigInt.parse(m['q']),
    );
  }

  String _encodePublicKey(RSAPublicKey key) {
    return jsonEncode({
      'modulus': key.modulus.toString(),
      'publicExponent': key.publicExponent.toString(),
    });
  }

  RSAPublicKey _decodePublicKey(String json) {
    final m = jsonDecode(json);
    return RSAPublicKey(
      BigInt.parse(m['modulus']),
      BigInt.parse(m['publicExponent']),
    );
  }

  AnimalCertificate generateCertificate(Animal animal) {
    final issuedAt = DateTime.now();
    final expiresAt = animal.withdrawalEnd != null ? DateTime.parse(animal.withdrawalEnd!) : issuedAt.add(Duration(days: 365));
    final cert = AnimalCertificate(
      animalId: animal.id,
      species: animal.species,
      breed: animal.breed,
      lastDrug: animal.lastDrug,
      withdrawalEnd: animal.withdrawalEnd,
      currentMRL: animal.currentMRL,
      mrlStatus: animal.mrlStatus,
      signature: '', // to be set
      issuedAt: issuedAt,
      expiresAt: expiresAt,
    );
    final data = jsonEncode(cert.toMap()..remove('signature'));
    final signature = _signData(data);
    return cert.copyWith(signature: signature);
  }

  String _signData(String data) {
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201'); // PKCS1
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(_privateKey!));
    final sig = signer.generateSignature(Uint8List.fromList(utf8.encode(data)));
    return base64Encode(sig.bytes);
  }

  Future<bool> verifyCertificate(AnimalCertificate cert, {bool online = false}) async {
    if (online) {
      return await _verifyOnline(cert);
    } else {
      return _verifyOffline(cert);
    }
  }

  bool _verifyOffline(AnimalCertificate cert) {
    // Check expiry
    if (DateTime.now().isAfter(cert.expiresAt)) return false;
    // Check revocation
    if (_revoked.contains(cert.animalId)) return false;
    // Verify signature
    final data = jsonEncode(cert.toMap()..remove('signature'));
    return _verifySignature(data, cert.signature);
  }

  bool _verifySignature(String data, String signature) {
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    signer.init(false, PublicKeyParameter<RSAPublicKey>(_publicKey!));
    final sig = RSASignature(base64Decode(signature));
    return signer.verifySignature(Uint8List.fromList(utf8.encode(data)), sig);
  }

  Future<bool> _verifyOnline(AnimalCertificate cert) async {
    // Check cache first
    if (_cache.containsKey(cert.animalId)) {
      return _cache[cert.animalId]!;
    }
    // Mock API call - in real app, replace with actual API
    final url = 'https://mock-api.example.com/verify'; // Replace with real endpoint
    try {
      final response = await http.post(
        Uri.parse(url),
        body: cert.toJson(),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)['valid'] as bool;
        // Cache the result
        _cache[cert.animalId] = result;
        await _saveCache();
        return result;
      } else {
        // Fallback to offline
        return _verifyOffline(cert);
      }
    } catch (e) {
      // Network error, fallback to offline
      return _verifyOffline(cert);
    }
  }

  Future<void> revokeAnimal(String animalId) async {
    _revoked.add(animalId);
    await _saveRevoked();
  }

  Future<void> _saveRevoked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_revokedKey, jsonEncode(_revoked.toList()));
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(_cache));
  }

  bool isRevoked(String animalId) => _revoked.contains(animalId);

  AnimalCertificate? parseCertificate(String qrData) {
    try {
      return AnimalCertificate.fromJson(qrData);
    } catch (e) {
      return null;
    }
  }
}

final qrService = QRCertificateService();