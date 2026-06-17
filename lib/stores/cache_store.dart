import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class CacheStore {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'mira_cache.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cache (
            service_id TEXT,
            report_id TEXT,
            content TEXT,
            cached_at INTEGER,
            PRIMARY KEY (service_id, report_id)
          )
        ''');
      },
    );
    return _db!;
  }

  Future<String?> get(String serviceId, String reportId) async {
    final database = await db;
    final results = await database.query(
      'cache',
      columns: ['content'],
      where: 'service_id = ? AND report_id = ?',
      whereArgs: [serviceId, reportId],
    );
    if (results.isEmpty) return null;
    return results.first['content'] as String;
  }

  Future<void> put(String serviceId, String reportId, String content) async {
    final database = await db;
    await database.insert(
      'cache',
      {
        'service_id': serviceId,
        'report_id': reportId,
        'content': content,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clear() async {
    final database = await db;
    await database.delete('cache');
  }
}
