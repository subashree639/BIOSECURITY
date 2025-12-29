import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/signers/rsa_signer.dart';
import 'package:pointycastle/digests/sha256.dart';
import '../models/animal.dart';

/// Blockchain service for ensuring data integrity and traceability
class BlockchainService {
  static final BlockchainService _instance = BlockchainService._internal();
  factory BlockchainService() => _instance;
  BlockchainService._internal();

  final List<Block> _chain = [];
  final List<Block> _pendingTransactions = [];
  late RSAPublicKey _publicKey;
  late RSAPrivateKey _privateKey;

  /// Initialize the blockchain with genesis block
  Future<void> initialize() async {
    await _generateKeyPair();
    _createGenesisBlock();
  }

  /// Generate RSA key pair for digital signatures
  Future<void> _generateKeyPair() async {
    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        _getSecureRandom(),
      ));

    final pair = keyGen.generateKeyPair();
    _publicKey = pair.publicKey as RSAPublicKey;
    _privateKey = pair.privateKey as RSAPrivateKey;
  }

  SecureRandom _getSecureRandom() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  /// Create the genesis (first) block
  void _createGenesisBlock() {
    final genesisBlock = Block(
      index: 0,
      timestamp: DateTime.now(),
      transactions: [],
      previousHash: '0',
      nonce: 0,
    );
    genesisBlock.hash = _calculateHash(genesisBlock);
    _chain.add(genesisBlock);
  }

  /// Add a new transaction to be included in the next block
  Future<void> addTransaction(BlockchainTransaction transaction) async {
    // Sign the transaction
    final signature = await _signTransaction(transaction);
    transaction.signature = signature;
    transaction.publicKey = _publicKey.modulus!.toString();

    _pendingTransactions.add(Block(
      index: _chain.length,
      timestamp: DateTime.now(),
      transactions: [transaction],
      previousHash: _chain.last.hash,
      nonce: 0,
    ));
  }

  /// Mine a new block with pending transactions
  Future<Block?> mineBlock() async {
    if (_pendingTransactions.isEmpty) return null;

    final block = _pendingTransactions.removeAt(0);
    block.nonce = await _proofOfWork(block);
    block.hash = _calculateHash(block);

    _chain.add(block);
    return block;
  }

  /// Proof of work algorithm (simplified for mobile)
  Future<int> _proofOfWork(Block block) async {
    int nonce = 0;
    String hash;

    do {
      nonce++;
      hash = _calculateHashWithNonce(block, nonce);
    } while (!hash.startsWith('0000')); // Difficulty level

    return nonce;
  }

  /// Calculate block hash
  String _calculateHash(Block block) {
    final data = '${block.index}${block.timestamp.millisecondsSinceEpoch}'
        '${block.transactions.map((t) => t.toString()).join('')}'
        '${block.previousHash}${block.nonce}';

    return sha256.convert(utf8.encode(data)).toString();
  }

  String _calculateHashWithNonce(Block block, int nonce) {
    final data = '${block.index}${block.timestamp.millisecondsSinceEpoch}'
        '${block.transactions.map((t) => t.toString()).join('')}'
        '${block.previousHash}$nonce';

    return sha256.convert(utf8.encode(data)).toString();
  }

  /// Sign a transaction with private key
  Future<String> _signTransaction(BlockchainTransaction transaction) async {
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(_privateKey));

    final data = utf8.encode(transaction.toString());
    final signature = signer.generateSignature(data);
    return base64Encode(signature.bytes);
  }

  /// Verify transaction signature
  bool verifyTransaction(BlockchainTransaction transaction) {
    if (transaction.signature == null || transaction.publicKey == null) {
      return false;
    }

    try {
      final verifier = RSASigner(SHA256Digest(), '0609608648016503040201');
      final publicKey = RSAPublicKey(BigInt.parse(transaction.publicKey!), BigInt.parse('65537'));
      verifier.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));

      final data = utf8.encode(transaction.toString());
      final signature = RSASignature(base64Decode(transaction.signature!));
      return verifier.verifySignature(data, signature);
    } catch (e) {
      return false;
    }
  }

  /// Verify the entire blockchain integrity
  bool verifyChain() {
    for (int i = 1; i < _chain.length; i++) {
      final currentBlock = _chain[i];
      final previousBlock = _chain[i - 1];

      // Verify hash
      if (currentBlock.hash != _calculateHash(currentBlock)) {
        return false;
      }

      // Verify previous hash link
      if (currentBlock.previousHash != previousBlock.hash) {
        return false;
      }

      // Verify transactions
      for (final transaction in currentBlock.transactions) {
        if (!verifyTransaction(transaction)) {
          return false;
        }
      }
    }
    return true;
  }

  /// Get blockchain data for a specific animal
  List<BlockchainTransaction> getAnimalTransactions(String animalId) {
    final transactions = <BlockchainTransaction>[];

    for (final block in _chain) {
      for (final transaction in block.transactions) {
        if (transaction.animalId == animalId) {
          transactions.add(transaction);
        }
      }
    }

    return transactions;
  }

  /// Generate certificate of authenticity for animal data
  Future<String> generateCertificateOfAuthenticity(String animalId) async {
    final transactions = getAnimalTransactions(animalId);
    final latestBlock = _chain.last;

    final certificate = {
      'animalId': animalId,
      'blockchainLength': _chain.length,
      'latestBlockHash': latestBlock.hash,
      'transactionCount': transactions.length,
      'lastTransaction': transactions.isNotEmpty ? transactions.last.timestamp : null,
      'certificateGenerated': DateTime.now().toIso8601String(),
      'isChainValid': verifyChain(),
    };

    return jsonEncode(certificate);
  }

  /// Export blockchain data for backup/audit
  String exportBlockchain() {
    final exportData = {
      'chain': _chain.map((block) => block.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'chainValid': verifyChain(),
    };

    return jsonEncode(exportData);
  }

  /// Import blockchain data
  Future<bool> importBlockchain(String jsonData) async {
    try {
      final data = jsonDecode(jsonData);
      final importedChain = (data['chain'] as List)
          .map((blockData) => Block.fromJson(blockData))
          .toList();

      // Verify imported chain
      _chain.clear();
      _chain.addAll(importedChain);

      return verifyChain();
    } catch (e) {
      return false;
    }
  }

  /// Get blockchain statistics
  Map<String, dynamic> getStatistics() {
    final totalTransactions = _chain.fold<int>(
      0,
      (sum, block) => sum + block.transactions.length,
    );

    final animalIds = <String>{};
    for (final block in _chain) {
      for (final transaction in block.transactions) {
        animalIds.add(transaction.animalId);
      }
    }

    return {
      'totalBlocks': _chain.length,
      'totalTransactions': totalTransactions,
      'uniqueAnimals': animalIds.length,
      'chainValid': verifyChain(),
      'pendingTransactions': _pendingTransactions.length,
    };
  }

  List<Block> get chain => List.unmodifiable(_chain);
}

/// Blockchain block containing transactions
class Block {
  final int index;
  final DateTime timestamp;
  final List<BlockchainTransaction> transactions;
  final String previousHash;
  int nonce;
  late String hash;

  Block({
    required this.index,
    required this.timestamp,
    required this.transactions,
    required this.previousHash,
    required this.nonce,
  });

  Map<String, dynamic> toJson() => {
    'index': index,
    'timestamp': timestamp.toIso8601String(),
    'transactions': transactions.map((t) => t.toJson()).toList(),
    'previousHash': previousHash,
    'nonce': nonce,
    'hash': hash,
  };

  static Block fromJson(Map<String, dynamic> json) => Block(
    index: json['index'],
    timestamp: DateTime.parse(json['timestamp']),
    transactions: (json['transactions'] as List)
        .map((t) => BlockchainTransaction.fromJson(t))
        .toList(),
    previousHash: json['previousHash'],
    nonce: json['nonce'],
  )..hash = json['hash'];
}

/// Transaction representing an animal treatment or health event
class BlockchainTransaction {
  final String id;
  final String animalId;
  final String transactionType; // 'treatment', 'vaccination', 'health_check', 'sale'
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String performedBy;
  String? signature;
  String? publicKey;

  BlockchainTransaction({
    required this.id,
    required this.animalId,
    required this.transactionType,
    required this.data,
    required this.timestamp,
    required this.performedBy,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'animalId': animalId,
    'transactionType': transactionType,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'performedBy': performedBy,
    'signature': signature,
    'publicKey': publicKey,
  };

  static BlockchainTransaction fromJson(Map<String, dynamic> json) =>
    BlockchainTransaction(
      id: json['id'],
      animalId: json['animalId'],
      transactionType: json['transactionType'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      performedBy: json['performedBy'],
    )
    ..signature = json['signature']
    ..publicKey = json['publicKey'];

  @override
  String toString() {
    return '$id$animalId$transactionType${data.toString()}${timestamp.millisecondsSinceEpoch}$performedBy';
  }

  /// Create transaction from animal treatment
  static BlockchainTransaction fromTreatmentRecord(
    TreatmentRecord treatment,
    String animalId,
    String performedBy,
  ) {
    return BlockchainTransaction(
      id: 'treatment_${treatment.dateAdministered.millisecondsSinceEpoch}_${animalId}',
      animalId: animalId,
      transactionType: 'treatment',
      data: {
        'drugName': treatment.drugName,
        'dosage': treatment.dosage,
        'condition': treatment.condition,
        'notes': treatment.notes,
        'cost': treatment.cost,
        'outcome': treatment.outcome,
      },
      timestamp: treatment.dateAdministered,
      performedBy: performedBy,
    );
  }

  /// Create transaction from animal health check
  static BlockchainTransaction fromHealthCheck(
    Animal animal,
    String performedBy,
  ) {
    return BlockchainTransaction(
      id: 'health_check_${DateTime.now().millisecondsSinceEpoch}_${animal.id}',
      animalId: animal.id,
      transactionType: 'health_check',
      data: {
        'healthScore': animal.healthScore,
        'mrlStatus': animal.mrlStatus,
        'withdrawalStatus': animal.hasActiveTreatment ? 'active' : 'completed',
        'currentMRL': animal.currentMRL,
      },
      timestamp: DateTime.now(),
      performedBy: performedBy,
    );
  }
}