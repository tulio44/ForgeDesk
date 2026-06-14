import 'package:flutter_test/flutter_test.dart';

import 'package:forgedesk_cliente/main.dart';

void main() {
  testWidgets('shows ForgeDesk client home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ForgeDeskClienteApp());

    expect(find.text('ForgeDesk Cliente'), findsOneWidget);
    expect(find.text('App Cliente do ForgeDesk'), findsOneWidget);
  });
}
