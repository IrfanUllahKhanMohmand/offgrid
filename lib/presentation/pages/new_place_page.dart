import 'package:flutter/material.dart';

import '../../domain/entities/place.dart';
import '../../domain/repositories/offline_repository.dart';

class NewPlacePage extends StatefulWidget {
  const NewPlacePage({super.key});

  @override
  State<NewPlacePage> createState() => _NewPlacePageState();
}

class _NewPlacePageState extends State<NewPlacePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _latitude = TextEditingController(text: '31.5204');
  final _longitude = TextEditingController(text: '74.3587');

  @override
  void dispose() {
    _name.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final now = DateTime.now();
    Navigator.of(context).pop(
      Place(
        id: 'place-${now.millisecondsSinceEpoch}',
        name: _name.text.trim(),
        latitude: double.parse(_latitude.text.trim()),
        longitude: double.parse(_longitude.text.trim()),
        syncState: SyncState.pendingPush,
        createdAt: now,
      ),
    );
  }

  String? _requiredCoordinate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Enter a number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add place')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Add a place name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _latitude,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              validator: _requiredCoordinate,
            ),
            TextFormField(
              controller: _longitude,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              validator: _requiredCoordinate,
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
