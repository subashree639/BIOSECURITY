import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../data/medicine_data.dart';

class MRLGraphPage extends StatefulWidget {
  final Animal animal;

  const MRLGraphPage({Key? key, required this.animal}) : super(key: key);

  @override
  _MRLGraphPageState createState() => _MRLGraphPageState();
}

class _MRLGraphPageState extends State<MRLGraphPage> {
  List<double> _mrlValues = [];
  List<int> _days = [];
  int _withdrawalDays = 7;

  @override
  void initState() {
    super.initState();
    _prepareGraphData();
  }

  void _prepareGraphData() {
    final animalMedicines = MEDICINES[widget.animal.species];
    final medicineSpecs = animalMedicines?[widget.animal.lastDrug];

    // Default values if medicine data is not available
    final withdrawalDays = medicineSpecs != null
        ? getWithdrawalDays(medicineSpecs, widget.animal.productType ?? 'milk') ?? 7
        : 7;

    final dosage = medicineSpecs != null
        ? (double.tryParse(widget.animal.lastDosage ?? '0') ?? medicineSpecs['dosage_mg_per_kg'] as double? ?? 10.0)
        : (double.tryParse(widget.animal.lastDosage ?? '0') ?? 10.0);

    setState(() {
      _withdrawalDays = withdrawalDays;
      _days = [];
      _mrlValues = [];

      // Generate data for at least 30 days or withdrawal period + 7 days, whichever is larger
      final totalDays = math.max(30, withdrawalDays + 7);

      for (int day = 0; day <= totalDays; day++) {
        _days.add(day);
        final mrl = computeMRL(dosage, day, withdrawalDays);
        _mrlValues.add(mrl);
      }

      // Ensure we have at least some data points
      if (_days.isEmpty || _mrlValues.isEmpty) {
        _days = [0, 1, 2, 3, 4, 5, 6, 7];
        _mrlValues = [dosage * 0.5, dosage * 0.4, dosage * 0.3, dosage * 0.2, dosage * 0.1, dosage * 0.05, dosage * 0.02, 0.0];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MRL Graph - ${widget.animal.id}'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animal: ${widget.animal.species} - ${widget.animal.breed}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Medicine: ${widget.animal.lastDrug ?? 'N/A'}'),
                    Text('Dosage: ${widget.animal.lastDosage ?? 'N/A'} mg/kg'),
                    Text('Product Type: ${widget.animal.productType ?? 'N/A'}'),
                    Text('Withdrawal Period: $_withdrawalDays days'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: _days.isEmpty || _mrlValues.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.show_chart, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No graph data available',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Consultation data may be incomplete',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: CustomPaint(
                            painter: MRLGraphPainter(
                              days: _days,
                              mrlValues: _mrlValues,
                              withdrawalDays: _withdrawalDays,
                              safeThreshold: safeThreshold,
                            ),
                            child: Container(),
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 6),
                    Text('MRL Trend', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 2,
                      color: Colors.red,
                    ),
                    SizedBox(width: 6),
                    Text('Safe Threshold (${safeThreshold.toStringAsFixed(1)})', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 2,
                      color: Colors.green,
                    ),
                    SizedBox(width: 6),
                    Text('Withdrawal End (Day $_withdrawalDays)', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MRLGraphPainter extends CustomPainter {
  final List<int> days;
  final List<double> mrlValues;
  final int withdrawalDays;
  final double safeThreshold;

  MRLGraphPainter({
    required this.days,
    required this.mrlValues,
    required this.withdrawalDays,
    required this.safeThreshold,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty || mrlValues.isEmpty || size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final thresholdPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final withdrawalPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Find max MRL for scaling (ensure minimum value)
    final maxMRL = math.max(mrlValues.reduce(math.max), safeThreshold * 2);
    final scaleY = size.height / (maxMRL * 1.1); // Add 10% padding
    final scaleX = size.width / (days.length - 1);

    // Draw threshold line
    final thresholdY = size.height - (safeThreshold * scaleY);
    if (thresholdY >= 0 && thresholdY <= size.height) {
      canvas.drawLine(
        Offset(0, thresholdY),
        Offset(size.width, thresholdY),
        thresholdPaint,
      );
    }

    // Draw withdrawal end line
    if (withdrawalDays < days.length && withdrawalDays >= 0) {
      final withdrawalX = withdrawalDays * scaleX;
      if (withdrawalX >= 0 && withdrawalX <= size.width) {
        canvas.drawLine(
          Offset(withdrawalX, 0),
          Offset(withdrawalX, size.height),
          withdrawalPaint,
        );
      }
    }

    // Draw MRL curve
    final path = Path();
    for (int i = 0; i < days.length; i++) {
      final x = i * scaleX;
      final y = size.height - (mrlValues[i] * scaleY);

      // Ensure coordinates are within bounds
      final clampedY = y.clamp(0.0, size.height);

      if (i == 0) {
        path.moveTo(x, clampedY);
      } else {
        path.lineTo(x, clampedY);
      }
    }
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < days.length; i += math.max(1, days.length ~/ 10)) { // Draw fewer points for performance
      final x = i * scaleX;
      final y = size.height - (mrlValues[i] * scaleY);
      final clampedY = y.clamp(0.0, size.height);

      if (x >= 0 && x <= size.width && clampedY >= 0 && clampedY <= size.height) {
        canvas.drawCircle(Offset(x, clampedY), 2, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}