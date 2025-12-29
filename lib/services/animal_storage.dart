import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/animal.dart';
import 'blockchain_service.dart';

class AnimalStorageService {
  static const _key = 'abc_animals';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BlockchainService _blockchain = BlockchainService();

  Future<void> initialize() async {
    await _blockchain.initialize();
  }

  Future<List<Animal>> loadAnimals() async {
    try {
      // Try loading from Firebase first
      final snapshot = await _firestore.collection('livestock').get();
      final out = <Animal>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          out.add(Animal.fromMap(data));
        } catch (e) {
          print('Error parsing animal from Firebase: $e');
        }
      }
      print('Loaded ${out.length} animals from Firebase');
      return out;
    } catch (e) {
      print('Error loading animals from Firebase: $e');
      // Fall back to SharedPreferences
      final p = await SharedPreferences.getInstance();
      final raw = p.getStringList(_key) ?? [];
      final out = <Animal>[];
      for (final s in raw) {
        try {
          final m = jsonDecode(s) as Map<String, dynamic>;
          out.add(Animal.fromMap(m));
        } catch (_) {}
      }
      print('Loaded ${out.length} animals from SharedPreferences backup');
      return out;
    }
  }

  Future<void> saveAnimals(List<Animal> animals) async {
    try {
      // Save to Firebase
      final batch = _firestore.batch();
      // Clear existing animals
      final existingAnimals = await _firestore.collection('livestock').get();
      for (final doc in existingAnimals.docs) {
        batch.delete(doc.reference);
      }
      // Add current animals
      for (final animal in animals) {
        final docRef = _firestore.collection('livestock').doc(animal.id);
        batch.set(docRef, animal.toMap());
      }
      await batch.commit();
      print('Saved ${animals.length} animals to Firebase');
    } catch (e) {
      print('Error saving animals to Firebase: $e');
      // Fall back to SharedPreferences
      final p = await SharedPreferences.getInstance();
      await p.setStringList(
          _key, animals.map((a) => jsonEncode(a.toMap())).toList());
      print('Saved ${animals.length} animals to SharedPreferences backup');
    }
  }

  Future<void> addAnimal(Animal a, {String? performedBy = 'system'}) async {
    final list = await loadAnimals();
    list.add(a);
    await saveAnimals(list);

    // Record to blockchain
    final transaction = BlockchainTransaction(
      id: 'animal_add_${DateTime.now().millisecondsSinceEpoch}_${a.id}',
      animalId: a.id,
      transactionType: 'animal_registration',
      data: {
        'species': a.species,
        'breed': a.breed,
        'age': a.age,
        'farmerId': a.farmerId,
      },
      timestamp: DateTime.now(),
      performedBy: performedBy ?? 'system',
    );

    await _blockchain.addTransaction(transaction);
    await _blockchain.mineBlock();
  }

  Future<void> deleteAnimalAt(int idx, {String? performedBy = 'system'}) async {
    final list = await loadAnimals();
    if (idx >= 0 && idx < list.length) {
      final animal = list[idx];

      // Record deletion to blockchain before removing
      final transaction = BlockchainTransaction(
        id: 'animal_delete_${DateTime.now().millisecondsSinceEpoch}_${animal.id}',
        animalId: animal.id,
        transactionType: 'animal_deletion',
        data: {
          'reason': 'deleted_by_user',
          'species': animal.species,
          'breed': animal.breed,
        },
        timestamp: DateTime.now(),
        performedBy: performedBy ?? 'system',
      );

      await _blockchain.addTransaction(transaction);
      await _blockchain.mineBlock();

      list.removeAt(idx);
      await saveAnimals(list);
    }
  }

  Future<void> updateAnimal(Animal updated,
      {String? performedBy = 'system'}) async {
    final list = await loadAnimals();
    final index = list.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      final originalAnimal = list[index];

      // Record update to blockchain
      final transaction = BlockchainTransaction(
        id: 'animal_update_${DateTime.now().millisecondsSinceEpoch}_${updated.id}',
        animalId: updated.id,
        transactionType: 'animal_update',
        data: {
          'changes': _getAnimalChanges(originalAnimal, updated),
          'previousState': {
            'lastDrug': originalAnimal.lastDrug,
            'lastDosage': originalAnimal.lastDosage,
            'withdrawalEnd': originalAnimal.withdrawalEnd,
            'mrlStatus': originalAnimal.mrlStatus,
          },
          'newState': {
            'lastDrug': updated.lastDrug,
            'lastDosage': updated.lastDosage,
            'withdrawalEnd': updated.withdrawalEnd,
            'mrlStatus': updated.mrlStatus,
          },
        },
        timestamp: DateTime.now(),
        performedBy: performedBy ?? 'system',
      );

      await _blockchain.addTransaction(transaction);
      await _blockchain.mineBlock();

      list[index] = updated;
      await saveAnimals(list);
    }
  }

  Future<void> recordTreatment(TreatmentRecord treatment, String animalId,
      {String? performedBy = 'system'}) async {
    // Record treatment to blockchain
    final transaction = BlockchainTransaction.fromTreatmentRecord(
      treatment,
      animalId,
      performedBy ?? 'system',
    );

    await _blockchain.addTransaction(transaction);
    await _blockchain.mineBlock();
  }

  Future<void> recordHealthCheck(Animal animal,
      {String? performedBy = 'system'}) async {
    // Record health check to blockchain
    final transaction = BlockchainTransaction.fromHealthCheck(
      animal,
      performedBy ?? 'system',
    );

    await _blockchain.addTransaction(transaction);
    await _blockchain.mineBlock();
  }

  Future<String> generateCertificateOfAuthenticity(String animalId) async {
    return await _blockchain.generateCertificateOfAuthenticity(animalId);
  }

  Future<List<BlockchainTransaction>> getAnimalBlockchainHistory(
      String animalId) async {
    return _blockchain.getAnimalTransactions(animalId);
  }

  Future<Map<String, dynamic>> getBlockchainStatistics() async {
    return _blockchain.getStatistics();
  }

  Future<String> exportBlockchainData() async {
    return _blockchain.exportBlockchain();
  }

  Future<bool> importBlockchainData(String jsonData) async {
    return await _blockchain.importBlockchain(jsonData);
  }

  Future<bool> verifyBlockchainIntegrity() async {
    return _blockchain.verifyChain();
  }

  Future<void> printDatabaseStructure() async {
    try {
      print('=== FIREBASE DATABASE STRUCTURE ===');

      // Get all collections
      final collections = await _firestore.collectionGroup('').get();
      print('Available collections: livestock');

      // Get livestock collection documents
      final livestockSnapshot = await _firestore.collection('livestock').get();
      print('\n=== LIVESTOCK COLLECTION ===');
      print('Total documents: ${livestockSnapshot.docs.length}');

      for (final doc in livestockSnapshot.docs) {
        print('\n--- Document ID: ${doc.id} ---');
        final data = doc.data();
        print('Fields:');
        data.forEach((key, value) {
          if (value is List) {
            print('  $key: List with ${value.length} items');
            if (value.isNotEmpty && value.first is Map) {
              print(
                  '    Sample item keys: ${(value.first as Map).keys.join(', ')}');
            }
          } else if (value is Map) {
            print('  $key: Map with keys: ${value.keys.join(', ')}');
          } else {
            print('  $key: $value (${value.runtimeType})');
          }
        });
      }

      print('\n=== STRUCTURE SUMMARY ===');
      print('Main collection: livestock');
      print(
          'Document structure: Complex animal records with nested treatment history, health data, etc.');
      print('Data types: Strings, numbers, dates, nested objects, arrays');
    } catch (e) {
      print('Error printing database structure: $e');
    }
  }

  Map<String, dynamic> _getAnimalChanges(Animal original, Animal updated) {
    final changes = <String, dynamic>{};

    if (original.lastDrug != updated.lastDrug) {
      changes['lastDrug'] = {'from': original.lastDrug, 'to': updated.lastDrug};
    }
    if (original.lastDosage != updated.lastDosage) {
      changes['lastDosage'] = {
        'from': original.lastDosage,
        'to': updated.lastDosage
      };
    }
    if (original.withdrawalEnd != updated.withdrawalEnd) {
      changes['withdrawalEnd'] = {
        'from': original.withdrawalEnd,
        'to': updated.withdrawalEnd
      };
    }
    if (original.mrlStatus != updated.mrlStatus) {
      changes['mrlStatus'] = {
        'from': original.mrlStatus,
        'to': updated.mrlStatus
      };
    }
    if (original.currentMRL != updated.currentMRL) {
      changes['currentMRL'] = {
        'from': original.currentMRL,
        'to': updated.currentMRL
      };
    }

    return changes;
  }
}
