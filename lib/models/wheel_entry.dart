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

  factory WheelEntry.fromMap(Map<String, dynamic> map) {
    return WheelEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      scores: Map<String, int>.from(map['scores']),
    );
  }
}
