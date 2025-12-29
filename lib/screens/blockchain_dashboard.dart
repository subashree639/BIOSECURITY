import 'package:flutter/material.dart';
import '../services/animal_storage.dart';

class BlockchainDashboard extends StatefulWidget {
  const BlockchainDashboard({Key? key}) : super(key: key);

  @override
  _BlockchainDashboardState createState() => _BlockchainDashboardState();
}

class _BlockchainDashboardState extends State<BlockchainDashboard> {
  final AnimalStorageService _storage = AnimalStorageService();
  Map<String, dynamic> _stats = {};
  bool _loading = true;
  bool _verifying = false;
  String? _certificateData;

  @override
  void initState() {
    super.initState();
    _loadBlockchainStats();
  }

  Future<void> _loadBlockchainStats() async {
    setState(() => _loading = true);
    try {
      final stats = await _storage.getBlockchainStatistics();
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load blockchain stats: $e')),
      );
    }
  }

  Future<void> _verifyChain() async {
    setState(() => _verifying = true);
    try {
      final isValid = await _storage.verifyBlockchainIntegrity();
      setState(() => _verifying = false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: [
              Icon(
                isValid ? Icons.verified : Icons.error,
                color: isValid ? Colors.green : Colors.red,
              ),
              SizedBox(width: 8),
              Text('Blockchain Verification'),
            ],
          ),
          content: Text(
            isValid
                ? '✅ Blockchain integrity verified! All data is authentic and tamper-proof.'
                : '❌ Blockchain integrity compromised! Data may have been tampered with.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _verifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
    }
  }

  Future<void> _exportBlockchain() async {
    try {
      final data = await _storage.exportBlockchainData();
      // In a real app, you might save this to a file or share it
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blockchain data exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blockchain Dashboard'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBlockchainStats,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.link, color: Colors.blue.shade700, size: 32),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Blockchain Data Integrity',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                    Text(
                                      'Secure, tamper-proof record of all animal treatments',
                                      style: TextStyle(
                                        color: Colors.blue.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Blocks',
                          _stats['totalBlocks']?.toString() ?? '0',
                          Icons.inventory,
                          Colors.purple,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Transactions',
                          _stats['totalTransactions']?.toString() ?? '0',
                          Icons.swap_horiz,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Animals',
                          _stats['uniqueAnimals']?.toString() ?? '0',
                          Icons.pets,
                          Colors.green,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          _stats['pendingTransactions']?.toString() ?? '0',
                          Icons.schedule,
                          Colors.amber,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Integrity Status
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Integrity Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                _stats['chainValid'] == true
                                    ? Icons.verified_user
                                    : Icons.warning,
                                color: _stats['chainValid'] == true
                                    ? Colors.green
                                    : Colors.red,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _stats['chainValid'] == true
                                      ? 'Blockchain is valid and secure'
                                      : 'Blockchain integrity compromised',
                                  style: TextStyle(
                                    color: _stats['chainValid'] == true
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _verifying ? null : _verifyChain,
                                icon: _verifying
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(Icons.verified),
                                label: Text(_verifying ? 'Verifying...' : 'Verify'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Features
                  Text(
                    'Blockchain Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 12),

                  _buildFeatureCard(
                    'Cryptographic Security',
                    'All transactions are digitally signed and cryptographically secured',
                    Icons.security,
                    Colors.blue,
                  ),

                  _buildFeatureCard(
                    'Immutable Records',
                    'Once recorded, data cannot be altered or deleted',
                    Icons.lock,
                    Colors.green,
                  ),

                  _buildFeatureCard(
                    'Transparent Audit Trail',
                    'Complete history of all changes and treatments',
                    Icons.visibility,
                    Colors.purple,
                  ),

                  _buildFeatureCard(
                    'Regulatory Compliance',
                    'Tamper-proof records for regulatory reporting',
                    Icons.gavel,
                    Colors.orange,
                  ),

                  SizedBox(height: 16),

                  // Actions
                  Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _exportBlockchain,
                          icon: Icon(Icons.download),
                          label: Text('Export Data'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade600,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to detailed blockchain viewer
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Detailed viewer coming soon')),
                            );
                          },
                          icon: Icon(Icons.search),
                          label: Text('View Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade600,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
      ),
    );
  }
}