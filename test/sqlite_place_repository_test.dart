import 'package:flutter_test/flutter_test.dart';
import 'package:offgrid/core/usecase/usecase.dart';
import 'package:offgrid/data/db/offgrid_database.dart';
import 'package:offgrid/data/repositories/sqlite_note_repository.dart';
import 'package:offgrid/data/repositories/sqlite_place_repository.dart';
import 'package:offgrid/domain/entities/note.dart';
import 'package:offgrid/domain/entities/place.dart';
import 'package:offgrid/domain/repositories/offline_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('stores places and notes in SQLite', () async {
    final database = OffgridDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    final places = SqlitePlaceRepository(database);
    final notes = SqliteNoteRepository(database);

    final place = Place(
      id: 'place-1',
      name: 'Lahore Fort',
      latitude: 31.588,
      longitude: 74.314,
      syncState: SyncState.pendingPush,
      createdAt: DateTime.utc(2026, 9, 17),
    );
    final note = Note(
      id: 'note-1',
      placeId: place.id,
      body: 'Quiet after sunset.',
      syncState: SyncState.pendingPush,
      createdAt: DateTime.utc(2026, 9, 17),
    );

    expect(await places.upsert(place), isA<Ok<Place>>());
    expect(await notes.upsert(note), isA<Ok<Note>>());

    final loadedPlaces = await places.getAll();
    final loadedNotes = await notes.getAll();

    expect(loadedPlaces, isA<Ok<List<Place>>>());
    expect((loadedPlaces as Ok<List<Place>>).value.single.name, 'Lahore Fort');
    expect((loadedNotes as Ok<List<Note>>).value.single.body, 'Quiet after sunset.');

    await database.close();
  });
}
