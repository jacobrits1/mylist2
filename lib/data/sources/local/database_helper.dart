import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mylist2/data/models/category.dart';
import 'package:mylist2/data/models/checklist_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mylist2.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create notes table with category foreign key
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT,
        category_id INTEGER,
        note_type TEXT NOT NULL DEFAULT 'text',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
          ON DELETE SET NULL
      )
    ''');

    // Create checklist_items table
    await db.execute('''
      CREATE TABLE checklist_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        note_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        is_checked INTEGER NOT NULL DEFAULT 0,
        position INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (note_id) REFERENCES notes (id)
          ON DELETE CASCADE
      )
    ''');

    // Insert default categories
    await db.insert('categories', Category(
      name: 'Personal',
      description: 'Personal notes and reminders',
    ).toMap());

    await db.insert('categories', Category(
      name: 'Work',
      description: 'Work-related notes and tasks',
    ).toMap());

    await db.insert('categories', Category(
      name: 'Shopping',
      description: 'Shopping lists and items to buy',
    ).toMap());

    await db.insert('categories', Category(
      name: 'Ideas',
      description: 'Ideas and inspirations',
    ).toMap());
  }

  // Category CRUD operations
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Checklist CRUD operations
  Future<int> insertChecklistItem(ChecklistItem item) async {
    final db = await database;
    return await db.insert('checklist_items', item.toMap());
  }

  Future<List<ChecklistItem>> getChecklistItemsByNoteId(int noteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'checklist_items',
      where: 'note_id = ?',
      whereArgs: [noteId],
      orderBy: 'position ASC',
    );
    return List.generate(maps.length, (i) => ChecklistItem.fromMap(maps[i]));
  }

  Future<int> updateChecklistItem(ChecklistItem item) async {
    final db = await database;
    return await db.update(
      'checklist_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteChecklistItem(int id) async {
    final db = await database;
    return await db.delete(
      'checklist_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> reorderChecklistItems(int noteId, List<int> itemIds) async {
    final db = await database;
    await db.transaction((txn) async {
      for (int i = 0; i < itemIds.length; i++) {
        await txn.update(
          'checklist_items',
          {'position': i},
          where: 'id = ?',
          whereArgs: [itemIds[i]],
        );
      }
    });
  }

  Future<void> deleteChecklistItemsByNoteId(int noteId) async {
    final db = await database;
    await db.delete(
      'checklist_items',
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
  }
} 