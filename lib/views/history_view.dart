import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wheel_entry.dart';
import '../controllers/database_service.dart';
import 'app_theme.dart';
import 'historical_wheel_view.dart';
import 'comparison_selection_view.dart';
import 'paywall_view.dart';
import '../controllers/auth_controller.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<WheelEntry> _entries = [];
  bool _isLoading = true;
  String _selectedCategory = 'Average';
  String _selectedTimeRange = 'All'; // 'Month', 'Quarter', 'Year', 'All'
  final AuthController _auth = AuthController();

  final List<String> _timeRangeOptions = ['Month', 'Quarter', 'Year', 'All'];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final data = await DatabaseService.instance.getEntries();
    setState(() {
      _entries = data;
      _isLoading = false;
    });
  }

  double _getEntryValue(WheelEntry entry) {
    if (_selectedCategory == 'Average') {
      double total = 0;
      entry.scores.forEach((key, val) => total += val);
      return total / 8.0;
    } else {
      return (entry.scores[_selectedCategory] ?? 0).toDouble();
    }
  }

  List<FlSpot> _getChartData() {
    if (_entries.isEmpty) return [];

    final now = DateTime.now();
    List<WheelEntry> filtered = _entries.where((e) {
      if (_selectedTimeRange == 'Month') {
        return e.date.year == now.year && e.date.month == now.month;
      } else if (_selectedTimeRange == 'Quarter') {
        // Simple quarter check: within last 3 months
        return e.date.isAfter(now.subtract(const Duration(days: 90)));
      } else if (_selectedTimeRange == 'Year') {
        return e.date.year == now.year;
      }
      return true; // All
    }).toList();

    if (filtered.isEmpty) return [];

    final Map<String, WheelEntry> dailyLatest = {};
    for (var entry in filtered) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.date);
      if (!dailyLatest.containsKey(dateKey)) {
        dailyLatest[dateKey] = entry;
      } else {
        if (entry.date.isAfter(dailyLatest[dateKey]!.date)) {
          dailyLatest[dateKey] = entry;
        }
      }
    }

    final sortedDaily = dailyLatest.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return sortedDaily.map((e) {
      return FlSpot(
        e.date.millisecondsSinceEpoch.toDouble(),
        _getEntryValue(e),
      );
    }).toList();
  }

  Color _getCategoryColor() {
    if (_selectedCategory == 'Average') {
      return AppTheme.accentColor;
    }
    return AppTheme.categoryColors[_selectedCategory] ?? AppTheme.accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getChartData();
    final currentColor = _getCategoryColor();

    // Calculate Average Score for display
    double averageScore = 0;
    if (spots.isNotEmpty) {
      averageScore =
          spots.map((e) => e.y).reduce((a, b) => a + b) / spots.length;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Evolution', style: AppTheme.heading2),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.only(
                            bottom: 100), // Space for nav if needed
                        children: [
                          const SizedBox(height: 10),
                          _buildTimeFilter(),
                          const SizedBox(height: 20),
                          _buildChartSection(spots, currentColor, averageScore),
                          const SizedBox(height: 30),
                          _buildCategoryFilter(),
                          const SizedBox(height: 20),
                          if (_entries.isNotEmpty) _buildHistoryList(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: _timeRangeOptions.map((range) {
          final isSelected = _selectedTimeRange == range;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTimeRange = range),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.accentColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  range,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartSection(List<FlSpot> spots, Color color, double avgScore) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Score Trend",
                  style: AppTheme.heading2.copyWith(fontSize: 20)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.6),
                            blurRadius: 8,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Avg. Score ${avgScore.toStringAsFixed(1)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 250,
          width: double.infinity,
          child: spots.isEmpty
              ? Center(
                  child: Text("No data available", style: AppTheme.bodyText))
              : Padding(
                  padding: const EdgeInsets.only(right: 24.0, left: 12.0),
                  child: LineChart(
                    LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 2,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.white.withOpacity(0.05),
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                // Show rough dates based on position
                                if (value == meta.min || value == meta.max) {
                                  final date =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          value.toInt());
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat('MM/dd').format(date),
                                      style: const TextStyle(
                                          color: Colors.white38, fontSize: 10),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        maxY: 10, // Assuming scores are 0-10
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: color,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: const Color(0xFF2E335A),
                                  strokeWidth: 3,
                                  strokeColor: color,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  color.withOpacity(0.3),
                                  color.withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (_) =>
                                    const Color(0xFF2E335A).withOpacity(0.9),
                                tooltipBorder:
                                    const BorderSide(color: Colors.white10),
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    final date =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            spot.x.toInt());
                                    return LineTooltipItem(
                                        '${DateFormat('MMM d').format(date)}\n',
                                        const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12),
                                        children: [
                                          TextSpan(
                                            text: spot.y.toStringAsFixed(1),
                                            style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          )
                                        ]);
                                  }).toList();
                                }))),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Average', ...AppTheme.categoryColors.keys];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0, bottom: 16.0),
          child: Text(
            "FILTER BY CATEGORY",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              final color = cat == 'Average'
                  ? AppTheme.accentColor
                  : (AppTheme.categoryColors[cat] ?? Colors.white);

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          )
                        : AppTheme.glassDecoration.copyWith(
                            borderRadius: BorderRadius.circular(16),
                          ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "HISTORY",
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              if (_entries.length >= 2)
                TextButton.icon(
                  onPressed: () async {
                    final isPremium = await _auth.isPremium;
                    if (!isPremium && context.mounted) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaywallView()),
                      );
                    } else if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ComparisonSelectionView(),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.compare_arrows,
                      size: 16, color: AppTheme.accentColor),
                  label: const Text(
                    "Compare",
                    style: TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _entries.length,
            itemBuilder: (context, index) {
              final entry = _entries[index];
              final val = _getEntryValue(entry);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: ValueKey(entry.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24.0),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    final isPremium = await _auth.isPremium;
                    if (!isPremium && context.mounted) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaywallView()),
                      );
                      return false; // Prevent dismissal
                    }

                    if (!context.mounted) return false;

                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF2E335A),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: const Text("Delete Snapshot",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        content: const Text(
                            "Are you sure you want to delete this historical wheel snapshot? This cannot be undone.",
                            style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel",
                                style: TextStyle(color: Colors.white54)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.redAccent.withOpacity(0.8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Delete",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    if (entry.id != null) {
                      await DatabaseService.instance.deleteEntry(entry.id!);
                      _loadEntries();
                    }
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoricalWheelView(entry: entry),
                        ),
                      );
                    },
                    child: AppTheme.glassCard(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('MMM d, yyyy').format(entry.date),
                                style: AppTheme.bodyText.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text(DateFormat('h:mm a').format(entry.date),
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: _getCategoryColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _getCategoryColor().withOpacity(0.3))),
                          child: Text(val.toStringAsFixed(1),
                              style: TextStyle(
                                  color: _getCategoryColor(),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
