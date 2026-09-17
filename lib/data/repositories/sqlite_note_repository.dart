import 'package:sqflite/sqflite.dart';

import '../../core/error/failure.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/offline_repository.dart';
import '../db/offgrid_database.dart';

class SqliteNoteRepository implements OfflineRepository<Note> {
  SqliteNoteRepository(this._database);

  final OffgridDatabase _database;

  @override
  Future<Result<List<Note>>> getAll() async {
    try {
      final db = await _database.open();
      final rows = await db.query('notes', orderBy: 'created_at DESC');
      return Ok(rows.map(_fromRow).toList());
    } catch (error) {
      return Err(CacheFailure(error.toString()));
    }
  }

  @override
  Future<Result<Note>> upsert(Note entity) async {
    try {
      final db = await _database.open();
      await db.insert(
        'notes',
        _toRow(entity),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Ok(entity);
    } catch (error) {
      return Err(CacheFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> syncPending() async {
    return const Ok(null);
  }

  Map<String, Object?> _toRow(Note note) {
    return {
      'id': note.id,
      'place_id': note.placeId,
      'body': note.body,
      'sync_state': note.syncState.name,
      'created_at': note.createdAt.toIso8601String(),
    };
  }

  Note _fromRow(Map<String, Object?> row) {
    return Note(
      id: row['id']! as String,
      placeId: row['place_id'] as String?,
      body: row['body']! as String,
      syncState: SyncState.values.byName(row['sync_state']! as String),
      createdAt: DateTime.parse(row['created_at']! as String),
    );
  }
}
