class Organizer {
  final String id;
  final String name;
  final DateTime createdAt;

  Organizer({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  Organizer copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Organizer(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Organizer.fromMap(Map<String, dynamic> map) {
    return Organizer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
