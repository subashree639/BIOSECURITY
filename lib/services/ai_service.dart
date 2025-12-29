import 'dart:math';
import '../models/animal.dart';

// AI Service for Veterinary Intelligence
class AIService {
  static const String _apiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _apiKey = 'YOUR_OPENAI_API_KEY'; // Replace with actual key

  // Treatment Recommendation Engine
  Future<List<AITreatmentRecommendation>> getTreatmentRecommendations(
    Animal animal,
    String symptoms,
    String? imageUrl,
  ) async {
    try {
      // Analyze animal health data
      final healthAnalysis = await _analyzeHealthData(animal);
      final patternAnalysis = await _analyzeHealthPatterns(animal);
      final riskAssessment = await _assessHealthRisks(animal);

      // Generate AI-powered recommendations
      final recommendations = await _generateAIRecommendations(
        animal,
        symptoms,
        healthAnalysis,
        patternAnalysis,
        riskAssessment,
        imageUrl,
      );

      return recommendations;
    } catch (e) {
      // Fallback to rule-based recommendations
      return _generateFallbackRecommendations(animal, symptoms);
    }
  }

  // Overloaded method for list of animals
  Future<List<Map<String, dynamic>>> getTreatmentRecommendationsForList(List<Animal> animals) async {
    final allRecommendations = <Map<String, dynamic>>[];

    for (final animal in animals) {
      try {
        final recommendations = await getTreatmentRecommendations(animal, 'General health check', null);
        allRecommendations.add({
          'animal_id': animal.id,
          'animal_name': '${animal.species} - ${animal.breed}',
          'recommendations': recommendations.map((rec) => {
            'title': rec.condition,
            'description': rec.recommendedTreatment,
            'confidence': rec.confidenceScore,
          }).toList(),
        });
      } catch (e) {
        // Skip animals with errors
        continue;
      }
    }

    return allRecommendations;
  }

  // Image Analysis for Health Assessment
  Future<ImageAnalysisResult> analyzeAnimalImage(
    String imageUrl,
    String animalId,
  ) async {
    try {
      // Simulate AI image analysis (replace with actual ML model)
      final analysisData = await _performImageAnalysis(imageUrl);

      return ImageAnalysisResult(
        imageUrl: imageUrl,
        analysisDate: DateTime.now(),
        analysisData: analysisData,
        conditionDetected: _detectConditionFromAnalysis(analysisData),
        confidenceScore: _calculateConfidenceScore(analysisData),
        recommendations: _generateImageBasedRecommendations(analysisData),
      );
    } catch (e) {
      throw Exception('Image analysis failed: $e');
    }
  }

  // Health Pattern Recognition
  Future<Map<String, dynamic>> analyzeHealthPatterns(Animal animal) async {
    final patterns = <String, dynamic>{};

    // Weight pattern analysis
    if (animal.weightHistory != null && animal.weightHistory!.length >= 3) {
      patterns['weight_trend'] = _analyzeWeightTrend(animal.weightHistory!);
    }

    // Treatment pattern analysis
    if (animal.treatmentHistory != null && animal.treatmentHistory!.length >= 2) {
      patterns['treatment_patterns'] = _analyzeTreatmentPatterns(animal.treatmentHistory!);
    }

    // Health note pattern analysis
    if (animal.healthNotes != null && animal.healthNotes!.length >= 3) {
      patterns['health_note_patterns'] = _analyzeHealthNotePatterns(animal.healthNotes!);
    }

    return patterns;
  }

  // Predictive Health Risk Assessment
  Future<List<String>> assessHealthRisks(Animal animal) async {
    final risks = <String>[];

    // Age-based risks
    final ageRisks = _assessAgeBasedRisks(animal);
    risks.addAll(ageRisks);

    // Breed-specific risks
    if (animal.geneticProfile?.inheritedTraits != null) {
      final breedRisks = _assessBreedBasedRisks(animal.geneticProfile!.inheritedTraits!);
      risks.addAll(breedRisks);
    }

    // Treatment history risks
    if (animal.treatmentHistory != null) {
      final treatmentRisks = _assessTreatmentBasedRisks(animal.treatmentHistory!);
      risks.addAll(treatmentRisks);
    }

    // Environmental risks
    if (animal.environmentalData != null) {
      final envRisks = _assessEnvironmentalRisks(animal.environmentalData!);
      risks.addAll(envRisks);
    }

    return risks;
  }

  // Calculate Health Score
  Future<double> calculateHealthScore(Animal animal) async {
    double score = 50.0; // Base score

    // Age factor
    final ageFactor = _calculateAgeHealthFactor(animal.ageInMonths);
    score += ageFactor;

    // Treatment history factor
    if (animal.treatmentHistory != null) {
      final treatmentFactor = _calculateTreatmentHealthFactor(animal.treatmentHistory!);
      score += treatmentFactor;
    }

    // Vaccination factor
    if (animal.vaccinationHistory != null) {
      final vaccinationFactor = _calculateVaccinationHealthFactor(animal.vaccinationHistory!);
      score += vaccinationFactor;
    }

    // Weight trend factor
    if (animal.weightHistory != null && animal.weightHistory!.length >= 2) {
      final weightFactor = _calculateWeightHealthFactor(animal.weightHistory!);
      score += weightFactor;
    }

    // Reproductive health factor
    if (animal.reproductiveData != null) {
      final reproductiveFactor = _calculateReproductiveHealthFactor(animal.reproductiveData!);
      score += reproductiveFactor;
    }

    // Clamp score between 0 and 100
    return max(0.0, min(100.0, score));
  }

  // Private helper methods

  Future<Map<String, dynamic>> _analyzeHealthData(Animal animal) async {
    return {
      'overall_health': animal.healthScore ?? 50.0,
      'active_treatments': animal.hasActiveTreatment,
      'recent_vaccinations': animal.vaccinationHistory?.length ?? 0,
      'pregnancy_status': animal.isPregnant,
      'age_category': _getAgeCategory(animal.ageInMonths),
      'risk_factors': await assessHealthRisks(animal),
    };
  }

  Future<Map<String, dynamic>> _analyzeHealthPatterns(Animal animal) async {
    return await analyzeHealthPatterns(animal);
  }

  Future<List<AITreatmentRecommendation>> _generateAIRecommendations(
    Animal animal,
    String symptoms,
    Map<String, dynamic> healthAnalysis,
    Map<String, dynamic> patternAnalysis,
    List<String> risks,
    String? imageUrl,
  ) async {
    final recommendations = <AITreatmentRecommendation>[];

    // Primary recommendation based on symptoms
    final primaryRec = await _generatePrimaryRecommendation(animal, symptoms, healthAnalysis);
    if (primaryRec != null) {
      recommendations.add(primaryRec);
    }

    // Pattern-based recommendations
    final patternRecs = _generatePatternBasedRecommendations(patternAnalysis);
    recommendations.addAll(patternRecs);

    // Risk-based preventive recommendations
    final riskRecs = _generateRiskBasedRecommendations(risks);
    recommendations.addAll(riskRecs);

    // Image-based recommendations (if available)
    if (imageUrl != null) {
      final imageRecs = await _generateImageBasedRecommendationsFromUrl(imageUrl, animal);
      recommendations.addAll(imageRecs);
    }

    return recommendations.take(5).toList(); // Limit to top 5 recommendations
  }

  Future<AITreatmentRecommendation?> _generatePrimaryRecommendation(
    Animal animal,
    String symptoms,
    Map<String, dynamic> healthAnalysis,
  ) async {
    // This would integrate with a real AI service
    // For now, return a mock recommendation
    return AITreatmentRecommendation(
      recommendationId: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      condition: symptoms,
      recommendedTreatment: _getRecommendedTreatmentForSymptoms(symptoms, animal.species),
      dosage: _calculateDosage(animal),
      confidenceScore: 0.85,
      generatedAt: DateTime.now(),
      reasoning: 'Based on reported symptoms and animal health history',
      alternativeTreatments: ['Alternative treatment 1', 'Alternative treatment 2'],
      supportingData: healthAnalysis,
    );
  }

  List<AITreatmentRecommendation> _generatePatternBasedRecommendations(
    Map<String, dynamic> patternAnalysis,
  ) {
    final recommendations = <AITreatmentRecommendation>[];

    // Weight trend recommendations
    if (patternAnalysis['weight_trend'] == 'declining') {
      recommendations.add(AITreatmentRecommendation(
        recommendationId: 'pattern_weight_${DateTime.now().millisecondsSinceEpoch}',
        condition: 'Weight Loss Pattern',
        recommendedTreatment: 'Nutritional Assessment',
        dosage: 'Consult veterinarian',
        confidenceScore: 0.75,
        generatedAt: DateTime.now(),
        reasoning: 'Detected declining weight trend over multiple measurements',
      ));
    }

    return recommendations;
  }

  List<AITreatmentRecommendation> _generateRiskBasedRecommendations(List<String> risks) {
    final recommendations = <AITreatmentRecommendation>[];

    for (final risk in risks.take(3)) { // Limit to top 3 risks
      recommendations.add(AITreatmentRecommendation(
        recommendationId: 'risk_${DateTime.now().millisecondsSinceEpoch}_${risk.hashCode}',
        condition: risk,
        recommendedTreatment: 'Preventive Care',
        dosage: 'Schedule veterinary consultation',
        confidenceScore: 0.70,
        generatedAt: DateTime.now(),
        reasoning: 'Proactive measure based on identified risk factor',
      ));
    }

    return recommendations;
  }

  Future<Map<String, dynamic>> _performImageAnalysis(String imageUrl) async {
    // Simulate image analysis (replace with actual ML model)
    return {
      'detected_features': ['healthy_coat', 'normal_posture', 'clear_eyes'],
      'confidence_scores': {'overall_health': 0.85},
      'potential_issues': [],
      'recommendations': ['Continue current care regimen'],
    };
  }

  String? _detectConditionFromAnalysis(Map<String, dynamic> analysis) {
    final issues = analysis['potential_issues'] as List<dynamic>?;
    return issues?.isNotEmpty == true ? issues?.first?.toString() : null;
  }

  double _calculateConfidenceScore(Map<String, dynamic> analysis) {
    return (analysis['confidence_scores']?['overall_health'] as num?)?.toDouble() ?? 0.5;
  }

  List<String> _generateImageBasedRecommendations(Map<String, dynamic> analysis) {
    return (analysis['recommendations'] as List<dynamic>?)?.cast<String>() ?? [];
  }

  Future<List<AITreatmentRecommendation>> _generateImageBasedRecommendationsFromUrl(
    String imageUrl,
    Animal animal,
  ) async {
    final analysis = await analyzeAnimalImage(imageUrl, animal.id);
    final recommendations = <AITreatmentRecommendation>[];

    if (analysis.conditionDetected != null) {
      recommendations.add(AITreatmentRecommendation(
        recommendationId: 'image_${DateTime.now().millisecondsSinceEpoch}',
        condition: analysis.conditionDetected!,
        recommendedTreatment: 'Further Examination Required',
        dosage: 'Consult veterinarian',
        confidenceScore: analysis.confidenceScore ?? 0.6,
        generatedAt: DateTime.now(),
        reasoning: 'Detected via image analysis',
        supportingData: analysis.analysisData,
      ));
    }

    return recommendations;
  }

  List<AITreatmentRecommendation> _generateFallbackRecommendations(
    Animal animal,
    String symptoms,
  ) {
    // Rule-based fallback recommendations
    return [
      AITreatmentRecommendation(
        recommendationId: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
        condition: symptoms,
        recommendedTreatment: 'General Supportive Care',
        dosage: 'Consult veterinarian for specific dosage',
        confidenceScore: 0.5,
        generatedAt: DateTime.now(),
        reasoning: 'Fallback recommendation - consult professional',
      ),
    ];
  }

  // Helper methods for analysis

  String _analyzeWeightTrend(List<WeightRecord> weights) {
    if (weights.length < 2) return 'insufficient_data';

    final recent = weights.sublist(max(0, weights.length - 5));
    final avgRecent = recent.map((w) => w.weight).reduce((a, b) => a + b) / recent.length;

    final older = weights.sublist(0, min(5, weights.length));
    final avgOlder = older.map((w) => w.weight).reduce((a, b) => a + b) / older.length;

    final change = ((avgRecent - avgOlder) / avgOlder) * 100;

    if (change > 5) return 'increasing';
    if (change < -5) return 'declining';
    return 'stable';
  }

  Map<String, dynamic> _analyzeTreatmentPatterns(List<TreatmentRecord> treatments) {
    final patterns = <String, dynamic>{};

    // Frequency analysis
    final treatmentFrequency = _calculateTreatmentFrequency(treatments);
    patterns['frequency'] = treatmentFrequency;

    // Common conditions
    final commonConditions = _findCommonConditions(treatments);
    patterns['common_conditions'] = commonConditions;

    // Seasonal patterns
    final seasonalPatterns = _analyzeSeasonalPatterns(treatments);
    patterns['seasonal_patterns'] = seasonalPatterns;

    return patterns;
  }

  Map<String, dynamic> _analyzeHealthNotePatterns(List<HealthNote> notes) {
    final patterns = <String, dynamic>{};

    // Severity trends
    final severityTrend = _calculateSeverityTrend(notes);
    patterns['severity_trend'] = severityTrend;

    // Category distribution
    final categoryDistribution = _calculateCategoryDistribution(notes);
    patterns['category_distribution'] = categoryDistribution;

    return patterns;
  }

  List<String> _assessAgeBasedRisks(Animal animal) {
    final risks = <String>[];
    final age = animal.ageInMonths;

    if (age < 6) risks.add('Young animal - higher susceptibility to infections');
    if (age > 120) risks.add('Senior animal - age-related health concerns');
    if (age > 60 && animal.species == 'Cow') risks.add('Potential reproductive issues');

    return risks;
  }

  List<String> _assessBreedBasedRisks(List<String> traits) {
    final risks = <String>[];

    if (traits.contains('susceptible_to_mastitis')) {
      risks.add('Breed predisposition to mastitis');
    }
    if (traits.contains('heat_stress_susceptible')) {
      risks.add('Susceptible to heat stress');
    }

    return risks;
  }

  List<String> _assessTreatmentBasedRisks(List<TreatmentRecord> treatments) {
    final risks = <String>[];

    // Check for frequent antibiotic use
    final antibioticTreatments = treatments.where((t) =>
      t.drugName.toLowerCase().contains('antibiotic') ||
      t.drugName.toLowerCase().contains('penicillin') ||
      t.drugName.toLowerCase().contains('tetracycline')
    ).length;

    if (antibioticTreatments > 3) {
      risks.add('Frequent antibiotic use - monitor for resistance');
    }

    return risks;
  }

  List<String> _assessEnvironmentalRisks(EnvironmentalData data) {
    final risks = <String>[];

    if (data.temperature != null && data.temperature! > 30) {
      risks.add('High temperature - heat stress risk');
    }
    if (data.humidity != null && data.humidity! > 80) {
      risks.add('High humidity - respiratory issues possible');
    }

    return risks;
  }

  double _calculateAgeHealthFactor(int ageInMonths) {
    if (ageInMonths < 3) return -10; // Very young
    if (ageInMonths < 12) return -5; // Young
    if (ageInMonths > 120) return -15; // Senior
    return 10; // Prime age
  }

  double _calculateTreatmentHealthFactor(List<TreatmentRecord> treatments) {
    if (treatments.isEmpty) return 15; // No treatments = good health
    if (treatments.length > 10) return -20; // Frequent treatments
    return 5; // Moderate treatment history
  }

  double _calculateVaccinationHealthFactor(List<VaccinationRecord> vaccinations) {
    final recentVaccinations = vaccinations.where((v) =>
      v.dateAdministered.isAfter(DateTime.now().subtract(Duration(days: 365)))
    ).length;

    if (recentVaccinations >= 3) return 15;
    if (recentVaccinations >= 1) return 10;
    return -5;
  }

  double _calculateWeightHealthFactor(List<WeightRecord> weights) {
    final trend = _analyzeWeightTrend(weights);
    switch (trend) {
      case 'increasing': return 10;
      case 'stable': return 5;
      case 'declining': return -15;
      default: return 0;
    }
  }

  double _calculateReproductiveHealthFactor(ReproductiveData data) {
    if (data.isPregnant) return 5;
    if (data.reproductiveStatus == 'cycling') return 10;
    return 0;
  }

  String _getAgeCategory(int ageInMonths) {
    if (ageInMonths < 3) return 'calf';
    if (ageInMonths < 12) return 'young';
    if (ageInMonths < 36) return 'adult';
    return 'senior';
  }

  String _getRecommendedTreatmentForSymptoms(String symptoms, String species) {
    // Simple rule-based treatment suggestions
    final symptom = symptoms.toLowerCase();

    if (symptom.contains('fever') || symptom.contains('temperature')) {
      return 'Antipyretic medication and supportive care';
    }
    if (symptom.contains('diarrhea') || symptom.contains('diarrhoea')) {
      return 'Electrolyte therapy and probiotics';
    }
    if (symptom.contains('cough') || symptom.contains('respiratory')) {
      return 'Bronchodilators and anti-inflammatory medication';
    }

    return 'Supportive care and veterinary consultation';
  }

  String _calculateDosage(Animal animal) {
    // Basic dosage calculation based on weight
    final weight = animal.latestWeight;
    if (weight > 0) {
      return 'Dosage based on ${weight}kg body weight - consult veterinarian';
    }
    return 'Consult veterinarian for appropriate dosage';
  }

  Map<String, dynamic> _calculateTreatmentFrequency(List<TreatmentRecord> treatments) {
    final now = DateTime.now();
    final last30Days = treatments.where((t) =>
      t.dateAdministered.isAfter(now.subtract(Duration(days: 30)))
    ).length;

    final last90Days = treatments.where((t) =>
      t.dateAdministered.isAfter(now.subtract(Duration(days: 90)))
    ).length;

    return {
      'last_30_days': last30Days,
      'last_90_days': last90Days,
      'frequency_level': last30Days > 2 ? 'high' : last30Days > 0 ? 'moderate' : 'low',
    };
  }

  List<String> _findCommonConditions(List<TreatmentRecord> treatments) {
    final conditionCount = <String, int>{};

    for (final treatment in treatments) {
      final condition = treatment.condition.toLowerCase();
      conditionCount[condition] = (conditionCount[condition] ?? 0) + 1;
    }

    return conditionCount.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key)
        .toList();
  }

  Map<String, dynamic> _analyzeSeasonalPatterns(List<TreatmentRecord> treatments) {
    final seasonalCount = <String, int>{'winter': 0, 'spring': 0, 'summer': 0, 'autumn': 0};

    for (final treatment in treatments) {
      final month = treatment.dateAdministered.month;
      if (month >= 12 || month <= 2) seasonalCount['winter'] = seasonalCount['winter']! + 1;
      else if (month >= 3 && month <= 5) seasonalCount['spring'] = seasonalCount['spring']! + 1;
      else if (month >= 6 && month <= 8) seasonalCount['summer'] = seasonalCount['summer']! + 1;
      else seasonalCount['autumn'] = seasonalCount['autumn']! + 1;
    }

    return seasonalCount;
  }

  String _calculateSeverityTrend(List<HealthNote> notes) {
    if (notes.length < 3) return 'insufficient_data';

    final recent = notes.sublist(max(0, notes.length - 5));
    final avgRecentSeverity = recent.map((n) => n.severity).reduce((a, b) => a + b) / recent.length;

    final older = notes.sublist(0, min(5, notes.length));
    final avgOlderSeverity = older.map((n) => n.severity).reduce((a, b) => a + b) / older.length;

    if (avgRecentSeverity > avgOlderSeverity + 1) return 'increasing';
    if (avgRecentSeverity < avgOlderSeverity - 1) return 'decreasing';
    return 'stable';
  }

  Map<String, int> _calculateCategoryDistribution(List<HealthNote> notes) {
    final distribution = <String, int>{};

    for (final note in notes) {
      distribution[note.category] = (distribution[note.category] ?? 0) + 1;
    }

    return distribution;
  }

  // Additional methods for dashboard integration

  Future<Map<String, dynamic>> analyzeAnimalHealth(Animal animal) async {
    final healthScore = await calculateHealthScore(animal);
    final risks = await assessHealthRisks(animal);
    final patterns = await analyzeHealthPatterns(animal);

    return {
      'healthScore': healthScore,
      'recommendations': [
        {
          'title': 'Regular Health Check',
          'description': 'Schedule routine veterinary examination',
        },
        {
          'title': 'Nutrition Assessment',
          'description': 'Review feeding regimen and nutritional needs',
        },
        if (risks.isNotEmpty) {
          'title': 'Risk Mitigation',
          'description': 'Address identified health risk factors',
        },
      ],
      'preventiveCare': [
        {
          'title': 'Vaccination Schedule',
          'description': 'Ensure up-to-date vaccinations',
        },
        {
          'title': 'Parasite Control',
          'description': 'Regular deworming and parasite prevention',
        },
        {
          'title': 'Dental Care',
          'description': 'Monitor dental health and cleaning needs',
        },
      ],
    };
  }

  Future<List<Map<String, dynamic>>> getVeterinaryInsights(List<Animal> animals) async {
    final insights = <Map<String, dynamic>>[];

    // Overall farm health insights
    final totalAnimals = animals.length;
    final healthyAnimals = animals.where((a) => (a.healthScore ?? 0) >= 70).length;
    final sickAnimals = animals.where((a) => (a.healthScore ?? 100) < 70).length;

    insights.add({
      'title': 'Farm Health Overview',
      'description': '$healthyAnimals out of $totalAnimals animals are in good health',
      'type': 'overview',
    });

    if (sickAnimals > 0) {
      insights.add({
        'title': 'Health Alert',
        'description': '$sickAnimals animals require attention',
        'type': 'alert',
      });
    }

    // Treatment pattern insights
    final recentTreatments = animals.where((a) =>
      a.treatmentHistory != null &&
      a.treatmentHistory!.any((t) =>
        t.dateAdministered.isAfter(DateTime.now().subtract(Duration(days: 30)))
      )
    ).length;

    if (recentTreatments > 0) {
      insights.add({
        'title': 'Recent Treatments',
        'description': '$recentTreatments animals treated in the last 30 days',
        'type': 'treatment',
      });
    }

    // Seasonal insights
    final currentMonth = DateTime.now().month;
    String season = 'winter';
    if (currentMonth >= 3 && currentMonth <= 5) season = 'spring';
    else if (currentMonth >= 6 && currentMonth <= 8) season = 'summer';
    else if (currentMonth >= 9 && currentMonth <= 11) season = 'autumn';

    insights.add({
      'title': 'Seasonal Care',
      'description': 'Monitor animals for $season-specific health concerns',
      'type': 'seasonal',
    });

    return insights;
  }

  Future<List<String>> _assessHealthRisks(Animal animal) async {
    return await assessHealthRisks(animal);
  }
}