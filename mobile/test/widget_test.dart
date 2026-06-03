import 'package:flutter_test/flutter_test.dart';
import 'package:potatos_racing_app/main.dart';

void main() {
  testWidgets('renders login entry point', (WidgetTester tester) async {
    await tester.pumpWidget(const PotatosApp());

    expect(find.text('Potatos Racing'), findsOneWidget);
    expect(find.text('Entrar no grid'), findsOneWidget);
  });
}
