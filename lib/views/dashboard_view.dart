import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../controllers/database_service.dart';
import '../models/wheel_entry.dart';

import 'assessment_view.dart';
import 'history_view.dart';
import 'settings_view.dart';
import 'app_theme.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  WheelEntry? _latestEntry;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLatestEntry();
  }

  Future<void> _loadLatestEntry() async {
    final entries = await DatabaseService.instance.getEntries();
    setState(() {
      if (entries.isNotEmpty) {
        _latestEntry = entries.first;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define categories and their fixed colors for the "Wheel" look
    final categories = [
      'Health',
      'Career',
      'Finances',
      'Growth',
      'Romance',
      'Social',
      'Fun',
      'Environment',
    ];
    final colors = [
      const Color(0xFF69F0AE), // Health - Green
      const Color(0xFF40C4FF), // Career - Blue
      const Color(0xFF7C4DFF), // Finances - Deep Purple
      const Color(0xFFFF4081), // Growth - Pink
      const Color(0xFFFF5252), // Romance - Red
      const Color(0xFFFFAB40), // Social - Orange
      const Color(0xFFFFD740), // Fun - Yellow
      const Color(0xFF18FFFF), // Environment - Cyan
    ];

    List<PieChartSectionData> sections = [];

    if (_latestEntry != null) {
      for (int i = 0; i < categories.length; i++) {
        final category = categories[i];
        final score = _latestEntry!.scores[category] ?? 0;
        final radius =
            20.0 +
            (score *
                12); // Base radius + score multiplier to create "Polar" effect.
        // Max radius ~= 20 + 120 = 140.

        // We want labels to be at a fixed distance to avoid overlapping the variable chart.
        // Let's aim for a distance of ~160 from center.
        final fixedDistance = 165.0;
        final offset = fixedDistance / radius;

        sections.add(
          PieChartSectionData(
            color: colors[i].withOpacity(0.8),
            value: 1, // Equal width slices
            title: score > 0 ? score.toString() : '',
            radius: radius,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            titlePositionPercentageOffset: 0.8,
            showTitle: false,
            badgeWidget: _Badge(category, score, colors[i]),
            badgePositionPercentageOffset: offset,
          ),
        );
      }
    } else {
      // Placeholder empty wheel
      for (int i = 0; i < categories.length; i++) {
        sections.add(
          PieChartSectionData(
            color: colors[i].withOpacity(0.2),
            value: 1,
            radius: 100,
            showTitle: false,
          ),
        );
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Wheel of Life', style: AppTheme.heading2),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryView()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsView()),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Dashboard", style: AppTheme.heading1),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Concentric Guide Circles (Benchmarks)
                          // Max radio is roughly 140 (20 + 10*12). let's visualize levels 3, 5, 8, 10.
                          // Level X radius = 20 + (X * 12).
                          // Level 10: 140
                          // Level 7: 104
                          // Level 5: 80
                          // Level 3: 56
                          for (final level in [3, 5, 8, 10])
                            Container(
                              width: (20.0 + (level * 12)) * 2,
                              height: (20.0 + (level * 12)) * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                            ),

                          PieChart(
                            PieChartData(
                              sections: sections,
                              centerSpaceRadius: 0,
                              sectionsSpace: 2,
                              startDegreeOffset: 270,
                              pieTouchData: PieTouchData(enabled: false),
                            ),
                            swapAnimationDuration: const Duration(
                              milliseconds: 800,
                            ),
                            swapAnimationCurve: Curves.elasticOut,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: AppTheme.accentColor.withOpacity(0.5),
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AssessmentView(),
                              ),
                            );
                            _loadLatestEntry();
                          },
                          child: const Text(
                            "New Assessment",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final int score;
  final Color color;

  const _Badge(this.text, this.score, this.color);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
            ),
          ),
          Text(
            score.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
            ),
          ),
        ],
      ),
    );
  }
}
