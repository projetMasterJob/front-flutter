import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:front_flutter/edit_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('EditProfilePage Widget Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'userinfo': '{"first_name":"John","last_name":"Doe","email":"john@example.com","address":"123 Main St","phone":"0123456789","description":"Test description","is_verified":true}'
      });
    });

    Widget createTestEditProfilePage() {
      return MaterialApp(
        home: EditProfilePage(),
      );
    }

    testWidgets('affiche la structure de base', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Modifier mon profil'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('affiche tous les champs du formulaire', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, 'Prénom'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Nom'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Description'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Adresse'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Téléphone'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    });

    testWidgets('affiche la section Changer le mot de passe et les champs associés', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      expect(find.text('Changer le mot de passe'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Ancien mot de passe'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Nouveau mot de passe'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Confirmer le nouveau mot de passe'), findsOneWidget);
    });

    testWidgets('affiche les boutons de visibilité pour les champs mot de passe', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('affiche le bouton Modifier', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ElevatedButton, 'Modifier'), findsOneWidget);
    });

    testWidgets('affiche les sections avec titres', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      expect(find.text('Informations personnelles'), findsOneWidget);
      expect(find.text('Changer le mot de passe'), findsOneWidget);
    });

    testWidgets('affiche les conteneurs avec ombre', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('affiche les Column pour la mise en page', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('affiche les SizedBox pour l\'espacement', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('affiche les Text avec différents styles', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('affiche le SingleChildScrollView pour le défilement', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('affiche les Padding pour l\'espacement', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('affiche les Form pour la validation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('affiche les TextFormField pour la saisie', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('permet de saisir du texte dans les champs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      
      final prenomField = find.widgetWithText(TextFormField, 'Prénom');
      await tester.enterText(prenomField, 'Nouveau Prénom');
      await tester.pump();
      
      expect(find.text('Nouveau Prénom'), findsOneWidget);
    });

    testWidgets('permet de saisir du texte dans le champ nom', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      
      final nomField = find.widgetWithText(TextFormField, 'Nom');
      await tester.enterText(nomField, 'Nouveau Nom');
      await tester.pump();
      
      expect(find.text('Nouveau Nom'), findsOneWidget);
    });

    testWidgets('permet de saisir du texte dans le champ email', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'nouveau@email.com');
      await tester.pump();
      
      expect(find.text('nouveau@email.com'), findsOneWidget);
    });

    testWidgets('permet de saisir du texte dans le champ téléphone', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      
      final phoneField = find.widgetWithText(TextFormField, 'Téléphone');
      await tester.enterText(phoneField, '0987654321');
      await tester.pump();
      
      expect(find.text('0987654321'), findsOneWidget);
    });

    testWidgets('permet de saisir du texte dans le champ adresse', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      
      final addressField = find.widgetWithText(TextFormField, 'Adresse');
      await tester.enterText(addressField, 'Nouvelle Adresse 123');
      await tester.pump();
      
      expect(find.text('Nouvelle Adresse 123'), findsOneWidget);
    });

    testWidgets('permet de saisir du texte dans le champ description', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      
      final descriptionField = find.widgetWithText(TextFormField, 'Description');
      await tester.enterText(descriptionField, 'Nouvelle description de test');
      await tester.pump();
      
      expect(find.text('Nouvelle description de test'), findsOneWidget);
    });

    testWidgets('permet de saisir du texte dans les champs de mot de passe', (WidgetTester tester) async {
      await tester.pumpWidget(createTestEditProfilePage());
      await tester.pumpAndSettle();
      
      final oldPasswordField = find.widgetWithText(TextFormField, 'Ancien mot de passe');
      await tester.enterText(oldPasswordField, 'ancien123');
      await tester.pump();
      
      final newPasswordField = find.widgetWithText(TextFormField, 'Nouveau mot de passe');
      await tester.enterText(newPasswordField, 'nouveau123');
      await tester.pump();
      
      final confirmPasswordField = find.widgetWithText(TextFormField, 'Confirmer le nouveau mot de passe');
      await tester.enterText(confirmPasswordField, 'nouveau123');
      await tester.pump();
      
      expect(find.text('ancien123'), findsOneWidget);
      expect(find.text('nouveau123'), findsNWidgets(2));
    });
  });
} 