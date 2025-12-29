import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'database/database_helper.dart';
import 'services/auth_service.dart';
import 'services/animal_storage.dart';
import 'services/language_service.dart';
import 'models/user.dart';
import 'models/farm.dart';
import 'models/animal.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database; // Initialize DB

  // Initialize language service
  final languageService = LanguageService();
  await languageService.initialize();

  // Create sample users for testing different roles
  await _createSampleUsers();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageService),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _createSampleUsers() async {
  final db = DatabaseHelper();
  var users = await db.getUsers();

  print('Existing users count: ${users.length}');
  for (var user in users) {
    print('User: ${user.name}, mobile: ${user.mobileNumber}, role: ${user.role}');
  }

  // Always recreate sample users for testing - delete all existing users first
  if (users.isNotEmpty) {
    await db.database.then((db) => db.delete('users'));
    print('Deleted existing users');
  }
  users = []; // Ensure clean slate

  final sampleUsers = [
    User(
      name: 'farmer1',
      role: 'farmer',
      mobileNumber: '9876543210', // Single farmer with this mobile
      otp: '111111',
      hashPassword: null, // No password for farmers
      pinHash: null,
      createdAt: DateTime.now(),
    ),
  ];

  for (final user in sampleUsers) {
    try {
      int id = await db.insertUser(user);
      print('Created user: ${user.name} with mobile: ${user.mobileNumber}, ID: $id');

      // Create sample farm for farmer
      if (user.role == 'farmer') {
        final farm = Farm(
          ownerName: user.name,
          farmName: 'Sample Farm',
          species: 'pig',
          size: 50,
          createdBy: id,
          locationText: 'Sample Location',
          latitude: 12.9716,
          longitude: 77.5946,
        );
        int farmId = await db.insertFarm(farm);
        print('Created farm for ${user.name}: ${farm.farmName}, ID: $farmId');

        // Create sample animals
        final animals = [
          Animal(
            id: 'animal_${DateTime.now().millisecondsSinceEpoch}',
            species: 'pig',
            age: '2 years',
            breed: 'Landrace',
            farmerId: id.toString(),
            createdAt: DateTime.now(),
            gender: 'female',
            weight: 120.5,
            healthStatus: 'healthy',
            tagNumber: 'PIG001',
          ),
          Animal(
            id: 'animal_${DateTime.now().millisecondsSinceEpoch + 1}',
            species: 'pig',
            age: '1.5 years',
            breed: 'Yorkshire',
            farmerId: id.toString(),
            createdAt: DateTime.now(),
            gender: 'male',
            weight: 110.0,
            healthStatus: 'healthy',
            tagNumber: 'PIG002',
          ),
        ];

        for (final animal in animals) {
          await AnimalStorageService().addAnimal(animal);
          print('Created animal for ${user.name}: ${animal.species} ${animal.breed}');
        }
      }
    } catch (e) {
      print('Error creating user ${user.name}: $e');
    }
  }

  print('Sample users creation completed');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            title: 'Digital Farm Biosecurity',
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: languageService.supportedLocales,
            locale: languageService.currentLocale,
            theme: ThemeData(
              primaryColor: const Color(0xFF116530), // deep green
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF116530),
                secondary: const Color(0xFFF4A261), // saffron/orange
              ),
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF116530),
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF116530),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

