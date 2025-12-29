import 'dart:math' as math;

// --- Medicine dataset (from Tkinter spec) ---
const Map<String, Map<String, Map<String, dynamic>>> MEDICINES = {
  'Cow': {
    'Penicillin': {
      'milk_days': 3,
      'meat_days': 7,
      'usage': 'Bacterial infections',
      'dosage_mg_per_kg': 10
    },
    'Oxytetracycline': {
      'milk_days': 4,
      'meat_days': 28,
      'usage': 'Respiratory infections',
      'dosage_mg_per_kg': 10
    },
    'Ampicillin': {
      'milk_days': 3,
      'meat_days': 14,
      'usage': 'Mastitis & pneumonia',
      'dosage_mg_per_kg': 7
    },
  },
  'Goat': {
    'Oxytetracycline': {
      'milk_days': 7,
      'meat_days': 28,
      'usage': 'Pneumonia & bacterial diseases',
      'dosage_mg_per_kg': 10
    },
    'Penicillin': {
      'milk_days': 3,
      'meat_days': 14,
      'usage': 'Bacterial infections',
      'dosage_mg_per_kg': 10
    },
    'Florfenicol': {
      'milk_days': null,
      'meat_days': 14,
      'usage': 'Respiratory infections',
      'dosage_mg_per_kg': 20
    },
  },
  'Pig': {
    'Oxytetracycline': {
      'milk_days': null,
      'meat_days': 7,
      'usage': 'Bacterial infections',
      'dosage_mg_per_kg': 10
    },
    'Sulfadimidine': {
      'milk_days': null,
      'meat_days': 7,
      'usage': 'Bacterial diarrhea',
      'dosage_mg_per_kg': 100
    },
    'Penicillin-streptomycin': {
      'milk_days': null,
      'meat_days': 7,
      'usage': 'Mixed infections',
      'dosage_mg_per_kg': 10
    },
  },
  'Chicken': {
    'Amoxicillin': {
      'eggs_days': 3,
      'meat_days': 7,
      'usage': 'Gut infections',
      'dosage_mg_per_kg': 10
    },
    'Enrofloxacin': {
      'eggs_days': 5,
      'meat_days': 7,
      'usage': 'Respiratory & gut infections',
      'dosage_mg_per_kg': 10
    },
    'Tetracycline': {
      'eggs_days': 7,
      'meat_days': 14,
      'usage': 'Broad spectrum infections',
      'dosage_mg_per_kg': 15
    },
  },
  'Duck': {
    'Amoxicillin': {
      'eggs_days': null,
      'meat_days': 7,
      'usage': 'Gut infections',
      'dosage_mg_per_kg': 10
    },
    'Doxycycline': {
      'eggs_days': null,
      'meat_days': 10,
      'usage': 'Respiratory infections',
      'dosage_mg_per_kg': 10
    },
    'Enrofloxacin': {
      'eggs_days': null,
      'meat_days': 7,
      'usage': 'Septicemia',
      'dosage_mg_per_kg': 10
    },
  }
};

// --- Settings for MRL model ---
const double initialResidueScale = 0.5;
const double safeThreshold = 1.0;

// Helper to compute withdrawal days according to product type
int? getWithdrawalDays(Map<String, dynamic> specs, String productType) {
  final lookupKey = '${productType}_days';
  return specs[lookupKey] as int?;
}

// MRL model with exponential decay
double computeMRL(double initialDosageMgPerKg, int daysElapsed, int? withdrawalPeriodDays) {
  double halfLife;
  if (withdrawalPeriodDays == null || withdrawalPeriodDays == 0) {
    halfLife = 7.0; // nominal half-life
  } else {
    halfLife = math.max(1.0, withdrawalPeriodDays / 3.0);
  }

  final initialMRL = initialDosageMgPerKg * initialResidueScale;
  final mrlToday = initialMRL * math.pow(0.5, daysElapsed / halfLife);
  return math.max(0.0, mrlToday);
}

// Extension method for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}