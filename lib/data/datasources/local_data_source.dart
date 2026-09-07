import '../../core/error/failure.dart';
import '../../core/usecase/usecase.dart';

/// SQLite (or similar) — source of truth while offline.
abstract class LocalDataSource<T> {
  Future<Result<List<T>>> readAll();

  Future<Result<T>> write(T entity);
}

class UnimplementedLocalDataSource<T> implements LocalDataSource<T> {
  @override
  Future<Result<List<T>>> readAll() async {
    return const Err(CacheFailure('Local data source is not wired yet'));
  }

  @override
  Future<Result<T>> write(T entity) async {
    return const Err(CacheFailure('Local data source is not wired yet'));
  }
}
