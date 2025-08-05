class TaskModel {
  final String id;
  final String uid;
  final String name;
  final String description;
  final DateTime dueAt;
  final String priority;
  final String contact;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TaskModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.description,
    required this.dueAt,
    required this.priority,
    required this.contact,
    required this.createdAt,
    required this.updatedAt,
  });

  TaskModel copyWith({
    String? id,
    String? uid,
    String? name,
    String? description,
    DateTime? dueAt,
    String? priority,
    String? contact,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      description: description ?? this.description,
      dueAt: dueAt ?? this.dueAt,
      priority: priority ?? this.priority,
      contact: contact ?? this.contact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? '',
      contact: json['contact'] ?? '',
      dueAt: DateTime.parse(json['dueAt']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'description': description,
      'dueAt': dueAt.millisecondsSinceEpoch,
      'priority': priority,
      'contact': contact,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return '''TaskModel(id: $id, uid: $uid, name: $name, description: $description, dueAt: $dueAt, priority: $priority, contact: $contact, createdAt: $createdAt, updatedAt: $updatedAt)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskModel &&
        other.id == id &&
        other.uid == uid &&
        other.name == name &&
        other.description == description &&
        other.dueAt == dueAt &&
        other.priority == priority &&
        other.contact == contact &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uid.hashCode ^
        name.hashCode ^
        description.hashCode ^
        dueAt.hashCode ^
        priority.hashCode ^
        contact.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
