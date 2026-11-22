import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/history_entry.dart';

/// Local history stored on the phone with sqflite.
class HistoryRepository {
  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'history.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, _) {
      return db.execute('CREATE TABLE history ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'label TEXT NOT NULL, confidence REAL NOT NULL, created_at TEXT NOT NULL)');
    });
    return _db!;
  }

  Future<void> add(HistoryEntry e) async {
    final db = await _database;
    await db.insert('history', e.toMap()..remove('id'));
  }

  Future<List<HistoryEntry>> getAll() async {
    final db = await _database;
    final rows = await db.query('history', orderBy: 'id DESC', limit: 200);
    return rows.map(HistoryEntry.fromMap).toList();
  }

  Future<void> clear() async {
    final db = await _database;
    await db.delete('history');
  }
}
