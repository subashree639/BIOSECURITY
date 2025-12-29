import 'dart:math' as math;
import '../models/animal.dart';
import '../data/medicine_data.dart';

/// Advanced Analytics Service for AMU trend analysis and reporting
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  /// Generate comprehensive AMU trend analysis
  Future<Map<String, dynamic>> generateAMUTrendAnalysis({
    required List<Animal> animals,
    required DateTime startDate,
    required DateTime endDate,
    String? species,
    String? region,
  }) async {
    print('DEBUG: Analytics Service - Starting generateAMUTrendAnalysis with ${animals.length} animals');

    final analysis = <String, dynamic>{
      'period': {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'duration_days': endDate.difference(startDate).inDays,
      },
      'summary': <String, dynamic>{},
      'trends': <String, dynamic>{},
      'compliance': <String, dynamic>{},
      'recommendations': <String>[],
    };

    // Filter animals by criteria
    final filteredAnimals = animals.where((animal) {
      if (species != null && animal.species != species) return false;
      // Add region filtering if location data is available
      return true;
    }).toList();

    print('DEBUG: Analytics Service - Filtered to ${filteredAnimals.length} animals');

    analysis['summary'] = await _calculateAMUSummary(filteredAnimals, startDate, endDate);
    print('DEBUG: Analytics Service - Summary calculated');

    analysis['trends'] = await _analyzeAMUTrends(filteredAnimals, startDate, endDate);
    print('DEBUG: Analytics Service - Trends analyzed');

    analysis['compliance'] = await _analyzeCompliance(filteredAnimals, startDate, endDate);
    print('DEBUG: Analytics Service - Compliance analyzed');

    analysis['recommendations'] = _generateRecommendations(analysis);
    print('DEBUG: Analytics Service - Recommendations generated');

    print('DEBUG: Analytics Service - Analysis complete, returning data');
    return analysis;
  }

  /// Calculate AMU summary statistics
  Future<Map<String, dynamic>> _calculateAMUSummary(
    List<Animal> animals,
    DateTime startDate,
    DateTime endDate,
  ) async {
    print('DEBUG: Analytics Service - Calculating AMU summary for ${animals.length} animals');

    int totalTreatments = 0;
    int animalsTreated = 0;
    final medicineUsage = <String, int>{};
    final speciesDistribution = <String, int>{};
    double totalDosage = 0.0;
    int complianceIssues = 0;

    for (final animal in animals) {
      speciesDistribution[animal.species] = (speciesDistribution[animal.species] ?? 0) + 1;

      if (animal.treatmentHistory != null) {
        print('DEBUG: Analytics Service - Animal ${animal.id} has ${animal.treatmentHistory!.length} treatments');

        for (final treatment in animal.treatmentHistory!) {
          if (treatment.dateAdministered.isAfter(startDate) &&
              treatment.dateAdministered.isBefore(endDate)) {

            totalTreatments++;
            medicineUsage[treatment.drugName] = (medicineUsage[treatment.drugName] ?? 0) + 1;

            // Parse dosage
            final dosage = double.tryParse(treatment.dosage.split(' ')[0]) ?? 0.0;
            totalDosage += dosage;

            // Check for compliance issues
            if (_isHighRiskTreatment(treatment, animal)) {
              complianceIssues++;
            }
          }
        }

        if (animal.treatmentHistory!.any((t) =>
            t.dateAdministered.isAfter(startDate) &&
            t.dateAdministered.isBefore(endDate))) {
          animalsTreated++;
        }
      } else {
        print('DEBUG: Analytics Service - Animal ${animal.id} has no treatment history');
      }

      // Check withdrawal period compliance
      if (animal.withdrawalEnd != null) {
        final withdrawalEnd = DateTime.parse(animal.withdrawalEnd!);
        if (withdrawalEnd.isAfter(startDate) && withdrawalEnd.isBefore(endDate)) {
          complianceIssues++;
        }
      }
    }

    final result = {
      'total_animals': animals.length,
      'animals_treated': animalsTreated,
      'total_treatments': totalTreatments,
      'treatment_rate': animals.isNotEmpty ? (animalsTreated / animals.length) * 100.0 : 0.0,
      'medicine_usage': medicineUsage,
      'species_distribution': speciesDistribution,
      'average_dosage_per_treatment': totalTreatments > 0 ? totalDosage / totalTreatments : 0.0,
      'compliance_issues': complianceIssues,
    };

    print('DEBUG: Analytics Service - Summary result: total_animals=${result['total_animals']}, animals_treated=${result['animals_treated']}, total_treatments=${result['total_treatments']}, medicine_usage_keys=${medicineUsage.keys.length}');

    return result;
  }

  /// Analyze AMU trends over time
  Future<Map<String, dynamic>> _analyzeAMUTrends(
    List<Animal> animals,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final monthlyTrends = <String, Map<String, dynamic>>{};
    final duration = endDate.difference(startDate).inDays;

    // Group treatments by month
    for (final animal in animals) {
      if (animal.treatmentHistory != null) {
        for (final treatment in animal.treatmentHistory!) {
          if (treatment.dateAdministered.isAfter(startDate) &&
              treatment.dateAdministered.isBefore(endDate)) {

            final monthKey = '${treatment.dateAdministered.year}-${treatment.dateAdministered.month.toString().padLeft(2, '0')}';

            if (!monthlyTrends.containsKey(monthKey)) {
              monthlyTrends[monthKey] = {
                'treatments': 0,
                'medicines': <String, int>{},
                'species': <String, int>{},
              };
            }

            monthlyTrends[monthKey]!['treatments'] = monthlyTrends[monthKey]!['treatments'] + 1;
            monthlyTrends[monthKey]!['medicines'][treatment.drugName] =
                (monthlyTrends[monthKey]!['medicines'][treatment.drugName] ?? 0) + 1;
            monthlyTrends[monthKey]!['species'][animal.species] =
                (monthlyTrends[monthKey]!['species'][animal.species] ?? 0) + 1;
          }
        }
      }
    }

    // Calculate trend indicators
    final trendAnalysis = _calculateTrendIndicators(monthlyTrends);

    return {
      'monthly_data': monthlyTrends,
      'trend_analysis': trendAnalysis,
      'seasonal_patterns': _identifySeasonalPatterns(monthlyTrends),
      'peak_usage_periods': _identifyPeakPeriods(monthlyTrends),
    };
  }

  /// Analyze compliance patterns
  Future<Map<String, dynamic>> _analyzeCompliance(
    List<Animal> animals,
    DateTime startDate,
    DateTime endDate,
  ) async {
    int totalAnimals = animals.length;
    int compliantAnimals = 0;
    int nonCompliantAnimals = 0;
    final complianceIssues = <String, int>{};
    final riskFactors = <String, int>{};

    for (final animal in animals) {
      bool isCompliant = true;
      final issues = <String>[];

      // Check withdrawal period compliance
      if (animal.withdrawalEnd != null) {
        final withdrawalEnd = DateTime.parse(animal.withdrawalEnd!);
        final now = DateTime.now();

        if (withdrawalEnd.isAfter(now)) {
          isCompliant = false;
          issues.add('active_withdrawal_period');
          complianceIssues['active_withdrawal_period'] =
              (complianceIssues['active_withdrawal_period'] ?? 0) + 1;
        }
      }

      // Check treatment frequency
      if (animal.treatmentHistory != null) {
        final recentTreatments = animal.treatmentHistory!
            .where((t) => t.dateAdministered.isAfter(startDate))
            .toList();

        if (recentTreatments.length > 5) {
          isCompliant = false;
          issues.add('frequent_treatments');
          complianceIssues['frequent_treatments'] =
              (complianceIssues['frequent_treatments'] ?? 0) + 1;
          riskFactors['over_treatment'] = (riskFactors['over_treatment'] ?? 0) + 1;
        }

        // Check for high-risk medicine usage
        for (final treatment in recentTreatments) {
          if (_isHighRiskMedicine(treatment.drugName)) {
            riskFactors['high_risk_medicine'] = (riskFactors['high_risk_medicine'] ?? 0) + 1;
          }
        }
      }

      // Check documentation completeness
      if (animal.treatmentHistory == null || animal.treatmentHistory!.isEmpty) {
        riskFactors['poor_documentation'] = (riskFactors['poor_documentation'] ?? 0) + 1;
      }

      if (isCompliant) {
        compliantAnimals++;
      } else {
        nonCompliantAnimals++;
      }
    }

    return {
      'compliance_rate': totalAnimals > 0 ? (compliantAnimals / totalAnimals) * 100.0 : 0.0,
      'compliant_animals': compliantAnimals,
      'non_compliant_animals': nonCompliantAnimals,
      'compliance_issues': complianceIssues,
      'risk_factors': riskFactors,
      'critical_issues': _identifyCriticalIssues(complianceIssues),
    };
  }

  /// Calculate trend indicators
  Map<String, dynamic> _calculateTrendIndicators(Map<String, Map<String, dynamic>> monthlyData) {
    if (monthlyData.isEmpty) return {};

    final months = monthlyData.keys.toList()..sort();
    final treatmentCounts = months.map((m) => monthlyData[m]!['treatments'] as int).toList();

    // Calculate moving averages
    final movingAverage3 = _calculateMovingAverage(treatmentCounts, 3);
    final movingAverage6 = _calculateMovingAverage(treatmentCounts, 6);

    // Calculate trend direction
    String trendDirection = 'stable';
    if (treatmentCounts.length >= 3) {
      final recent = treatmentCounts.sublist(treatmentCounts.length - 3);
      final earlier = treatmentCounts.sublist(0, math.min(3, treatmentCounts.length));

      final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
      final earlierAvg = earlier.reduce((a, b) => a + b) / earlier.length;

      if (recentAvg > earlierAvg * 1.1) {
        trendDirection = 'increasing';
      } else if (recentAvg < earlierAvg * 0.9) {
        trendDirection = 'decreasing';
      }
    }

    return {
      'trend_direction': trendDirection,
      'moving_average_3_month': movingAverage3,
      'moving_average_6_month': movingAverage6,
      'volatility': _calculateVolatility(treatmentCounts).toDouble(),
      'seasonal_variation': _calculateSeasonalVariation(monthlyData).toDouble(),
    };
  }

  /// Calculate moving average
  List<double> _calculateMovingAverage(List<int> data, int period) {
    final result = <double>[];
    for (int i = period - 1; i < data.length; i++) {
      final sum = data.sublist(i - period + 1, i + 1).reduce((a, b) => a + b);
      result.add(sum / period);
    }
    return result;
  }

  /// Calculate volatility (coefficient of variation)
  double _calculateVolatility(List<int> data) {
    if (data.isEmpty) return 0.0;

    final mean = data.reduce((a, b) => a + b) / data.length;
    if (mean == 0) return 0.0;

    final variance = data.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / data.length;
    final stdDev = math.sqrt(variance);

    return stdDev / mean;
  }

  /// Calculate seasonal variation
  double _calculateSeasonalVariation(Map<String, Map<String, dynamic>> monthlyData) {
    final monthlyAverages = <int, double>{};

    for (final entry in monthlyData.entries) {
      final month = DateTime.parse('${entry.key}-01').month;
      final treatments = entry.value['treatments'] as int;

      monthlyAverages[month] = (monthlyAverages[month] ?? 0) + treatments;
    }

    if (monthlyAverages.isEmpty) return 0.0;

    final values = monthlyAverages.values.toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    final max = values.reduce(math.max);
    final min = values.reduce(math.min);

    return mean > 0 ? ((max - min) / mean) * 100 : 0.0;
  }

  /// Identify seasonal patterns
  Map<String, dynamic> _identifySeasonalPatterns(Map<String, Map<String, dynamic>> monthlyData) {
    final patterns = <String, dynamic>{};
    final monthlyTotals = <int, int>{};

    // Aggregate by month
    for (final entry in monthlyData.entries) {
      final month = DateTime.parse('${entry.key}-01').month;
      final treatments = entry.value['treatments'] as int;
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + treatments;
    }

    if (monthlyTotals.isEmpty) return patterns;

    // Find peak and low months
    final sortedMonths = monthlyTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    patterns['peak_months'] = sortedMonths.take(2).map((e) => _monthName(e.key)).toList();
    patterns['low_months'] = sortedMonths.reversed.take(2).map((e) => _monthName(e.key)).toList();

    return patterns;
  }

  /// Identify peak usage periods
  List<String> _identifyPeakPeriods(Map<String, Map<String, dynamic>> monthlyData) {
    final peaks = <String>[];

    for (final entry in monthlyData.entries) {
      final treatments = entry.value['treatments'] as int;
      final medicines = entry.value['medicines'] as Map<String, int>;

      if (treatments > 10) { // Threshold for peak period
        peaks.add('${entry.key}: $treatments treatments');
      }
    }

    return peaks;
  }

  /// Identify critical compliance issues
  List<String> _identifyCriticalIssues(Map<String, int> complianceIssues) {
    final critical = <String>[];

    if ((complianceIssues['active_withdrawal_period'] ?? 0) > 5) {
      critical.add('High number of animals in withdrawal period');
    }

    if ((complianceIssues['frequent_treatments'] ?? 0) > 3) {
      critical.add('Excessive treatment frequency detected');
    }

    return critical;
  }

  /// Generate recommendations based on analysis
  List<String> _generateRecommendations(Map<String, dynamic> analysis) {
    final recommendations = <String>[];
    final summary = analysis['summary'] as Map<String, dynamic>;
    final trends = analysis['trends'] as Map<String, dynamic>;
    final compliance = analysis['compliance'] as Map<String, dynamic>;

    // Treatment rate recommendations
    final treatmentRate = summary['treatment_rate'] as double;
    if (treatmentRate > 30) {
      recommendations.add('High treatment rate detected. Consider reviewing treatment protocols.');
    } else if (treatmentRate < 5) {
      recommendations.add('Low treatment rate. Ensure adequate health monitoring.');
    }

    // Trend-based recommendations
    final trendDirection = trends['trend_direction'] as String?;
    if (trendDirection == 'increasing') {
      recommendations.add('Increasing AMU trend. Implement antibiotic stewardship measures.');
    }

    // Compliance recommendations
    final complianceRate = compliance['compliance_rate'] as double;
    if (complianceRate < 80) {
      recommendations.add('Compliance rate below 80%. Review and improve compliance procedures.');
    }

    // Seasonal recommendations
    final seasonalPatterns = trends['seasonal_patterns'] as Map<String, dynamic>?;
    if (seasonalPatterns != null && seasonalPatterns['peak_months'] != null) {
      final peakMonths = seasonalPatterns['peak_months'] as List<String>;
      recommendations.add('Prepare for increased treatment needs during ${peakMonths.join(' and ')}.');
    }

    return recommendations;
  }

  /// Helper methods
  bool _isHighRiskTreatment(TreatmentRecord treatment, Animal animal) {
    // High-risk indicators
    if (_isHighRiskMedicine(treatment.drugName)) return true;

    // Check dosage against recommended
    final recommendedDosage = _getRecommendedDosage(treatment.drugName, animal.species);
    final actualDosage = double.tryParse(treatment.dosage.split(' ')[0]) ?? 0.0;

    if (recommendedDosage > 0 && actualDosage > recommendedDosage * 1.5) {
      return true; // Dosage exceeds 150% of recommended
    }

    return false;
  }

  bool _isHighRiskMedicine(String medicineName) {
    final highRiskMedicines = [
      'colistin', 'fluoroquinolones', 'third_generation_cephalosporins'
    ];

    return highRiskMedicines.any((risk) =>
        medicineName.toLowerCase().contains(risk.toLowerCase()));
  }

  double _getRecommendedDosage(String medicine, String species) {
    final speciesMedicines = MEDICINES[species];
    if (speciesMedicines == null) return 0.0;

    final medicineData = speciesMedicines[medicine];
    if (medicineData == null) return 0.0;

    final dosage = medicineData['dosage_mg_per_kg'];
    if (dosage is int) return dosage.toDouble();
    if (dosage is double) return dosage;
    return 0.0;
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  /// Generate predictive analytics
  Future<Map<String, dynamic>> generatePredictiveAnalytics({
    required List<Animal> animals,
    required int predictionMonths,
  }) async {
    final predictions = <String, dynamic>{};

    // Predict future treatment needs based on historical data
    final historicalData = await _analyzeHistoricalPatterns(animals);

    predictions['treatment_forecast'] = _forecastTreatmentNeeds(historicalData, predictionMonths);
    predictions['risk_predictions'] = _predictHealthRisks(animals);
    predictions['resource_needs'] = _predictResourceRequirements(historicalData, predictionMonths);

    return predictions;
  }

  Future<Map<String, dynamic>> _analyzeHistoricalPatterns(List<Animal> animals) async {
    final patterns = <String, dynamic>{};
    // Implementation for historical pattern analysis
    return patterns;
  }

  Map<String, dynamic> _forecastTreatmentNeeds(Map<String, dynamic> historicalData, int months) {
    // Simple forecasting based on moving averages
    return {'forecasted_treatments': 0, 'confidence_level': 0.0};
  }

  Map<String, dynamic> _predictHealthRisks(List<Animal> animals) {
    final risks = <String, int>{};
    // Implementation for risk prediction
    return risks;
  }

  Map<String, dynamic> _predictResourceRequirements(Map<String, dynamic> historicalData, int months) {
    // Predict medicine and resource needs
    return {'medicines_needed': <String, int>{}, 'estimated_cost': 0.0};
  }
}