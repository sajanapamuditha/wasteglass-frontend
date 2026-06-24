// lib/database/local_database.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/collection.dart';
import '../utils/constants.dart';

/// Manages offline SQLite storage of collection records.
class LocalDatabase {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path   = p.join(dbPath, AppConstants.localDbName);

    return openDatabase(
      path,
      version: AppConstants.localDbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE collections (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            supplier_id INTEGER NOT NULL,
            clear_kg    REAL    NOT NULL,
            coloured_kg REAL    NOT NULL,
            condition   TEXT    NOT NULL,
            timestamp   TEXT    NOT NULL,
            synced      INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  /// Insert a new collection record locally.
  static Future<int> insertCollection(Collection c) async {
    final db = await database;
    return db.insert('collections', c.toMap());
  }

  /// Fetch all unsynced records.
  static Future<List<Collection>> getUnsynced() async {
    final db   = await database;
    final rows = await db.query('collections', where: 'synced = 0');
    return rows.map(Collection.fromMap).toList();
  }

  /// Fetch all records.
  static Future<List<Collection>> getAll() async {
    final db   = await database;
    final rows = await db.query('collections');
    return rows.map(Collection.fromMap).toList();
  }

  /// Mark a record as synced.
  static Future<void> markSynced(int localId) async {
    final db = await database;
    await db.update(
      'collections',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Delete all records.
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('collections');
  }
}
