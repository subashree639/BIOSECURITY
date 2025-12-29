import 'package:flutter/material.dart';

enum Language { english, tamil, hindi }

class MultilingualAddressInput extends StatefulWidget {
  final TextEditingController doorNoController;
  final TextEditingController streetController;
  final TextEditingController cityController;
  final TextEditingController districtController;
  final Language selectedLanguage;
  final Function(Language)? onLanguageChanged;
  final String label;

  const MultilingualAddressInput({
    Key? key,
    required this.doorNoController,
    required this.streetController,
    required this.cityController,
    required this.districtController,
    required this.selectedLanguage,
    this.onLanguageChanged,
    this.label = 'Complete Address',
  }) : super(key: key);

  @override
  _MultilingualAddressInputState createState() => _MultilingualAddressInputState();
}

class _MultilingualAddressInputState extends State<MultilingualAddressInput> {
  final Map<Language, Map<String, String>> _labels = {
    Language.english: {
      'doorNo': 'Door No',
      'street': 'Street Name',
      'city': 'City/Town',
      'district': 'District',
      'doorNoHint': 'Enter door/building number',
      'streetHint': 'Enter street name or area',
      'cityHint': 'Enter city or town name',
      'districtHint': 'Enter district name',
    },
    Language.tamil: {
      'doorNo': 'கதவு எண்',
      'street': 'தெரு பெயர்',
      'city': 'நகரம்/நகராட்சி',
      'district': 'மாவட்டம்',
      'doorNoHint': 'கதவு/கட்டிட எண்ணை உள்ளிடவும்',
      'streetHint': 'தெரு பெயர் அல்லது பகுதியை உள்ளிடவும்',
      'cityHint': 'நகரம் அல்லது நகராட்சி பெயரை உள்ளிடவும்',
      'districtHint': 'மாவட்டம் பெயரை உள்ளிடவும்',
    },
    Language.hindi: {
      'doorNo': 'दरवाजा नंबर',
      'street': 'गली का नाम',
      'city': 'शहर/कस्बा',
      'district': 'जिला',
      'doorNoHint': 'दरवाजा/इमारत संख्या दर्ज करें',
      'streetHint': 'गली का नाम या क्षेत्र दर्ज करें',
      'cityHint': 'शहर या कस्बे का नाम दर्ज करें',
      'districtHint': 'जिले का नाम दर्ज करें',
    },
  };

  String getLabel(String key) {
    return _labels[widget.selectedLanguage]?[key] ?? _labels[Language.english]![key]!;
  }

  String getHint(String key) {
    return _labels[widget.selectedLanguage]?['${key}Hint'] ?? _labels[Language.english]!['${key}Hint']!;
  }

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
                      Icons.home,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.2,
                    ),
                  ),
                  Spacer(),
                  if (widget.onLanguageChanged != null) _buildLanguageSelector(),
                ],
              ),
              SizedBox(height: 16),
              _buildAddressField(
                controller: widget.doorNoController,
                label: getLabel('doorNo'),
                hint: getHint('doorNo'),
                icon: Icons.door_front_door,
              ),
              SizedBox(height: 12),
              _buildAddressField(
                controller: widget.streetController,
                label: getLabel('street'),
                hint: getHint('street'),
                icon: Icons.streetview,
              ),
              SizedBox(height: 12),
              _buildAddressField(
                controller: widget.cityController,
                label: getLabel('city'),
                hint: getHint('city'),
                icon: Icons.location_city,
              ),
              SizedBox(height: 12),
              _buildAddressField(
                controller: widget.districtController,
                label: getLabel('district'),
                hint: getHint('district'),
                icon: Icons.map,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _languageChip(Language.english, 'EN'),
          _languageChip(Language.tamil, 'த'),
          _languageChip(Language.hindi, 'हिं'),
        ],
      ),
    );
  }

  Widget _languageChip(Language language, String text) {
    final isSelected = widget.selectedLanguage == language;
    return GestureDetector(
      onTap: widget.onLanguageChanged != null ? () => widget.onLanguageChanged!(language) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade700 : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.green.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildAddressField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: Colors.green.shade600, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
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
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}