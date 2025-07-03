import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeMapPage extends StatefulWidget {
  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  bool _locationPermissionGranted = false;
  bool hasCenteredOnce = false;

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
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationPermissionGranted = false);
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationPermissionGranted = false);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationPermissionGranted = false);
      return;
    }
    setState(() => _locationPermissionGranted = true);
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JobAzur', style: TextStyle(color: Color(0xFF3264E0))),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF3264E0)),
      ),
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
