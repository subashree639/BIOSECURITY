import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/farm.dart';
import '../models/assessment.dart';
import '../models/consultation.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getApplicationDocumentsDirectory().then((dir) => dir.path), 'dfm_v4.db');
    return await openDatabase(
      path,
      version: 9,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add animals table for version 2
      await db.execute('''
        CREATE TABLE animals (
          id TEXT PRIMARY KEY,
          species TEXT NOT NULL,
          age TEXT NOT NULL,
          breed TEXT NOT NULL,
          farmer_id TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (farmer_id) REFERENCES users (id)
        )
      ''');
    }
    if (oldVersion < 3) {
      // Add photo_path column for version 3
      await db.execute('ALTER TABLE animals ADD COLUMN photo_path TEXT');
    }
    if (oldVersion < 4) {
      // Add mobile_number column for version 4
      await db.execute('ALTER TABLE users ADD COLUMN mobile_number TEXT');
    }
    if (oldVersion < 5) {
      // Add comprehensive animal tracking fields for version 5
      await db.execute('ALTER TABLE animals ADD COLUMN gender TEXT');
      await db.execute('ALTER TABLE animals ADD COLUMN weight REAL');
      await db.execute('ALTER TABLE animals ADD COLUMN birth_date TEXT');
      await db.execute('ALTER TABLE animals ADD COLUMN health_status TEXT');
      await db.execute('ALTER TABLE animals ADD COLUMN vaccination_status TEXT');
      await db.execute('ALTER TABLE animals ADD COLUMN medical_history TEXT');
      await db.execute('ALTER TABLE animals ADD COLUMN notes TEXT');
      await db.execute('ALTER TABLE animals ADD COLUMN is_pregnant INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE animals ADD COLUMN last_vaccination_date TEXT');
      await db.execute('ALTER TABLE animals ADD COLUMN next_vaccination_date TEXT');
      await db.execute('ALTER TABLE animals ADD COLUMN tag_number TEXT');
      await db.execute('ALTER TABLE animals ADD COLUMN mother_id TEXT');
      await db.execute('ALTER TABLE animals ADD COLUMN father_id TEXT');
    }
    if (oldVersion < 6) {
      // Add email and vet_id columns for version 6
      await db.execute('ALTER TABLE users ADD COLUMN email TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN vet_id TEXT');
    }
    if (oldVersion < 7) {
      // Add consultations table for version 7
      await db.execute('''
        CREATE TABLE consultations (
          id TEXT PRIMARY KEY,
          animal_id TEXT NOT NULL,
          animal_name TEXT NOT NULL,
          species TEXT NOT NULL,
          disease TEXT NOT NULL,
          consultation_date TEXT NOT NULL,
          vet_name TEXT NOT NULL,
          vet_id TEXT NOT NULL,
          diagnosis TEXT NOT NULL,
          treatment TEXT NOT NULL,
          status TEXT NOT NULL,
          follow_up_date TEXT NOT NULL,
          notes TEXT,
          created_at TEXT,
          FOREIGN KEY (animal_id) REFERENCES animals (id)
        )
      ''');
    }
    if (oldVersion < 8) {
      // Add mobile_number and otp columns for version 8
      await db.execute('ALTER TABLE users ADD COLUMN mobile_number TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN otp TEXT');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        mobile_number TEXT,
        email TEXT,
        vet_id TEXT,
        hash_password TEXT,
        pin_hash TEXT,
        otp TEXT,
        biometric_enabled INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        last_login TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE farms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_name TEXT NOT NULL,
        farm_name TEXT NOT NULL,
        location_text TEXT,
        latitude REAL,
        longitude REAL,
        species TEXT NOT NULL,
        size INTEGER NOT NULL,
        photos TEXT,
        created_by INTEGER NOT NULL,
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE assessment_templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        questions TEXT NOT NULL,
        created_by INTEGER NOT NULL,
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE assessments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farm_id INTEGER NOT NULL,
        template_id INTEGER NOT NULL,
        answers TEXT NOT NULL,
        score REAL NOT NULL,
        risk_level TEXT NOT NULL,
        created_at TEXT NOT NULL,
        attachments TEXT,
        FOREIGN KEY (farm_id) REFERENCES farms (id),
        FOREIGN KEY (template_id) REFERENCES assessment_templates (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE trainings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        video_paths TEXT,
        quiz TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE training_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        training_id INTEGER NOT NULL,
        score REAL,
        completed_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (training_id) REFERENCES trainings (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE compliance_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farm_id INTEGER NOT NULL,
        task_type TEXT NOT NULL,
        date TEXT NOT NULL,
        performed_by INTEGER NOT NULL,
        photos TEXT,
        notes TEXT,
        FOREIGN KEY (farm_id) REFERENCES farms (id),
        FOREIGN KEY (performed_by) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE incidents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farm_id INTEGER NOT NULL,
        incident_type TEXT NOT NULL,
        date TEXT NOT NULL,
        affected_count INTEGER,
        symptoms TEXT,
        photos TEXT,
        reported_by INTEGER NOT NULL,
        FOREIGN KEY (farm_id) REFERENCES farms (id),
        FOREIGN KEY (reported_by) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_id INTEGER,
        level TEXT NOT NULL,
        message TEXT NOT NULL,
        acknowledged_by INTEGER,
        acknowledged_at TEXT,
        FOREIGN KEY (acknowledged_by) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        action TEXT NOT NULL,
        meta TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE animals (
        id TEXT PRIMARY KEY,
        species TEXT NOT NULL,
        age TEXT NOT NULL,
        breed TEXT NOT NULL,
        farmer_id TEXT,
        created_at TEXT NOT NULL,
        photo_path TEXT,
        gender TEXT,
        weight REAL,
        birth_date TEXT,
        health_status TEXT,
        vaccination_status TEXT,
        medical_history TEXT,
        notes TEXT,
        is_pregnant INTEGER DEFAULT 0,
        last_vaccination_date TEXT,
        next_vaccination_date TEXT,
        tag_number TEXT,
        mother_id TEXT,
        father_id TEXT,
        FOREIGN KEY (farmer_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_path TEXT NOT NULL,
        mime TEXT,
        referenced_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE consultations (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        animal_name TEXT NOT NULL,
        species TEXT NOT NULL,
        disease TEXT NOT NULL,
        consultation_date TEXT NOT NULL,
        vet_name TEXT NOT NULL,
        vet_id TEXT NOT NULL,
        diagnosis TEXT NOT NULL,
        treatment TEXT NOT NULL,
        status TEXT NOT NULL,
        follow_up_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT,
        FOREIGN KEY (animal_id) REFERENCES animals (id)
      )
    ''');
  }

  // User methods
  Future<int> insertUser(User user) async {
    try {
      Database db = await database;
      return await db.insert('users', user.toMap());
    } catch (e) {
      debugPrint('Error inserting user: $e');
      rethrow;
    }
  }

  Future<List<User>> getUsers() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query('users');
      return List.generate(maps.length, (i) => User.fromMap(maps[i]));
    } catch (e) {
      debugPrint('Error getting users: $e');
      return [];
    }
  }

  // Farm methods
  Future<int> insertFarm(Farm farm) async {
    Database db = await database;
    return await db.insert('farms', farm.toMap());
  }

  Future<List<Farm>> getFarms() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('farms');
    return List.generate(maps.length, (i) => Farm.fromMap(maps[i]));
  }

  // Assessment methods
  Future<int> insertAssessment(Assessment assessment) async {
    Database db = await database;
    return await db.insert('assessments', assessment.toMap());
  }

  Future<List<Assessment>> getAssessments() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('assessments');
    return List.generate(maps.length, (i) => Assessment.fromMap(maps[i]));
  }

  // Update farm
  Future<int> updateFarm(Farm farm) async {
    if (farm.id == null) {
      throw Exception('Cannot update farm: farm ID is null');
    }
    Database db = await database;
    return await db.update(
      'farms',
      farm.toMap(),
      where: 'id = ?',
      whereArgs: [farm.id],
    );
  }

  // Consultation methods
  Future<int> insertConsultation(Consultation consultation) async {
    try {
      Database db = await database;
      return await db.insert('consultations', consultation.toMap());
    } catch (e) {
      debugPrint('Error inserting consultation: $e');
      rethrow;
    }
  }

  Future<List<Consultation>> getConsultations() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query('consultations', orderBy: 'created_at DESC');
      return List.generate(maps.length, (i) => Consultation.fromMap(maps[i]));
    } catch (e) {
      debugPrint('Error getting consultations: $e');
      return [];
    }
  }

  Future<List<Consultation>> getConsultationsByAnimal(String animalId) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'consultations',
        where: 'animal_id = ?',
        whereArgs: [animalId],
        orderBy: 'created_at DESC',
      );
      return List.generate(maps.length, (i) => Consultation.fromMap(maps[i]));
    } catch (e) {
      debugPrint('Error getting consultations by animal: $e');
      return [];
    }
  }

  Future<List<Consultation>> getConsultationsByVet(String vetId) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'consultations',
        where: 'vet_id = ?',
        whereArgs: [vetId],
        orderBy: 'created_at DESC',
      );
      return List.generate(maps.length, (i) => Consultation.fromMap(maps[i]));
    } catch (e) {
      debugPrint('Error getting consultations by vet: $e');
      return [];
    }
  }

  Future<List<Consultation>> getConsultationsByAnimals(List<String> animalIds) async {
    try {
      if (animalIds.isEmpty) return [];

      Database db = await database;
      String placeholders = List.filled(animalIds.length, '?').join(',');
      List<Map<String, dynamic>> maps = await db.query(
        'consultations',
        where: 'animal_id IN ($placeholders)',
        whereArgs: animalIds,
        orderBy: 'created_at DESC',
      );
      return List.generate(maps.length, (i) => Consultation.fromMap(maps[i]));
    } catch (e) {
      debugPrint('Error getting consultations by animals: $e');
      return [];
    }
  }
}