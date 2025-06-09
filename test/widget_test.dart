import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/main.dart';  // Adjust to your project name

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ClockApp());  // Use your actual main widget
    expect(find.byType(ClockApp), findsOneWidget);
  });
}
