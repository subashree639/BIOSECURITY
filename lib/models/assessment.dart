import 'dart:convert';
class Assessment {
  int? id;
  int farmId;
  int templateId;
  Map<String, dynamic> answers; // json
  double score;
  String riskLevel; // Low, Medium, High
  DateTime createdAt;
  List<String> attachments; // paths

  Assessment({
    this.id,
    required this.farmId,
    required this.templateId,
    required this.answers,
    required this.score,
    required this.riskLevel,
    required this.createdAt,
    this.attachments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farm_id': farmId,
      'template_id': templateId,
      'answers': jsonEncode(answers),
      'score': score,
      'risk_level': riskLevel,
      'created_at': createdAt.toIso8601String(),
      'attachments': attachments.join(','),
    };
  }

  factory Assessment.fromMap(Map<String, dynamic> map) {
    return Assessment(
      id: map['id'],
      farmId: map['farm_id'],
      templateId: map['template_id'],
      answers: map['answers'] != null ? jsonDecode(map['answers']) : {},
      score: map['score'],
      riskLevel: map['risk_level'],
      createdAt: DateTime.parse(map['created_at']),
      attachments: map['attachments'] != null ? (map['attachments'] as String).split(',') : [],
    );
  }
}