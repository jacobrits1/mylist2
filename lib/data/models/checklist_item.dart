import 'package:equatable/equatable.dart';

class ChecklistItem extends Equatable {
  final int? id;
  final int? noteId;
  final String text;
  final bool isChecked;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChecklistItem({
    this.id,
    this.noteId,
    required this.text,
    required this.isChecked,
    required this.position,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert ChecklistItem to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note_id': noteId,
      'text': text,
      'is_checked': isChecked ? 1 : 0,
      'position': position,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create ChecklistItem from Map
  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as int?,
      noteId: map['note_id'] as int?,
      text: map['text'] as String,
      isChecked: (map['is_checked'] as int) == 1,
      position: map['position'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Copy with method for immutability
  ChecklistItem copyWith({
    int? id,
    int? noteId,
    String? text,
    bool? isChecked,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, noteId, text, isChecked, position, createdAt, updatedAt];
} 