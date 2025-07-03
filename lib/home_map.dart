import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'services/location_service.dart';

class HomeMapPage extends StatefulWidget {
  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  bool _locationPermissionGranted = false;
  bool _serviceEnabled = true;
  bool hasCenteredOnce = false;
  bool _isLoading = true;

  static const String _mapStyleHidePOI = '''[
    { "featureType": "all", "elementType": "all", "stylers": [ { "visibility": "off" } ] },
    { "featureType": "road", "elementType": "geometry", "stylers": [ { "visibility": "on" } ] },
    { "featureType": "road", "elementType": "labels.text", "stylers": [ { "visibility": "on" } ] },
    { "featureType": "administrative.locality", "elementType": "labels.text", "stylers": [ { "visibility": "on" } ] },
    { "featureType": "administrative.neighborhood", "elementType": "labels.text", "stylers": [ { "visibility": "on" } ] },
    { "featureType": "administrative.country", "elementType": "labels.text", "stylers": [ { "visibility": "on" } ] },
    { "featureType": "water", "elementType": "geometry", "stylers": [ { "visibility": "on" } ] },
    { "featureType": "landscape.natural", "elementType": "geometry", "stylers": [ { "visibility": "on" } ] },
    { "featureType": "landscape.man_made", "elementType": "geometry", "stylers": [ { "visibility": "on" } ] },
    { "featureType": "poi.park", "elementType": "geometry", "stylers": [ { "visibility": "on" } ] }
  ]''';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
    });
    // Vérifie et demande la permission via LocationService
    bool permissionGranted = await LocationService.checkAndRequestPermission();
    if (!permissionGranted) {
      setState(() {
        _locationPermissionGranted = false;
        _serviceEnabled = true;
        _isLoading = false;
      });
      return;
    }
    // Tente de récupérer la position
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        _currentLocation = position;
        _locationPermissionGranted = true;
        _serviceEnabled = true;
        _isLoading = false;
      });
    } catch (e) {
      // Si la localisation de l'appareil est désactivée
      setState(() {
        _serviceEnabled = false;
        _locationPermissionGranted = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _openLocationSettings() async {
    await LocationService.openLocationSettings();
  }

  Future<void> _openAppSettings() async {
    await LocationService.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // Cas 1 : Permission refusée (localisation non autorisée)
    if (!_locationPermissionGranted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_searching, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text('Permission de localisation requise.', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Veuillez autoriser l’accès à la localisation.'),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _openAppSettings,
                child: Text('Ouvrir les paramètres de l’application'),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _initializeLocation,
                child: Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    // Cas 2 : Localisation autorisée mais désactivée sur l'appareil
    if (!_serviceEnabled) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text('La localisation est désactivée.', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Veuillez activer la localisation pour utiliser la carte.'),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _openLocationSettings,
                child: Text('Activer la localisation'),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _initializeLocation,
                child: Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    // Cas 3 : Localisation autorisée et activée => loader ou carte
    return Scaffold(
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 17.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _mapController!.setMapStyle(_mapStyleHidePOI);
                if (!hasCenteredOnce) {
                  _mapController!.moveCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 17.0));
                  hasCenteredOnce = true;
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              mapType: MapType.normal,
            ),
    );
  }
}
