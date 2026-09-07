import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offgrid')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('No places yet'),
              subtitle: Text('Add a place or a note when you are ready.'),
            ),
          ],
        ),
      ),
    );
  }
}
