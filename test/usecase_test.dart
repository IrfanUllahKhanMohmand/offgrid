import 'package:flutter_test/flutter_test.dart';
import 'package:offgrid/core/error/failure.dart';
import 'package:offgrid/core/usecase/usecase.dart';

void main() {
  test('Ok and Err wrap success and failure', () {
    const ok = Ok<int>(1);
    const err = Err<int>(CacheFailure('disk'));

    expect(ok.value, 1);
    expect(err.failure.message, 'disk');
  });
}
