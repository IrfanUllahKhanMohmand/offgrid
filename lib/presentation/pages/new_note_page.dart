import 'package:flutter/material.dart';

import '../../domain/entities/note.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/offline_repository.dart';

class NewNotePage extends StatefulWidget {
  const NewNotePage({super.key, required this.places});

  final List<Place> places;

  @override
  State<NewNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  final _formKey = GlobalKey<FormState>();
  final _body = TextEditingController();
  String? _placeId;

  @override
  void initState() {
    super.initState();
    _placeId = widget.places.isEmpty ? null : widget.places.first.id;
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final now = DateTime.now();
    Navigator.of(context).pop(
      Note(
        id: 'note-${now.millisecondsSinceEpoch}',
        placeId: _placeId,
        body: _body.text.trim(),
        syncState: SyncState.pendingPush,
        createdAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add note')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (widget.places.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _placeId,
                decoration: const InputDecoration(labelText: 'Place'),
                items: [
                  for (final place in widget.places)
                    DropdownMenuItem(
                      value: place.id,
                      child: Text(place.name),
                    ),
                ],
                onChanged: (value) => setState(() => _placeId = value),
              ),
            if (widget.places.isNotEmpty) const SizedBox(height: 16),
            TextFormField(
              controller: _body,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Write a short note';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
