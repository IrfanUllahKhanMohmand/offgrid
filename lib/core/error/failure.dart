sealed class Failure {
  const Failure(this.message);

  final String message;
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class SyncFailure extends Failure {
  const SyncFailure(super.message);
}
