import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:front_flutter/home_map.dart';

void main() {
  testWidgets('Affiche le loader au démarrage', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomeMapPage(
        search: '',
        onClearSearch: null,
        onNavigateToDetail: null,
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }); 
}

// Explications sur la couverture de tests widget pour home_map :

// Seul le test du loader est présent car :
// - Toutes les méthodes de LocationService sont statiques, donc non mockables.
// - Impossible de simuler la permission ou la localisation sans refactoriser LocationService.
// - Les tests avancés (affichage de la carte, permission refusée, etc.) nécessitent soit un téléphone physique
//   avec la localisation activée, soit un refactoring pour permettre l'injection de dépendances.
// - Ce choix est volontaire pour garantir des tests fiables et reproductibles en CI.
// - Pour une couverture avancée, il faudrait refactoriser LocationService en classe à méthodes d'instance.
