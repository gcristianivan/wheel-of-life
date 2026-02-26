import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/wheel_entry.dart';
import 'app_theme.dart';

class ComparisonResultView extends StatelessWidget {
  final WheelEntry olderEntry;
  final WheelEntry newerEntry;

  const ComparisonResultView({
    super.key,
    required this.olderEntry,
    required this.newerEntry,
  });

  @override
  Widget build(BuildContext context) {
    final categories = AppTheme.categoryColors.keys.toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Comparison", style: AppTheme.heading2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildLegend(),
                const SizedBox(height: 30),
                _buildRadarChart(categories),
                const SizedBox(height: 30),
                _buildDeltaList(categories),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: AppTheme.glassCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.5),
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(olderEntry.date),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const Text("Previous",
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white24, size: 16),
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.5),
                    border: Border.all(color: Colors.orangeAccent, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(newerEntry.date),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const Text("Later",
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarChart(List<String> categories) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: Colors.blueAccent.withOpacity(0.2),
              borderColor: Colors.blueAccent,
              entryRadius: 4,
              borderWidth: 2,
              dataEntries: categories
                  .map((cat) => RadarEntry(
                      value: (olderEntry.scores[cat] ?? 0).toDouble()))
                  .toList(),
            ),
            RadarDataSet(
              fillColor: Colors.orangeAccent.withOpacity(0.2),
              borderColor: Colors.orangeAccent,
              entryRadius: 4,
              borderWidth: 2,
              dataEntries: categories
                  .map((cat) => RadarEntry(
                      value: (newerEntry.scores[cat] ?? 0).toDouble()))
                  .toList(),
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData: const BorderSide(color: Colors.white24, width: 1.5),
          titlePositionPercentageOffset: 0.1,
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 10),
          getTitle: (index, angle) {
            return RadarChartTitle(
              text: categories[index],
              angle: 0, // Keep title text horizontal
            );
          },
          tickCount:
              1, // Only show outer border (tick=10) or we can specify more for guide rings.
          ticksTextStyle:
              const TextStyle(color: Colors.transparent, fontSize: 10),
          tickBorderData: const BorderSide(color: Colors.white10),
          gridBorderData: const BorderSide(color: Colors.white10, width: 1.5),
        ),
        swapAnimationDuration: const Duration(milliseconds: 600),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildDeltaList(List<String> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SCORE BREAKDOWN",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ...categories.map((cat) {
            final oldScore = olderEntry.scores[cat] ?? 0;
            final newScore = newerEntry.scores[cat] ?? 0;
            final delta = newScore - oldScore;

            Color deltaColor = Colors.white54;
            IconData deltaIcon = Icons.horizontal_rule;
            if (delta > 0) {
              deltaColor = Colors.greenAccent;
              deltaIcon = Icons.arrow_upward;
            } else if (delta < 0) {
              deltaColor = Colors.redAccent;
              deltaIcon = Icons.arrow_downward;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: AppTheme.glassCard(
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.categoryColors[cat],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cat,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                        children: [
                          TextSpan(
                              text: oldScore.toString(),
                              style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold)),
                          const TextSpan(text: " → "),
                          TextSpan(
                              text: newScore.toString(),
                              style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(deltaIcon, color: deltaColor, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            delta.abs().toString(),
                            style: TextStyle(
                                color: deltaColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
