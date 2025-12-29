import 'package:flutter/material.dart';

class FarmLocationInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool required;
  final Function(String)? onLocationChanged;

  const FarmLocationInput({
    Key? key,
    required this.controller,
    this.label = 'Farm Location',
    this.hint = 'Enter farm location (village, district, state)',
    this.required = true,
    this.onLocationChanged,
  }) : super(key: key);

  @override
  _FarmLocationInputState createState() => _FarmLocationInputState();
}

class _FarmLocationInputState extends State<FarmLocationInput> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.green.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.green.shade50.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    widget.label + (widget.required ? ' *' : ''),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _hasError ? Colors.red.shade300 : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.green.shade400,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
                validator: (value) {
                  if (widget.required && (value == null || value.trim().isEmpty)) {
                    setState(() => _hasError = true);
                    return 'Farm location is required';
                  }
                  if (value != null && value.trim().isNotEmpty && value.trim().length < 3) {
                    setState(() => _hasError = true);
                    return 'Farm location must be at least 3 characters';
                  }
                  setState(() => _hasError = false);
                  return null;
                },
                onChanged: (value) {
                  if (_hasError) {
                    setState(() => _hasError = false);
                  }
                  if (widget.onLocationChanged != null) {
                    widget.onLocationChanged!(value);
                  }
                },
              ),
              SizedBox(height: 8),
              Text(
                'Please enter your farm location including village, district, and state for better veterinary services',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}