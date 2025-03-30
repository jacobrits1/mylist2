import 'package:sqflite/sqflite.dart';
import '../models/reminder_model.dart';
import '../sources/local/database_helper.dart';

/// Repository class for managing reminders in the database
class ReminderRepository {
  final DatabaseHelper _databaseHelper;
  static const String tableName = 'reminders';

  ReminderRepository(this._databaseHelper);

  /// Create the reminders table in the database
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        noteId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        reminderTime TEXT NOT NULL,
        isCompleted INTEGER DEFAULT 0,
        FOREIGN KEY (noteId) REFERENCES notes(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Add a new reminder to the database
  Future<int> addReminder(ReminderModel reminder) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      tableName,
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all reminders for a specific note
  Future<List<ReminderModel>> getRemindersForNote(int noteId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
    return List.generate(maps.length, (i) => ReminderModel.fromMap(maps[i]));
  }

  /// Get all reminders
  Future<List<ReminderModel>> getAllReminders() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => ReminderModel.fromMap(maps[i]));
  }

  /// Update a reminder in the database
  Future<int> updateReminder(ReminderModel reminder) async {
    final db = await _databaseHelper.database;
    return await db.update(
      tableName,
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  /// Delete a reminder from the database
  Future<int> deleteReminder(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark a reminder as completed
  Future<int> markReminderAsCompleted(int id) async {
    final db = await _databaseHelper.database;
    return await db.update(
      tableName,
      {'isCompleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all reminders for a specific note
  Future<int> deleteRemindersForNote(int noteId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      tableName,
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
  }
} 