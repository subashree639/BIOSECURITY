import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/animal_storage.dart';
import '../models/animal.dart';
import '../services/auth_service.dart';

//
// Enhanced AddAnimalPage with modern UI design and animations
//
class AddAnimalPage extends StatefulWidget {
  @override
  _AddAnimalPageState createState() => _AddAnimalPageState();
}

class _AddAnimalPageState extends State<AddAnimalPage> with TickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _id = TextEditingController();
  final _species = TextEditingController();
  final _age = TextEditingController();
  final _breed = TextEditingController();
  final _storage = AnimalStorageService();
  bool _saving = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> speciesOptions = ['Cow','Buffalo','Goat','Sheep','Pig','Poultry','Other'];

  // Keep internal keys in English for logic, but use localized display names
  final Map<String,List<String>> breedsMap = {
    'Cow': ['Jersey','Holstein','Sahiwal','Gir','Red Sindhi','Tharparkar'],
    'Buffalo': ['Murrah','Nili-Ravi','Jaffarabadi','Surti','Bhadawari'],
    'Goat': ['Beetal','Boer','Jamunapari','Sirohi','Barbari'],
    'Sheep': ['Merino','Rambouillet','Cheviot','Suffolk','Hampshire'],
    'Pig': ['Large White','Yorkshire','Berkshire'],
    'Poultry': ['Desi','Layer','Broiler'],
    'Other': ['Unknown']
  };

  final Map<String, IconData> speciesIcons = {
    'Cow': Icons.pets,
    'Buffalo': Icons.pets,
    'Goat': Icons.pets,
    'Sheep': Icons.pets,
    'Pig': Icons.pets,
    'Poultry': Icons.egg,
    'Other': Icons.pets
  };

  // Localized display names
  String getLocalizedSpecies(String species) {
    switch (species) {
      case 'Cow': return AppLocalizations.of(context)!.cow;
      case 'Buffalo': return AppLocalizations.of(context)!.buffalo;
      case 'Goat': return AppLocalizations.of(context)!.goat;
      case 'Sheep': return AppLocalizations.of(context)!.sheep;
      case 'Pig': return AppLocalizations.of(context)!.pig;
      case 'Poultry': return AppLocalizations.of(context)!.poultry;
      case 'Other': return AppLocalizations.of(context)!.other;
      default: return species;
    }
  }

  String getLocalizedBreed(String breed) {
    switch (breed) {
      case 'Jersey': return AppLocalizations.of(context)!.jersey;
      case 'Holstein': return AppLocalizations.of(context)!.holstein;
      case 'Sahiwal': return AppLocalizations.of(context)!.sahiwal;
      case 'Gir': return AppLocalizations.of(context)!.gir;
      case 'Red Sindhi': return AppLocalizations.of(context)!.redSindhi;
      case 'Tharparkar': return AppLocalizations.of(context)!.tharparkar;
      case 'Murrah': return AppLocalizations.of(context)!.murrah;
      case 'Nili-Ravi': return AppLocalizations.of(context)!.niliRavi;
      case 'Jaffarabadi': return AppLocalizations.of(context)!.jaffarabadi;
      case 'Surti': return AppLocalizations.of(context)!.surti;
      case 'Bhadawari': return AppLocalizations.of(context)!.bhadawari;
      case 'Beetal': return AppLocalizations.of(context)!.beetal;
      case 'Boer': return AppLocalizations.of(context)!.boer;
      case 'Jamunapari': return AppLocalizations.of(context)!.jamunapari;
      case 'Sirohi': return AppLocalizations.of(context)!.sirohi;
      case 'Barbari': return AppLocalizations.of(context)!.barbari;
      case 'Merino': return AppLocalizations.of(context)!.merino;
      case 'Rambouillet': return AppLocalizations.of(context)!.rambouillet;
      case 'Cheviot': return AppLocalizations.of(context)!.cheviot;
      case 'Suffolk': return AppLocalizations.of(context)!.suffolk;
      case 'Hampshire': return AppLocalizations.of(context)!.hampshire;
      case 'Large White': return AppLocalizations.of(context)!.largeWhite;
      case 'Yorkshire': return AppLocalizations.of(context)!.yorkshire;
      case 'Berkshire': return AppLocalizations.of(context)!.berkshire;
      case 'Desi': return AppLocalizations.of(context)!.desi;
      case 'Layer': return AppLocalizations.of(context)!.layer;
      case 'Broiler': return AppLocalizations.of(context)!.broiler;
      case 'Unknown': return AppLocalizations.of(context)!.unknown;
      default: return breed;
    }
  }

  String? _selectedSpecies;
  String? _selectedBreed;
  bool _breedCustom = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _id.dispose();
    _species.dispose();
    _age.dispose();
    _breed.dispose();
    super.dispose();
  }

  void _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final shortId = timestamp.substring(timestamp.length - 6);
    setState(() {
      _id.text = 'A${shortId}';
    });
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    try {
      // Get current farmer ID
      await auth.init();
      final currentFarmerId = auth.currentType == 'farmer' ? auth.currentId : null;

      final speciesVal = _selectedSpecies ?? _species.text.trim();
      final breedVal = _breedCustom ? _breed.text.trim() : (_selectedBreed ?? _breed.text.trim());
      final a = Animal(
        id: _id.text.trim(),
        species: speciesVal,
        age: _age.text.trim(),
        breed: breedVal,
        farmerId: currentFarmerId,
      );

      // Save to local storage
      await _storage.addAnimal(a);

      // Also save to Firebase if farmer ID is available
      if (currentFarmerId != null) {
        final animalData = {
          'id': a.id,
          'species': a.species,
          'age': a.age,
          'breed': a.breed,
          'farmerId': a.farmerId,
          'addedAt': DateTime.now().toIso8601String(),
        };
        await auth.saveAnimalData(currentFarmerId, a.id, animalData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.animalAddedSuccessfully,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(Duration(milliseconds: 500));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.failedToSaveAnimal,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Custom App Bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade200,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.addAnimal,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.pets, color: Colors.white, size: 28),
                      ],
                    ),
                  ),

                  // Form Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Animal ID Section
                            _buildSectionCard(
                              title: AppLocalizations.of(context)!.animalIdentification,
                              icon: Icons.tag,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _id,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.animalId,
                                      hintText: AppLocalizations.of(context)!.enterUniqueAnimalId,
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircleAvatar(
                                          radius: 16,
                                          backgroundImage: AssetImage('assets/images/Animal ID.png'),
                                          backgroundColor: Colors.grey.shade200,
                                        ),
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return AppLocalizations.of(context)!.pleaseEnterAnimalId;
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: _generateId,
                                      icon: Icon(Icons.auto_fix_high, color: Colors.green.shade700),
                                      label: Text(AppLocalizations.of(context)!.generateId, style: TextStyle(color: Colors.green.shade700)),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.green.shade700),
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20),

                            // Species Section
                            _buildSectionCard(
                              title: AppLocalizations.of(context)!.species,
                              icon: Icons.pets,
                              child: Column(
                                children: [
                                  DropdownButtonFormField<String>(
                                    initialValue: _selectedSpecies,
                                    items: speciesOptions.map((species) => DropdownMenuItem(
                                          value: species,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundImage: AssetImage('assets/images/${species.toLowerCase()}.png'),
                                                backgroundColor: Colors.grey.shade200,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  getLocalizedSpecies(species),
                                                  style: TextStyle(fontWeight: FontWeight.w500),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )).toList(),
                                    onChanged: (v) {
                                      setState(() {
                                        _selectedSpecies = v;
                                        _species.text = v ?? '';
                                        // Reset breed selection when species changes
                                        final breeds = breedsMap[v] ?? [];
                                        _selectedBreed = breeds.isNotEmpty ? breeds.first : null;
                                        _breed.text = _selectedBreed ?? '';
                                        _breedCustom = false;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.selectSpecies,
                                      border: OutlineInputBorder(),
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade900,
                                    ),
                                    validator: (v) => (v == null || v.isEmpty) ? AppLocalizations.of(context)!.pleaseSelectSpecies : null,
                                    dropdownColor: Colors.white,
                                    isExpanded: true,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20),

                            // Breed and Age Section
                            _buildSectionCard(
                              title: AppLocalizations.of(context)!.breedAgeDetails,
                              icon: Icons.info,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: _buildInputField(
                                          controller: _age,
                                          labelText: AppLocalizations.of(context)!.age,
                                          prefixIcon: Icons.calendar_today,
                                          hintText: AppLocalizations.of(context)!.enterAge,
                                          keyboardType: TextInputType.number,
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) {
                                              return AppLocalizations.of(context)!.pleaseEnterAge;
                                            }
                                            final age = int.tryParse(v);
                                            if (age == null || age < 0 || age > 50) {
                                              return AppLocalizations.of(context)!.enterValidAge;
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (!_breedCustom)
                                              DropdownButtonFormField<String>(
                                                initialValue: _selectedBreed,
                                                items: (_selectedSpecies != null
                                                    ? (breedsMap[_selectedSpecies] ?? [AppLocalizations.of(context)!.unknown])
                                                    : [AppLocalizations.of(context)!.selectSpeciesFirst]
                                                ).map((breed) => DropdownMenuItem(
                                                  value: breed,
                                                  child: Container(
                                                    constraints: BoxConstraints(maxWidth: 120),
                                                    child: Text(
                                                      getLocalizedBreed(breed),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                )).toList()
                                                  ..add(DropdownMenuItem(
                                                    value: 'Other',
                                                    child: Container(
                                                      constraints: BoxConstraints(maxWidth: 120),
                                                      child: Text(
                                                        AppLocalizations.of(context)!.otherCustom,
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  )),
                                                onChanged: (v) {
                                                  if (v == 'Other') {
                                                    setState(() {
                                                      _breedCustom = true;
                                                      _selectedBreed = null;
                                                      _breed.text = '';
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _selectedBreed = v;
                                                      _breed.text = v ?? '';
                                                    });
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  labelText: AppLocalizations.of(context)!.breed,
                                                  border: OutlineInputBorder(),
                                                ),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey.shade900,
                                                ),
                                                validator: (v) => (v == null || v.isEmpty) ? AppLocalizations.of(context)!.pleaseSelectBreed : null,
                                                dropdownColor: Colors.white,
                                                isExpanded: true,
                                              )
                                            else
                                              _buildInputField(
                                                controller: _breed,
                                                labelText: AppLocalizations.of(context)!.enterCustomBreed,
                                                prefixIcon: Icons.pets,
                                                hintText: AppLocalizations.of(context)!.enterBreedName,
                                                validator: (v) {
                                                  if (v == null || v.trim().isEmpty) {
                                                    return AppLocalizations.of(context)!.pleaseEnterBreed;
                                                  }
                                                  return null;
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 32),

                            // Save Button
                            Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.green.shade600, Colors.green.shade700],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.shade300,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _saving ? null : _save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _saving
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          ),
                                          SizedBox(width: 12),
                                          Text(AppLocalizations.of(context)!.saving, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.save, size: 24),
                                          SizedBox(width: 8),
                                          Text(
                                            AppLocalizations.of(context)!.saveAnimal,
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required List<DropdownMenuItem<String>> items,
    String? value,
    void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      validator: validator,
      dropdownColor: Colors.white,
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.green.shade700, size: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}