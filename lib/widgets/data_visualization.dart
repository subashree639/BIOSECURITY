import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/animal.dart';

// Data Visualization Components for Health Analytics
class HealthDashboard extends StatefulWidget {
  final Animal animal;
  final List<Animal> farmAnimals;

  const HealthDashboard({
    Key? key,
    required this.animal,
    required this.farmAnimals,
  }) : super(key: key);

  @override
  _HealthDashboardState createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Score Overview
          _buildHealthScoreCard(),

          SizedBox(height: 20),

          // Key Metrics Row
          Row(
            children: [
              Expanded(child: _buildMetricCard('Active Treatments', widget.animal.hasActiveTreatment ? '1' : '0', Icons.medical_services, Colors.orange)),
              SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Vaccinations', '${widget.animal.vaccinationHistory?.length ?? 0}', Icons.vaccines, Colors.green)),
            ],
          ),

          SizedBox(height: 20),

          // Weight Trend Chart
          if (widget.animal.weightHistory != null && widget.animal.weightHistory!.isNotEmpty)
            _buildWeightTrendChart(),

          SizedBox(height: 20),

          // Treatment Timeline
          if (widget.animal.treatmentHistory != null && widget.animal.treatmentHistory!.isNotEmpty)
            _buildTreatmentTimeline(),

          SizedBox(height: 20),

          // Farm Health Overview
          _buildFarmHealthOverview(),

          SizedBox(height: 20),

          // Health Insights
          _buildHealthInsights(),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    final healthScore = widget.animal.healthScore ?? 50.0;
    final isHealthy = healthScore >= 70;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isHealthy
                ? [Colors.green.shade400, Colors.green.shade600]
                : [Colors.orange.shade400, Colors.orange.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Score',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${healthScore.toInt()}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: healthScore / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 8,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              isHealthy ? 'Excellent Health' : 'Needs Attention',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightTrendChart() {
    final weightData = widget.animal.weightHistory!
        .map((w) => FlSpot(
              w.dateRecorded.millisecondsSinceEpoch.toDouble(),
              w.weight,
            ))
        .toList();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_weight, color: Colors.blue.shade600),
                SizedBox(width: 8),
                Text(
                  'Weight Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}kg',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          return Text(
                            '${date.month}/${date.day}',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weightData,
                      isCurved: true,
                      color: Colors.blue.shade600,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.shade100.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentTimeline() {
    final treatments = widget.animal.treatmentHistory!
        .take(5) // Show last 5 treatments
        .toList()
        .reversed
        .toList();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.purple.shade600),
                SizedBox(width: 8),
                Text(
                  'Recent Treatments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...treatments.map((treatment) => Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple.shade400,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          treatment.drugName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          treatment.condition,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${treatment.dateAdministered.month}/${treatment.dateAdministered.day}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmHealthOverview() {
    final healthyCount = widget.farmAnimals.where((a) => (a.healthScore ?? 0) >= 70).length;
    final totalAnimals = widget.farmAnimals.length;
    final healthyPercentage = totalAnimals > 0 ? (healthyCount / totalAnimals) * 100 : 0;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: Colors.teal.shade600),
                SizedBox(width: 8),
                Text(
                  'Farm Health Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$healthyCount/$totalAnimals',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Healthy Animals',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: healthyPercentage / 100,
                    backgroundColor: Colors.teal.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade600),
                    strokeWidth: 8,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: healthyPercentage / 100,
              backgroundColor: Colors.teal.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade600),
            ),
            SizedBox(height: 8),
            Text(
              '${healthyPercentage.toInt()}% of animals are healthy',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthInsights() {
    final insights = <String>[];

    if (widget.animal.healthScore != null && widget.animal.healthScore! < 70) {
      insights.add('Health score indicates need for attention');
    }

    if (widget.animal.hasActiveTreatment) {
      insights.add('Currently under treatment - monitor closely');
    }

    if (widget.animal.vaccinationHistory != null && widget.animal.vaccinationHistory!.isEmpty) {
      insights.add('No vaccination records found');
    }

    if (insights.isEmpty) {
      insights.add('Animal appears to be in good health');
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: Colors.amber.shade600),
                SizedBox(width: 8),
                Text(
                  'Health Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...insights.map((insight) => Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber.shade600, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight,
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// Interactive Health Timeline Widget
class HealthTimeline extends StatelessWidget {
  final List<TreatmentRecord> treatments;
  final List<VaccinationRecord> vaccinations;
  final List<WeightRecord> weights;

  const HealthTimeline({
    Key? key,
    required this.treatments,
    required this.vaccinations,
    required this.weights,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Combine all health events
    final events = <HealthEvent>[];

    for (final treatment in treatments) {
      events.add(HealthEvent(
        date: treatment.dateAdministered,
        type: 'treatment',
        title: treatment.drugName,
        description: treatment.condition,
        color: Colors.red.shade400,
      ));
    }

    for (final vaccination in vaccinations) {
      events.add(HealthEvent(
        date: vaccination.dateAdministered,
        type: 'vaccination',
        title: vaccination.vaccineName,
        description: 'Vaccination administered',
        color: Colors.green.shade400,
      ));
    }

    for (final weight in weights) {
      events.add(HealthEvent(
        date: weight.dateRecorded,
        type: 'weight',
        title: '${weight.weight} ${weight.unit}',
        description: 'Weight measurement',
        color: Colors.blue.shade400,
      ));
    }

    // Sort by date
    events.sort((a, b) => b.date.compareTo(a.date));

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Timeline',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            ...events.take(10).map((event) => Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: event.color,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          event.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${event.date.month}/${event.date.day}/${event.date.year}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// Health Event Model for Timeline
class HealthEvent {
  final DateTime date;
  final String type;
  final String title;
  final String description;
  final Color color;

  HealthEvent({
    required this.date,
    required this.type,
    required this.title,
    required this.description,
    required this.color,
  });
}

// Farm Analytics Dashboard
class FarmAnalyticsDashboard extends StatelessWidget {
  final List<Animal> animals;

  const FarmAnalyticsDashboard({
    Key? key,
    required this.animals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final healthyCount = animals.where((a) => (a.healthScore ?? 0) >= 70).length;
    final sickCount = animals.where((a) => (a.healthScore ?? 0) < 70 && (a.healthScore ?? 0) > 0).length;
    final unknownCount = animals.where((a) => a.healthScore == null || a.healthScore == 0).length;

    final sections = [
      PieChartSectionData(
        value: healthyCount.toDouble(),
        title: '$healthyCount',
        color: Colors.green.shade400,
        radius: 80,
      ),
      PieChartSectionData(
        value: sickCount.toDouble(),
        title: '$sickCount',
        color: Colors.red.shade400,
        radius: 80,
      ),
      PieChartSectionData(
        value: unknownCount.toDouble(),
        title: '$unknownCount',
        color: Colors.grey.shade400,
        radius: 80,
      ),
    ];

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farm Health Analytics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Healthy', Colors.green.shade400, healthyCount),
                      SizedBox(height: 12),
                      _buildLegendItem('Needs Attention', Colors.red.shade400, sickCount),
                      SizedBox(height: 12),
                      _buildLegendItem('Unknown', Colors.grey.shade400, unknownCount),
                      SizedBox(height: 24),
                      Text(
                        'Total Animals: ${animals.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label: $count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

// Treatment Effectiveness Chart
class TreatmentEffectivenessChart extends StatelessWidget {
  final List<TreatmentRecord> treatments;

  const TreatmentEffectivenessChart({
    Key? key,
    required this.treatments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Group treatments by condition
    final conditionGroups = <String, List<TreatmentRecord>>{};
    for (final treatment in treatments) {
      final condition = treatment.condition.toLowerCase();
      conditionGroups[condition] = (conditionGroups[condition] ?? [])..add(treatment);
    }

    final barGroups = conditionGroups.entries.map((entry) {
      final condition = entry.key;
      final treatments = entry.value;
      final successRate = _calculateSuccessRate(treatments);

      return BarChartGroupData(
        x: conditionGroups.keys.toList().indexOf(condition),
        barRods: [
          BarChartRodData(
            toY: successRate,
            color: _getConditionColor(condition),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Treatment Effectiveness',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final conditions = conditionGroups.keys.toList();
                          if (value.toInt() < conditions.length) {
                            return Text(
                              conditions[value.toInt()],
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateSuccessRate(List<TreatmentRecord> treatments) {
    if (treatments.isEmpty) return 0;

    final successful = treatments.where((t) => t.outcome?.toLowerCase() == 'successful').length;
    return (successful / treatments.length) * 100;
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'fever':
      case 'infection':
        return Colors.red.shade400;
      case 'parasites':
        return Colors.orange.shade400;
      case 'respiratory':
        return Colors.blue.shade400;
      case 'digestive':
        return Colors.green.shade400;
      default:
        return Colors.purple.shade400;
    }
  }
}