class TaskModel {
  final String id;
  final String userId; // Changed from uid to userId
  final String name;
  final String description;
  final DateTime dueAt;
  final String priority;
  final String contact;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hasReminder;
  final DateTime? reminderAt;
  final String? reminderType; // 'push', 'local', 'both'

  const TaskModel({
    required this.id,
    required this.userId, // Changed from uid to userId
    required this.name,
    required this.description,
    required this.dueAt,
    required this.priority,
    required this.contact,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.hasReminder = false,
    this.reminderAt,
    this.reminderType,
  });

  TaskModel copyWith({
    String? id,
    String? userId, // Changed from uid to userId
    String? name,
    String? description,
    DateTime? dueAt,
    String? priority,
    String? contact,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasReminder,
    DateTime? reminderAt,
    String? reminderType,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId, // Changed from uid to userId
      name: name ?? this.name,
      description: description ?? this.description,
      dueAt: dueAt ?? this.dueAt,
      priority: priority ?? this.priority,
      contact: contact ?? this.contact,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderAt: reminderAt ?? this.reminderAt,
      reminderType: reminderType ?? this.reminderType,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString() ?? '',
      userId:
          json['uid']?.toString() ?? '', // Keep as uid to match your backend
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? '',
      contact: json['contact'] ?? '',
      status: json['status'] ?? 'pending',
      dueAt:
          DateTime.parse(json['dueAt']), // Keep as dueAt to match your backend
      createdAt: DateTime.parse(
          json['createdAt']), // Keep as createdAt to match your backend
      updatedAt: DateTime.parse(
          json['updatedAt']), // Keep as updatedAt to match your backend
      hasReminder: json['hasReminder'] ??
          false, // Keep as hasReminder to match your backend
      reminderAt:
          json['reminderAt'] != null // Keep as reminderAt to match your backend
              ? DateTime.parse(json['reminderAt'])
              : null,
      reminderType:
          json['reminderType'], // Keep as reminderType to match your backend
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': userId, // Keep as uid to match your backend
      'name': name,
      'description': description,
      'dueAt':
          dueAt.millisecondsSinceEpoch, // Keep as dueAt to match your backend
      'priority': priority,
      'contact': contact,
      'status': status,
      'createdAt': createdAt
          .millisecondsSinceEpoch, // Keep as createdAt to match your backend
      'updatedAt': updatedAt
          .millisecondsSinceEpoch, // Keep as updatedAt to match your backend
      'hasReminder': hasReminder, // Keep as hasReminder to match your backend
      'reminderAt': reminderAt
          ?.millisecondsSinceEpoch, // Keep as reminderAt to match your backend
      'reminderType':
          reminderType, // Keep as reminderType to match your backend
    };
  }

  @override
  String toString() {
    return '''TaskModel(id: $id, uid: $userId, name: $name, description: $description, dueAt: $dueAt, priority: $priority, contact: $contact, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, hasReminder: $hasReminder, reminderAt: $reminderAt, reminderType: $reminderType)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskModel &&
        other.id == id &&
        other.userId == userId && // Changed from uid to userId
        other.name == name &&
        other.description == description &&
        other.dueAt == dueAt &&
        other.priority == priority &&
        other.contact == contact &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.hasReminder == hasReminder &&
        other.reminderAt == reminderAt &&
        other.reminderType == reminderType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^ // Changed from uid to userId
        name.hashCode ^
        description.hashCode ^
        dueAt.hashCode ^
        priority.hashCode ^
        contact.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        hasReminder.hashCode ^
        reminderAt.hashCode ^
        reminderType.hashCode;
  }
}
