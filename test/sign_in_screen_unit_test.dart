import 'package:flutter_test/flutter_test.dart';
import 'package:front_flutter/sign_in_screen.dart';
import 'package:flutter/material.dart';

void main() {
  group('SignInScreen Unit Tests', () {
    
    test('SignInScreen widget should be created', () {
      final widget = SignInScreen();
      expect(widget, isA<StatefulWidget>());
    });

    test('SignInScreen should create state', () {
      final widget = SignInScreen();
      final state = widget.createState();
      expect(state, isNotNull);
      expect(state.runtimeType.toString(), contains('_SignInScreenState'));
    });

    test('SignInScreen state should initialize with correct default values', () {
      final widget = SignInScreen();
      final state = widget.createState();
      
      expect(state.isCompany, isFalse);
      expect(state.loginError, isNull);
    });

    test('SignInScreen should be a widget', () {
      final widget = SignInScreen();
      expect(widget, isA<Widget>());
    });

    test('SignInScreen should have StatefulWidget properties', () {
      final widget = SignInScreen();
      expect(widget.runtimeType, equals(SignInScreen));
    });

    test('SignInScreen state should have form functionality', () {
      final widget = SignInScreen();
      final state = widget.createState();
      
      // Vérifier que l'état peut être créé
      expect(state, isNotNull);
    });

    test('SignInScreen state should have text controllers', () {
      final widget = SignInScreen();
      final state = widget.createState();
      
      expect(state.firstNameController, isNotNull);
      expect(state.lastNameController, isNotNull);
      expect(state.emailController, isNotNull);
      expect(state.passwordController, isNotNull);
      expect(state.adresseController, isNotNull);
      expect(state.phoneController, isNotNull);
    });

    test('SignInScreen controllers should be TextEditingController instances', () {
      final widget = SignInScreen();
      final state = widget.createState();
      
      expect(state.firstNameController, isA<TextEditingController>());
      expect(state.lastNameController, isA<TextEditingController>());
      expect(state.emailController, isA<TextEditingController>());
      expect(state.passwordController, isA<TextEditingController>());
      expect(state.adresseController, isA<TextEditingController>());
      expect(state.phoneController, isA<TextEditingController>());
    });
  });
}