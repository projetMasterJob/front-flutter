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
