// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gusto/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App loads onboarding screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GustoApp());
    await tester.pumpAndSettle();

    // Verify onboarding screen elements
    expect(find.text('Gusto'), findsOneWidget);
    expect(find.text('"Anyone can cook."\n- Auguste Gusteau'), findsOneWidget);
    expect(find.text("Let's Get Started"), findsOneWidget);
  });
}
