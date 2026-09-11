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
}
