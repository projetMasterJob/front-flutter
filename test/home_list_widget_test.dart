import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:front_flutter/home_tab.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TestHomeList extends StatelessWidget {
  final List<Map> items;
  final void Function(String type, {String? id})? onNavigateToDetail;
  const TestHomeList({Key? key, required this.items, this.onNavigateToDetail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            final location = item['location'] ?? {};
            final title = item['title'] ?? item['name'] ?? '';
            final cp = location['cp'] ?? '';
            final address = location['address'] ?? '';
            final imageUrl = item['image_url'] ?? '';
            final distance = item['__distance'] as double?;
            return InkWell(
              onTap: () {
                if (onNavigateToDetail != null) {
                  onNavigateToDetail!(item['entity_type'] ?? 'company', id: item['id']);
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      spreadRadius: 0.5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: Icon(Icons.image, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 70),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                SizedBox(height: 2),
                                Text(address, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
                                if (cp.isNotEmpty || distance != null) SizedBox(height: 6),
                                if (cp.isNotEmpty)
                                  Text(cp, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 70),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFFECF4FB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.directions_walk, size: 14, color: Color(0xFF3264E0)),
                            SizedBox(width: 4),
                            if (distance != null && distance != double.infinity)
                              Text(
                                '${distance.toStringAsFixed(2)} km',
                                style: TextStyle(
                                  color: Color(0xFF3264E0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  final companies = [
    {
      'id': '1',
      'name': 'Alpha',
      'description': 'desc',
      'location': {'latitude': 43.6, 'longitude': 7.1, 'address': 'adr', 'cp': '06000', 'entity_type': 'company'},
      'image_url': 'img1',
      '__distance': 0.0,
      'entity_type': 'company',
    },
  ];
  final jobs = [
    {
      'id': '2',
      'title': 'Bravo',
      'description': 'desc',
      'location': {'latitude': 43.7, 'longitude': 7.2, 'address': 'adr', 'cp': '06001', 'entity_type': 'job'},
      'image_url': 'img2',
      '__distance': 1.5,
      'entity_type': 'job',
    },
  ];

  testWidgets('affiche la liste des éléments', (WidgetTester tester) async {
    await tester.pumpWidget(TestHomeList(items: [...companies, ...jobs]));
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Bravo'), findsOneWidget);
  });

  testWidgets('affiche le code postal et l\'adresse', (WidgetTester tester) async {
    await tester.pumpWidget(TestHomeList(items: [...companies, ...jobs]));
    expect(find.text('06000'), findsOneWidget);
    expect(find.text('06001'), findsOneWidget);
    expect(find.text('adr'), findsNWidgets(2));
  });

  testWidgets('affiche la distance si définie', (WidgetTester tester) async {
    await tester.pumpWidget(TestHomeList(items: [...companies, ...jobs]));
    expect(find.text('0.00 km'), findsOneWidget);
    expect(find.text('1.50 km'), findsOneWidget);
  });

  testWidgets('filtrage par recherche', (WidgetTester tester) async {
    final filtered = companies.where((c) => c['name'] == 'Alpha').toList();
    await tester.pumpWidget(TestHomeList(items: filtered));
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Bravo'), findsNothing);
  });

  testWidgets('tri par nom décroissant', (WidgetTester tester) async {
    final sorted = [...companies, ...jobs];
    sorted.sort((a, b) => ((b['name'] ?? b['title']) ?? '').toString().compareTo(((a['name'] ?? a['title']) ?? '').toString()));
    await tester.pumpWidget(TestHomeList(items: sorted));
    final bravo = find.text('Bravo');
    final alpha = find.text('Alpha');
    expect(tester.getTopLeft(bravo).dy < tester.getTopLeft(alpha).dy, isTrue);
  });

  testWidgets('callback navigation appelé au clic', (WidgetTester tester) async {
    String? tappedType;
    String? tappedId;
    await tester.pumpWidget(TestHomeList(
      items: [...companies, ...jobs],
      onNavigateToDetail: (type, {id}) {
        tappedType = type;
        tappedId = id;
      },
    ));
    await tester.tap(find.text('Alpha'));
    expect(tappedType, 'company');
    expect(tappedId, '1');
  });
} 