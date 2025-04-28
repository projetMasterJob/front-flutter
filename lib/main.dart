import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

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
  LatLng _currentLocation =
      LatLng(43.7102, 7.2620); // Coordonnées de Nice par défaut

  // Coordonnées pour les deux points supplémentaires à Nice
  LatLng point1 =
      LatLng(43.7075, 7.2619); // Point 1 - Parc de la Colline du Château
  LatLng point2 = LatLng(43.7333, 7.4167); // Point 2 - Promenade des Anglais

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  // Méthode pour récupérer la position actuelle de l'utilisateur
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si les services de localisation ne sont pas activés, retourner
      return;
    }

    // Vérifier les permissions de localisation
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Si les permissions sont refusées, retourner
        return;
      }
    }

    // Obtenir la position actuelle de l'utilisateur
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    // Centrer la carte sur la position de l'utilisateur
    _mapController.move(_currentLocation, 15.0);
  }

  // Calculer la distance entre deux points en mètres
  double _calculateDistance(LatLng start, LatLng end) {
    final distanceInMeters = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
    return distanceInMeters / 1000; // Conversion en kilomètres
  }

  // Afficher le popup avec le texte de distance et le numéro du marqueur
  void _showMarkerPopup(BuildContext context, int markerNumber, LatLng point) {
    double distance = _calculateDistance(_currentLocation, point);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          title: Text("Marqueur N°$markerNumber", textAlign: TextAlign.center),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Distance depuis votre position : ${distance.toStringAsFixed(2)} Km',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carte centrée sur la position actuelle'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _currentLocation, // Initialisation avec la position actuelle
          zoom: 13.0,
          onTap: (_, __) {
            // Ferme le popup lorsqu'on tape n'importe où sur la carte
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              // Marqueur pour la position actuelle de l'utilisateur
              Marker(
                point: _currentLocation,
                builder: (ctx) => GestureDetector(
                  onTap: () =>
                      _showLocationPopup(context), // On tap, show the popup
                  child: Icon(Icons.location_on, color: Colors.red),
                ),
              ),
              // Marqueur pour le premier point avec distance
              Marker(
                point: point1,
                builder: (ctx) => GestureDetector(
                  onTap: () => _showMarkerPopup(context, 1, point1),
                  child: Icon(Icons.location_on, color: Colors.blue),
                ),
              ),
              // Marqueur pour le second point avec distance
              Marker(
                point: point2,
                builder: (ctx) => GestureDetector(
                  onTap: () => _showMarkerPopup(context, 2, point2),
                  child: Icon(Icons.location_on, color: Colors.green),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Afficher le popup avec le message "Vous êtes ici"
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
              'Vous êtes actuellement ici à ${_currentLocation.latitude.toStringAsFixed(4)}, ${_currentLocation.longitude.toStringAsFixed(4)}.',
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
}
