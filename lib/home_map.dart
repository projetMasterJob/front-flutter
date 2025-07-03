import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'services/location_service.dart';
import 'models/point.dart';
import 'dart:math' show sqrt, pow;

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
  Set<Marker> _markers = {};
  List<Point> _points = [];

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
    _loadMarkers();
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

  Future<void> _loadMarkers() async {
    final String data = await rootBundle.loadString('assets/points.json');
    final List<dynamic> jsonResult = json.decode(data);
    final List<Point> points = jsonResult.map((e) => Point.fromJson(e)).toList();
    Set<Marker> markers = points.map((point) => Marker(
      markerId: MarkerId(point.title),
      position: LatLng(point.latitude, point.longitude),
      icon: BitmapDescriptor.defaultMarker,
      onTap: () => _showModernModal(point),
    )).toSet();
    setState(() {
      _markers = markers;
      _points = points;
    });
  }

  void _showModernModal(Point point) {
    double? distance;
    if (_currentLocation != null) {
      distance = LocationService.calculateDistance(
        _currentLocation!,
        LatLng(point.latitude, point.longitude),
      );
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                color: Colors.transparent,
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16)],
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                point.title,
                                style: const TextStyle(
                                  color: Color(0xFF3264E0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.close, size: 20, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            height: 1,
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            color: Color(0xFFF5F5F5), // white smoke
                          ),
                        ),
                        Text(
                          point.description,
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.directions_walk, size: 16, color: Color(0xFF3264E0)),
                                  const SizedBox(width: 6),
                                  Text(
                                    distance != null ? "${distance.toStringAsFixed(2)} Km" : "- Km",
                                    style: const TextStyle(
                                      color: Color(0xFF3264E0),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3264E0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                              ),
                              child: const Text('Détails >>', style: TextStyle(fontSize: 13, color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
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
              Text("Veuillez autoriser l'accès à la localisation."),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _openAppSettings,
                child: Text("Ouvrir les paramètres de l'application"),
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
              markers: _markers,
            ),
    );
  }
}
