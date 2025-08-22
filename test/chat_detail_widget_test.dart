import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front_flutter/chat_detail.dart';

void main() {
  group('ChatDetail Widget Tests', () {
    
    testWidgets('ChatDetail widget renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatDetail(
            chatId: 'test_chat_id',
            userId: 'test_user_id',
          ),
        ),
      );

      expect(find.byType(ChatDetail), findsOneWidget);
    });

    testWidgets('ChatDetail has basic structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatDetail(
            chatId: 'test_chat_id',
            userId: 'test_user_id',
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ChatDetail has app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatDetail(
            chatId: 'test_chat_id',
            userId: 'test_user_id',
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}