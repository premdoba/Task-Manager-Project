import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get _database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'tasks.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE tasks(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL DEFAULT '',
          due_date INTEGER,
          is_done INTEGER NOT NULL DEFAULT 0
        )
      '''),
    );
  }

  /// Returns the new row id.
  Future<int> insert(Task task) async =>
      (await _database).insert('tasks', task.toMap()..remove('id'));

  Future<void> update(Task task) async => (await _database)
      .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);

  Future<void> delete(int id) async =>
      (await _database).delete('tasks', where: 'id = ?', whereArgs: [id]);

  /// Pending tasks first, ordered by due date (undated last).
  Future<List<Task>> getAll() async {
    final rows = await (await _database).query(
      'tasks',
      orderBy: 'is_done ASC, due_date IS NULL, due_date ASC, id DESC',
    );
    return rows.map(Task.fromMap).toList();
  }
}
