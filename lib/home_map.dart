import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'services/location_service.dart';
import 'models/point.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';

class HomeMapPage extends StatefulWidget {
  final String search;
  final VoidCallback? onClearSearch;
  final void Function(String type, {String? id})? onNavigateToDetail;
  const HomeMapPage({Key? key, required this.search, this.onClearSearch, this.onNavigateToDetail}) : super(key: key);

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
  bool _showSearchHereButton = false;
  CameraPosition? _lastIdleCameraPosition;
  LatLng? _originalLocation;
  static const double _displacementThreshold = 0.5;
  bool _isSearchButtonLoading = false;

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
        _originalLocation = position;
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

  // Fonction pour calculer si l'utilisateur s'est suffisamment éloigné
  bool _shouldShowSearchButton(LatLng currentPosition, double currentZoom) {
    if (_originalLocation == null) return false;
    
    // Calculer la distance entre la position actuelle et l'origine
    double distance = LocationService.calculateDistance(_originalLocation!, currentPosition);
    
    // Ajuster le seuil en fonction du zoom
    double adjustedThreshold = _displacementThreshold;
    if (currentZoom > 15) {
      adjustedThreshold = 0.2;
    } else if (currentZoom > 12) {
      adjustedThreshold = 0.5;
    } else {
      adjustedThreshold = 1.0;
    }
    

    
    return distance > adjustedThreshold;
  }

  Future<void> _loadMarkersFromApi({required double centerLat, required double centerLng, required double zoom, double radiusKm = 5.0}) async {
    setState(() {
      _isLoading = true;
      _showSearchHereButton = false;
    });
    
    final url = Uri.parse('https://cartographielocal.vercel.app/map/entities?center_lat=$centerLat&center_lng=$centerLng&zoom_level=$zoom&radius_km=$radiusKm');
    
    try {
      final response = await http.get(url);
              if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> companies = data['companies'] ?? [];
          final List<dynamic> jobs = data['jobs'] ?? [];
        final List<Point> points = [
          ...companies.map((e) => Point(
            id: e['id'],
            latitude: e['location'] != null ? e['location']['latitude'] : 0.0,
            longitude: e['location'] != null ? e['location']['longitude'] : 0.0,
            title: e['name'],
            description: e['description'],
            address: e['location'] != null ? e['location']['address'] : "Non renseigné",
            cp: e['location'] != null ? e['location']['cp'] : "Non renseigné",
            entity_type: e['location'] != null ? e['location']['entity_type'] : "Non renseigné",
            image_url: e['image_url'] ?? '',
          )),
          ...jobs.map((e) => Point(
            id: e['id'],
            latitude: e['location'] != null ? e['location']['latitude'] : 0.0,
            longitude: e['location'] != null ? e['location']['longitude'] : 0.0,
            title: e['title'],
            description: e['description'],
            address: e['location'] != null ? e['location']['address'] : "Non renseigné",
            cp: e['location'] != null ? e['location']['cp'] : "Non renseigné",
            entity_type: e['location'] != null ? e['location']['entity_type'] : "Non renseigné",
            image_url: e['image_url'] ?? '',
          )),
        ]
        // On filtre les points invalides
        .where((p) => p.latitude != 0.0 && p.longitude != 0.0)
        .toList();
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
          _isLoading = false;
          // Le bouton s'affichera seulement si l'utilisateur s'est éloigné
        });
              } else {
          setState(() {
            _markers = {};
            _points = [];
            _isLoading = false;
          });
        }
          } catch (e) {
        setState(() {
          _markers = {};
          _points = [];
          _isLoading = false;
        });
      }
  }

  // Nouvelle fonction pour charger seulement les points sans rafraîchir la carte
  Future<void> _loadPointsOnly({required double centerLat, required double centerLng, required double zoom, double radiusKm = 5.0}) async {
    setState(() {
      _isSearchButtonLoading = true;
    });
    
    final url = Uri.parse('https://cartographielocal.vercel.app/map/entities?center_lat=$centerLat&center_lng=$centerLng&zoom_level=$zoom&radius_km=$radiusKm');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> companies = data['companies'] ?? [];
        final List<dynamic> jobs = data['jobs'] ?? [];
        final List<Point> points = [
          ...companies.map((e) => Point(
            id: e['id'],
            latitude: e['location'] != null ? e['location']['latitude'] : 0.0,
            longitude: e['location'] != null ? e['location']['longitude'] : 0.0,
            title: e['name'],
            description: e['description'],
            address: e['location'] != null ? e['location']['address'] : "Non renseigné",
            cp: e['location'] != null ? e['location']['cp'] : "Non renseigné",
            entity_type: e['location'] != null ? e['location']['entity_type'] : "Non renseigné",
            image_url: e['image_url'] ?? '',
          )),
          ...jobs.map((e) => Point(
            id: e['id'],
            latitude: e['location'] != null ? e['location']['latitude'] : 0.0,
            longitude: e['location'] != null ? e['location']['longitude'] : 0.0,
            title: e['title'],
            description: e['description'],
            address: e['location'] != null ? e['location']['address'] : "Non renseigné",
            cp: e['location'] != null ? e['location']['cp'] : "Non renseigné",
            entity_type: e['location'] != null ? e['location']['entity_type'] : "Non renseigné",
            image_url: e['image_url'] ?? '',
          )),
        ]
        .where((p) => p.latitude != 0.0 && p.longitude != 0.0)
        .toList();
        
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
          _isSearchButtonLoading = false;
        });
      } else {
        setState(() {
          _markers = {};
          _points = [];
          _isSearchButtonLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _markers = {};
        _points = [];
        _isSearchButtonLoading = false;
      });
    }
  }

  Future<BitmapDescriptor> _createMarkerIconWithImage(String imageUrl, {double size = 100}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final markerSize = Size(size, size);

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
      return BitmapDescriptor.defaultMarker;
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
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            color: Colors.transparent,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final modalWidth = constraints.maxWidth * 0.8;
                    return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: modalWidth,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                              ),
                              image: DecorationImage(
                                image: NetworkImage(point.image_url),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 4,
                                  bottom: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.directions_walk, size: 16, color: Color(0xFF3264E0)),
                                        const SizedBox(width: 4),
                                        Text(
                                          distance != null ? "${distance.toStringAsFixed(2)} km" : "- km",
                                          style: const TextStyle(
                                            color: Color(0xFF3264E0),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: modalWidth,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(18),
                                bottomRight: Radius.circular(18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[800]!.withValues(alpha: 0.20),
                                  blurRadius: 6,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Titre
                                  Padding(
                                    padding: const EdgeInsets.only(top: 0, bottom: 10),
                                    child: Text(
                                      point.title,
                                      style: const TextStyle(
                                        color: Color(0xFF3264E0),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  // Description
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      point.description,
                                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                                    ),
                                  ),
                                  // Adresse + icône
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Icon(Icons.location_on, size: 20, color: Color(0xFF3264E0)),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              point.address,
                                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              point.cp,
                                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 110,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF2ECC40),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.08),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: GestureDetector(
                                          onTap: () => _openMapsNavigation(point),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.directions, color: Colors.white, size: 18),
                                              SizedBox(width: 8),
                                              Text(
                                                'Itinéraire',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Container(
                                        width: 100,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF3264E0),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.08),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            if (widget.onNavigateToDetail != null) {
                                              widget.onNavigateToDetail!(point.entity_type, id: point.id);
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.info, color: Colors.white, size: 18),
                                              SizedBox(width: 8),
                                              Text(
                                                'Détails',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Croix de fermeture en haut à droite
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.close, size: 22, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ));
      },
    );
  }

  Future<void> _openLocationSettings() async {
    await LocationService.openLocationSettings();
  }

  Future<void> _openAppSettings() async {
    await LocationService.openAppSettings();
  }

  Future<void> _openMapsNavigation(Point point) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${point.latitude},${point.longitude}';
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print("Aucune application configurée pour naviguer");
      }
    } catch (e) {
      print("Aucune application configurée pour naviguer");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController!.setMapStyle(_mapStyleHidePOI);
    if (!hasCenteredOnce && _currentLocation != null) {
      _mapController!.moveCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 12.0));
      hasCenteredOnce = true;
      _loadMarkersFromApi(centerLat: _currentLocation!.latitude, centerLng: _currentLocation!.longitude, zoom: 12.0);
    }
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
      body: (_currentLocation == null || _isLoading)
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 17.0,
                  ),
                  onMapCreated: _onMapCreated,
                  onCameraMove: (position) {
                    _lastCameraPosition = position;
                  },
                  onCameraIdle: () {
                    if (_lastCameraPosition != null) {
                      _lastIdleCameraPosition = _lastCameraPosition;
                      bool shouldShow = _shouldShowSearchButton(
                        _lastCameraPosition!.target,
                        _lastCameraPosition!.zoom
                      );
                      setState(() {
                        _showSearchHereButton = shouldShow;
                      });
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  mapToolbarEnabled: false,
                  mapType: MapType.normal,
                  markers: _markers,
                ),
                if (widget.search.isNotEmpty)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 0,
                    child: Material(
                      elevation: 12,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _points
                              .where((p) => p.title.toLowerCase().contains(widget.search.toLowerCase()))
                              .map((p) => Column(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (_mapController != null) {
                                            await _mapController!.animateCamera(
                                              CameraUpdate.newLatLngZoom(
                                                LatLng(p.latitude, p.longitude),
                                                17.0,
                                              ),
                                            );
                                          }
                                          _showModernModal(p);
                                          if (widget.onClearSearch != null) widget.onClearSearch!();
                                        },
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                          child: Text(
                                            p.title,
                                            style: TextStyle(fontSize: 13),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 1,
                                        color: Color(0xFFE0E0E0),
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                if (_showSearchHereButton && widget.search.isEmpty)
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7EC8E3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          elevation: 2,
                        ),
                        onPressed: _isSearchButtonLoading ? null : () {
                          if (_lastIdleCameraPosition != null) {
                            final lat = _lastIdleCameraPosition!.target.latitude;
                            final lng = _lastIdleCameraPosition!.target.longitude;
                            final zoom = _lastIdleCameraPosition!.zoom;
                            _loadPointsOnly(
                              centerLat: lat,
                              centerLng: lng,
                              zoom: zoom,
                            );
                          }
                        },
                        child: _isSearchButtonLoading 
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Recherche...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            )
                          : Text('Rechercher ici', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
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
                          if (_currentLocation != null) {
                            _originalLocation = _currentLocation;
                          }
                          _showSearchHereButton = false;
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
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