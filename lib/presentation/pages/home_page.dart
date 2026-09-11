import 'package:flutter/material.dart';

import '../../domain/entities/note.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/offline_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final _place = Place(
    id: 'place-fort',
    name: 'Lahore Fort',
    latitude: 31.588,
    longitude: 74.314,
    syncState: SyncState.pendingPush,
    createdAt: DateTime.utc(2026, 9, 11),
  );

  static final _note = Note(
    id: 'note-gate',
    placeId: _place.id,
    body: 'Alamgiri gate is quieter after late afternoon.',
    syncState: SyncState.pendingPush,
    createdAt: DateTime.utc(2026, 9, 11),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offgrid')),
      body: ListView(
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
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_place.name),
            subtitle: Text(
              '${_place.latitude}, ${_place.longitude} · ${_place.syncState.name}',
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_note.body),
            subtitle: Text('On ${_place.name}'),
          ),
        ],
      ),
    );
  }
}
