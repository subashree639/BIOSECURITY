import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/animal.dart';

// Regulatory Compliance Service
class RegulatoryService {
  static const String _apiEndpoint = 'https://api.regulatory.gov/v1';

  // Compliance Report Generation
  Future<String> generateComplianceReport({
    required List<Animal> animals,
    required String farmId,
    required DateTime startDate,
    required DateTime endDate,
    required String reportType, // 'monthly', 'quarterly', 'annual'
  }) async {
    try {
      final reportData = await _gatherComplianceData(animals, startDate, endDate);
      final pdfPath = await _generatePDFReport(reportData, farmId, reportType);

      // Submit to regulatory body if required
      await _submitToRegulatoryBody(reportData, reportType);

      return pdfPath;
    } catch (e) {
      throw Exception('Failed to generate compliance report: $e');
    }
  }

  // Antibiotic Usage Tracking
  Future<Map<String, dynamic>> trackAntibioticUsage({
    required List<Animal> animals,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final usage = <String, dynamic>{
      'total_animals_treated': 0,
      'antibiotics_used': <String, int>{},
      'withdrawal_periods': <String, List<DateTime>>{},
      'compliance_status': 'compliant',
      'violations': <String>[],
    };

    for (final animal in animals) {
      if (animal.treatmentHistory != null) {
        for (final treatment in animal.treatmentHistory!) {
          if (treatment.dateAdministered.isAfter(startDate) &&
              treatment.dateAdministered.isBefore(endDate)) {

            // Check if it's an antibiotic treatment
            if (_isAntibiotic(treatment.drugName)) {
              usage['total_animals_treated'] =
                  (usage['total_animals_treated'] as int) + 1;

              final antibiotic = treatment.drugName.toLowerCase();
              usage['antibiotics_used'][antibiotic] =
                  (usage['antibiotics_used'][antibiotic] ?? 0) + 1;

              // Check withdrawal period compliance
              if (animal.productType != null && animal.withdrawalEnd != null) {
                final withdrawalEnd = DateTime.parse(animal.withdrawalEnd!);
                final now = DateTime.now();

                if (withdrawalEnd.isAfter(now)) {
                  usage['withdrawal_periods'][animal.id] =
                      (usage['withdrawal_periods'][animal.id] ?? [])..add(withdrawalEnd);
                } else {
                  // Violation: product consumed during withdrawal period
                  usage['violations'].add(
                    'Animal ${animal.id}: ${animal.productType} consumed during withdrawal period'
                  );
                  usage['compliance_status'] = 'non_compliant';
                }
              }
            }
          }
        }
      }
    }

    return usage;
  }

  // MRL Compliance Monitoring
  Future<List<String>> checkMRLCompliance(List<Animal> animals) async {
    final violations = <String>[];

    for (final animal in animals) {
      if (animal.currentMRL != null && animal.currentMRL! > 0) {
        final mrlLimit = await _getMRLLimit(animal.species, animal.lastDrug ?? '');

        if (animal.currentMRL! > mrlLimit) {
          violations.add(
            'Animal ${animal.id}: MRL violation - ${animal.lastDrug} level ${animal.currentMRL} exceeds limit of $mrlLimit'
          );
        }
      }
    }

    return violations;
  }

  // Export Certificate Generation
  Future<String> generateExportCertificate({
    required Animal animal,
    required String destinationCountry,
    required String exporterName,
    required DateTime exportDate,
  }) async {
    try {
      final certificateData = await _gatherCertificateData(animal, destinationCountry);
      final pdfPath = await _generateExportCertificatePDF(certificateData, exporterName, exportDate);

      return pdfPath;
    } catch (e) {
      throw Exception('Failed to generate export certificate: $e');
    }
  }

  // Audit Trail Management
  Future<void> logAuditEvent({
    required String action,
    required String performedBy,
    required String entityType, // 'animal', 'treatment', 'farm'
    required String entityId,
    required Map<String, dynamic> details,
  }) async {
    final auditEntry = AuditEntry(
      action: action,
      performedBy: performedBy,
      timestamp: DateTime.now(),
      details: details,
    );

    // Store audit entry (implement storage logic)
    await _storeAuditEntry(auditEntry);
  }

  // Regulatory Updates Monitoring
  Future<List<Map<String, dynamic>>> getRegulatoryUpdates({
    required String country,
    required String category, // 'antibiotics', 'mrl', 'export'
  }) async {
    try {
      // This would integrate with regulatory APIs
      // For now, return mock data
      return [
        {
          'title': 'Updated MRL Limits for Tetracycline',
          'description': 'New maximum residue limits effective from Jan 2024',
          'date': DateTime.now().subtract(Duration(days: 30)),
          'category': 'mrl',
          'severity': 'high',
        },
        {
          'title': 'Antibiotic Usage Reporting Requirements',
          'description': 'New quarterly reporting requirements for antibiotic usage',
          'date': DateTime.now().subtract(Duration(days: 15)),
          'category': 'antibiotics',
          'severity': 'medium',
        },
      ];
    } catch (e) {
      throw Exception('Failed to fetch regulatory updates: $e');
    }
  }

  // Compliance Scoring
  Future<double> calculateComplianceScore({
    required List<Animal> animals,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    double score = 100.0;

    // Check antibiotic usage compliance
    final antibioticUsage = await trackAntibioticUsage(
      animals: animals,
      startDate: startDate,
      endDate: endDate,
    );

    // Deduct points for violations
    final violations = antibioticUsage['violations'] as List<String>;
    score -= violations.length * 10;

    // Check MRL compliance
    final mrlViolations = await checkMRLCompliance(animals);
    score -= mrlViolations.length * 15;

    // Check documentation completeness
    final documentationScore = await _calculateDocumentationScore(animals);
    score = (score + documentationScore) / 2;

    return score.clamp(0.0, 100.0);
  }

  // Private helper methods

  Future<Map<String, dynamic>> _gatherComplianceData(
    List<Animal> animals,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final antibioticUsage = await trackAntibioticUsage(
      animals: animals,
      startDate: startDate,
      endDate: endDate,
    );

    final mrlViolations = await checkMRLCompliance(animals);
    final complianceScore = await calculateComplianceScore(
      animals: animals,
      startDate: startDate,
      endDate: endDate,
    );

    return {
      'period': {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
      'summary': {
        'total_animals': animals.length,
        'animals_treated': antibioticUsage['total_animals_treated'],
        'compliance_score': complianceScore,
        'status': complianceScore >= 80 ? 'compliant' : 'non_compliant',
      },
      'antibiotic_usage': antibioticUsage,
      'mrl_violations': mrlViolations,
      'recommendations': _generateComplianceRecommendations(
        antibioticUsage,
        mrlViolations,
        complianceScore,
      ),
    };
  }

  Future<String> _generatePDFReport(
    Map<String, dynamic> reportData,
    String farmId,
    String reportType,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('Antibiotic Usage Compliance Report'),
            ),
            pw.Text('Farm ID: $farmId'),
            pw.Text('Report Type: $reportType'),
            pw.Text('Period: ${reportData['period']['start_date']} to ${reportData['period']['end_date']}'),
            pw.SizedBox(height: 20),
            pw.Text('Summary:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Total Animals: ${reportData['summary']['total_animals']}'),
            pw.Text('Animals Treated: ${reportData['summary']['animals_treated']}'),
            pw.Text('Compliance Score: ${reportData['summary']['compliance_score']}'),
            pw.Text('Status: ${reportData['summary']['status']}'),
          ],
        ),
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/compliance_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  Future<void> _submitToRegulatoryBody(
    Map<String, dynamic> reportData,
    String reportType,
  ) async {
    // Implement submission to regulatory body API
    // This would send the report data to government systems
    print('Submitting report to regulatory body...');
  }

  bool _isAntibiotic(String drugName) {
    final antibiotics = [
      'penicillin', 'tetracycline', 'oxytetracycline', 'amoxicillin',
      'cef', 'sulfa', 'quinolone', 'aminoglycoside', 'macrolide'
    ];

    return antibiotics.any((abx) => drugName.toLowerCase().contains(abx));
  }

  Future<double> _getMRLLimit(String species, String drug) async {
    // This would query regulatory databases for MRL limits
    // For now, return mock values
    final mrlLimits = {
      'cattle_tetracycline': 100.0,
      'cattle_penicillin': 4.0,
      'poultry_tetracycline': 200.0,
      'pig_amoxicillin': 50.0,
    };

    final key = '${species.toLowerCase()}_${drug.toLowerCase()}';
    return mrlLimits[key] ?? 50.0; // Default MRL limit
  }

  Future<Map<String, dynamic>> _gatherCertificateData(
    Animal animal,
    String destinationCountry,
  ) async {
    return {
      'animal_id': animal.id,
      'species': animal.species,
      'age': animal.age,
      'last_treatment_date': animal.lastDrug != null ? 'No recent treatments' : 'Has treatments',
      'withdrawal_status': animal.hasActiveTreatment ? 'In withdrawal period' : 'Safe for consumption',
      'mrl_status': animal.mrlStatus ?? 'Unknown',
      'destination_country': destinationCountry,
      'certification_date': DateTime.now().toIso8601String(),
    };
  }

  Future<String> _generateExportCertificatePDF(
    Map<String, dynamic> certificateData,
    String exporterName,
    DateTime exportDate,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('Export Health Certificate'),
            ),
            pw.Text('Exporter: $exporterName'),
            pw.Text('Export Date: ${exportDate.toIso8601String()}'),
            pw.SizedBox(height: 20),
            pw.Text('Animal Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('ID: ${certificateData['animal_id']}'),
            pw.Text('Species: ${certificateData['species']}'),
            pw.Text('Age: ${certificateData['age']}'),
            pw.SizedBox(height: 20),
            pw.Text('Health Status:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Treatment Status: ${certificateData['last_treatment_date']}'),
            pw.Text('Withdrawal Status: ${certificateData['withdrawal_status']}'),
            pw.Text('MRL Status: ${certificateData['mrl_status']}'),
          ],
        ),
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/export_certificate_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  Future<void> _storeAuditEntry(AuditEntry entry) async {
    // Implement audit entry storage
    // This could be local storage or cloud storage
    print('Storing audit entry: ${entry.action}');
  }

  List<String> _generateComplianceRecommendations(
    Map<String, dynamic> antibioticUsage,
    List<String> mrlViolations,
    double complianceScore,
  ) {
    final recommendations = <String>[];

    if (complianceScore < 80) {
      recommendations.add('Improve antibiotic usage documentation');
      recommendations.add('Implement stricter withdrawal period monitoring');
    }

    if (mrlViolations.isNotEmpty) {
      recommendations.add('Review MRL testing procedures');
      recommendations.add('Consider alternative treatments with lower MRL concerns');
    }

    final totalTreated = antibioticUsage['total_animals_treated'] as int;
    if (totalTreated > 10) {
      recommendations.add('Consider implementing antibiotic stewardship program');
    }

    return recommendations;
  }

  Future<double> _calculateDocumentationScore(List<Animal> animals) async {
    double totalScore = 0;
    int animalCount = 0;

    for (final animal in animals) {
      double animalScore = 0;

      // Check vaccination records
      if (animal.vaccinationHistory != null && animal.vaccinationHistory!.isNotEmpty) {
        animalScore += 25;
      }

      // Check treatment records
      if (animal.treatmentHistory != null && animal.treatmentHistory!.isNotEmpty) {
        animalScore += 25;
      }

      // Check health notes
      if (animal.healthNotes != null && animal.healthNotes!.isNotEmpty) {
        animalScore += 25;
      }

      // Check weight records
      if (animal.weightHistory != null && animal.weightHistory!.isNotEmpty) {
        animalScore += 25;
      }

      totalScore += animalScore;
      animalCount++;
    }

    return animalCount > 0 ? totalScore / animalCount : 0;
  }
}

// Compliance Status Enum
enum ComplianceStatus {
  compliant,
  warning,
  nonCompliant,
  underReview,
}

// Regulatory Body Integration
class RegulatoryBodyService {
  static const Map<String, String> regulatoryBodies = {
    'india': 'https://apeda.gov.in',
    'usa': 'https://www.fsis.usda.gov',
    'eu': 'https://ec.europa.eu',
    'china': 'https://www.aqsiq.gov.cn',
  };

  Future<Map<String, dynamic>> getRegulatoryRequirements({
    required String country,
    required String productType, // 'meat', 'milk', 'eggs'
  }) async {
    // This would fetch actual regulatory requirements
    // For now, return mock data
    return {
      'country': country,
      'product_type': productType,
      'mrl_limits': {
        'tetracycline': 100.0,
        'penicillin': 4.0,
        'amoxicillin': 50.0,
      },
      'withdrawal_periods': {
        'tetracycline': 14, // days
        'penicillin': 7,
        'amoxicillin': 3,
      },
      'documentation_requirements': [
        'Treatment records',
        'Withdrawal certificates',
        'Laboratory test results',
      ],
      'last_updated': DateTime.now().subtract(Duration(days: 30)),
    };
  }

  Future<bool> validateCompliance({
    required Map<String, dynamic> animalData,
    required String destinationCountry,
  }) async {
    // Implement compliance validation logic
    final requirements = await getRegulatoryRequirements(
      country: destinationCountry,
      productType: animalData['product_type'] ?? 'meat',
    );

    // Check MRL compliance
    final currentMRL = animalData['current_mrl'] as double?;
    final drug = animalData['last_drug'] as String?;
    if (currentMRL != null && drug != null) {
      final mrlLimit = requirements['mrl_limits'][drug.toLowerCase()] ?? 50.0;
      if (currentMRL > mrlLimit) {
        return false;
      }
    }

    // Check withdrawal period
    final withdrawalEnd = animalData['withdrawal_end'];
    if (withdrawalEnd != null) {
      final endDate = DateTime.parse(withdrawalEnd);
      if (endDate.isAfter(DateTime.now())) {
        return false;
      }
    }

    return true;
  }
}