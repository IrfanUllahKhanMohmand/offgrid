import '../../core/error/failure.dart';
import '../../core/usecase/usecase.dart';

/// Network side of sync. Unused until the device is online.
abstract class RemoteDataSource<T> {
  Future<Result<List<T>>> pull();

  Future<Result<T>> push(T entity);
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
