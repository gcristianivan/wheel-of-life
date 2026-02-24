import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() {
  final random = Random();
  final categories = [
    'Health',
    'Career',
    'Finances',
    'Growth',
    'Romance',
    'Social',
    'Fun',
    'Environment'
  ];

  final now = DateTime.now();
  final twoYearsAgo = now.subtract(const Duration(days: 365 * 2));

  List<Map<String, dynamic>> wheelEntries = [];

  DateTime currentDate = twoYearsAgo;

  while (currentDate.isBefore(now)) {
    // Determine random interval (1 to 2 months)
    final addMonths = random.nextInt(2) + 1; // 1 or 2
    final addDays = random.nextInt(28); // Random day within the month offset

    currentDate = DateTime(
      currentDate.year,
      currentDate.month + addMonths,
      currentDate.day + addDays,
      random.nextInt(24), // hour
      random.nextInt(60), // minute
    );

    if (currentDate.isAfter(now)) break;

    // Generate random scores
    Map<String, int> scores = {};
    for (var cat in categories) {
      scores[cat] = random.nextInt(10) + 1; // 1 to 10
    }

    final entry = {
      'id': currentDate.millisecondsSinceEpoch,
      'date': currentDate.toIso8601String(),
      'scores': scores,
    };

    wheelEntries.add(entry);
  }

  // Sort by date descending
  wheelEntries.sort((a, b) => b['date'].compareTo(a['date']));

  // Generate 10 random Action Items
  List<Map<String, dynamic>> actionItems = [];
  final goalTitles = [
    'Run a marathon',
    'Get promoted',
    'Save \$10,000',
    'Read 10 books',
    'Go on dates twice a month',
    'Join a club',
    'Learn to play guitar',
    'Recycle more',
    'Eat healthier',
    'Travel to Japan',
    'Meditate daily',
    'Network with 5 people',
  ];

  for (int i = 0; i < 10; i++) {
    final cat = categories[random.nextInt(categories.length)];
    final title = goalTitles[random.nextInt(goalTitles.length)];
    final isCompleted = random.nextBool();

    // Target date in the future or past
    final targetDate = now.add(Duration(days: random.nextInt(60) - 30));

    actionItems.add({
      'id': now.millisecondsSinceEpoch.toString() + i.toString(),
      'title': title,
      'pillarCategory': cat,
      'isCompleted': isCompleted,
      'createdAt':
          now.subtract(Duration(days: random.nextInt(30))).toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
    });
  }

  final data = {
    'wheel_entries': wheelEntries,
    'action_items': actionItems,
  };

  final file = File('generate_sample_data.json');
  file.writeAsStringSync(jsonEncode(data));
  print(
      'Generated ${wheelEntries.length} entries and ${actionItems.length} action items to generate_sample_data.json');
}
