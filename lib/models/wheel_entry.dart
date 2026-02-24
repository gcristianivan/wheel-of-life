class WheelEntry {
  final int? id;
  final DateTime date;
  final Map<String, int> scores;

  WheelEntry({this.id, required this.date, required this.scores});

  Map<String, dynamic> toMap() {
    // scores stored as Map in the object, but we'll serialize to JSON in the DB service/caller
    // OR we can handle it here if we want a flat map.
    // Let's keep it simple here.
    return {'id': id, 'date': date.toIso8601String(), 'scores': scores};
  }

  factory WheelEntry.fromMap(Map<dynamic, dynamic> map) {
    final Map<String, int> parsedScores = {};
    if (map['scores'] != null) {
      final rawScores = map['scores'] as Map;
      for (var entry in rawScores.entries) {
        parsedScores[entry.key.toString()] = (entry.value as num).toInt();
      }
    }

    int? parsedId;
    if (map['id'] != null) {
      if (map['id'] is int) {
        parsedId = map['id'] as int;
      } else {
        parsedId = int.tryParse(map['id'].toString());
      }
    }

    return WheelEntry(
      id: parsedId,
      date: DateTime.parse(map['date'].toString()),
      scores: parsedScores,
    );
  }
}
