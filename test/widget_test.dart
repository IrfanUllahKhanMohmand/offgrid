import 'package:flutter_test/flutter_test.dart';
import 'package:offgrid/core/usecase/usecase.dart';
import 'package:offgrid/domain/entities/note.dart';
import 'package:offgrid/domain/entities/place.dart';
import 'package:offgrid/domain/repositories/offline_repository.dart';
import 'package:offgrid/main.dart';
import 'package:offgrid/presentation/pages/home_page.dart';

class _MemoryRepo<T> implements OfflineRepository<T> {
  _MemoryRepo(this._items);

  final List<T> _items;

  @override
  Future<Result<List<T>>> getAll() async => Ok(List.unmodifiable(_items));

  @override
  Future<Result<T>> upsert(T entity) async {
    _items.add(entity);
    return Ok(entity);
  }

  @override
  Future<Result<void>> syncPending() async => const Ok(null);
}

void main() {
  testWidgets('shows places and notes from the repository', (tester) async {
    final place = Place(
      id: 'place-fort',
      name: 'Lahore Fort',
      latitude: 31.588,
      longitude: 74.314,
      syncState: SyncState.pendingPush,
      createdAt: DateTime.utc(2026, 9, 11),
    );
    final note = Note(
      id: 'note-gate',
      placeId: place.id,
      body: 'Alamgiri gate is quieter after late afternoon.',
      syncState: SyncState.pendingPush,
      createdAt: DateTime.utc(2026, 9, 11),
    );

    await tester.pumpWidget(
      OffgridApp(
        home: HomePage(
          placeRepository: _MemoryRepo([place]),
          noteRepository: _MemoryRepo([note]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Offgrid'), findsOneWidget);
    expect(find.text('Lahore Fort'), findsOneWidget);
    expect(find.text('Alamgiri gate is quieter after late afternoon.'), findsOneWidget);
  });
}
