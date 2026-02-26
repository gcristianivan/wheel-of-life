import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/database_service.dart';
import '../models/wheel_entry.dart';
import '../models/action_item.dart';
import '../controllers/action_item_service.dart';

import 'assessment_view.dart';
import 'settings_view.dart';
import 'app_theme.dart';
import 'pillar_detail_view.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback? onNavigateToGoals;

  const DashboardView({super.key, this.onNavigateToGoals});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  WheelEntry? _latestEntry;
  List<ActionItem> _activeGoals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadLatestEntry(),
      _loadActiveGoals(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadLatestEntry() async {
    final entries = await DatabaseService.instance.getEntries();
    if (entries.isNotEmpty) {
      _latestEntry = entries.first;
    } else {
      _latestEntry = null;
    }
  }

  Future<void> _loadActiveGoals() async {
    _activeGoals = await ActionItemService.instance.getAllActiveActionItems();
  }

  @override
  Widget build(BuildContext context) {
    // Define categories and their fixed colors for the "Wheel" look
    // Define categories
    final categories = AppTheme.categoryColors.keys.toList();

    List<PieChartSectionData> sections = [];

    if (_latestEntry != null) {
      for (int i = 0; i < categories.length; i++) {
        final category = categories[i];
        final score = _latestEntry!.scores[category] ?? 0;
        final radius = 20.0 +
            (score *
                12); // Base radius + score multiplier to create "Polar" effect.
        // Max radius ~= 20 + 120 = 140.

        // We want labels to be at a fixed distance to avoid overlapping the variable chart.
        // Let's aim for a distance of ~160 from center.
        final fixedDistance = 165.0;
        final offset = fixedDistance / radius;

        sections.add(
          PieChartSectionData(
            color: (AppTheme.categoryColors[category] ?? Colors.white)
                .withOpacity(0.8),
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
            badgeWidget: _Badge(category, score,
                AppTheme.categoryColors[category] ?? Colors.white),
            badgePositionPercentageOffset: offset,
          ),
        );
      }
    } else {
      // Placeholder empty wheel
      for (int i = 0; i < categories.length; i++) {
        sections.add(
          PieChartSectionData(
            color: (AppTheme.categoryColors[categories[i]] ?? Colors.white)
                .withOpacity(0.2),
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
        title: Text('Life Wheel', style: AppTheme.heading2),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsView()),
              );
              if (mounted) _loadData();
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 400, // Fixed height for the chart area
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Concentric Guide Circles (Benchmarks)
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
                                pieTouchData: PieTouchData(
                                  touchCallback: (
                                    FlTouchEvent event,
                                    pieTouchResponse,
                                  ) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection ==
                                              null) {
                                        return;
                                      }
                                      if (event is FlTapUpEvent) {
                                        final index = pieTouchResponse
                                            .touchedSection!
                                            .touchedSectionIndex;
                                        if (index >= 0 &&
                                            index < categories.length) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PillarDetailView(
                                                category: categories[index],
                                                currentScore: _latestEntry
                                                            ?.scores[
                                                        categories[index]] ??
                                                    0,
                                                color: AppTheme.categoryColors[
                                                        categories[index]] ??
                                                    Colors.white,
                                              ),
                                            ),
                                          ).then((_) =>
                                              _loadData()); // Refresh on return
                                        }
                                      }
                                    });
                                  },
                                ),
                              ),
                              swapAnimationDuration: const Duration(
                                milliseconds: 800,
                              ),
                              swapAnimationCurve: Curves.elasticOut,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.touch_app,
                              size: 16, color: Colors.white54),
                          const SizedBox(width: 8),
                          Text(
                            "Tap a slice to manage goals for that pillar",
                            style: AppTheme.bodyText.copyWith(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                              shadowColor:
                                  AppTheme.accentColor.withOpacity(0.5),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AssessmentView(),
                                ),
                              );
                              _loadData();
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
                      const SizedBox(height: 16),
                      if (_activeGoals.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Active Goals",
                              style: AppTheme.heading2.copyWith(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount:
                              _activeGoals.length > 3 ? 3 : _activeGoals.length,
                          itemBuilder: (context, index) {
                            final item = _activeGoals[index];
                            // Find color for category
                            final color =
                                AppTheme.categoryColors[item.pillarCategory] ??
                                    Colors.white;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: color.withOpacity(0.3)),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 4,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  "${item.pillarCategory} • ${item.targetDate != null ? DateFormat('MMM d').format(item.targetDate!) : 'No deadline'}",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Checkbox(
                                  value: item.isCompleted,
                                  activeColor: color,
                                  checkColor: Colors.black,
                                  side:
                                      BorderSide(color: color.withOpacity(0.5)),
                                  onChanged: (val) async {
                                    final updated =
                                        item.copyWith(isCompleted: val);
                                    await ActionItemService.instance
                                        .updateActionItem(updated);
                                    _loadData(); // Refresh list
                                  },
                                ),
                                onTap: () => _showEditDialog(item),
                              ),
                            );
                          },
                        ),
                        if (_activeGoals.length > 3) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: widget.onNavigateToGoals,
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.accentColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              "View All Goals",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(ActionItem item) async {
    final titleController = TextEditingController(text: item.title);
    DateTime? selectedDate = item.targetDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2E335A),
            title: Text(
              "Edit Goal",
              style: AppTheme.heading2.copyWith(fontSize: 20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "What do you want to achieve?",
                    hintStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      selectedDate == null
                          ? "No Deadline"
                          : DateFormat('MMM d, yyyy').format(selectedDate!),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      child: const Text("Set Date"),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                ),
                onPressed: () async {
                  if (titleController.text.trim().isNotEmpty) {
                    final updatedItem = item.copyWith(
                      title: titleController.text.trim(),
                      targetDate: selectedDate,
                    );
                    await ActionItemService.instance
                        .updateActionItem(updatedItem);
                    if (mounted) Navigator.pop(context);
                    _loadData();
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
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
