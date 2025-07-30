import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:front_flutter/profil.dart';

void main() {
  group('ProfilPage Widget Tests', () {
    Widget createTestProfilPage() {
      return MaterialApp(
        home: ProfilPage(),
      );
    }

    testWidgets('affiche la structure de base de la page profil', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('affiche les boutons de déconnexion et suppression', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.text('Se déconnecter'), findsOneWidget);
      expect(find.text('Supprimer mon compte'), findsOneWidget);
    });

    testWidgets('affiche le mot de passe masqué', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.text('●●●●●●●●'), findsOneWidget);
    });

    testWidgets('affiche le bouton Modifier dans la section informations', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.text('Modifier'), findsOneWidget);
    });

    testWidgets('affiche les labels des champs d\'information', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.text('Adresse'), findsOneWidget);
      expect(find.text('Téléphone'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
    });

    testWidgets('affiche le titre Mes informations', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.text('Mes informations'), findsOneWidget);
    });

    testWidgets('affiche les icônes de déconnexion et suppression', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('affiche l\'image de support', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('affiche les conteneurs avec ombre', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('affiche les ListTile pour déconnexion et suppression', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('affiche les InkWell pour les interactions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('affiche les Positioned widgets pour l\'avatar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.byType(Positioned), findsWidgets);
    });

    testWidgets('affiche les Row et Column pour la mise en page', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('affiche les SizedBox pour l\'espacement', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('affiche les Divider dans le centre d\'aide', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('affiche les Text avec différents styles', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('affiche les GestureDetector pour les interactions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('affiche le Stack pour la mise en page', (WidgetTester tester) async {
      await tester.pumpWidget(createTestProfilPage());
      await tester.pumpAndSettle();

      expect(find.byType(Stack), findsWidgets);
    });
  });
} 