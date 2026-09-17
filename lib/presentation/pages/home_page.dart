import 'package:flutter/material.dart';

import '../../core/usecase/usecase.dart';
import '../../data/db/offgrid_database.dart';
import '../../data/repositories/sqlite_note_repository.dart';
import '../../data/repositories/sqlite_place_repository.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/offline_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.placeRepository,
    this.noteRepository,
  });

  final OfflineRepository<Place>? placeRepository;
  final OfflineRepository<Note>? noteRepository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final OfflineRepository<Place> _places;
  late final OfflineRepository<Note> _notes;
  late Future<_HomeData> _load;

  @override
  void initState() {
    super.initState();
    if (widget.placeRepository != null && widget.noteRepository != null) {
      _places = widget.placeRepository!;
      _notes = widget.noteRepository!;
    } else {
      final database = OffgridDatabase();
      _places = widget.placeRepository ?? SqlitePlaceRepository(database);
      _notes = widget.noteRepository ?? SqliteNoteRepository(database);
    }
    _load = _loadHome();
  }

  Future<_HomeData> _loadHome() async {
    var placesResult = await _places.getAll();
    if (placesResult is Ok<List<Place>> && placesResult.value.isEmpty) {
      await _seed();
      placesResult = await _places.getAll();
    }
    final notesResult = await _notes.getAll();

    if (placesResult is Err<List<Place>>) {
      throw Exception(placesResult.failure.message);
    }
    if (notesResult is Err<List<Note>>) {
      throw Exception(notesResult.failure.message);
    }

    return _HomeData(
      places: (placesResult as Ok<List<Place>>).value,
      notes: (notesResult as Ok<List<Note>>).value,
    );
  }

  Future<void> _seed() async {
    final place = Place(
      id: 'place-fort',
      name: 'Lahore Fort',
      latitude: 31.588,
      longitude: 74.314,
      syncState: SyncState.pendingPush,
      createdAt: DateTime.utc(2026, 9, 11),
    );
    final note = Note(
      id: 'note-gate',
      placeId: place.id,
      body: 'Alamgiri gate is quieter after late afternoon.',
      syncState: SyncState.pendingPush,
      createdAt: DateTime.utc(2026, 9, 11),
    );
    await _places.upsert(place);
    await _notes.upsert(note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offgrid')),
      body: FutureBuilder<_HomeData>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Could not open local storage.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final placeNames = {
            for (final place in data.places) place.id: place.name,
          };

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Places and notes',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Saved on this device first. They sync when you are back online.',
              ),
              const SizedBox(height: 24),
              if (data.places.isEmpty && data.notes.isEmpty)
                const Text('Nothing saved on this device yet.')
              else ...[
                for (final place in data.places)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(place.name),
                    subtitle: Text(
                      '${place.latitude}, ${place.longitude} · ${place.syncState.name}',
                    ),
                  ),
                for (final note in data.notes)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(note.body),
                    subtitle: Text(
                      note.placeId == null
                          ? 'Note'
                          : 'On ${placeNames[note.placeId] ?? 'a place'}',
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HomeData {
  const _HomeData({required this.places, required this.notes});

  final List<Place> places;
  final List<Note> notes;
}
