import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gusto_app/screens/onboarding/welcome_screen.dart';

void main() {
  testWidgets('WelcomeScreen has a title and a button', (WidgetTester tester) async {
    // A MaterialApp is needed to provide context like Theme.
    await tester.pumpWidget(MaterialApp(
      home: WelcomeScreen(onNext: () {}),
    ));

    expect(find.text('"Anyone can cook."'), findsOneWidget);
    expect(find.text('- Auguste Gusteau'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
