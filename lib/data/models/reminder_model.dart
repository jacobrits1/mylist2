import 'package:equatable/equatable.dart';

/// Model class for reminders
class ReminderModel {
  final int? id;
  final int noteId;
  final String title;
  final String? description;
  final DateTime reminderTime;
  final bool isCompleted;

  ReminderModel({
    this.id,
    required this.noteId,
    required this.title,
    this.description,
    required this.reminderTime,
    this.isCompleted = false,
  });

  /// Create a copy of this reminder with some fields replaced
  ReminderModel copyWith({
    int? id,
    int? noteId,
    String? title,
    String? description,
    DateTime? reminderTime,
    bool? isCompleted,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderTime: reminderTime ?? this.reminderTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Convert reminder to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'noteId': noteId,
      'title': title,
      'description': description,
      'reminderTime': reminderTime.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  /// Create a reminder from a map (database row)
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as int?,
      noteId: map['noteId'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      reminderTime: DateTime.parse(map['reminderTime'] as String),
      isCompleted: (map['isCompleted'] as int) == 1,
    );
  }

  @override
  String toString() {
    return 'ReminderModel(id: $id, noteId: $noteId, title: $title, description: $description, reminderTime: $reminderTime, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderModel &&
        other.id == id &&
        other.noteId == noteId &&
        other.title == title &&
        other.description == description &&
        other.reminderTime == reminderTime &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      noteId,
      title,
      description,
      reminderTime,
      isCompleted,
    );
  }
} 