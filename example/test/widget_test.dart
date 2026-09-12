import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_iot_example/main.dart';

void main() {
  testWidgets('Verify IoT Example App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const FlutterIoTExampleApp());
    expect(find.text('Flutter IoT Control Center'), findsOneWidget);
  });
}
