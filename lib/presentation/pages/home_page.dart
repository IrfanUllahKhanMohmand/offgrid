import 'package:flutter/material.dart';

import '../../core/usecase/usecase.dart';
import '../../data/db/offgrid_database.dart';
import '../../data/repositories/sqlite_note_repository.dart';
import '../../data/repositories/sqlite_place_repository.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/offline_repository.dart';
import 'new_note_page.dart';
import 'new_place_page.dart';

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
  var _syncing = false;

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

  Future<void> _sync() async {
    setState(() => _syncing = true);
    final placesResult = await _places.syncPending();
    final notesResult = await _notes.syncPending();
    if (!mounted) {
      return;
    }
    final next = _loadHome();
    setState(() {
      _syncing = false;
      _load = next;
    });
    if (placesResult is Err || notesResult is Err) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sync right now.')),
      );
    }
  }

  Future<void> _addPlace() async {
    final place = await Navigator.of(context).push<Place>(
      MaterialPageRoute(builder: (context) => const NewPlacePage()),
    );
    if (place == null) {
      return;
    }
    await _places.upsert(place);
    if (!mounted) {
      return;
    }
    final next = _loadHome();
    setState(() {
      _load = next;
    });
  }

  Future<void> _addNote(List<Place> places) async {
    final note = await Navigator.of(context).push<Note>(
      MaterialPageRoute(builder: (context) => NewNotePage(places: places)),
    );
    if (note == null) {
      return;
    }
    await _notes.upsert(note);
    if (!mounted) {
      return;
    }
    final next = _loadHome();
    setState(() {
      _load = next;
    });
  }

  String _syncLabel(SyncState state) {
    return switch (state) {
      SyncState.clean => 'Synced',
      SyncState.pendingPush => 'Waiting to sync',
      SyncState.conflict => 'Needs attention',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offgrid'),
        actions: [
          IconButton(
            tooltip: 'Sync',
            onPressed: _syncing ? null : _sync,
            icon: _syncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
          ),
        ],
      ),
      floatingActionButton: FutureBuilder<_HomeData>(
        future: _load,
        builder: (context, snapshot) {
          final places = snapshot.data?.places ?? const <Place>[];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'add-note',
                tooltip: 'Add note',
                onPressed: () => _addNote(places),
                child: const Icon(Icons.note_add_outlined),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'add-place',
                tooltip: 'Add place',
                onPressed: _addPlace,
                child: const Icon(Icons.add_location_alt_outlined),
              ),
            ],
          );
        },
      ),
      body: FutureBuilder<_HomeData>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not open local storage.'));
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
                      '${place.latitude}, ${place.longitude} · ${_syncLabel(place.syncState)}',
                    ),
                  ),
                for (final note in data.notes)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(note.body),
                    subtitle: Text(
                      [
                        note.placeId == null
                            ? 'Note'
                            : 'On ${placeNames[note.placeId] ?? 'a place'}',
                        _syncLabel(note.syncState),
                      ].join(' · '),
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
