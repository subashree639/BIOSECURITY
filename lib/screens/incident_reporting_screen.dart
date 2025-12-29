import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class IncidentReportingScreen extends StatefulWidget {
  final bool isEmergency;

  const IncidentReportingScreen({super.key, this.isEmergency = false});

  @override
  State<IncidentReportingScreen> createState() => _IncidentReportingScreenState();
}

class _IncidentReportingScreenState extends State<IncidentReportingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _incidentType = 'disease_outbreak';
  final _descriptionController = TextEditingController();
  final _affectedCountController = TextEditingController();
  final _locationController = TextEditingController();

  final List<String> _incidentTypes = [
    'disease_outbreak',
    'mortality_event',
    'biosecurity_breach',
    'feed_contamination',
    'water_contamination',
    'equipment_failure',
    'visitor_incident',
    'other',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEmergency ? 'Emergency Report' : 'Report Incident'),
        backgroundColor: widget.isEmergency ? Colors.red : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isEmergency)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red[700], size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'EMERGENCY REPORTING MODE',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This will trigger immediate response protocols',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              Text(
                'Incident Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _incidentType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: _incidentTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      _formatIncidentType(type),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _incidentType = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe what happened...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'Description is required' : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _affectedCountController,
                decoration: InputDecoration(
                  labelText: 'Affected Animals Count',
                  hintText: 'Number of affected animals',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Count is required';
                  final count = int.tryParse(value);
                  if (count == null || count < 0) return 'Invalid count';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'Specific location within the farm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) => value!.isEmpty ? 'Location is required' : null,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isEmergency ? Colors.red : Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.isEmergency ? 'SUBMIT EMERGENCY REPORT' : 'Submit Report',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (widget.isEmergency)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Response Protocol',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reports will be immediately flagged for authorities and may trigger outbreak response protocols.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatIncidentType(String type) {
    return type.split('_').map((word) =>
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save incident report to database
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEmergency
            ? 'Emergency report submitted! Authorities will be notified immediately.'
            : 'Incident report submitted successfully.'),
          backgroundColor: widget.isEmergency ? Colors.red : Colors.green,
        ),
      );

      if (widget.isEmergency) {
        // For emergency, go back to dashboard
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _affectedCountController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}