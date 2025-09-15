import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'services/company_service.dart';

class NewJobPage extends StatefulWidget {
  const NewJobPage({super.key, this.companyId});
  final String? companyId;

  @override
  State<NewJobPage> createState() => _NewJobPageState();
}

class _NewJobPageState extends State<NewJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = CompanyService();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  String _jobType = 'full_time';
  String? _companyId;
  bool _saving = false;
  double? _latitude;
  double? _longitude;

  // Google Maps
  Set<Marker> _markers = {};
  LatLng _center = const LatLng(48.8566, 2.3522); // Paris par défaut
  GoogleMapController? _mapController;
  
  // Autocomplétion d'adresse
  List<Map<String, dynamic>> _addressSuggestions = [];
  bool _showSuggestions = false;
  bool _loadingSuggestions = false;
  bool _addressSelected = false; // Pour masquer les suggestions après sélection

  @override
  void initState() {
    super.initState();
    _companyId = widget.companyId;
    if (_companyId == null) _loadCompanyId();
    
    _addressCtrl.addListener(_onAddressChanged);
  }

  void _onAddressChanged() {
    // Réinitialiser le flag de sélection si l'utilisateur modifie l'adresse
    if (_addressSelected) {
      _addressSelected = false;
      _latitude = null;
      _longitude = null;
      _markers.clear();
    }
    
    if (_addressCtrl.text.length >= 3) {
      _getAddressSuggestions(_addressCtrl.text);
    } else {
      _hideSuggestions();
    }
    
    // Géocoder l'adresse tapée manuellement après un délai
    _debounceGeocode();
  }

  Timer? _debounceTimer;
  
  void _debounceGeocode() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_addressCtrl.text.length >= 10 && !_addressSelected) {
        _geocodeAddress(_addressCtrl.text);
      }
    });
  }

  Future<void> _geocodeAddress(String address) async {
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=AIzaSyCzRQdPz89Iz323Y9c9-HQWV_fjtDMSDjY&language=fr'
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final geometry = result['geometry']['location'];
          final lat = geometry['lat'].toDouble();
          final lng = geometry['lng'].toDouble();
          
          setState(() {
            _latitude = lat;
            _longitude = lng;
            _addressSelected = true;
            _showSuggestions = false;
          });
          
          // Ajouter le marqueur et centrer la carte
          _updateMapMarker(lat, lng);
          _centerMapOnLocation(lat, lng);
        }
      }
    } catch (e) {
      // Erreur silencieuse
    }
  }

  Future<void> _getAddressSuggestions(String query) async {
    setState(() {
      _loadingSuggestions = true;
    });
    
    try {
      final suggestions = await _service.getAddressSuggestions(query);
      setState(() {
        _addressSuggestions = suggestions;
        _showSuggestions = suggestions.isNotEmpty;
        _loadingSuggestions = false;
      });
    } catch (e) {
      setState(() {
        _addressSuggestions = [];
        _showSuggestions = false;
        _loadingSuggestions = false;
      });
    }
  }

  void _selectAddress(Map<String, dynamic> suggestion) {
    setState(() {
      _addressCtrl.text = suggestion['address'];
      _postalCodeCtrl.text = suggestion['postal_code'];
      _latitude = suggestion['latitude'];
      _longitude = suggestion['longitude'];
      _showSuggestions = false;
      _addressSelected = true; // Marquer comme sélectionné
    });
    
    // Mettre à jour la carte avec le nouveau marqueur et centrer
    _updateMapMarker(suggestion['latitude'], suggestion['longitude']);
    _centerMapOnLocation(suggestion['latitude'], suggestion['longitude']);
    _hideSuggestions();
  }

  void _updateMapMarker(double lat, double lng) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('job_location'),
          position: LatLng(lat, lng),
          infoWindow: const InfoWindow(title: 'Emplacement du poste'),
        ),
      );
    });
  }

  void _centerMapOnLocation(double lat, double lng) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(lat, lng)),
      );
    }
  }

  void _hideSuggestions() {
    setState(() {
      _showSuggestions = false;
      _addressSuggestions = [];
    });
  }

  Future<void> _loadCompanyId() async {
    try {
      final company = await _service.fetchCompanyInfo();
      setState(() => _companyId = company.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible de récupérer l'entreprise : $e")),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng position) async {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('job_location'),
          position: position,
          infoWindow: const InfoWindow(title: 'Emplacement du poste'),
        ),
      );
      _latitude = position.latitude;
      _longitude = position.longitude;
      _addressSelected = true; // Marquer comme sélectionné
      _showSuggestions = false; // Masquer les suggestions
    });

    // Récupérer l'adresse à partir des coordonnées
    await _getAddressFromCoordinates(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final address = await _service.getAddressFromCoordinates(lat, lng);
      
      if (address != null) {
        setState(() {
          _addressCtrl.text = address['address'] ?? '';
          _postalCodeCtrl.text = address['postal_code'] ?? '';
        });
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune adresse trouvée pour cette position')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération de l\'adresse: $e')),
      );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _salaryCtrl.dispose();
    _addressCtrl.dispose();
    _postalCodeCtrl.dispose();
    _imageUrlCtrl.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_companyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entreprise introuvable.")),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner un emplacement sur la carte.")),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _service.createJob(
        companyId: _companyId!,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        salary: _salaryCtrl.text.trim(),
        jobType: _jobType,
        address: _addressCtrl.text.trim(),
        postalCode: _postalCodeCtrl.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        imageUrl: _imageUrlCtrl.text.trim().isNotEmpty ? _imageUrlCtrl.text.trim() : null,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = _saving || _companyId == null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Nouvelle annonce'),
      ),
      body: AbsorbPointer(
        absorbing: _saving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    hintText: 'Ex: Développeur Flutter',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Titre requis' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descCtrl,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Décrivez le poste, missions, exigences…',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Description requise' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _salaryCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Salaire (€/mois brut)',
                    hintText: 'Ex: 2200',
                    suffixText: '€',
                  ),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return 'Salaire requis';
                    final n = num.tryParse(s.replaceAll(',', '.'));
                    return (n == null || n <= 0) ? 'Salaire invalide' : null;
                  },
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _jobType,
                  items: const [
                    DropdownMenuItem(value: 'full_time', child: Text('Temps plein')),
                    DropdownMenuItem(value: 'part_time', child: Text('Temps partiel')),
                    DropdownMenuItem(value: 'internship', child: Text('Intérim')),
                    DropdownMenuItem(value: 'contract', child: Text('Contrat')),
                  ],
                  onChanged: (v) => setState(() => _jobType = v ?? 'full_time'),
                  decoration: const InputDecoration(labelText: 'Type de job'),
                ),

                const SizedBox(height: 20),

                // Section carte
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Emplacement du poste',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                            if (_latitude != null && _longitude != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '✓ Sélectionné',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        height: 300,
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _center,
                            zoom: 12.0,
                          ),
                          markers: _markers,
                          onTap: _onMapTap,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          mapType: MapType.normal,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instructions :',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Cliquez sur la carte pour positionner le marqueur\n• L\'adresse sera automatiquement récupérée',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Champs d'adresse avec autocomplétion
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        hintText: 'Tapez une adresse ou cliquez sur la carte',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Adresse requise' : null,
                    ),
                    if (_loadingSuggestions && !_addressSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Recherche d\'adresses...'),
                          ],
                        ),
                      ),
                    if (_showSuggestions && _addressSuggestions.isNotEmpty && !_addressSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: _addressSuggestions.map((suggestion) {
                            return InkWell(
                              onTap: () => _selectAddress(suggestion),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200, 
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            suggestion['address'],
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            'Code postal: ${suggestion['postal_code']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _postalCodeCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Code postal (automatique)',
                    hintText: 'Récupéré automatiquement',
                    prefixIcon: Icon(Icons.local_post_office),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _imageUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL de l\'image',
                    hintText: 'Ex: https://example.com/image.jpg',
                    prefixIcon: Icon(Icons.image),
                  ),
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      final uri = Uri.tryParse(v.trim());
                      if (uri == null || (!uri.hasScheme || (!uri.scheme.startsWith('http')))) {
                        return 'Veuillez entrer une URL valide';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: disabled ? null : _submit,
                    icon: const Icon(Icons.publish_outlined),
                    label: const Text('Publier l\'annonce'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
