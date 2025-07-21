import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:front_flutter/services/location_service.dart';
import 'package:front_flutter/models/point.dart';

void main() {
  group('HomeMapPage logique', () {
    test('shouldShowSearchButton retourne true si la distance dépasse le seuil',
        () {
      final state = _FakeHomeMapState(
        originalLocation: LatLng(43.6, 7.1),
      );
      expect(state.shouldShowSearchButton(LatLng(43.7, 7.2), 13), isTrue);
    });

    test(
        'shouldShowSearchButton retourne false si la distance ne dépasse pas le seuil',
        () {
      final state = _FakeHomeMapState(
        originalLocation: LatLng(43.6, 7.1),
      );
      expect(
          state.shouldShowSearchButton(LatLng(43.6001, 7.1001), 13), isFalse);
    });

    test('shouldShowSearchButton retourne false si originalLocation est null',
        () {
      final state = _FakeHomeMapState(
        originalLocation: null,
      );
      expect(state.shouldShowSearchButton(LatLng(43.7, 7.2), 13), isFalse);
    });

    test('parsing d\'un Point à partir de données API', () {
      final data = {
        'id': '1',
        'location': {
          'latitude': 43.6,
          'longitude': 7.1,
          'address': 'Adresse',
          'cp': '06000',
          'entity_type': 'company',
        },
        'name': 'Entreprise',
        'description': 'Desc',
        'image_url': 'url',
      };
      final location = data['location'] as Map<String, dynamic>?;
      final point = Point(
        id: data['id'] as String,
        latitude: location?['latitude'] as double,
        longitude: location?['longitude'] as double,
        title: data['name'] as String,
        description: data['description'] as String,
        address: location?['address'] as String,
        cp: location?['cp'] as String,
        entity_type: location?['entity_type'] as String,
        image_url: data['image_url'] as String,
      );
      expect(point.id, '1');
      expect(point.latitude, 43.6);
      expect(point.longitude, 7.1);
      expect(point.title, 'Entreprise');
      expect(point.description, 'Desc');
      expect(point.address, 'Adresse');
      expect(point.cp, '06000');
      expect(point.entity_type, 'company');
      expect(point.image_url, 'url');
    });

    test(
        'LocationService.calculateDistance retourne 0 pour deux points identiques',
        () {
      final from = LatLng(43.6, 7.1);
      final to = LatLng(43.6, 7.1);
      final distance = LocationService.calculateDistance(from, to);
      expect(distance, 0);
    });

    test(
        'LocationService.calculateDistance retourne une valeur positive pour deux points différents',
        () {
      final from = LatLng(43.6, 7.1);
      final to = LatLng(43.7, 7.2);
      final distance = LocationService.calculateDistance(from, to);
      expect(distance, greaterThan(0));
    });
  });
}

// Classe utilitaire pour tester la logique de shouldShowSearchButton
class _FakeHomeMapState {
  final LatLng? originalLocation;
  final double displacementThreshold;
  _FakeHomeMapState({
    required this.originalLocation,
    this.displacementThreshold = 0.5,
  });
  bool shouldShowSearchButton(LatLng currentPosition, double currentZoom) {
    if (originalLocation == null) return false;
    double distance =
        LocationService.calculateDistance(originalLocation!, currentPosition);
    double adjustedThreshold = displacementThreshold;
    if (currentZoom > 15) {
      adjustedThreshold = 0.2;
    } else if (currentZoom > 12) {
      adjustedThreshold = 0.5;
    } else {
      adjustedThreshold = 1.0;
    }
    return distance > adjustedThreshold;
  }
}
