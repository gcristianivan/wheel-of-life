import 'package:hive_flutter/hive_flutter.dart';
import '../models/wheel_entry.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static const String _boxName = 'wheel_entries';

  DatabaseService._init();

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<int> insertEntry(WheelEntry entry) async {
    final box = await _getBox();
    final map = entry.toMap(); // using the existing toMap
    // Hive keys can be auto-increment integers if we use add(), returning the key
    return await box.add(map);
  }

  Future<List<WheelEntry>> getEntries() async {
    final box = await _getBox();
    final List<WheelEntry> entries = [];

    // box.values is an iterable of dynamic (the maps)
    for (var i = 0; i < box.length; i++) {
      // hive stores keys separate from values.
      // We might want to store the ID?
      // For 'add', key is an int.
      final key = box.keyAt(i);
      final value = box.getAt(i);

      if (value is Map) {
        final entryMap = Map<String, dynamic>.from(value);
        // Inject ID if needed, though WheelEntry.fromMap takes 'id'
        entryMap['id'] = key;
        entries.add(WheelEntry.fromMap(entryMap));
      }
    }

    // Sort by date DESC
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Future<void> clearData() async {
    final box = await _getBox();
    await box.clear();
  }

  Future<void> insertEntries(List<WheelEntry> entries) async {
    final box = await _getBox();
    for (var entry in entries) {
      await box.add(entry.toMap());
    }
  }
}
