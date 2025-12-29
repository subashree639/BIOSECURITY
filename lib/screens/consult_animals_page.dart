import 'dart:async';
import 'package:flutter/material.dart';
import '../services/animal_storage.dart';
import '../models/animal.dart';
import '../services/auth_service.dart';
import 'vet_consult_form.dart';
import 'voice_login_page.dart';

//
// Vet Consult Animals Page
//
class ConsultAnimalsPage extends StatefulWidget {
  @override
  _ConsultAnimalsPageState createState() => _ConsultAnimalsPageState();
}

class _ConsultAnimalsPageState extends State<ConsultAnimalsPage> {
  final _storage = AnimalStorageService();
  List<Animal> _allAnimals = [];
  List<Animal> _filteredAnimals = [];
  final _searchController = TextEditingController();
  bool _loading = true;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAnimals() async {
    _allAnimals = await _storage.loadAnimals();
    _filteredAnimals = List.from(_allAnimals);
    setState(() => _loading = false);
  }

  void _performSearch() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _filteredAnimals = [];
        _hasSearched = false;
      });
      return;
    }

    _filteredAnimals = _allAnimals.where((animal) {
      final queryLower = query.toLowerCase();

      // Search in farmer ID
      final matchesFarmerId = animal.farmerId?.toLowerCase().contains(queryLower) == true;

      // Search in animal ID
      final matchesAnimalId = animal.id.toLowerCase().contains(queryLower);

      // Search in phone number (assuming farmer ID might contain phone)
      final matchesPhone = animal.farmerId?.toLowerCase().contains(queryLower) == true;

      return matchesFarmerId || matchesAnimalId || matchesPhone;
    }).toList();

    setState(() {
      _hasSearched = true;
    });
  }

  Widget _buildSearchInterface() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Single Search Field
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Search Animals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter Farmer ID, Animal ID, or Phone Number',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search, color: Colors.teal.shade600),
                      border: OutlineInputBorder(),
                      hintText: 'Enter farmer ID, animal ID, or phone number',
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _performSearch,
                    icon: Icon(Icons.search),
                    label: Text('Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Results
          Expanded(
            child: _hasSearched
              ? _buildAnimalList(_filteredAnimals)
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Enter search criteria to find animals',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalList(List<Animal> animals) {
    if (animals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'No animals found',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: animals.length,
      itemBuilder: (ctx, i) {
        final animal = animals[i];
        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Icon(Icons.pets, color: Colors.teal.shade700),
            ),
            title: Text('${animal.species} - ${animal.breed}'),
            subtitle: Text('ID: ${animal.id}\nFarmer: ${animal.farmerId}'),
            isThreeLine: true,
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VetConsultFormPage(animal: animal),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consult Animals'),
        backgroundColor: Colors.teal.shade700,
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'logout') {
                await auth.setCurrent('', '');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => VoiceLoginPage()),
                );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(child: Text('Logout'), value: 'logout'),
            ],
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _loading
          ? Center(child: CircularProgressIndicator())
          : _buildSearchInterface(),
      ),
    );
  }
}