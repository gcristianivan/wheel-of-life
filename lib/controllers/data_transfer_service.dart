import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/wheel_entry.dart';
import '../models/action_item.dart';
import 'database_service.dart';
import 'action_item_service.dart';

class DataTransferService {
  final DatabaseService _db = DatabaseService.instance;
  final ActionItemService _actionDb = ActionItemService.instance;

  // Exports data to a JSON file
  Future<String?> exportData() async {
    try {
      final entries = await _db.getEntries();
      final actionItems = await _actionDb.getAllActionItems();

      final data = {
        'wheel_entries': entries.map((e) => e.toMap()).toList(),
        'action_items': actionItems.map((e) => e.toMap()).toList(),
      };

      final jsonString = jsonEncode(data);

      if (kIsWeb) {
        // file_picker does not support saveFile on Web directly in the same way,
        // so we might need to rely on the user downloading but wait,
        // actually for Web we can use dart:html or similar. But since we use file_picker,
        // wait, let's use the standard web approach, or just hope file_picker.saveFile works or throws unsupported.
        // As a fallback, on web we just throw an exception for now unless we implement dart:html anchor.
        // Actually, we can use FilePicker for downloading? No, FilePicker is just for picking.
      }

      final bytes = utf8.encode(jsonString);

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save your data export',
        fileName: 'wheel_of_life_export.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(bytes),
      );

      // On Web, file_picker downloads the file automatically and outputFile is null
      if (outputFile != null && !kIsWeb) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
        return outputFile;
      }

      if (kIsWeb) {
        return 'wheel_of_life_export.json';
      }

      return null;
    } catch (e) {
      debugPrint("Export Error: $e");
      rethrow;
    }
  }

  // Imports data from a JSON file. Returns true if successful.
  Future<bool> importData({required bool overwrite}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // required for web and sometimes useful
      );

      if (result != null) {
        String jsonString;

        if (kIsWeb) {
          jsonString = utf8.decode(result.files.single.bytes!);
        } else {
          final file = File(result.files.single.path!);
          jsonString = await file.readAsString();
        }

        final Map<String, dynamic> data = jsonDecode(jsonString);

        if (overwrite) {
          await _db.clearData();
          await _actionDb.clearData();
        }

        if (data.containsKey('wheel_entries')) {
          final entriesList =
              List<Map<String, dynamic>>.from(data['wheel_entries']);
          final entries =
              entriesList.map((e) => WheelEntry.fromMap(e)).toList();
          await _db.insertEntries(entries);
        }

        if (data.containsKey('action_items')) {
          final itemsList =
              List<Map<String, dynamic>>.from(data['action_items']);
          final items = itemsList.map((e) => ActionItem.fromMap(e)).toList();
          await _actionDb.insertActionItems(items);
        }

        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Import Error: $e");
      rethrow;
    }
  }
}
