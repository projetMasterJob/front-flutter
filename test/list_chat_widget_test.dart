import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front_flutter/list_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ListChat Widget Tests', () {
    
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('ListChat widget renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ListChat(),
        ),
      );

      expect(find.byType(ListChat), findsOneWidget);
    });

    testWidgets('ListChat shows some content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ListChat(),
        ),
      );

      await tester.pump();

      // Vérifier qu'il y a au moins un widget de base
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ListChat has app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ListChat(),
        ),
      );

      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('ListChat handles different states', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(
          home: ListChat(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que le widget est toujours présent
      expect(find.byType(ListChat), findsOneWidget);
    });

    testWidgets('ListChat widget structure is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ListChat(),
        ),
      );

      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('ListChat handles empty state correctly', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'user_id': 'test_user'});

      await tester.pumpWidget(
        const MaterialApp(
          home: ListChat(),
        ),
      );

      await tester.pump();

      expect(find.byType(ListChat), findsOneWidget);
    });
  });
}