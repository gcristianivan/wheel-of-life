import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/wheel_entry.dart';
import 'app_theme.dart';

class HistoricalWheelView extends StatefulWidget {
  final WheelEntry entry;

  const HistoricalWheelView({super.key, required this.entry});

  @override
  State<HistoricalWheelView> createState() => _HistoricalWheelViewState();
}

class _HistoricalWheelViewState extends State<HistoricalWheelView> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isCapturing = false;

  Future<void> _shareScreenshot() async {
    setState(() => _isCapturing = true);

    try {
      final imageBytes = await _screenshotController.capture(
          delay:
              const Duration(milliseconds: 100)); // Small delay for any paint

      if (imageBytes != null) {
        final dateStr = DateFormat('yyyyMMdd').format(widget.entry.date);
        final fileName = 'life_wheel_$dateStr.png';

        XFile xFile;
        if (kIsWeb) {
          xFile = XFile.fromData(
            imageBytes,
            mimeType: 'image/png',
            name: fileName,
          );
        } else {
          final directory = await getApplicationDocumentsDirectory();
          final imagePath = '${directory.path}/$fileName';
          final imageFile = File(imagePath);
          await imageFile.writeAsBytes(imageBytes);
          xFile = XFile(imagePath);
        }

        // Share the file
        await Share.shareXFiles(
          [xFile],
          text:
              'My Life Wheel from ${DateFormat('MMM d, yyyy').format(widget.entry.date)}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = AppTheme.categoryColors.keys.toList();
    final List<PieChartSectionData> sections = [];

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final currentScore = widget.entry.scores[category] ?? 0;
      final categoryColor = AppTheme.categoryColors[category] ?? Colors.white;

      final radius = 20.0 + (currentScore * 12);
      final offset = 165.0 / radius;

      sections.add(
        PieChartSectionData(
          color: categoryColor.withOpacity(0.8),
          value: 1, // prevent 0 size
          title: currentScore > 0 ? '$currentScore' : '',
          radius: radius, // scaling visual size
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          showTitle: false,
          badgeWidget: _Badge(
            category,
            currentScore,
            categoryColor,
          ),
          badgePositionPercentageOffset: offset,
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Wheel from ${DateFormat('MMM d, yyyy').format(widget.entry.date)}',
          style: AppTheme.heading2.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _isCapturing
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white)),
                ))
              : IconButton(
                  icon: const Icon(Icons.ios_share, color: Colors.white),
                  onPressed: _shareScreenshot,
                  tooltip: 'Export Image',
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
                      ),
                    ),
                    child: AppTheme.glassCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isCapturing) // Add title to screenshot when capturing
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Text(
                                  'My Life Wheel (${DateFormat('MMM d, yyyy').format(widget.entry.date)})',
                                  style: AppTheme.heading2.copyWith(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ),
                            SizedBox(
                              height: 400,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
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
                                    ),
                                    swapAnimationDuration: const Duration(
                                        milliseconds:
                                            0), // Disable animation during screenshot
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
