import 'package:flutter_test/flutter_test.dart';
import 'package:front_flutter/chat_detail.dart';
import 'package:flutter/material.dart';

void main() {
  group('ChatDetail Unit Tests', () {
    
    test('ChatDetail widget should be created with required parameters', () {
      const widget = ChatDetail(
        chatId: 'test_chat_id',
        userId: 'test_user_id',
      );
      
      expect(widget, isA<StatefulWidget>());
      expect(widget.chatId, equals('test_chat_id'));
      expect(widget.userId, equals('test_user_id'));
    });

    test('ChatDetail should have correct key when provided', () {
      const key = Key('test_key');
      const widget = ChatDetail(
        key: key,
        chatId: 'test_chat_id',
        userId: 'test_user_id',
      );
      
      expect(widget.key, equals(key));
      expect(widget.chatId, equals('test_chat_id'));
      expect(widget.userId, equals('test_user_id'));
    });

    test('ChatDetail should create state', () {
      const widget = ChatDetail(
        chatId: 'test_chat_id',
        userId: 'test_user_id',
      );
      
      final state = widget.createState();
      expect(state, isNotNull);
      expect(state.runtimeType.toString(), contains('_ChatDetailState'));
    });

    test('ChatDetail state should be created correctly', () {
      const widget = ChatDetail(
        chatId: 'test_chat_id',
        userId: 'test_user_id',
      );
      
      final state = widget.createState();
      
      // Vérifier que l'état est créé
      expect(state, isNotNull);
    });

    test('ChatDetail should be a widget', () {
      const widget = ChatDetail(
        chatId: 'test_chat_id',
        userId: 'test_user_id',
      );
      
      expect(widget, isA<Widget>());
    });

    test('ChatDetail parameters should not be null', () {
      const widget = ChatDetail(
        chatId: 'test_chat_id',
        userId: 'test_user_id',
      );
      
      expect(widget.chatId, isNotNull);
      expect(widget.userId, isNotNull);
      expect(widget.chatId, isNotEmpty);
      expect(widget.userId, isNotEmpty);
    });

    test('ChatDetail should have StatefulWidget properties', () {
      const widget = ChatDetail(
        chatId: 'test_chat_id',
        userId: 'test_user_id',
      );
      
      expect(widget.runtimeType, equals(ChatDetail));
    });
  });
}