import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/animal_storage.dart';
import '../models/animal.dart';
import 'add_animal_screen.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({super.key});

  @override
  State<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  final _storage = AnimalStorageService();
  List<Animal> _animals = [];
  bool _loading = true;
  String _searchQuery = '';
  String _selectedSpecies = 'All';

  final List<String> _speciesOptions = ['All', 'Pig', 'Poultry', 'Cow', 'Buffalo', 'Goat', 'Sheep', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    setState(() => _loading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser != null) {
        _animals = await _storage.getAnimalsByFarmer(currentUser.id!.toString());
      } else {
        _animals = await _storage.getAllAnimals();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading animals: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<Animal> _getFilteredAnimals() {
    return _animals.where((animal) {
      final matchesSearch = _searchQuery.isEmpty ||
          animal.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          animal.breed.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesSpecies = _selectedSpecies == 'All' || animal.species == _selectedSpecies;

      return matchesSearch && matchesSpecies;
    }).toList();
  }

  Future<void> _deleteAnimal(Animal animal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Animal'),
        content: Text('Are you sure you want to delete animal ${animal.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storage.deleteAnimal(animal.id);
        await _loadAnimals();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Animal ${animal.id} deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting animal: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredAnimals = _getFilteredAnimals();

    return Scaffold(
      appBar: AppBar(
        title: Text('Animal Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAnimalScreen()),
              );
              _loadAnimals(); // Refresh list after adding
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by ID or breed...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedSpecies,
                  decoration: InputDecoration(
                    labelText: 'Filter by Species',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _speciesOptions.map((species) {
                    return DropdownMenuItem(
                      value: species,
                      child: Text(species),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSpecies = value!);
                  },
                ),
              ],
            ),
          ),

          // Animal Count Summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue[50],
            child: Row(
              children: [
                Text(
                  'Total Animals: ${filteredAnimals.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                Text(
                  'Showing: ${filteredAnimals.length} of ${_animals.length}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Animal List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filteredAnimals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _animals.isEmpty
                                  ? 'No animals added yet'
                                  : 'No animals match your search',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_animals.isEmpty)
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AddAnimalScreen()),
                                  );
                                  _loadAnimals();
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Animal'),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAnimals,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredAnimals.length,
                          itemBuilder: (context, index) {
                            final animal = filteredAnimals[index];
                            return _buildAnimalCard(animal);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalCard(Animal animal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showAnimalDetails(animal),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      // Animal Icon with Photo
                      Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _getSpeciesColor(animal.species).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getSpeciesColor(animal.species).withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: animal.photoPath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(animal.photoPath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(
                                        _getSpeciesIcon(animal.species),
                                        color: _getSpeciesColor(animal.species),
                                        size: 30,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    _getSpeciesIcon(animal.species),
                                    color: _getSpeciesColor(animal.species),
                                    size: 30,
                                  ),
                          ),
                          if (animal.isPregnant == true)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.pink,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.pregnant_woman,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(width: 12),

                      // Basic Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'ID: ${animal.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getSpeciesColor(animal.species).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    animal.species,
                                    style: TextStyle(
                                      color: _getSpeciesColor(animal.species),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Breed: ${animal.breed}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (animal.tagNumber != null) ...[
                              const SizedBox(height: 1),
                              Text(
                                'Tag: ${animal.tagNumber}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Action Menu
                      SizedBox(
                        width: 40,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            switch (value) {
                              case 'view':
                                _showAnimalDetails(animal);
                                break;
                              case 'edit':
                                // TODO: Implement edit functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Edit functionality coming soon')),
                                );
                                break;
                              case 'delete':
                                _deleteAnimal(animal);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 18),
                                  SizedBox(width: 6),
                                  Text('View Details'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 6),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 6),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),

              // Status Indicators
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  // Age & Gender
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 2),
                      Text(
                        '${animal.age} months',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                      if (animal.gender != null) ...[
                        const SizedBox(width: 6),
                        Icon(
                          animal.gender == 'male' ? Icons.male : Icons.female,
                          size: 14,
                          color: animal.gender == 'male' ? Colors.blue : Colors.pink,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          animal.gender!.toUpperCase(),
                          style: TextStyle(
                            color: animal.gender == 'male' ? Colors.blue : Colors.pink,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Health Status
                  if (animal.healthStatus != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getHealthStatusColor(animal.healthStatus!).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getHealthStatusColor(animal.healthStatus!),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        animal.healthStatus!,
                        style: TextStyle(
                          color: _getHealthStatusColor(animal.healthStatus!),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Vaccination Status
                  if (animal.vaccinationStatus != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: animal.vaccinationStatus == 'vaccinated'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        animal.vaccinationStatus == 'vaccinated' ? '✓' : '!',
                        style: TextStyle(
                          color: animal.vaccinationStatus == 'vaccinated' ? Colors.green : Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              // Weight & Birth Date
              if (animal.weight != null || animal.birthDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      if (animal.weight != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.monitor_weight, size: 13, color: Colors.grey[600]),
                            const SizedBox(width: 2),
                            Text(
                              '${animal.weight} kg',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      if (animal.birthDate != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cake, size: 13, color: Colors.grey[600]),
                            const SizedBox(width: 2),
                            Text(
                              DateFormat('MMM dd, yyyy').format(animal.birthDate!),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 11,
                              ),
                            ),
                          ],
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

  IconData _getSpeciesIcon(String species) {
    switch (species.toLowerCase()) {
      case 'pig':
        return Icons.pets;
      case 'poultry':
        return Icons.egg;
      case 'cow':
        return Icons.pets;
      case 'buffalo':
        return Icons.pets;
      case 'goat':
        return Icons.pets;
      case 'sheep':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }

  Color _getSpeciesColor(String species) {
    switch (species.toLowerCase()) {
      case 'pig':
        return Colors.pink;
      case 'poultry':
        return Colors.orange;
      case 'cow':
        return Colors.brown;
      case 'buffalo':
        return Colors.grey;
      case 'goat':
        return Colors.green;
      case 'sheep':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'sick':
        return Colors.red;
      case 'recovering':
        return Colors.orange;
      case 'critical':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  void _showAnimalDetails(Animal animal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getSpeciesIcon(animal.species), color: _getSpeciesColor(animal.species)),
            const SizedBox(width: 8),
            Text('Animal Details - ${animal.id}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Species', animal.species),
              _buildDetailRow('Breed', animal.breed),
              _buildDetailRow('Age', '${animal.age} months'),
              if (animal.gender != null) _buildDetailRow('Gender', animal.gender!.toUpperCase()),
              if (animal.weight != null) _buildDetailRow('Weight', '${animal.weight} kg'),
              if (animal.birthDate != null)
                _buildDetailRow('Birth Date', DateFormat('MMM dd, yyyy').format(animal.birthDate!)),
              if (animal.healthStatus != null) _buildDetailRow('Health Status', animal.healthStatus!),
              if (animal.vaccinationStatus != null) _buildDetailRow('Vaccination', animal.vaccinationStatus!),
              if (animal.lastVaccinationDate != null)
                _buildDetailRow('Last Vaccination', DateFormat('MMM dd, yyyy').format(animal.lastVaccinationDate!)),
              if (animal.nextVaccinationDate != null)
                _buildDetailRow('Next Vaccination', DateFormat('MMM dd, yyyy').format(animal.nextVaccinationDate!)),
              if (animal.tagNumber != null) _buildDetailRow('Tag Number', animal.tagNumber!),
              if (animal.isPregnant == true) _buildDetailRow('Pregnancy Status', 'Pregnant'),
              if (animal.medicalHistory != null && animal.medicalHistory!.isNotEmpty)
                _buildDetailRow('Medical History', animal.medicalHistory!),
              if (animal.notes != null && animal.notes!.isNotEmpty) _buildDetailRow('Notes', animal.notes!),
              _buildDetailRow('Added', DateFormat('MMM dd, yyyy').format(animal.createdAt!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}