import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import '../l10n/app_localizations.dart';
import '../services/animal_storage.dart';
import '../models/animal.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';
import '../models/farm.dart';
import 'package:provider/provider.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  _AddAnimalScreenState createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> with TickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _id = TextEditingController();
  final _age = TextEditingController();
  final _species = TextEditingController();
  final _breed = TextEditingController();
  final _storage = AnimalStorageService();
  bool _saving = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _farmSpecies;
  bool _loadingFarm = true;

  // Default breed based on farm species
  String get _defaultBreed => _farmSpecies == 'pig' ? 'Large White' : 'Desi';

  String? _animalPhoto;
  bool _takingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadFarmSpecies();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  Future<void> _loadFarmSpecies() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser != null) {
        final farms = await DatabaseHelper().getFarms();
        final userFarm = farms.firstWhere(
          (farm) => farm.createdBy == currentUser.id,
          orElse: () => Farm(
            ownerName: '',
            farmName: '',
            species: 'pig', // default
            size: 0,
            createdBy: 0,
          ),
        );

        setState(() {
          _farmSpecies = userFarm.species;
          _species.text = _farmSpecies ?? 'pig'; // Set the species text field
          _loadingFarm = false;
        });
      }
    } catch (e) {
      setState(() {
        _farmSpecies = 'pig'; // default fallback
        _species.text = _farmSpecies ?? 'pig'; // Set the species text field
        _loadingFarm = false;
      });
    }
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

  Future<void> _capturePhoto(ImageSource source) async {
    setState(() => _takingPhoto = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedFile != null) {
        setState(() {
          _animalPhoto = pickedFile.path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(source == ImageSource.camera ? 'Photo captured!' : 'Photo selected!'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Failed to ${source == ImageSource.camera ? 'capture' : 'select'} photo: $e'),
              ],
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      setState(() => _takingPhoto = false);
    }
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentFarmerId = authService.currentUser?.id;

      final speciesVal = _farmSpecies ?? 'pig'; // Use farm species or default to pig
      final breedVal = _defaultBreed; // Use default breed based on farm species
      final a = Animal(
        id: _id.text.trim(),
        species: speciesVal,
        age: _age.text.trim(),
        breed: breedVal,
        farmerId: currentFarmerId?.toString(),
        createdAt: DateTime.now(),
        photoPath: _animalPhoto,
      );
      await _storage.addAnimal(a);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Animal added successfully!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to save animal: $e',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade400.withOpacity(0.1),
              Colors.white,
              Colors.green.shade300.withOpacity(0.1),
              Colors.green.shade200.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating particles background
              _buildFloatingParticles(),

              // Main content with glassmorphism
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Premium Glassmorphism App Bar
                      _buildPremiumAppBar(),

                      // Form Content with Glass Cards
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _form,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Animal ID Section with Premium Design
                                FadeInUp(
                                  duration: const Duration(milliseconds: 600),
                                  child: _buildPremiumCard(
                                    title: 'Animal Identification',
                                    icon: Icons.tag,
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.white.withOpacity(0.9), Colors.grey.shade50.withOpacity(0.8)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.3),
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green.shade100.withOpacity(0.3),
                                                blurRadius: 20,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: TextFormField(
                                            controller: _id,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: 'Animal ID',
                                              labelStyle: TextStyle(
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              prefixIcon: Container(
                                                margin: const EdgeInsets.all(12),
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [Colors.green.shade400, Colors.green.shade600],
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Icon(Icons.vpn_key, color: Colors.white, size: 20),
                                              ),
                                              border: InputBorder.none,
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                              hintText: 'Enter unique animal ID',
                                              hintStyle: TextStyle(color: Colors.grey.shade400),
                                            ),
                                            validator: (v) {
                                              if (v == null || v.trim().isEmpty) {
                                                return 'Please enter animal ID';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        FadeInUp(
                                          delay: const Duration(milliseconds: 200),
                                          duration: const Duration(milliseconds: 600),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.green.shade600, Colors.green.shade700],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.green.shade300.withOpacity(0.4),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton.icon(
                                              onPressed: _generateId,
                                              icon: const Icon(Icons.auto_fix_high, size: 20),
                                              label: const Text(
                                                'Generate ID',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                foregroundColor: Colors.white,
                                                shadowColor: Colors.transparent,
                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Age Section with Premium Design
                                FadeInUp(
                                  duration: const Duration(milliseconds: 700),
                                  child: _buildPremiumCard(
                                    title: 'Animal Age',
                                    icon: Icons.calendar_today,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.white.withOpacity(0.9), Colors.grey.shade50.withOpacity(0.8)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.shade100.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: TextFormField(
                                        controller: _age,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Age (in months)',
                                          labelStyle: TextStyle(
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.all(12),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.green.shade400, Colors.green.shade600],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(Icons.calendar_today, color: Colors.white, size: 20),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                          hintText: 'Enter age in months',
                                          hintStyle: TextStyle(color: Colors.grey.shade400),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return 'Please enter age';
                                          }
                                          final age = int.tryParse(v);
                                          if (age == null || age < 0 || age > 600) {
                                            return 'Enter valid age (0-600 months)';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Premium Photo Capture Section
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  child: _buildPremiumCard(
                                    title: 'Animal Photo',
                                    icon: Icons.camera_alt,
                                    child: Column(
                                      children: [
                                        if (_animalPhoto != null)
                                          FadeIn(
                                            duration: const Duration(milliseconds: 500),
                                            child: Container(
                                              margin: const EdgeInsets.only(bottom: 20),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.15),
                                                    blurRadius: 25,
                                                    offset: const Offset(0, 10),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: Stack(
                                                  children: [
                                                    Image.file(
                                                      File(_animalPhoto!),
                                                      height: 220,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Positioned(
                                                      top: 12,
                                                      right: 12,
                                                      child: Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withOpacity(0.5),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: const Icon(
                                                          Icons.check_circle,
                                                          color: Colors.white,
                                                          size: 24,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        else
                                          FadeIn(
                                            duration: const Duration(milliseconds: 500),
                                            child: Container(
                                              height: 180,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.grey.shade100.withOpacity(0.8),
                                                    Colors.grey.shade50.withOpacity(0.6),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.4),
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.green.shade100.withOpacity(0.2),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  BounceIn(
                                                    duration: const Duration(milliseconds: 1000),
                                                    child: Icon(
                                                      Icons.photo_camera,
                                                      size: 64,
                                                      color: Colors.green.shade400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    'Capture ${_farmSpecies ?? 'Animal'} Photo',
                                                    style: TextStyle(
                                                      color: Colors.green.shade700,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Take a clear photo for identification',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: FadeInLeft(
                                                duration: const Duration(milliseconds: 600),
                                                child: _buildPremiumPhotoButton(
                                                  onPressed: _takingPhoto ? null : () => _capturePhoto(ImageSource.camera),
                                                  icon: _takingPhoto
                                                      ? Container(
                                                          width: 20,
                                                          height: 20,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                          ),
                                                        )
                                                      : const Icon(Icons.camera_alt, size: 22),
                                                  label: 'Camera',
                                                  gradient: LinearGradient(
                                                    colors: [Colors.green.shade600, Colors.green.shade700],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: FadeInRight(
                                                duration: const Duration(milliseconds: 600),
                                                child: _buildPremiumPhotoButton(
                                                  onPressed: _takingPhoto ? null : () => _capturePhoto(ImageSource.gallery),
                                                  icon: const Icon(Icons.photo_library, size: 22),
                                                  label: 'Gallery',
                                                  gradient: LinearGradient(
                                                    colors: [Colors.blue.shade600, Colors.blue.shade700],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // Premium Save Button
                                FadeInUp(
                                  duration: const Duration(milliseconds: 900),
                                  child: _buildPremiumSaveButton(),

                                ),

                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Floating Particles Background
  Widget _buildFloatingParticles() {
    return Positioned.fill(
      child: Stack(
        children: List.generate(12, (index) {
          return FadeIn(
            duration: Duration(milliseconds: 1000 + (index * 200)),
            child: _buildFloatingParticle(index),
          );
        }),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final colors = [
      Colors.green.shade200.withOpacity(0.3),
      Colors.green.shade300.withOpacity(0.2),
      Colors.blue.shade200.withOpacity(0.25),
      Colors.purple.shade200.withOpacity(0.2),
    ];

    return GestureDetector(
      onTap: () {
        // Add subtle interaction feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Premium Experience Activated!'),
            duration: const Duration(milliseconds: 1000),
            backgroundColor: Colors.green.shade700,
          ),
        );
      },
      child: AnimatedContainer(
        duration: Duration(seconds: 3 + (index % 3)),
        curve: Curves.easeInOut,
        width: 8 + (index % 4) * 4,
        height: 8 + (index % 4) * 4,
        decoration: BoxDecoration(
          color: colors[index % colors.length],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors[index % colors.length].withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  // Premium Glassmorphism App Bar
  Widget _buildPremiumAppBar() {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade600.withOpacity(0.95),
              Colors.green.shade500.withOpacity(0.9),
              Colors.green.shade400.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade300.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Animal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Premium animal registration with photo capture',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                BounceIn(
                  duration: const Duration(milliseconds: 1000),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      _farmSpecies == 'pig' ? Icons.pets : Icons.egg,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Premium Glassmorphism Card
  Widget _buildPremiumCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.85),
            Colors.white.withOpacity(0.75),
            Colors.grey.shade50.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade500,
                            Colors.green.shade600,
                            Colors.green.shade700,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade300.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Premium Photo Capture Button
  Widget _buildPremiumPhotoButton({
    required VoidCallback? onPressed,
    required Widget icon,
    required String label,
    required Gradient gradient,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : gradient,
        color: onPressed == null ? Colors.grey.shade300 : null,
        borderRadius: BorderRadius.circular(18),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: (gradient.colors.first as Color).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: icon,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Premium Save Button
  Widget _buildPremiumSaveButton() {
    return BounceInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade600,
              Colors.green.shade700,
              Colors.green.shade800,
              Colors.green.shade900,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade400.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.green.shade600.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: _saving
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'Saving Animal...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: BounceIn(
                        duration: const Duration(milliseconds: 1200),
                        child: const Icon(
                          Icons.pets,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Save Animal',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}