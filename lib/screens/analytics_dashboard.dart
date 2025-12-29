import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';
import '../services/animal_storage.dart';
import '../services/firestore_service.dart';
import '../models/firestore_models.dart' as firestore;
import '../l10n/app_localizations.dart';
import '../models/animal.dart';
import '../main.dart'; // For global auth instance

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({Key? key}) : super(key: key);

  @override
  _AnalyticsDashboardState createState() => _AnalyticsDashboardState();
}

enum AnalyticsState { loading, loaded, error, empty }

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  final AnalyticsService _analytics = AnalyticsService();
  final AnimalStorageService _storage = AnimalStorageService();
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, dynamic>? _analysisData;
  firestore.KPIs? _kpiData;
  AnalyticsState _state = AnalyticsState.loading;
  bool _usingDemoData = false;
  String? _errorMessage;
  DateTime _startDate = DateTime.now().subtract(Duration(days: 90));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
    _listenToKPIsStream();
  }

  void _listenToKPIsStream() {
    _firestoreService.getKPIsStream().listen((kpis) {
      setState(() {
        _kpiData = kpis;
      });
    });
  }

  Future<void> _loadAnalytics() async {
    print('DEBUG: Analytics Dashboard - Starting _loadAnalytics');
    setState(() {
      _state = AnalyticsState.loading;
      _errorMessage = null;
    });

    try {
      // Get current farmer ID to filter animals
      await auth.init();
      final currentFarmerId =
          auth.currentType == 'farmer' ? auth.currentId : null;
      print('DEBUG: Analytics Dashboard - Current farmer ID: $currentFarmerId');

      final allAnimals = await _storage.loadAnimals();
      print(
          'DEBUG: Analytics Dashboard - Loaded ${allAnimals.length} total animals');

      // Filter animals by current farmer ID
      final farmerAnimals = currentFarmerId != null
          ? allAnimals
              .where((animal) => animal.farmerId == currentFarmerId)
              .toList()
          : [];
      print(
          'DEBUG: Analytics Dashboard - Filtered to ${farmerAnimals.length} farmer animals');

      // Use demo data if no real animals exist for this farmer
      final animalsToAnalyze =
          farmerAnimals.isEmpty ? _getDemoAnimals() : farmerAnimals;
      _usingDemoData = farmerAnimals.isEmpty;
      print(
          'DEBUG: Analytics Dashboard - Using ${animalsToAnalyze.length} animals for analysis, demo data: $_usingDemoData');

      final analysis = await _analytics.generateAMUTrendAnalysis(
        animals: animalsToAnalyze as List<Animal>,
        startDate: _startDate,
        endDate: _endDate,
      );
      print(
          'DEBUG: Analytics Dashboard - Generated analysis data: ${'success'}');

      // Load KPI data from Firestore
      final kpiData = await _firestoreService.getKPIs();
      print(
          'DEBUG: Analytics Dashboard - Loaded KPI data: ${kpiData != null ? 'success' : 'null'}');

      print(
          'DEBUG: Analytics Dashboard - Analysis keys: ${analysis.keys.toList()}');
      if (analysis.containsKey('summary')) {
        print('DEBUG: Analytics Dashboard - Summary data present');
      } else {
        print('DEBUG: Analytics Dashboard - Summary data missing');
      }

      // Validate the analysis data structure before setting state
      print('DEBUG: Analytics Dashboard - Validating analysis data structure');
      try {
        // Check summary data
        if (analysis.containsKey('summary')) {
          final summary = analysis['summary'] as Map<String, dynamic>;
          print(
              'DEBUG: Analytics Dashboard - Summary keys: ${summary.keys.toList()}');
          print(
              'DEBUG: Analytics Dashboard - treatment_rate type: ${summary['treatment_rate']?.runtimeType}');
          print(
              'DEBUG: Analytics Dashboard - compliance_issues type: ${summary['compliance_issues']?.runtimeType}');
        }

        // Check compliance data
        if (analysis.containsKey('compliance')) {
          final compliance = analysis['compliance'] as Map<String, dynamic>;
          print(
              'DEBUG: Analytics Dashboard - compliance_rate type: ${compliance['compliance_rate']?.runtimeType}');
        }

        // Check trends data
        if (analysis.containsKey('trends')) {
          final trends = analysis['trends'] as Map<String, dynamic>;
          if (trends.containsKey('trend_analysis')) {
            final trendAnalysis =
                trends['trend_analysis'] as Map<String, dynamic>;
            print(
                'DEBUG: Analytics Dashboard - volatility type: ${trendAnalysis['volatility']?.runtimeType}');
          }
        }

        setState(() {
          _analysisData = analysis;
          _kpiData = kpiData;
          _state = AnalyticsState.loaded;
        });
        print(
            'DEBUG: Analytics Dashboard - Set state completed successfully, state: $_state');
      } catch (validationError) {
        print(
            'DEBUG: Analytics Dashboard - Validation error: $validationError');
        print('DEBUG: Analytics Dashboard - Analysis data: $analysis');
        setState(() {
          _state = AnalyticsState.error;
          _errorMessage = 'Data validation error: $validationError';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data validation error: $validationError')),
        );
      }
    } catch (e, stackTrace) {
      print('DEBUG: Analytics Dashboard - Error in _loadAnalytics: $e');
      print('DEBUG: Analytics Dashboard - Stack trace: $stackTrace');
      setState(() {
        _state = AnalyticsState.error;
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analytics error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'DEBUG: Analytics Dashboard - Building widget, state: $_state, analysisData null: ${_analysisData == null}');

    final localizations = AppLocalizations.of(context);
    print(
        'DEBUG: Analytics Dashboard - Localizations available: ${localizations != null}');

    return Scaffold(
      appBar: AppBar(
        title: Text(
            localizations?.amuAnalyticsDashboard ?? 'AMU Analytics Dashboard'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed:
                _state == AnalyticsState.loading ? null : _showDatePicker,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _state == AnalyticsState.loading ? null : _loadAnalytics,
          ),
        ],
      ),
      body: _buildBody(localizations),
    );
  }

  Widget _buildBody(AppLocalizations? localizations) {
    switch (_state) {
      case AnalyticsState.loading:
        return _buildLoadingView();
      case AnalyticsState.loaded:
        return _buildLoadedView(localizations);
      case AnalyticsState.error:
        return _buildErrorView(localizations);
      case AnalyticsState.empty:
        return _buildEmptyView(localizations);
    }
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading analytics data...',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedView(AppLocalizations? localizations) {
    if (_analysisData == null) {
      // This should not happen in loaded state, but handle it gracefully
      return _buildErrorView(localizations);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Demo data notice
          if (_usingDemoData)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo data shown - Add real animals and treatments to see your actual analytics',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Date Range Display
          _buildDateRangeCard(),

          SizedBox(height: 16),

          // Summary Cards
          _buildSummaryCards(),

          SizedBox(height: 16),

          // KPI Cards from Firestore
          if (_kpiData != null) _buildKPICards(),

          SizedBox(height: 16),

          // Trend Analysis
          _buildTrendAnalysis(),

          SizedBox(height: 16),

          // Compliance Analysis
          _buildComplianceAnalysis(),

          SizedBox(height: 16),

          // Medicine Usage Chart
          _buildMedicineUsageChart(),

          SizedBox(height: 16),

          // Recommendations
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue.shade700),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)?.analysisPeriod(
                        _startDate.toString().split(' ')[0],
                        _endDate.toString().split(' ')[0]) ??
                    'Analysis Period: ${_startDate.toString().split(' ')[0]} to ${_endDate.toString().split(' ')[0]}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final summary = _analysisData!['summary'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.summaryStatistics ??
              'Summary Statistics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                AppLocalizations.of(context)?.totalAnimals ?? 'Total Animals',
                (summary['total_animals'] as int?)?.toString() ?? '0',
                Icons.pets,
                Colors.green,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                AppLocalizations.of(context)?.animalsTreated ??
                    'Animals Treated',
                (summary['animals_treated'] as int?)?.toString() ?? '0',
                Icons.medical_services,
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
                AppLocalizations.of(context)?.treatmentRate ?? 'Treatment Rate',
                '${((summary['treatment_rate'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.blue,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                AppLocalizations.of(context)?.complianceIssues ??
                    'Compliance Issues',
                (summary['compliance_issues'] as int?)?.toString() ?? '0',
                Icons.warning,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
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

  Widget _buildKPICards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System KPIs',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Livestock',
                _kpiData!.totalLivestock.toString(),
                Icons.pets,
                Colors.green.shade600,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Active Withdrawal',
                _kpiData!.activeWithdrawal.toString(),
                Icons.schedule,
                Colors.orange.shade600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Compliance Rate',
                '${_kpiData!.complianceRate.toStringAsFixed(1)}%',
                Icons.verified,
                _kpiData!.complianceRate >= 80
                    ? Colors.green.shade600
                    : Colors.red.shade600,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Pending Reviews',
                _kpiData!.pendingReviews.toString(),
                Icons.pending,
                Colors.blue.shade600,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Nested KPIs
        if (_kpiData!.farmersKPIs != null) ...[
          Text(
            'Farmers KPIs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _buildNestedKPICards(_kpiData!.farmersKPIs!),
          SizedBox(height: 16),
        ],
        if (_kpiData!.livestockKPIs != null) ...[
          Text(
            'Livestock KPIs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _buildNestedKPICards(_kpiData!.livestockKPIs!),
          SizedBox(height: 16),
        ],
        if (_kpiData!.vetsKPIs != null) ...[
          Text(
            'Veterinarians KPIs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _buildNestedKPICards(_kpiData!.vetsKPIs!),
          SizedBox(height: 16),
        ],
        if (_kpiData!.usersKPIs != null) ...[
          Text(
            'Users KPIs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _buildNestedKPICards(_kpiData!.usersKPIs!),
          SizedBox(height: 16),
        ],
        if (_kpiData!.translationsKPIs != null) ...[
          Text(
            'Translations KPIs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _buildNestedKPICards(_kpiData!.translationsKPIs!),
        ],
      ],
    );
  }

  Widget _buildNestedKPICards(firestore.KPIs kpis) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Livestock',
                kpis.totalLivestock.toString(),
                Icons.pets,
                Colors.green.shade400,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Active Withdrawal',
                kpis.activeWithdrawal.toString(),
                Icons.schedule,
                Colors.orange.shade400,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Compliance Rate',
                '${kpis.complianceRate.toStringAsFixed(1)}%',
                Icons.verified,
                kpis.complianceRate >= 80
                    ? Colors.green.shade400
                    : Colors.red.shade400,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Pending Reviews',
                kpis.pendingReviews.toString(),
                Icons.pending,
                Colors.blue.shade400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendAnalysis() {
    final trends = _analysisData!['trends'] as Map<String, dynamic>;
    final trendAnalysis = trends['trend_analysis'] as Map<String, dynamic>;

    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.trendAnalysis ?? 'Trend Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTrendIndicator(
                    AppLocalizations.of(context)?.trendDirection ??
                        'Trend Direction',
                    trendAnalysis['trend_direction']?.toString() ?? 'Unknown',
                    _getTrendColor(
                        trendAnalysis['trend_direction']?.toString() ?? ''),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildTrendIndicator(
                    AppLocalizations.of(context)?.volatility ?? 'Volatility',
                    '${((trendAnalysis['volatility'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                    Colors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.seasonalPatterns ??
                  'Seasonal Patterns',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildSeasonalPatterns(
                trends['seasonal_patterns'] as Map<String, dynamic>?),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalPatterns(Map<String, dynamic>? patterns) {
    if (patterns == null)
      return Text(AppLocalizations.of(context)?.noSeasonalPatternsDetected ??
          'No seasonal patterns detected');

    final peakMonths =
        (patterns['peak_months'] as List<dynamic>?)?.cast<String>() ?? [];
    final lowMonths =
        (patterns['low_months'] as List<dynamic>?)?.cast<String>() ?? [];

    return Column(
      children: [
        if (peakMonths.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(AppLocalizations.of(context)
                      ?.peakMonths(peakMonths.join(', ')) ??
                  'Peak months: ${peakMonths.join(', ')}'),
            ],
          ),
        ],
        if (lowMonths.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.trending_down, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(AppLocalizations.of(context)
                      ?.lowMonths(lowMonths.join(', ')) ??
                  'Low months: ${lowMonths.join(', ')}'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildComplianceAnalysis() {
    final compliance = _analysisData!['compliance'] as Map<String, dynamic>;

    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.complianceAnalysis ??
                  'Compliance Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildComplianceMetric(
                    AppLocalizations.of(context)?.complianceRate ??
                        'Compliance Rate',
                    '${((compliance['compliance_rate'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1)}%',
                    ((compliance['compliance_rate'] as num?)?.toDouble() ??
                                0.0) >
                            80
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildComplianceMetric(
                    AppLocalizations.of(context)?.compliantAnimals ??
                        'Compliant Animals',
                    (compliance['compliant_animals'] as int?)?.toString() ??
                        '0',
                    Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.riskFactors ?? 'Risk Factors',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildRiskFactors(
                (compliance['risk_factors'] as Map<String, dynamic>?)
                        ?.map((k, v) => MapEntry(k, v as int)) ??
                    {}),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceMetric(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFactors(Map<String, int> riskFactors) {
    if (riskFactors.isEmpty) {
      return Text(AppLocalizations.of(context)!.noSignificantRiskFactors);
    }

    return Column(
      children: riskFactors.entries.map((entry) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 16),
              SizedBox(width: 8),
              Expanded(
                child:
                    Text('${entry.key.replaceAll('_', ' ')}: ${entry.value}'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMedicineUsageChart() {
    print('DEBUG: Analytics Dashboard - Building medicine usage chart');

    final summary = _analysisData!['summary'] as Map<String, dynamic>;
    print(
        'DEBUG: Analytics Dashboard - Summary keys: ${summary.keys.toList()}');

    final medicineUsage = (summary['medicine_usage'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v as int)) ??
        {};
    print(
        'DEBUG: Analytics Dashboard - Medicine usage: $medicineUsage, isEmpty: ${medicineUsage.isEmpty}');

    if (medicineUsage.isEmpty) {
      print(
          'DEBUG: Analytics Dashboard - Medicine usage is empty, showing no data message');
      return Card(
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
              child: Text(AppLocalizations.of(context)?.noMedicineUsageData ??
                  'No medicine usage data')),
        ),
      );
    }

    final sortedMedicines = medicineUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.medicineUsageDistribution ??
                  'Medicine Usage Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: sortedMedicines.first.value.toDouble(),
                  barGroups: sortedMedicines.take(5).map((entry) {
                    return BarChartGroupData(
                      x: sortedMedicines.indexOf(entry),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.blue,
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < sortedMedicines.length) {
                            return Text(
                              sortedMedicines[value.toInt()].key,
                              style: TextStyle(fontSize: 10),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations =
        (_analysisData!['recommendations'] as List<dynamic>?)?.cast<String>() ??
            [];

    if (recommendations.isEmpty) {
      return Card(
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
              child: Text(
                  AppLocalizations.of(context)?.noRecommendationsAvailable ??
                      'No recommendations available')),
        ),
      );
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.recommendations ??
                  'Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...recommendations.map((rec) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Expanded(child: Text(rec)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'increasing':
        return Colors.red;
      case 'decreasing':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showDatePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadAnalytics();
    }
  }

  List<Animal> _getDemoAnimals() {
    // Create demo animals with treatment history for analytics demonstration
    final now = DateTime.now();
    final demoAnimals = <Animal>[];

    // Demo animal 1: Cow with multiple treatments
    final cow1 = Animal(
      id: 'DEMO-COW-001',
      species: 'Cow',
      age: '4 years',
      breed: 'Holstein',
      farmerId: 'demo-farmer',
      lastDrug: 'Amoxicillin',
      lastDosage: '10 mg/kg',
      withdrawalStart: now.subtract(Duration(days: 30)).toIso8601String(),
      withdrawalEnd: now.subtract(Duration(days: 15)).toIso8601String(),
      productType: 'Milk',
      withdrawalDays: 14,
      currentMRL: 0.02,
      mrlStatus: 'Safe to Consume',
      vetId: 'vet-001',
      vetUsername: 'Dr. Smith',
      treatmentHistory: [
        TreatmentRecord(
          drugName: 'Amoxicillin',
          dosage: '10 mg/kg',
          dateAdministered: now.subtract(Duration(days: 30)),
          administeredBy: 'Dr. Smith',
          condition: 'Mastitis',
          notes: 'Routine treatment',
          cost: 25.0,
          outcome: 'Recovered',
        ),
        TreatmentRecord(
          drugName: 'Oxytetracycline',
          dosage: '8 mg/kg',
          dateAdministered: now.subtract(Duration(days: 60)),
          administeredBy: 'Dr. Smith',
          condition: 'Respiratory infection',
          notes: 'Preventive treatment',
          cost: 30.0,
          outcome: 'Improved',
        ),
      ],
    );

    // Demo animal 2: Buffalo with recent treatment
    final buffalo1 = Animal(
      id: 'DEMO-BUFFALO-001',
      species: 'Buffalo',
      age: '3 years',
      breed: 'Murrah',
      farmerId: 'demo-farmer',
      lastDrug: 'Enrofloxacin',
      lastDosage: '5 mg/kg',
      withdrawalStart: now.subtract(Duration(days: 10)).toIso8601String(),
      withdrawalEnd: now.add(Duration(days: 5)).toIso8601String(),
      productType: 'Milk',
      withdrawalDays: 14,
      currentMRL: 0.15,
      mrlStatus: 'In Withdrawal',
      vetId: 'vet-002',
      vetUsername: 'Dr. Johnson',
      treatmentHistory: [
        TreatmentRecord(
          drugName: 'Enrofloxacin',
          dosage: '5 mg/kg',
          dateAdministered: now.subtract(Duration(days: 10)),
          administeredBy: 'Dr. Johnson',
          condition: 'Diarrhea',
          notes: 'Antibiotic treatment',
          cost: 20.0,
          outcome: 'Recovering',
        ),
      ],
    );

    // Demo animal 3: Goat with old treatment
    final goat1 = Animal(
      id: 'DEMO-GOAT-001',
      species: 'Goat',
      age: '2 years',
      breed: 'Saanen',
      farmerId: 'demo-farmer',
      lastDrug: 'Florfenicol',
      lastDosage: '20 mg/kg',
      withdrawalStart: now.subtract(Duration(days: 45)).toIso8601String(),
      withdrawalEnd: now.subtract(Duration(days: 30)).toIso8601String(),
      productType: 'Meat',
      withdrawalDays: 28,
      currentMRL: 0.01,
      mrlStatus: 'Safe to Consume',
      vetId: 'vet-001',
      vetUsername: 'Dr. Smith',
      treatmentHistory: [
        TreatmentRecord(
          drugName: 'Florfenicol',
          dosage: '20 mg/kg',
          dateAdministered: now.subtract(Duration(days: 45)),
          administeredBy: 'Dr. Smith',
          condition: 'Pneumonia',
          notes: 'Severe infection',
          cost: 35.0,
          outcome: 'Cured',
        ),
      ],
    );

    demoAnimals.addAll([cow1, buffalo1, goat1]);
    return demoAnimals;
  }

  Widget _buildErrorView(AppLocalizations? localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          SizedBox(height: 16),
          Text(
            'Failed to load analytics',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700),
          ),
          SizedBox(height: 8),
          if (_errorMessage != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAnalytics,
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(AppLocalizations? localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            localizations?.noDataAvailable ?? 'No Analytics Data Available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Add animals and treatments to see analytics',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAnalytics,
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
