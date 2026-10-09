import 'package:sqflite/sqflite.dart';

import '../../core/error/failure.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/offline_repository.dart';
import '../datasources/remote_data_source.dart';
import '../db/offgrid_database.dart';

class SqlitePlaceRepository implements OfflineRepository<Place> {
  SqlitePlaceRepository(
    this._database, {
    RemoteDataSource<Place>? remote,
  }) : _remote = remote ?? MemoryRemoteDataSource<Place>();

  final OffgridDatabase _database;
  final RemoteDataSource<Place> _remote;

  @override
  Future<Result<List<Place>>> getAll() async {
    try {
      final db = await _database.open();
      final rows = await db.query('places', orderBy: 'created_at DESC');
      return Ok(rows.map(_fromRow).toList());
    } catch (error) {
      return Err(CacheFailure(error.toString()));
    }
  }

  @override
  Future<Result<Place>> upsert(Place entity) async {
    try {
      final db = await _database.open();
      await db.insert(
        'places',
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
    final loaded = await getAll();
    if (loaded is Err<List<Place>>) {
      return Err(loaded.failure);
    }
    final places = (loaded as Ok<List<Place>>).value;
    for (final place in places) {
      if (place.syncState != SyncState.pendingPush) {
        continue;
      }
      final pushed = await _remote.push(place);
      if (pushed is Err<Place>) {
        return Err(pushed.failure);
      }
      final saved = await upsert(place.copyWith(syncState: SyncState.clean));
      if (saved is Err<Place>) {
        return Err(saved.failure);
      }
    }
    return const Ok(null);
  }

  Map<String, Object?> _toRow(Place place) {
    return {
      'id': place.id,
      'name': place.name,
      'latitude': place.latitude,
      'longitude': place.longitude,
      'sync_state': place.syncState.name,
      'created_at': place.createdAt.toIso8601String(),
    };
  }

  Place _fromRow(Map<String, Object?> row) {
    return Place(
      id: row['id']! as String,
      name: row['name']! as String,
      latitude: (row['latitude']! as num).toDouble(),
      longitude: (row['longitude']! as num).toDouble(),
      syncState: SyncState.values.byName(row['sync_state']! as String),
      createdAt: DateTime.parse(row['created_at']! as String),
    );
  }
}
