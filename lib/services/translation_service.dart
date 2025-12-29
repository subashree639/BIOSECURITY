import 'package:flutter/material.dart';
import 'firestore_service.dart';
import '../models/firestore_models.dart' as firestore;
import '../l10n/app_localizations.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._();
  factory TranslationService() => _instance;
  TranslationService._();

  final FirestoreService _firestoreService = FirestoreService();
  firestore.Translations? _firestoreTranslations;

  /// Load translations from Firestore
  Future<void> loadTranslations() async {
    try {
      _firestoreTranslations = await _firestoreService.getTranslations();
      print(
          'Loaded translations from Firestore: ${_firestoreTranslations != null}');
    } catch (e) {
      print('Error loading translations from Firestore: $e');
      _firestoreTranslations = null;
    }
  }

  /// Get a translated string, falling back to ARB translations if not found in Firestore
  String getTranslation(BuildContext context, String key,
      {Map<String, dynamic>? args}) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return key;

    // Try to get from Firestore translations first
    if (_firestoreTranslations != null) {
      final languageCode = localizations.localeName
          .split('_')[0]; // Get language code (e.g., 'en' from 'en_US')
      final firestoreTranslations =
          _firestoreTranslations!.getTranslations(languageCode);

      if (firestoreTranslations.containsKey(key)) {
        String translation = firestoreTranslations[key]!;

        // Apply arguments if provided
        if (args != null) {
          args.forEach((argKey, argValue) {
            translation =
                translation.replaceAll('{$argKey}', argValue.toString());
          });
        }

        return translation;
      }
    }

    // Fall back to ARB translations
    return _getArbTranslation(localizations, key, args);
  }

  /// Get translation from ARB files
  String _getArbTranslation(
      AppLocalizations localizations, String key, Map<String, dynamic>? args) {
    // Provide basic fallbacks for common keys
    final fallbackTranslations = {
      'dashboard': 'Dashboard',
      'farmers': 'Farmers',
      'livestock': 'Livestock',
      'withdrawal': 'Withdrawal Periods',
      'prescriptions': 'Prescriptions',
      'compliance': 'Compliance Reports',
      'alerts': 'Alerts',
      'audit': 'Audit Trail',
      'help': 'Help & Support',
      'dashboard-title': 'Dashboard Overview',
      'refresh': 'Refresh Data',
      'total-livestock': 'Total Livestock',
      'active-withdrawal': 'Active Withdrawal',
      'compliance-rate': 'Compliance Rate',
      'pending-reviews': 'Pending Reviews',
      'livestock-monitoring': 'Livestock Monitoring Overview',
      'district-compliance': 'Regional Compliance',
      'area-breakdown': 'Area-wise Compliance Breakdown',
      'active-periods': 'Active Withdrawal Periods',
      'recent-alerts': 'Recent Alerts',
      'loading': 'Loading...',
    };

    if (fallbackTranslations.containsKey(key)) {
      return fallbackTranslations[key]!;
    }

    // For keys with arguments, try to find the corresponding ARB method
    if (args != null && args.isNotEmpty) {
      return _getParameterizedTranslation(localizations, key, args);
    }

    return key; // Return key as fallback
  }

  /// Handle parameterized translations from ARB
  String _getParameterizedTranslation(
      AppLocalizations localizations, String key, Map<String, dynamic> args) {
    switch (key) {
      case 'animalIdLabel':
        return localizations.animalIdLabel(args['id']);
      case 'shareId':
        return localizations.shareId(args['id']);
      case 'consultAnimal':
        return localizations.consultAnimal(args['id']);
      case 'lastMedicineDosage':
        return localizations.lastMedicineDosage(
            args['dosage'], args['end'], args['medicine']);
      case 'ageWithValue':
        return localizations.ageWithValue(args['age']);
      case 'prescriptionForSpecies':
        return localizations.prescriptionForSpecies(args['species']);
      case 'prescribedByLabel':
        return localizations.prescribedByLabel(args['vet']);
      case 'speciesAndBreedLabel':
        return localizations.speciesAndBreedLabel(
            args['species'], args['breed']);
      case 'prescribedDateLabel':
        return localizations.prescribedDateLabel(args['date']);
      case 'withdrawalEndsLabel':
        return localizations.withdrawalEndsLabel(args['date']);
      case 'currentMrlLabel':
        return localizations.currentMrlLabel(args['mrl']);
      case 'statusLabel':
        return localizations.statusLabel(args['status']);
      case 'consultingVetLabel':
        return localizations.consultingVetLabel(args['vet']);
      case 'vetIdLabel':
        return localizations.vetIdLabel(args['id']);
      case 'qrGenerationDateLabel':
        return localizations.qrGenerationDateLabel(args['date']);
      case 'speciesBreedDisplay':
        return localizations.speciesBreedDisplay(
            args['species'], args['breed']);
      case 'idDisplay':
        return localizations.idDisplay(args['id']);
      case 'endsDateDisplay':
        return localizations.endsDateDisplay(args['date']);
      case 'farmerIdLabel':
        return localizations.farmerIdLabel(args['id']);
      case 'generatedDateLabel':
        return localizations.generatedDateLabel(args['date']);
      case 'validUntilLabel':
        return localizations.validUntilLabel(args['date']);
      default:
        return key;
    }
  }

  /// Check if translations are loaded
  bool get isLoaded => _firestoreTranslations != null;

  /// Get current Firestore translations
  firestore.Translations? get firestoreTranslations => _firestoreTranslations;

  /// Refresh translations from Firestore
  Future<void> refreshTranslations() async {
    await loadTranslations();
  }
}

final translationService = TranslationService();
