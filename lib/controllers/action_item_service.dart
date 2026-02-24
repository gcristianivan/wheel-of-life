import 'package:hive_flutter/hive_flutter.dart';
import '../models/action_item.dart';

class ActionItemService {
  static final ActionItemService instance = ActionItemService._init();
  static const String _boxName = 'action_items';

  ActionItemService._init();

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<void> addActionItem(ActionItem item) async {
    final box = await _getBox();
    await box.put(item.id, item.toMap());
  }

  Future<List<ActionItem>> getActionItems(String pillarCategory) async {
    final box = await _getBox();
    final List<ActionItem> items = [];

    for (var i = 0; i < box.length; i++) {
      final value = box.getAt(i);
      if (value is Map) {
        final itemMap = Map<String, dynamic>.from(value);
        final item = ActionItem.fromMap(itemMap);
        if (item.pillarCategory == pillarCategory) {
          items.add(item);
        }
      }
    }

    // Sort: incomplete first, then by createdAt desc
    items.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return items;
  }

  Future<List<ActionItem>> getAllActiveActionItems() async {
    final box = await _getBox();
    final List<ActionItem> items = [];

    for (var i = 0; i < box.length; i++) {
      final value = box.getAt(i);
      if (value is Map) {
        final itemMap = Map<String, dynamic>.from(value);
        final item = ActionItem.fromMap(itemMap);
        if (!item.isCompleted) {
          items.add(item);
        }
      }
    }

    // Sort by targetDate (nulls last)
    items.sort((a, b) {
      if (a.targetDate == null && b.targetDate == null) return 0;
      if (a.targetDate == null) return 1;
      if (b.targetDate == null) return -1;
      return a.targetDate!.compareTo(b.targetDate!);
    });

    return items;
  }

  Future<void> updateActionItem(ActionItem item) async {
    final box = await _getBox();
    await box.put(item.id, item.toMap());
  }

  Future<void> deleteActionItem(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<List<ActionItem>> getAllActionItems() async {
    final box = await _getBox();
    final List<ActionItem> items = [];

    for (var i = 0; i < box.length; i++) {
      final value = box.getAt(i);
      if (value is Map) {
        final itemMap = Map<String, dynamic>.from(value);
        items.add(ActionItem.fromMap(itemMap));
      }
    }
    return items;
  }

  Future<void> clearData() async {
    final box = await _getBox();
    await box.clear();
  }

  Future<void> insertActionItems(List<ActionItem> items) async {
    final box = await _getBox();
    for (var item in items) {
      await box.put(item.id, item.toMap());
    }
  }
}
