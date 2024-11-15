// database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Open or create the database
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create the database schema
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');
  }

  // Insert a new item
  Future<int> insertItem(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('items', row);
  }

  // Get all items from the database
  Future<List<Map<String, dynamic>>> getAllItems() async {
    final db = await instance.database;
    return await db.query('items');
  }

  // Update an item by its ID
  Future<int> updateItem(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update(
      'items',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete an item by its ID
  Future<int> deleteItem(int id) async {
    final db = await instance.database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close the database connection
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
