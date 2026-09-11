import 'package:flutter_test/flutter_test.dart';
import 'package:offgrid/main.dart';

void main() {
  testWidgets('shows home', (tester) async {
    await tester.pumpWidget(const OffgridApp());

    expect(find.text('Offgrid'), findsOneWidget);
    expect(find.text('Places and notes'), findsOneWidget);
    expect(find.text('Lahore Fort'), findsOneWidget);
  });
}
