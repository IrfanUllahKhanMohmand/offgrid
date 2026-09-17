import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class OffgridDatabase {
  OffgridDatabase({DatabaseFactory? factory, this.path})
    : _factory = factory ?? databaseFactory;

  final DatabaseFactory _factory;
  final String? path;

  Database? _db;

  Future<Database> open() async {
    if (_db != null) {
      return _db!;
    }
    final dbPath = path ?? p.join(await getDatabasesPath(), 'offgrid.db');
    _db = await _factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
CREATE TABLE places (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  sync_state TEXT NOT NULL,
  created_at TEXT NOT NULL
)
''');
          await db.execute('''
CREATE TABLE notes (
  id TEXT PRIMARY KEY,
  place_id TEXT,
  body TEXT NOT NULL,
  sync_state TEXT NOT NULL,
  created_at TEXT NOT NULL
)
''');
        },
      ),
    );
    return _db!;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
