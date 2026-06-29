import 'package:flutter_test/flutter_test.dart';
import 'package:prestador/main.dart';

void main() {
  testWidgets('shows the Prestador home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PrestadorApp());

    expect(find.text('ForgeDesk Prestador'), findsOneWidget);
    expect(find.text('App Prestador do ForgeDesk'), findsOneWidget);
  });
}
