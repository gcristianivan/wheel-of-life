import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wheel_entry.dart';
import '../controllers/database_service.dart';
import 'app_theme.dart';
import 'comparison_result_view.dart';

class ComparisonSelectionView extends StatefulWidget {
  const ComparisonSelectionView({super.key});

  @override
  State<ComparisonSelectionView> createState() =>
      _ComparisonSelectionViewState();
}

class _ComparisonSelectionViewState extends State<ComparisonSelectionView> {
  List<WheelEntry> _entries = [];
  bool _isLoading = true;
  final List<WheelEntry> _selectedEntries = [];

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

  void _toggleSelection(WheelEntry entry) {
    setState(() {
      if (_selectedEntries.contains(entry)) {
        _selectedEntries.remove(entry);
      } else {
        if (_selectedEntries.length < 2) {
          _selectedEntries.add(entry);
        } else {
          // If 2 are already selected and we click a 3rd, replace the oldest selection
          _selectedEntries.removeAt(0);
          _selectedEntries.add(entry);
        }
      }
    });
  }

  double _getAverageScore(WheelEntry entry) {
    double total = 0;
    entry.scores.forEach((key, val) => total += val);
    return total / (entry.scores.isEmpty ? 1 : entry.scores.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Select Wheels to Compare",
            style: AppTheme.heading2.copyWith(fontSize: 18)),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Text(
                  "Select two historical wheels from the list below to compare their scores.",
                  style: AppTheme.bodyText.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _entries.isEmpty
                        ? Center(
                            child: Text("No data available",
                                style: AppTheme.bodyText))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 8.0),
                            itemCount: _entries.length,
                            itemBuilder: (context, index) {
                              final entry = _entries[index];
                              final avg = _getAverageScore(entry);
                              final isSelected =
                                  _selectedEntries.contains(entry);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () => _toggleSelection(entry),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: isSelected
                                        ? BoxDecoration(
                                            color: AppTheme.accentColor
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color: AppTheme.accentColor,
                                                width: 2),
                                          )
                                        : AppTheme.glassDecoration.copyWith(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                DateFormat('MMM d, yyyy')
                                                    .format(entry.date),
                                                style:
                                                    AppTheme.bodyText.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('h:mm a')
                                                    .format(entry.date),
                                                style: const TextStyle(
                                                  color: Colors.white38,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: AppTheme.accentColor
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  "Avg: ${avg.toStringAsFixed(1)}",
                                                  style: const TextStyle(
                                                    color: AppTheme.accentColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Icon(
                                                isSelected
                                                    ? Icons.check_circle
                                                    : Icons.circle_outlined,
                                                color: isSelected
                                                    ? AppTheme.accentColor
                                                    : Colors.white24,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedEntries.length == 2
                          ? AppTheme.accentColor
                          : Colors.grey.withOpacity(0.5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _selectedEntries.length == 2
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ComparisonResultView(
                                  // Sort the two entries by date so Older is always first
                                  olderEntry: _selectedEntries[0]
                                          .date
                                          .isBefore(_selectedEntries[1].date)
                                      ? _selectedEntries[0]
                                      : _selectedEntries[1],
                                  newerEntry: _selectedEntries[0]
                                          .date
                                          .isBefore(_selectedEntries[1].date)
                                      ? _selectedEntries[1]
                                      : _selectedEntries[0],
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text(
                      "Compare",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
