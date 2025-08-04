import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class LocationService {
  static final Location _location = Location();

  static Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }
    return true;
  }

  static Future<LatLng> getCurrentLocation() async {
    bool hasPermission = await checkAndRequestPermission();
    if (!hasPermission) {
      throw Exception('Permissions de géolocalisation non accordées');
    }
    
    LocationData locationData = await _location.getLocation();
    
    if (locationData.latitude == null || locationData.longitude == null) {
      throw Exception('Impossible d\'obtenir les coordonnées de géolocalisation');
    }
    
    return LatLng(locationData.latitude!, locationData.longitude!);
  }

  static double calculateDistance(LatLng from, LatLng to) {
    const double earthRadius = 6371;
    
    double lat1Rad = from.latitude * (pi / 180);
    double lat2Rad = to.latitude * (pi / 180);
    double deltaLatRad = (to.latitude - from.latitude) * (pi / 180);
    double deltaLonRad = (to.longitude - from.longitude) * (pi / 180);

    double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static Future<void> openLocationSettings() async {
    await _location.requestService();
  }

  static Future<void> openAppSettings() async {
    await _location.requestPermission();
  }
} 