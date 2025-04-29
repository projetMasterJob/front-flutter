import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/point.dart';
import '../services/location_service.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MapController _mapController;
  LatLng _currentLocation = LatLng(43.7102, 7.2620);
  bool _locationPermissionGranted = false;
  List<Point> points = [];
  late Timer _timer;
  bool hasCenteredOnce = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final permissionGranted = await LocationService.checkAndRequestPermission();
    setState(() => _locationPermissionGranted = permissionGranted);

    if (permissionGranted) {
      await _updateLocation();
      await _loadPoints();
      _startLocationUpdates();
    }
  }

  Future<void> _updateLocation() async {
    final location = await LocationService.getCurrentLocation();
    setState(() => _currentLocation = location);

    if (!hasCenteredOnce) {
      _mapController.move(_currentLocation, 15.0);
      hasCenteredOnce = true;
    }
  }

  Future<void> _loadPoints() async {
    final String response =
        await rootBundle.rootBundle.loadString('assets/points.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      points = data.map((json) => Point.fromJson(json)).toList();
    });
  }

  void _startLocationUpdates() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateLocation());
  }

  void _showLocationPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.all(10),
        title: Text("Vous êtes ici", textAlign: TextAlign.center),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Profil ?', textAlign: TextAlign.center),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Fermer"),
          ),
        ],
      ),
    );
  }

  void _showMarkerPopup(BuildContext context, Point point) {
    final distance = LocationService.calculateDistance(
      _currentLocation,
      LatLng(point.latitude, point.longitude),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.all(10),
        title: Text(point.title, textAlign: TextAlign.center),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${point.description}\nDistance : ${distance.toStringAsFixed(2)} Km',
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Fermer"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carte centrée sur la position actuelle'),
      ),
      body: _locationPermissionGranted
          ? FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentLocation,
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      builder: (_) => GestureDetector(
                        onTap: () => _showLocationPopup(context),
                        child: Image.asset(
                          'assets/images/user_marker.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                    ...points.map(
                      (point) => Marker(
                        point: LatLng(point.latitude, point.longitude),
                        builder: (_) => GestureDetector(
                          onTap: () => _showMarkerPopup(context, point),
                          child: Icon(Icons.location_on, color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Center(
              child: ElevatedButton(
                onPressed: _initializeLocation,
                child: Text('Activer la localisation'),
              ),
            ),
    );
  }
}
