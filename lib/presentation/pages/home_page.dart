import 'package:flutter/material.dart';

import '../../domain/repositories/offline_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _layers = [
    ('domain/', 'Entities and repository contracts'),
    ('data/', 'Local SQLite + remote sync adapters'),
    ('presentation/', 'Pages and BLoC'),
    ('core/', 'Failure and use-case types'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offgrid')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Offline places and notes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Writes stay on device first, then sync when you are online. '
            'Place and Note entities come next.',
          ),
          const SizedBox(height: 8),
          Text(
            'Sync states: ${SyncState.values.map((s) => s.name).join(', ')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          ..._layers.map(
            (layer) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(layer.$1),
              subtitle: Text(layer.$2),
            ),
          ),
        ],
      ),
    );
  }
}
