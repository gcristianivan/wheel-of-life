class ActionItem {
  final String id;
  final String title;
  final String pillarCategory;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? targetDate;

  ActionItem({
    required this.id,
    required this.title,
    required this.pillarCategory,
    this.isCompleted = false,
    required this.createdAt,
    this.targetDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'pillarCategory': pillarCategory,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
    };
  }

  factory ActionItem.fromMap(Map<dynamic, dynamic> map) {
    return ActionItem(
      id: map['id'].toString(),
      title: map['title'].toString(),
      pillarCategory: map['pillarCategory'].toString(),
      isCompleted: map['isCompleted'] == true,
      createdAt: DateTime.parse(map['createdAt'].toString()),
      targetDate: map['targetDate'] != null
          ? DateTime.parse(map['targetDate'].toString())
          : null,
    );
  }

  ActionItem copyWith({
    String? id,
    String? title,
    String? pillarCategory,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? targetDate,
  }) {
    return ActionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      pillarCategory: pillarCategory ?? this.pillarCategory,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
    );
  }
}
