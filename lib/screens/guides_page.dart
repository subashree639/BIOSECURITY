import 'dart:async';
import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../services/animal_storage.dart';
import '../services/auth_service.dart';
import 'mrl_graph_page.dart';

//
// Guides Page for Farmer Dashboard - Withdrawal Monitoring
//
class GuidesPage extends StatefulWidget {
  @override
  _GuidesPageState createState() => _GuidesPageState();
}

class _GuidesPageState extends State<GuidesPage> {
  final _storage = AnimalStorageService();
  List<Animal> _withdrawalAnimals = [];
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadWithdrawalAnimals();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadWithdrawalAnimals() async {
    await auth.init();
    final currentFarmerId = auth.currentType == 'farmer' ? auth.currentId : null;

    final allAnimals = await _storage.loadAnimals();
    final now = DateTime.now();
    setState(() {
      _withdrawalAnimals = allAnimals.where((a) {
        // First filter by current farmer
        if (currentFarmerId != null && a.farmerId != currentFarmerId) return false;

        // Then filter by withdrawal status
        if (a.withdrawalEnd == null) return false;
        try {
          final end = DateTime.parse(a.withdrawalEnd!);
          return end.isAfter(now);
        } catch (_) {
          return false;
        }
      }).toList();
      _loading = false;
    });
  }

  String _formatCountdown(DateTime endTime) {
    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.isNegative) return 'Expired';

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    if (days > 0) {
      return '$days days ${hours}h ${minutes}m ${seconds}s';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  void _showAnimalDetails(Animal a) {
    final endTime = DateTime.parse(a.withdrawalEnd!);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(child: Text('Withdrawal Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close))
                ],
              ),
              SizedBox(height: 16),

              // Real-time countdown - prominently positioned
              StreamBuilder(
                stream: Stream.periodic(Duration(seconds: 1)),
                builder: (context, snapshot) => Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade100, Colors.orange.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade200,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.timer, size: 32, color: Colors.orange.shade800),
                      SizedBox(height: 8),
                      Text('Time Remaining', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                      SizedBox(height: 8),
                      Text(
                        _formatCountdown(endTime),
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animal details section
                      Text('Animal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                      SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(child: Icon(Icons.vpn_key)),
                                title: Text('Animal ID'),
                                subtitle: Text(a.id),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading: CircleAvatar(child: Icon(Icons.category)),
                                title: Text('Species & Breed'),
                                subtitle: Text('${a.species} - ${a.breed}'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading: CircleAvatar(child: Icon(Icons.calendar_today)),
                                title: Text('Age'),
                                subtitle: Text(a.age),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Medicine details section
                      Text('Medicine & Withdrawal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                      SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(child: Icon(Icons.medical_services)),
                                title: Text('Last Medicine'),
                                subtitle: Text('${a.lastDrug ?? 'N/A'} • ${a.lastDosage ?? 'N/A'} mg/kg'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading: CircleAvatar(child: Icon(Icons.schedule)),
                                title: Text('Withdrawal Period'),
                                subtitle: Text('${a.withdrawalDays ?? 0} days (${a.productType ?? 'milk'})'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading: CircleAvatar(child: Icon(Icons.access_time)),
                                title: Text('Started'),
                                subtitle: Text(a.withdrawalStart != null
                                    ? DateTime.parse(a.withdrawalStart!).toLocal().toString().split(' ')[0]
                                    : 'N/A'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading: CircleAvatar(child: Icon(Icons.flag)),
                                title: Text('Ends'),
                                subtitle: Text(a.withdrawalEnd != null
                                    ? DateTime.parse(a.withdrawalEnd!).toLocal().toString().split(' ')[0]
                                    : 'N/A'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // MRL info
                      if (a.currentMRL != null) ...[
                        SizedBox(height: 16),
                        Text('MRL Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                        SizedBox(height: 8),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(child: Icon(Icons.show_chart)),
                                  title: Text('Current MRL'),
                                  subtitle: Text('${a.currentMRL!.toStringAsFixed(3)} units'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                ListTile(
                                  leading: CircleAvatar(child: Icon(a.mrlStatus == 'Safe to Consume' ? Icons.check_circle : Icons.warning)),
                                  title: Text('Status'),
                                  subtitle: Text(a.mrlStatus ?? 'Unknown'),
                                  tileColor: a.mrlStatus == 'Safe to Consume' ? Colors.green.shade50 : Colors.red.shade50,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Vet details - moved to top of scrollable area
                      SizedBox(height: 16),
                      Text('Veterinary Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                      SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              if (a.vetId != null && a.vetId!.isNotEmpty) ...[
                                ListTile(
                                  leading: CircleAvatar(child: Icon(Icons.person)),
                                  title: Text('Consulting Vet'),
                                  subtitle: Text(a.vetUsername ?? 'Unknown Vet'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                ListTile(
                                  leading: CircleAvatar(child: Icon(Icons.badge)),
                                  title: Text('Vet ID'),
                                  subtitle: Text(a.vetId!),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ] else ...[
                                ListTile(
                                  leading: CircleAvatar(child: Icon(Icons.person_off)),
                                  title: Text('Consulting Vet'),
                                  subtitle: Text('No vet assigned'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Action buttons
                      Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => MRLGraphPage(animal: a)),
                          ),
                          icon: Icon(Icons.show_chart),
                          label: Text('View MRL Graph'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Withdrawal Guides'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadWithdrawalAnimals,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _withdrawalAnimals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 72, color: Colors.green.shade400),
                      SizedBox(height: 16),
                      Text(
                        'No animals in withdrawal period',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'All your animals are safe for consumption',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: _withdrawalAnimals.length,
                  itemBuilder: (ctx, i) {
                    final a = _withdrawalAnimals[i];
                    final endTime = DateTime.parse(a.withdrawalEnd!);
                    final countdown = _formatCountdown(endTime);
                    final isExpiringSoon = endTime.difference(DateTime.now()).inHours < 24;

                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isExpiringSoon ? Colors.orange.shade100 : Colors.blue.shade100,
                          child: Icon(
                            Icons.timer,
                            color: isExpiringSoon ? Colors.orange.shade700 : Colors.blue.shade700,
                          ),
                        ),
                        title: Text('${a.species} - ${a.breed} (${a.id})'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Medicine: ${a.lastDrug ?? 'N/A'}'),
                            Text(
                              'Time left: $countdown',
                              style: TextStyle(
                                color: isExpiringSoon ? Colors.orange.shade800 : Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (a.vetUsername != null)
                              Text('Vet: ${a.vetUsername}', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => _showAnimalDetails(a),
                      ),
                    );
                  },
                ),
    );
  }
}