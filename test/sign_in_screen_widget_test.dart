import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front_flutter/sign_in_screen.dart';

void main() {
  group('SignInScreen Widget Tests', () {
    
    testWidgets('SignInScreen widget renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('SignInScreen shows logo', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('SignInScreen has inscription button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      await tester.pump();

      expect(find.text('Inscription'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('SignInScreen widget structure is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('SignInScreen can toggle company mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      await tester.pump();

      final switchWidget = find.byType(Switch);
      expect(switchWidget, findsOneWidget);

      await tester.tap(switchWidget);
      await tester.pump();

      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('SignInScreen form fields accept input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignInScreen(),
        ),
      );

      await tester.pump();

      final firstNameField = find.widgetWithText(TextFormField, 'Prénom *').first;
      await tester.enterText(firstNameField, 'John');
      expect(find.text('John'), findsOneWidget);

      final emailField = find.widgetWithText(TextFormField, 'Adresse mail *').first;
      await tester.enterText(emailField, 'test@example.com');
      expect(find.text('test@example.com'), findsOneWidget);
    });
  });
}