import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class Point {
  final double latitude;
  final double longitude;
  final String title;
  final String description;

  Point({
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.description,
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      latitude: json['latitude'],
      longitude: json['longitude'],
      title: json['title'],
      description: json['description'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

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
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          _locationPermissionGranted = false;
        });
        return;
      }
    }

    setState(() {
      _locationPermissionGranted = true;
    });

    if (_locationPermissionGranted) {
      _getCurrentLocation();
      _loadPoints();
      _startLocationUpdates();
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationPermissionGranted = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

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
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _getCurrentLocation();
    });
  }

  void _showLocationPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          title: Text("Vous êtes ici", textAlign: TextAlign.center),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Profil ?',
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            TextButton(
              child: Text("Fermer"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showMarkerPopup(BuildContext context, Point point) {
    double distance = Geolocator.distanceBetween(
          _currentLocation.latitude,
          _currentLocation.longitude,
          point.latitude,
          point.longitude,
        ) /
        1000;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
              child: Text("Fermer"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
        title: Text('Job Finder'),
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
                      builder: (ctx) => GestureDetector(
                        onTap: () => _showLocationPopup(context),
                        child: Icon(Icons.location_on, color: Colors.red),
                      ),
                    ),
                    ...points.map(
                      (point) => Marker(
                        point: LatLng(point.latitude, point.longitude),
                        builder: (ctx) => GestureDetector(
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
                onPressed: _checkLocationPermission,
                child: Text('Activer la localisation'),
              ),
            ),
    );
  }
}
