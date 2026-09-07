import 'package:flutter_test/flutter_test.dart';
import 'package:offgrid/main.dart';

void main() {
  testWidgets('shows scaffold home', (tester) async {
    await tester.pumpWidget(const OffgridApp());

    expect(find.text('Offgrid'), findsOneWidget);
    expect(find.text('domain/'), findsOneWidget);
  });
}
