import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'qr_certificate_service.dart';
import 'l10n/app_localizations.dart';

// Services
import 'services/auth_service.dart';
import 'services/otp_service.dart';
import 'services/animal_storage.dart';
import 'services/alert_service.dart';
import 'services/translation_service.dart';
import 'services/firestore_service.dart';

// Screens

import 'screens/splash_screen.dart';
import 'screens/voice_login_page.dart';
import 'screens/firebase_test_screen.dart';
import 'language_selection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ABCApp());
}

/// Root app class
class ABCApp extends StatefulWidget {
  @override
  ABCAppState createState() => ABCAppState();
}

class ABCAppState extends State<ABCApp> {
  Locale _locale = Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    print('Initializing services...');

    // Initialize authentication service first
    print('Initializing auth service...');
    await auth.init();
    print('Auth service initialized');

    await qrService.init();
    await otpService.init();

    // Initialize blockchain service
    final animalStorage = AnimalStorageService();
    await animalStorage.initialize();

    // Initialize alert service
    final alertService = AlertService();
    await alertService.initialize();

    // Initialize Firestore default data
    await firestoreService.initializeDefaultData();

    // Initialize translation service
    await translationService.loadTranslations();

    print('All services initialized');
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('selected_language') ?? 'en';
    setState(() {
      _locale = Locale(savedLanguage);
    });
  }

  void changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABC (Antibiotic Check)',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('hi'),
        Locale('ta'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Color(0xFFF8FAFC),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
              height: 1.5),
          bodyMedium: TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w500,
              height: 1.4),
          titleMedium: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.2),
          titleLarge: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: 0.3),
          headlineSmall: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.2),
          headlineMedium: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
              fontSize: 24,
              letterSpacing: 0.3),
          displaySmall: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              letterSpacing: 0.5),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1),
          hintStyle:
              TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF22C55E), width: 2.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color(0xFF16A34A),
            textStyle: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.5),
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: Color(0xFF16A34A).withOpacity(0.3),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 8,
          shadowColor: Color(0xFF000000).withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.zero,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF16A34A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/language': (context) => LanguageSelectionPage(),
        '/firebase-test': (context) => FirebaseTestScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (_) => VoiceLoginPage());
        }
        return null;
      },
    );
  }
}

// Global instances
final auth = AuthService();
final qrService = QRCertificateService();
final otpService = OTPService();

// Medicine data
const MEDICINES = {
  'Cow': {
    'Amoxicillin': {
      'dosage_mg_per_kg': 7.0,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 14,
      'eggs_withdrawal_days': 0
    },
    'Ampicillin': {
      'dosage_mg_per_kg': 7.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 15, 'meat_withdrawal_days': 15},
        'injection': {'milk_withdrawal_days': 6, 'meat_withdrawal_days': 6}
      }
    },
    'Chlortetracycline': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 10, 'meat_withdrawal_days': 10},
        'injection': {'milk_withdrawal_days': 10, 'meat_withdrawal_days': 10}
      }
    },
    'Dihydrostreptomycine': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 10, 'meat_withdrawal_days': 10},
        'injection': {'milk_withdrawal_days': 30, 'meat_withdrawal_days': 30}
      }
    },
    'Erythromycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'injection': {'milk_withdrawal_days': 14, 'meat_withdrawal_days': 14}
      }
    },
    'Oxytetracycline': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 7, 'meat_withdrawal_days': 7},
        'injection': {'milk_withdrawal_days': 22, 'meat_withdrawal_days': 22}
      }
    },
    'Procaine penicillin': {
      'dosage_mg_per_kg': 7.0,
      'withdrawal_periods': {
        'injection': {'milk_withdrawal_days': 10, 'meat_withdrawal_days': 10}
      }
    },
    'Sulphamezathine': {
      'dosage_mg_per_kg': 100.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 7, 'meat_withdrawal_days': 7}
      }
    },
    'Dihydrostreptomycine (Intramammary)': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'intramammary': {'milk_withdrawal_days': 4, 'meat_withdrawal_days': 4}
      }
    },
    'Streptomycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 2, 'meat_withdrawal_days': 2}
      }
    },
    'Neomycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 1, 'meat_withdrawal_days': 1}
      }
    },
    'Ivermectin': {
      'dosage_mg_per_kg': 0.2,
      'withdrawal_periods': {
        'subcutaneous': {'milk_withdrawal_days': 49, 'meat_withdrawal_days': 66}
      },
      'notes': 'Withdrawal period range: 49–66 days for meat'
    },
    'Penicillin': {
      'dosage_mg_per_kg': 7.0,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 10,
      'eggs_withdrawal_days': 0
    },
    'Ceftiofur': {
      'dosage_mg_per_kg': 1.1,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 4,
      'eggs_withdrawal_days': 0
    },
    'Florfenicol': {
      'dosage_mg_per_kg': 20.0,
      'milk_withdrawal_days': 2,
      'meat_withdrawal_days': 28,
      'eggs_withdrawal_days': 0
    },
    'Enrofloxacin': {
      'dosage_mg_per_kg': 2.5,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 14,
      'eggs_withdrawal_days': 0
    },
    'Tilmicosin': {
      'dosage_mg_per_kg': 10.0,
      'milk_withdrawal_days': 14,
      'meat_withdrawal_days': 42,
      'eggs_withdrawal_days': 0
    },
    'Tulathromycin': {
      'dosage_mg_per_kg': 2.5,
      'milk_withdrawal_days': 5,
      'meat_withdrawal_days': 18,
      'eggs_withdrawal_days': 0
    },
  },
  'Buffalo': {
    'Amoxicillin': {
      'dosage_mg_per_kg': 7.0,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 14,
      'eggs_withdrawal_days': 0
    },
    'Ampicillin': {
      'dosage_mg_per_kg': 7.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 15, 'meat_withdrawal_days': 15},
        'injection': {'milk_withdrawal_days': 6, 'meat_withdrawal_days': 6}
      }
    },
    'Chlortetracycline': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 10, 'meat_withdrawal_days': 10},
        'injection': {'milk_withdrawal_days': 10, 'meat_withdrawal_days': 10}
      }
    },
    'Dihydrostreptomycine': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 10, 'meat_withdrawal_days': 10},
        'injection': {'milk_withdrawal_days': 30, 'meat_withdrawal_days': 30}
      }
    },
    'Erythromycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'injection': {'milk_withdrawal_days': 14, 'meat_withdrawal_days': 14}
      }
    },
    'Oxytetracycline': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 7, 'meat_withdrawal_days': 7},
        'injection': {'milk_withdrawal_days': 22, 'meat_withdrawal_days': 22}
      }
    },
    'Procaine penicillin': {
      'dosage_mg_per_kg': 7.0,
      'withdrawal_periods': {
        'injection': {'milk_withdrawal_days': 10, 'meat_withdrawal_days': 10}
      }
    },
    'Sulphamezathine': {
      'dosage_mg_per_kg': 100.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 7, 'meat_withdrawal_days': 7}
      }
    },
    'Dihydrostreptomycine (Intramammary)': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'intramammary': {'milk_withdrawal_days': 4, 'meat_withdrawal_days': 4}
      }
    },
    'Streptomycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 2, 'meat_withdrawal_days': 2}
      }
    },
    'Neomycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 1, 'meat_withdrawal_days': 1}
      }
    },
    'Ivermectin': {
      'dosage_mg_per_kg': 0.2,
      'withdrawal_periods': {
        'subcutaneous': {'milk_withdrawal_days': 49, 'meat_withdrawal_days': 66}
      },
      'notes': 'Withdrawal period range: 49–66 days for meat'
    },
    'Penicillin': {
      'dosage_mg_per_kg': 7.0,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 10,
      'eggs_withdrawal_days': 0
    },
    'Ceftiofur': {
      'dosage_mg_per_kg': 1.1,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 4,
      'eggs_withdrawal_days': 0
    },
    'Florfenicol': {
      'dosage_mg_per_kg': 20.0,
      'milk_withdrawal_days': 2,
      'meat_withdrawal_days': 28,
      'eggs_withdrawal_days': 0
    },
    'Enrofloxacin': {
      'dosage_mg_per_kg': 2.5,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 14,
      'eggs_withdrawal_days': 0
    },
    'Tilmicosin': {
      'dosage_mg_per_kg': 10.0,
      'milk_withdrawal_days': 14,
      'meat_withdrawal_days': 42,
      'eggs_withdrawal_days': 0
    },
    'Tulathromycin': {
      'dosage_mg_per_kg': 2.5,
      'milk_withdrawal_days': 5,
      'meat_withdrawal_days': 18,
      'eggs_withdrawal_days': 0
    },
  },
  'Goat': {
    'Amoxicillin': {
      'dosage_mg_per_kg': 7.0,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 14,
      'eggs_withdrawal_days': 0
    },
    'Dihydrostreptomycine': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'injection': {'milk_withdrawal_days': 30, 'meat_withdrawal_days': 30}
      }
    },
    'Erythromycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'injection': {'milk_withdrawal_days': 3, 'meat_withdrawal_days': 3}
      }
    },
    'Procaine penicillin G': {
      'dosage_mg_per_kg': 7.0,
      'withdrawal_periods': {
        'injection': {'milk_withdrawal_days': 9, 'meat_withdrawal_days': 9}
      }
    },
    'Chlortetracycline': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 2, 'meat_withdrawal_days': 2}
      }
    },
    'Sulphamezathine': {
      'dosage_mg_per_kg': 100.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 10, 'meat_withdrawal_days': 10},
        'injection': {'milk_withdrawal_days': 10, 'meat_withdrawal_days': 10}
      }
    },
    'Sulphaquinoxaline': {
      'dosage_mg_per_kg': 25.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 10, 'meat_withdrawal_days': 10}
      }
    },
    'Neomycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 2, 'meat_withdrawal_days': 2}
      }
    },
    'Oxytetracycline': {
      'dosage_mg_per_kg': 10.0,
      'milk_withdrawal_days': 7,
      'meat_withdrawal_days': 28,
      'eggs_withdrawal_days': 0
    },
    'Penicillin': {
      'dosage_mg_per_kg': 7.0,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 10,
      'eggs_withdrawal_days': 0
    },
    'Ceftiofur': {
      'dosage_mg_per_kg': 1.1,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 4,
      'eggs_withdrawal_days': 0
    },
    'Florfenicol': {
      'dosage_mg_per_kg': 20.0,
      'milk_withdrawal_days': 2,
      'meat_withdrawal_days': 28,
      'eggs_withdrawal_days': 0
    },
    'Enrofloxacin': {
      'dosage_mg_per_kg': 2.5,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 14,
      'eggs_withdrawal_days': 0
    },
    'Tilmicosin': {
      'dosage_mg_per_kg': 10.0,
      'milk_withdrawal_days': 14,
      'meat_withdrawal_days': 42,
      'eggs_withdrawal_days': 0
    },
    'Tulathromycin': {
      'dosage_mg_per_kg': 2.5,
      'milk_withdrawal_days': 5,
      'meat_withdrawal_days': 18,
      'eggs_withdrawal_days': 0
    },
  },
  'Sheep': {
    'Amoxicillin': {
      'dosage_mg_per_kg': 7.0,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 14,
      'eggs_withdrawal_days': 0
    },
    'Dihydrostreptomycine': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'injection': {'milk_withdrawal_days': 30, 'meat_withdrawal_days': 30}
      }
    },
    'Erythromycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'injection': {'milk_withdrawal_days': 3, 'meat_withdrawal_days': 3}
      }
    },
    'Procaine penicillin G': {
      'dosage_mg_per_kg': 7.0,
      'withdrawal_periods': {
        'injection': {'milk_withdrawal_days': 9, 'meat_withdrawal_days': 9}
      }
    },
    'Chlortetracycline': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 2, 'meat_withdrawal_days': 2}
      }
    },
    'Sulphamezathine': {
      'dosage_mg_per_kg': 100.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 10, 'meat_withdrawal_days': 10},
        'injection': {'milk_withdrawal_days': 10, 'meat_withdrawal_days': 10}
      }
    },
    'Sulphaquinoxaline': {
      'dosage_mg_per_kg': 25.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 10, 'meat_withdrawal_days': 10}
      }
    },
    'Neomycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 2, 'meat_withdrawal_days': 2}
      }
    },
    'Oxytetracycline': {
      'dosage_mg_per_kg': 10.0,
      'milk_withdrawal_days': 7,
      'meat_withdrawal_days': 28,
      'eggs_withdrawal_days': 0
    },
    'Penicillin': {
      'dosage_mg_per_kg': 7.0,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 10,
      'eggs_withdrawal_days': 0
    },
    'Ceftiofur': {
      'dosage_mg_per_kg': 1.1,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 4,
      'eggs_withdrawal_days': 0
    },
    'Florfenicol': {
      'dosage_mg_per_kg': 20.0,
      'milk_withdrawal_days': 2,
      'meat_withdrawal_days': 28,
      'eggs_withdrawal_days': 0
    },
    'Enrofloxacin': {
      'dosage_mg_per_kg': 2.5,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 14,
      'eggs_withdrawal_days': 0
    },
    'Tilmicosin': {
      'dosage_mg_per_kg': 10.0,
      'milk_withdrawal_days': 14,
      'meat_withdrawal_days': 42,
      'eggs_withdrawal_days': 0
    },
    'Tulathromycin': {
      'dosage_mg_per_kg': 2.5,
      'milk_withdrawal_days': 5,
      'meat_withdrawal_days': 18,
      'eggs_withdrawal_days': 0
    },
  },
  'Pig': {
    'Amoxicillin': {
      'dosage_mg_per_kg': 15.0,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 20,
      'eggs_withdrawal_days': 0
    },
    'Streptomycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 0, 'meat_withdrawal_days': 0}
      }
    },
    'Gentamicin': {
      'dosage_mg_per_kg': 5.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 3, 'meat_withdrawal_days': 14},
        'intramuscular': {
          'milk_withdrawal_days': 40,
          'meat_withdrawal_days': 40
        }
      },
      'notes': 'Oral: 3–14 days for meat; Intramuscular: 40 days'
    },
    'Neomycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 3, 'meat_withdrawal_days': 3}
      }
    },
    'Apramycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 28, 'meat_withdrawal_days': 28}
      }
    },
    'Ivermectin': {
      'dosage_mg_per_kg': 0.3,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 5, 'meat_withdrawal_days': 5}
      }
    },
    'Levamisole': {
      'dosage_mg_per_kg': 8.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 3, 'meat_withdrawal_days': 3}
      }
    },
    'Piperazine': {
      'dosage_mg_per_kg': 100.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 21, 'meat_withdrawal_days': 21}
      }
    },
    'Pyrantel tartrate': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 1, 'meat_withdrawal_days': 1}
      }
    },
    'Dichlorvos': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 0, 'meat_withdrawal_days': 0}
      }
    },
    'Fenbendazole': {
      'dosage_mg_per_kg': 5.0,
      'withdrawal_periods': {
        'oral': {'milk_withdrawal_days': 0, 'meat_withdrawal_days': 0}
      }
    },
    'Oxytetracycline': {
      'dosage_mg_per_kg': 20.0,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 8,
      'eggs_withdrawal_days': 0
    },
    'Penicillin': {
      'dosage_mg_per_kg': 15.0,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 15,
      'eggs_withdrawal_days': 0
    },
    'Ceftiofur': {
      'dosage_mg_per_kg': 3.0,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 4,
      'eggs_withdrawal_days': 0
    },
    'Florfenicol': {
      'dosage_mg_per_kg': 15.0,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 18,
      'eggs_withdrawal_days': 0
    },
    'Enrofloxacin': {
      'dosage_mg_per_kg': 2.5,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 14,
      'eggs_withdrawal_days': 0
    },
    'Tilmicosin': {
      'dosage_mg_per_kg': 10.0,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 14,
      'eggs_withdrawal_days': 0
    },
    'Tulathromycin': {
      'dosage_mg_per_kg': 2.5,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 5,
      'eggs_withdrawal_days': 0
    },
  },
  'Poultry': {
    'Amoxicillin': {
      'dosage_mg_per_kg': 10.0,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 1,
      'eggs_withdrawal_days': 1
    },
    'Streptomycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {
          'milk_withdrawal_days': 4,
          'meat_withdrawal_days': 4,
          'eggs_withdrawal_days': 4
        }
      }
    },
    'Gentamicin': {
      'dosage_mg_per_kg': 5.0,
      'withdrawal_periods': {
        'subcutaneous': {
          'milk_withdrawal_days': 35,
          'meat_withdrawal_days': 35,
          'eggs_withdrawal_days': 35
        }
      }
    },
    'Chlortetracycline': {
      'dosage_mg_per_kg': 20.0,
      'withdrawal_periods': {
        'oral': {
          'milk_withdrawal_days': 1,
          'meat_withdrawal_days': 1,
          'eggs_withdrawal_days': 1
        }
      }
    },
    'Erythromycin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {
          'milk_withdrawal_days': 2,
          'meat_withdrawal_days': 2,
          'eggs_withdrawal_days': 2
        }
      }
    },
    'Monensin': {
      'dosage_mg_per_kg': 100.0,
      'withdrawal_periods': {
        'oral': {
          'milk_withdrawal_days': 5,
          'meat_withdrawal_days': 5,
          'eggs_withdrawal_days': 5
        }
      }
    },
    'Tylosine': {
      'dosage_mg_per_kg': 50.0,
      'withdrawal_periods': {
        'oral': {
          'milk_withdrawal_days': 5,
          'meat_withdrawal_days': 5,
          'eggs_withdrawal_days': 5
        }
      }
    },
    'Levamisole': {
      'dosage_mg_per_kg': 25.0,
      'withdrawal_periods': {
        'oral': {
          'milk_withdrawal_days': 0,
          'meat_withdrawal_days': 7,
          'eggs_withdrawal_days': 0
        }
      },
      'notes': 'Withdrawal period: 0–7 days'
    },
    'Ivermectin': {
      'dosage_mg_per_kg': 0.2,
      'withdrawal_periods': {
        'oral': {
          'milk_withdrawal_days': 0,
          'meat_withdrawal_days': 12,
          'eggs_withdrawal_days': 0
        }
      },
      'notes': 'Withdrawal period: 0–12 days'
    },
    'Nicarbazin narasin combination': {
      'dosage_mg_per_kg': 50.0,
      'withdrawal_periods': {
        'oral': {
          'milk_withdrawal_days': 5,
          'meat_withdrawal_days': 5,
          'eggs_withdrawal_days': 5
        }
      }
    },
    'Lasalocid, salinomycin narasin, maduramicin, and semduramicin': {
      'dosage_mg_per_kg': 50.0,
      'withdrawal_periods': {
        'oral': {
          'milk_withdrawal_days': 5,
          'meat_withdrawal_days': 5,
          'eggs_withdrawal_days': 5
        }
      }
    },
    'Ciprofloxacin': {
      'dosage_mg_per_kg': 10.0,
      'withdrawal_periods': {
        'oral': {
          'milk_withdrawal_days': 15,
          'meat_withdrawal_days': 19,
          'eggs_withdrawal_days': 15
        }
      },
      'notes': 'Withdrawal period: 15–19 days for meat'
    },
    'Oxytetracycline': {
      'dosage_mg_per_kg': 20.0,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 5,
      'eggs_withdrawal_days': 8
    },
    'Penicillin': {
      'dosage_mg_per_kg': 10.0,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 4,
      'eggs_withdrawal_days': 1
    },
    'Ceftiofur': {
      'dosage_mg_per_kg': 0.08,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 0,
      'eggs_withdrawal_days': 0
    },
    'Florfenicol': {
      'dosage_mg_per_kg': 10.0,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 7,
      'eggs_withdrawal_days': 0
    },
    'Enrofloxacin': {
      'dosage_mg_per_kg': 10.0,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 10,
      'eggs_withdrawal_days': 10
    },
    'Tilmicosin': {
      'dosage_mg_per_kg': 10.0,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 12,
      'eggs_withdrawal_days': 0
    },
    'Tulathromycin': {
      'dosage_mg_per_kg': 2.5,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 5,
      'eggs_withdrawal_days': 0
    },
  },
  'Other': {
    'Amoxicillin': {
      'dosage_mg_per_kg': 7.0,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 14,
      'eggs_withdrawal_days': 0
    },
    'Oxytetracycline': {
      'dosage_mg_per_kg': 10.0,
      'milk_withdrawal_days': 7,
      'meat_withdrawal_days': 28,
      'eggs_withdrawal_days': 0
    },
    'Penicillin': {
      'dosage_mg_per_kg': 7.0,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 10,
      'eggs_withdrawal_days': 0
    },
    'Ceftiofur': {
      'dosage_mg_per_kg': 1.1,
      'milk_withdrawal_days': 0,
      'meat_withdrawal_days': 4,
      'eggs_withdrawal_days': 0
    },
    'Florfenicol': {
      'dosage_mg_per_kg': 20.0,
      'milk_withdrawal_days': 2,
      'meat_withdrawal_days': 28,
      'eggs_withdrawal_days': 0
    },
    'Enrofloxacin': {
      'dosage_mg_per_kg': 2.5,
      'milk_withdrawal_days': 3,
      'meat_withdrawal_days': 14,
      'eggs_withdrawal_days': 0
    },
    'Tilmicosin': {
      'dosage_mg_per_kg': 10.0,
      'milk_withdrawal_days': 14,
      'meat_withdrawal_days': 42,
      'eggs_withdrawal_days': 0
    },
    'Tulathromycin': {
      'dosage_mg_per_kg': 2.5,
      'milk_withdrawal_days': 5,
      'meat_withdrawal_days': 18,
      'eggs_withdrawal_days': 0
    },
  },
};

// Helper functions
int? getWithdrawalDays(Map<String, dynamic> medicineSpecs, String productType,
    [String? administrationMethod]) {
  // First try the new withdrawal_periods structure
  if (administrationMethod != null &&
      medicineSpecs.containsKey('withdrawal_periods')) {
    final withdrawalPeriods =
        medicineSpecs['withdrawal_periods'] as Map<String, dynamic>?;
    if (withdrawalPeriods != null &&
        withdrawalPeriods.containsKey(administrationMethod)) {
      final methodData =
          withdrawalPeriods[administrationMethod] as Map<String, dynamic>;
      final key = '${productType}_withdrawal_days';
      return methodData[key] as int?;
    }
  }

  // Fall back to the old simple structure
  final key = '${productType}_withdrawal_days';
  return medicineSpecs[key] as int?;
}

double computeMRL(double dosage, int daysElapsed, int? withdrawalDays) {
  if (withdrawalDays == null || withdrawalDays == 0) return 0.0;

  // Simple exponential decay model
  final halfLife = withdrawalDays /
      3.32; // ln(2) ≈ 0.693, so 3.32 half-lives for 99% elimination
  final decayConstant = 0.693 / halfLife;

  return dosage * math.exp(-decayConstant * daysElapsed);
}

const double safeThreshold = 0.05; // MRL threshold in mg/kg

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
