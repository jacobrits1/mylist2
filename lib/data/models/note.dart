import 'package:equatable/equatable.dart';

/// Model class for notes
class Note extends Equatable {
  final int? id;
  final String title;
  final String? content;
  final int? categoryId;
  final String noteType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;

  Note({
    this.id,
    required this.title,
    this.content,
    this.categoryId,
    this.noteType = 'text',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.dueDate,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert Note to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'category_id': categoryId,
      'note_type': noteType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
    };
  }

  /// Create Note from Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String?,
      categoryId: map['category_id'] as int?,
      noteType: map['note_type'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
    );
  }

  /// Copy with method for immutability
  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? categoryId,
    String? noteType,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      noteType: noteType ?? this.noteType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        categoryId,
        noteType,
        createdAt,
        updatedAt,
        dueDate,
      ];
} 