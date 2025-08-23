import 'package:flutter_test/flutter_test.dart';
import 'package:front_flutter/list_chat.dart';
import 'package:flutter/material.dart';

void main() {
  group('ListChat Unit Tests', () {
    
    test('ListChat widget should be created', () {
      const widget = ListChat();
      expect(widget, isA<StatefulWidget>());
      expect(widget.key, isNull);
    });

    test('ListChat should have correct key when provided', () {
      const key = Key('test_key');
      const widget = ListChat(key: key);
      expect(widget.key, equals(key));
    });

    test('ListChat should create state', () {
      const widget = ListChat();
      final state = widget.createState();
      expect(state, isNotNull);
      expect(state.runtimeType.toString(), contains('_ListChatState'));
    });

    test('ListChat state should be created correctly', () {
      const widget = ListChat();
      final state = widget.createState();
      
      // Vérifier que l'état est créé
      expect(state, isNotNull);
    });

    test('ListChat should be a widget', () {
      const widget = ListChat();
      expect(widget, isA<Widget>());
    });

    test('ListChat should have StatefulWidget properties', () {
      const widget = ListChat();
      expect(widget.runtimeType, equals(ListChat));
    });
  });
}