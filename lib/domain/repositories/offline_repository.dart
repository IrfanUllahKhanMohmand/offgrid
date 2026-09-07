import '../../core/usecase/usecase.dart';

/// Local-first store. Writes go to the device first; [syncPending] pushes later.
abstract class OfflineRepository<T> {
  Future<Result<List<T>>> getAll();

  Future<Result<T>> upsert(T entity);

  Future<Result<void>> syncPending();
}

/// Marker for records that still need a server round-trip.
enum SyncState { clean, pendingPush, conflict }
