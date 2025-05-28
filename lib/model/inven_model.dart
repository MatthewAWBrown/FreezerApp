
class InvenModel{

  final String id;
  final String title;
  final int count;
  final DateTime date;

  InvenModel({
    required this.id,
    required this.title,
    required this.count,
    required this.date
  });

  factory InvenModel.fromMap(Map<String, dynamic> map) {
    return InvenModel(
      id: map['id'] as String,
      title: map['title'] as String,
      count: (map['count'] is String) ? (int.tryParse(map['count'] as String) ?? 0) : (map['count'] as int? ?? 0),
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'count': count,
      'date': date.toIso8601String(),
    };
  }

  InvenModel copyWith({
    String? id,
    String? title,
    int? count,
    DateTime? date,
}) {
    return InvenModel(
      id: id ?? this.id,
      title: title ?? this.title,
      count: count ?? this.count,
      date: date ?? this.date,
    );
  }

  // -- optional override methods ---
  @override
  bool operator ==(Object other){
    if (identical(this, other)) return true;

    return other is InvenModel &&
      other.id == id &&
      other.title == title &&
      other.count == count &&
      other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    title.hashCode ^
    count.hashCode ^
    date.hashCode;
  }

  @override
  String toString() {
    return 'InvenModel(id: $id, title: $title, count: $count, date: $date)';
  }
}