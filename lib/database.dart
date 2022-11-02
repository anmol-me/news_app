import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

final databaseHelperProvider = Provider((ref) {
  return DatabaseHelper(ref);
});

class DatabaseHelper {
  final ProviderRef ref;

  DatabaseHelper(this.ref);

  // static const dbName = 'myDatabase.db';
  // static Database? database;

  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'categories.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE feed_categories(id TEXT PRIMARY KEY, title TEXT)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DatabaseHelper.database();

    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, Object?>>> getData(String table) async {
    final db = await DatabaseHelper.database();
    return db.query(table);
  }
}
