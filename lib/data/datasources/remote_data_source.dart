import '../../core/error/failure.dart';
import '../../core/usecase/usecase.dart';

/// Network side of sync.
abstract class RemoteDataSource<T> {
  Future<Result<List<T>>> pull();

  Future<Result<T>> push(T entity);
}

/// Accepts every push so offline-first repos can clear pending state.
class MemoryRemoteDataSource<T> implements RemoteDataSource<T> {
  final List<T> pushed = [];

  @override
  Future<Result<List<T>>> pull() async => Ok(List.unmodifiable(pushed));

  @override
  Future<Result<T>> push(T entity) async {
    pushed.add(entity);
    return Ok(entity);
  }
}

class UnimplementedRemoteDataSource<T> implements RemoteDataSource<T> {
  @override
  Future<Result<List<T>>> pull() async {
    return const Err(SyncFailure('Could not reach the server'));
  }

  @override
  Future<Result<T>> push(T entity) async {
    return const Err(SyncFailure('Could not reach the server'));
  }
}
