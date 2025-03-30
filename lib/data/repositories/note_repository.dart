import 'package:sqflite/sqflite.dart';
import '../models/note.dart';
import '../models/checklist_item.dart';
import '../sources/local/database_helper.dart';

/// Repository class for managing notes in the database
class NoteRepository {
  final DatabaseHelper _databaseHelper;
  static const String tableName = 'notes';

  NoteRepository(this._databaseHelper);

  /// Add a new note to the database
  Future<int> insertNote(Note note) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      tableName, 
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all notes
  Future<List<Note>> getAllNotes() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Get notes by category ID
  Future<List<Note>> getNotesByCategory(int categoryId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Get note by ID
  Future<Note?> getNoteById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  /// Update a note
  Future<int> updateNote(Note note) async {
    final db = await _databaseHelper.database;
    return await db.update(
      tableName,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Delete a note
  Future<int> deleteNote(int id) async {
    final db = await _databaseHelper.database;
    // We have cascade delete set up, so this will also delete related checklist items
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get checklist items for a note
  Future<List<ChecklistItem>> getChecklistItemsByNoteId(int noteId) async {
    return await _databaseHelper.getChecklistItemsByNoteId(noteId);
  }

  /// Save checklist items for a note
  /// This will replace all existing items for the note
  Future<void> saveChecklistItems(int noteId, List<ChecklistItem> items) async {
    final db = await _databaseHelper.database;
    
    // Use a transaction for atomicity
    await db.transaction((txn) async {
      // Delete existing items
      await txn.delete(
        'checklist_items',
        where: 'note_id = ?',
        whereArgs: [noteId],
      );
      
      // Insert new items
      for (var i = 0; i < items.length; i++) {
        final item = items[i].copyWith(
          noteId: noteId,
          position: i,
          updatedAt: DateTime.now(),
        );
        
        await txn.insert(
          'checklist_items',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Search notes by title or content
  Future<List<Note>> searchNotes(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Get notes with upcoming due dates
  Future<List<Note>> getNotesByDueDate({DateTime? fromDate, DateTime? toDate}) async {
    final db = await _databaseHelper.database;
    String whereClause = 'due_date IS NOT NULL';
    List<dynamic> whereArgs = [];
    
    if (fromDate != null) {
      whereClause += ' AND due_date >= ?';
      whereArgs.add(fromDate.toIso8601String());
    }
    
    if (toDate != null) {
      whereClause += ' AND due_date <= ?';
      whereArgs.add(toDate.toIso8601String());
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'due_date ASC',
    );
    
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Get notes by type
  Future<List<Note>> getNotesByType(String noteType) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'note_type = ?',
      whereArgs: [noteType],
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }
} 