import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/animal_storage.dart';
import '../services/auth_service.dart';
import '../models/animal.dart';
import 'add_animal_page.dart';

//
// Animal Database (responsive & pixel bug fixes)
//
class AnimalDatabasePage extends StatefulWidget {
  @override
  _AnimalDatabasePageState createState() => _AnimalDatabasePageState();
}
class _AnimalDatabasePageState extends State<AnimalDatabasePage> {
  final _storage = AnimalStorageService();
  final _auth = AuthService();
  List<Animal> _all = [];
  List<Animal> _allAnimals = [];
  List<Animal> _filtered = [];
  Map<String, List<Animal>> _animalsByFarmer = {};
  Map<String, String> _farmerLocations = {};
  String _q = '';
  String? _filterSpecies;
  String? _selectedFarmerId;
  bool _loading = true;
  final speciesOptions = ['Cow','Buffalo','Goat','Sheep','Pig','Poultry','Other'];

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    _all = await _storage.loadAnimals();
    _allAnimals = List.from(_all);
    await _organizeAnimalsByFarmer();
    _apply();
    setState(()=>_loading=false);
  }

  Future<void> _organizeAnimalsByFarmer() async {
    _animalsByFarmer.clear();
    _farmerLocations.clear();

    // Group animals by farmer ID
    for (final animal in _all) {
      final farmerId = animal.farmerId ?? 'Unknown';
      if (_animalsByFarmer[farmerId] == null) {
        _animalsByFarmer[farmerId] = [];
      }
      _animalsByFarmer[farmerId]!.add(animal);
    }

    // Load farmer locations from Firebase
    await _loadFarmerLocations();
  }

  Future<void> _loadFarmerLocations() async {
    try {
      _farmerLocations.clear();

      // Load farmer locations from Firebase
      for (final farmerId in _animalsByFarmer.keys) {
        final farmerData = await _auth.getFarmerData(farmerId);
        if (farmerData != null) {
          final farmLocation = farmerData['location'] ?? 'Location not available';
          _farmerLocations[farmerId] = farmLocation;
        } else {
          _farmerLocations[farmerId] = 'Location not available';
        }
      }
    } catch (e) {
      print('Error loading farmer locations: $e');
      // Fallback to placeholder data
      _farmerLocations = {
        for (final farmerId in _animalsByFarmer.keys)
          farmerId: 'Farm Location for $farmerId',
      };
    }
  }

  void _apply() {
    final q = _q.trim().toLowerCase();

    if (_selectedFarmerId != null) {
      // Filter animals within selected farmer
      final farmerAnimals = _animalsByFarmer[_selectedFarmerId] ?? [];
      _filtered = farmerAnimals.where((a) {
        final mq = q.isEmpty || a.id.toLowerCase().contains(q) || a.species.toLowerCase().contains(q) || a.breed.toLowerCase().contains(q);
        final ms = _filterSpecies == null || _filterSpecies == a.species;
        return mq && ms;
      }).toList();
    } else {
      // Show all animals or filter across all farmers
      _filtered = _all.where((a) {
        final mq = q.isEmpty || a.id.toLowerCase().contains(q) || a.species.toLowerCase().contains(q) || a.breed.toLowerCase().contains(q) || (a.farmerId?.toLowerCase().contains(q) ?? false);
        final ms = _filterSpecies == null || _filterSpecies == a.species;
        return mq && ms;
      }).toList();
    }
  }

  void _applyFilter() {
    _apply();
    setState(() {});
  }

  Future<void> _delete(int idx) async {
    await _storage.deleteAnimalAt(idx);
    await _load();
  }

  Future<void> _deleteAnimal(int idx) async {
    await _delete(idx);
  }


  bool _inWithdrawal(Animal a) {
    if (a.withdrawalEnd == null) return false;
    try { return DateTime.now().isBefore(DateTime.parse(a.withdrawalEnd!)); } catch(_) { return false; }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.animalDatabase),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _load),
          if (_selectedFarmerId != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFarmerId = null;
                  _q = '';
                  _filterSpecies = null;
                });
                _apply();
              },
              icon: Icon(Icons.arrow_back, color: Colors.white),
              label: Text('All Farmers', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.green.shade700,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddAnimalPage())).then((_)=>_load()),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: _loading ? Center(child: CircularProgressIndicator()) : Column(children: [
            if (_selectedFarmerId == null) ...[
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by farmer ID, location, species or breed',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v){ setState(()=>_q=v); _apply(); },
              ),
              SizedBox(height: 8),
              SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, children: [
                SizedBox(width:8),
                ChoiceChip(
                  label: Text('All Species'),
                  selected: _filterSpecies==null,
                  onSelected: (_) { setState(()=>_filterSpecies=null); _apply(); },
                ),
                SizedBox(width:8),
                ...speciesOptions.map((s) => Padding(
                  padding: EdgeInsets.only(right:8),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: _filterSpecies==s,
                    onSelected: (sel) { setState(()=> _filterSpecies = sel? s : null); _apply(); },
                  ),
                )).toList(),
              ])),
              SizedBox(height: 8),
            ] else ...[
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search animals by ID, species or breed',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v){ setState(()=>_q=v); _apply(); },
              ),
              SizedBox(height: 8),
              SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, children: [
                SizedBox(width:8),
                ChoiceChip(
                  label: Text('All Species'),
                  selected: _filterSpecies==null,
                  onSelected: (_) { setState(()=>_filterSpecies=null); _apply(); },
                ),
                SizedBox(width:8),
                ...speciesOptions.map((s) => Padding(
                  padding: EdgeInsets.only(right:8),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: _filterSpecies==s,
                    onSelected: (sel) { setState(()=> _filterSpecies = sel? s : null); _apply(); },
                  ),
                )).toList(),
              ])),
              SizedBox(height: 8),
            ],
            Expanded(
              child: _selectedFarmerId == null ? _buildFarmerList() : _buildAnimalGrid(),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildFarmerList() {
    final farmerIds = _animalsByFarmer.keys.where((farmerId) {
      final query = _q.trim().toLowerCase();
      if (query.isEmpty) return true;
      return farmerId.toLowerCase().contains(query) ||
             (_farmerLocations[farmerId]?.toLowerCase().contains(query) ?? false);
    }).toList();

    if (farmerIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 70, color: Colors.grey[400]),
            SizedBox(height: 12),
            Text('No farmers found', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Add animals to see farmers here')
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: farmerIds.length,
      itemBuilder: (ctx, i) => _buildFarmerCard(farmerIds[i]),
    );
  }

  Widget _buildFarmerCard(String farmerId) {
    final animals = _animalsByFarmer[farmerId] ?? [];
    final location = _farmerLocations[farmerId] ?? 'Location not available';

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFarmerId = farmerId;
            _q = '';
            _filterSpecies = null;
          });
          _apply();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.green.shade100,
                    child: Icon(Icons.person, color: Colors.green.shade700),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Farmer ID: $farmerId',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${animals.length} animals',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalGrid() {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 70, color: Colors.grey[400]),
            SizedBox(height: 12),
            Text('No animals found', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Try adjusting your search or filters')
          ],
        ),
      );
    }

    final cols = MediaQuery.of(context).size.width > 900 ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1);
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: _filtered.length,
      itemBuilder: (ctx, i) => _buildAnimalCard(i),
    );
  }

  Widget _buildAnimalCard(int i) {
    final a = _filtered[i];
    final inW = _inWithdrawal(a);
    final farmerLocation = _farmerLocations[a.farmerId] ?? 'Unknown Location';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green.shade50,
                  child: Icon(Icons.pets, color: Colors.green.shade700, size: 20),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.id,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Farmer: ${a.farmerId ?? 'Unknown'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                a.species,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
            SizedBox(height: 6),
            Text(
              a.breed,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.cake, size: 12, color: Colors.grey[500]),
                SizedBox(width: 4),
                Text(
                  a.age,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                SizedBox(width: 8),
                Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    farmerLocation,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _showDetails(a),
                  icon: Icon(Icons.visibility, size: 14),
                  label: Text('View', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 8)),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final realIndex = _all.indexWhere((el) => el.id == a.id);
                    if (realIndex != -1) {
                      await _storage.deleteAnimalAt(realIndex);
                      await _load();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Animal deleted'))
                      );
                    }
                  },
                  icon: Icon(Icons.delete, size: 14, color: Colors.red),
                  label: Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
                  style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(Animal a) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(18.0),
        child: Wrap(
          children: [
            Row(
              children: [
                Expanded(child: Text('Animal Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close))
              ],
            ),
            SizedBox(height: 8),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.vpn_key)),
              title: Text('ID'),
              subtitle: Text(a.id),
            ),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.pets)),
              title: Text('Species'),
              subtitle: Text(a.species),
            ),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.info)),
              title: Text('Breed'),
              subtitle: Text(a.breed),
            ),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.calendar_today)),
              title: Text('Age'),
              subtitle: Text(a.age),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                final realIndex = _all.indexWhere((el) => el.id == a.id);
                if (realIndex != -1) {
                  await _storage.deleteAnimalAt(realIndex);
                  await _load();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted')));
                }
              },
              icon: Icon(Icons.delete),
              label: Text('Delete Animal'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAnimalDetails(Animal a) {
    _showDetails(a);
  }
}