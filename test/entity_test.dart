import 'package:flutter_test/flutter_test.dart';
import 'package:offgrid/domain/entities/note.dart';
import 'package:offgrid/domain/entities/place.dart';
import 'package:offgrid/domain/repositories/offline_repository.dart';

void main() {
  test('a note can sit on a place', () {
    final place = Place(
      id: 'p1',
      name: 'Fort',
      latitude: 31.5,
      longitude: 74.3,
      syncState: SyncState.pendingPush,
      createdAt: DateTime.utc(2026, 9, 11),
    );
    final note = Note(
      id: 'n1',
      placeId: place.id,
      body: 'Quiet after sunset.',
      syncState: SyncState.pendingPush,
      createdAt: DateTime.utc(2026, 9, 11),
    );

    expect(note.placeId, place.id);
    expect(place.syncState, SyncState.pendingPush);
  });
}
