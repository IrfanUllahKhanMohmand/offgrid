import '../repositories/offline_repository.dart';

class Note {
  const Note({
    required this.id,
    required this.body,
    required this.syncState,
    required this.createdAt,
    this.placeId,
  });

  final String id;
  final String? placeId;
  final String body;
  final SyncState syncState;
  final DateTime createdAt;

  Note copyWith({SyncState? syncState}) {
    return Note(
      id: id,
      placeId: placeId,
      body: body,
      syncState: syncState ?? this.syncState,
      createdAt: createdAt,
    );
  }
}
