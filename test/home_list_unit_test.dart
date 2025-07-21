import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:front_flutter/services/location_service.dart';
import 'package:front_flutter/models/point.dart';

void main() {
  group('LocationService', () {
    test('calculateDistance retourne 0 pour deux points identiques', () {
      final from = LatLng(43.6, 7.1);
      final to = LatLng(43.6, 7.1);
      final distance = LocationService.calculateDistance(from, to);
      expect(distance, 0);
    });

    test('calculateDistance retourne une valeur positive pour deux points différents', () {
      final from = LatLng(43.6, 7.1);
      final to = LatLng(43.7, 7.2);
      final distance = LocationService.calculateDistance(from, to);
      expect(distance, greaterThan(0));
    });

    test('calculateDistance gère les valeurs extrêmes', () {
      final from = LatLng(-90, -180);
      final to = LatLng(90, 180);
      final distance = LocationService.calculateDistance(from, to);
      expect(distance, greaterThan(0));
    });
  });

  group('Point parsing', () {
    test('création d\'un Point à partir de données API complètes', () {
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

    test('création d\'un Point avec des valeurs manquantes', () {
      final data = {
        'id': '2',
        'location': null,
        'name': null,
        'description': null,
        'image_url': null,
      };
      final point = Point(
        id: data['id'] as String,
        latitude: 0.0,
        longitude: 0.0,
        title: data['name'] ?? '',
        description: data['description'] ?? '',
        address: '',
        cp: '',
        entity_type: '',
        image_url: data['image_url'] ?? '',
      );
      expect(point.id, '2');
      expect(point.latitude, 0.0);
      expect(point.longitude, 0.0);
      expect(point.title, '');
      expect(point.description, '');
      expect(point.address, '');
      expect(point.cp, '');
      expect(point.entity_type, '');
      expect(point.image_url, '');
    });
  });
} 