import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'services/location_service.dart';
import 'models/point.dart';
import 'dart:math' show sqrt, pow;
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'dart:typed_data';

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
  double _mapRotation = 0.0;
  CameraPosition? _lastCameraPosition;
  Stream<dynamic>? _compassStream;
  bool _isCenteredOnUser = true;

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
    _listenCompass();
  }

  void _listenCompass() {
    _compassStream = FlutterCompass.events;
    _compassStream?.listen((event) {
      if (event.heading != null && _isCenteredOnUser) {
        double newRotation = event.heading!;
        if ((newRotation - _mapRotation).abs() > 2) {
          setState(() {
            _mapRotation = newRotation;
          });
          if (_mapController != null && _lastCameraPosition != null) {
            _mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _lastCameraPosition!.target,
                  zoom: _lastCameraPosition!.zoom,
                  bearing: _mapRotation,
                  tilt: _lastCameraPosition!.tilt,
                ),
              ),
            );
          }
        }
      }
    });
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
    Set<Marker> markers = {};
    for (final point in points) {
      final markerIcon = await _createMarkerIconWithImage(point.image_url, size: 100);
      markers.add(Marker(
        markerId: MarkerId(point.title),
        position: LatLng(point.latitude, point.longitude),
        icon: markerIcon,
        onTap: () => _showModernModal(point),
      ));
    }
    setState(() {
      _markers = markers;
      _points = points;
    });
  }

  Future<BitmapDescriptor> _createMarkerIconWithImage(String imageUrl, {double size = 100}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final markerSize = Size(size, size);

    // Fond blanc avec coins arrondis (4px)
    final paint = Paint()..color = Colors.white;
    final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size, size), Radius.circular(4));
    canvas.drawRRect(rrect, paint);

    // Téléchargement de l'image
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        final codec = await ui.instantiateImageCodec(bytes, targetWidth: size.toInt(), targetHeight: size.toInt());
        final frame = await codec.getNextFrame();
        final image = frame.image;

        // Dessine l'image sur le canvas (recouvre tout le carré)
        paintImage(
          canvas: canvas,
          rect: Rect.fromLTWH(0, 0, size, size),
          image: image,
          fit: BoxFit.cover,
        );
      }
    } catch (e) {
      // En cas d'erreur, le marker reste blanc
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(markerSize.width.toInt(), markerSize.height.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
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
          : Stack(
              children: [
                GoogleMap(
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
                  onCameraMove: (position) {
                    _lastCameraPosition = position;
                    if (_currentLocation != null &&
                        (position.target.latitude - _currentLocation!.latitude).abs() > 0.0001 ||
                        (position.target.longitude - _currentLocation!.longitude).abs() > 0.0001) {
                      if (_isCenteredOnUser) {
                        setState(() {
                          _isCenteredOnUser = false;
                        });
                      }
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  mapType: MapType.normal,
                  markers: _markers,
                ),
                Positioned(
                  bottom: 102,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      if (_currentLocation != null && _mapController != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: _currentLocation!,
                              zoom: 17.0,
                            ),
                          ),
                        );
                        setState(() {
                          _isCenteredOnUser = true;
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: Icon(
                          Icons.my_location,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class MarkerCustom extends StatelessWidget {
  final String title;
  final double size;
  const MarkerCustom({required this.title, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            title.isNotEmpty ? title[0] : '',
            style: const TextStyle(
              color: Color(0xFF3264E0),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _MarkerCustomPainter extends CustomPainter {
  final String title;
  final double size;
  _MarkerCustomPainter(this.title, {this.size = 100});

  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size, size),
      Radius.circular(12),
    );
    canvas.drawRRect(rrect, paint);
    final shadowPaint = Paint()
      ..color = Colors.black12
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(rrect.shift(const Offset(2, 2)), shadowPaint);
    final textSpan = TextSpan(
      text: title.isNotEmpty ? title[0] : '',
      style: const TextStyle(
        color: Color(0xFF3264E0),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    tp.layout(maxWidth: size - 8);
    tp.paint(canvas, Offset((size - tp.width) / 2, 8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
