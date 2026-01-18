import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wheel_entry.dart';
import '../controllers/database_service.dart';
import 'app_theme.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<WheelEntry> _entries = [];
  bool _isLoading = true;
  String _selectedCategory = 'Average';
  String _selectedTimeRange =
      'All Time'; // 'All Time', 'This Year', 'This Month'

  final List<String> _categoryOptions = [
    'Average',
    'Health',
    'Career',
    'Finances',
    'Growth',
    'Romance',
    'Social',
    'Fun',
    'Environment',
  ];

  final List<String> _timeRangeOptions = [
    'All Time',
    'This Year',
    'This Month',
  ];

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

  // Helper to get value for a specific entry based on selected category
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

    // 1. Filter by Time Range
    final now = DateTime.now();
    List<WheelEntry> filtered = _entries.where((e) {
      if (_selectedTimeRange == 'This Month') {
        return e.date.year == now.year && e.date.month == now.month;
      } else if (_selectedTimeRange == 'This Year') {
        return e.date.year == now.year;
      }
      return true; // All Time
    }).toList();

    if (filtered.isEmpty) return [];

    // 2. Group by Day and pick latest
    // Map: "YYYY-MM-DD" -> WheelEntry
    final Map<String, WheelEntry> dailyLatest = {};

    for (var entry in filtered) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.date);
      if (!dailyLatest.containsKey(dateKey)) {
        dailyLatest[dateKey] = entry;
      } else {
        // If existing is older than current, replace it
        // Note: _entries are typically loaded DESC, but let's be safe
        if (entry.date.isAfter(dailyLatest[dateKey]!.date)) {
          dailyLatest[dateKey] = entry;
        }
      }
    }

    // Convert to list and sort ASC by date for chart
    final sortedDaily = dailyLatest.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // 3. Convert to Spots (X = milliseconds since epoch, Y = value)
    return sortedDaily.map((e) {
      return FlSpot(
        e.date.millisecondsSinceEpoch.toDouble(),
        _getEntryValue(e),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getChartData();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Evolution", style: AppTheme.heading2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFF1C1B33), Color(0xFF2E335A)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Filters Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Category Filter
                          _buildDropdown(_selectedCategory, _categoryOptions, (
                            val,
                          ) {
                            if (val != null)
                              setState(() => _selectedCategory = val);
                          }),
                          const SizedBox(width: 12),
                          // Time Range Filter
                          _buildDropdown(
                            _selectedTimeRange,
                            _timeRangeOptions,
                            (val) {
                              if (val != null)
                                setState(() => _selectedTimeRange = val);
                            },
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 250,
                        child: spots.isEmpty
                            ? Center(
                                child: Text(
                                  "No data for selected period",
                                  style: AppTheme.bodyText,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                  right: 16.0,
                                  top: 24.0,
                                ),
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (val, meta) {
                                            final date =
                                                DateTime.fromMillisecondsSinceEpoch(
                                                  val.toInt(),
                                                );
                                            if (val == meta.min ||
                                                val == meta.max) {
                                              // Show edge dates
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Text(
                                                  DateFormat(
                                                    'MMM d',
                                                  ).format(date),
                                                  style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              );
                                            }
                                            return const SizedBox();
                                          },
                                          reservedSize: 30,
                                          interval:
                                              86400000 *
                                              5, // rough interval, doesn't matter much if we handle logic above or just show start/end
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (val, meta) => Text(
                                            val.toInt().toString(),
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 10,
                                            ),
                                          ),
                                          interval: 2,
                                          reservedSize: 20,
                                        ),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: spots,
                                        isCurved: true,
                                        color: AppTheme.accentColor,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(show: true),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: AppTheme.accentColor
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "$_selectedCategory Trend ($_selectedTimeRange)",
                        style: AppTheme.bodyText.copyWith(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // List of ALL entries for context, respecting visual filter filters?
                      // User said "indicate if multiple assessments taken" (implicitly handled by list showing all, chart showing latest).
                      Expanded(
                        child: ListView.builder(
                          itemCount: _entries.length,
                          itemBuilder: (context, index) {
                            final entry = _entries[index];

                            // Apply filters to list as well? Usually yes.
                            final now = DateTime.now();
                            if (_selectedTimeRange == 'This Month' &&
                                (entry.date.year != now.year ||
                                    entry.date.month != now.month)) {
                              return const SizedBox();
                            }
                            if (_selectedTimeRange == 'This Year' &&
                                entry.date.year != now.year) {
                              return const SizedBox();
                            }

                            final value = _getEntryValue(
                              entry,
                            ).toStringAsFixed(1);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: AppTheme.glassCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          DateFormat(
                                            'MMM d, yyyy',
                                          ).format(entry.date),
                                          style: AppTheme.bodyText.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          DateFormat(
                                            'h:mm a',
                                          ).format(entry.date),
                                          style: AppTheme.bodyText.copyWith(
                                            fontSize: 12,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentColor.withOpacity(
                                          0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.accentColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      child: Text(
                                        value,
                                        style: AppTheme.heading2.copyWith(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String currentVal,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: const Color(0xFF2E335A)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentVal,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 20,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
          ),
        ),
      ),
    );
  }
}
