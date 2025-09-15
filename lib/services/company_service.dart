// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/company_dashboard_data.dart';
import '../models/company.dart';
import '../models/job.dart';
import '../models/application.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class CompanyService {
  CompanyService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  final String _baseUrl = 'https://gestion-service.vercel.app/api';
  final String _chatUrl = 'https://chat-service-six-red.vercel.app/api';

  // --- Helpers
  Future<(String token, String userId)> _auth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) throw ApiException('Aucun token. Connectez-vous.');
    var userId = prefs.getString('user_id');
    if (userId == null || userId.isEmpty) {
      final payload = JwtDecoder.decode(token);
      userId = (payload['sub'] ?? payload['id'] ?? payload['userId']).toString();
      await prefs.setString('user_id', userId);
    }
    return (token, userId);
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // --- Endpoints unitaires
  Future<Company> fetchCompanyInfo() async {
    final (token, userId) = await _auth();

    // Variante A (recommandée côté backend) : votre API lit l’ID via le token
    //final uri = Uri.parse('$_baseUrl/companies/me');

    // Variante B (si besoin du userId en query) :
    final uri = Uri.parse('$_baseUrl/companies/$userId');

    final r = await _client.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 12));
    if (r.statusCode != 200) throw ApiException('Company: erreur ${r.statusCode}');
    return Company.fromJson(json.decode(r.body) as Map<String, dynamic>);
  }

  Future<List<Job>> fetchCompanyJobs({int page = 1, int limit = 10}) async {
    final (token, userId) = await _auth();
    
    //final uri = Uri.parse('$_baseUrl/companies/me/jobs?page=$page&limit=$limit');
    final uri = Uri.parse('$_baseUrl/companies/$userId/jobs');

    final r = await _client.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 12));
    if (r.statusCode != 200) throw ApiException('Jobs: erreur ${r.statusCode}');
    final list = json.decode(r.body) as List;
    return list.map((e) => Job.fromJson(e)).toList();
  }

  Future<List<Application>> fetchCompanyApplications({int page = 1, int limit = 10}) async {
    final (token, userId) = await _auth();
    //final uri = Uri.parse('$_baseUrl/companies/me/applications?page=$page&limit=$limit');
    final uri = Uri.parse('$_baseUrl/companies/$userId/applications');

    final r = await _client.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 12));
    if (r.statusCode != 200) throw ApiException('Applications: erreur ${r.statusCode}');
    final list = json.decode(r.body) as List;
    return list.map((e) => Application.fromJson(e)).toList();
  }

  // --- Agrégateur pour ton écran
  Future<CompanyDashboardData> fetchDashboardForCurrentUser() async {
    try {
      final results = await Future.wait([
        fetchCompanyInfo(),
        fetchCompanyJobs(page: 1, limit: 10),
      ]);
      return CompanyDashboardData(
        company: results[0] as Company,
        jobs: results[1] as List<Job>,
      );
    } catch (e) {
      print('❌ Error in fetchDashboardForCurrentUser: $e');
      throw ApiException('Erreur lors du chargement du tableau de bord: $e');
    }
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status, // "accepted" ou "rejected"
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) throw Exception('Aucun token');

    assert(status == 'accepted' || status == 'rejected',
        'status doit être "accepted" ou "rejected"');

    //final (token, _) = await _auth();
    final uri = Uri.parse('$_baseUrl/companies/application/$applicationId');

    final r = await _client
        .put(
          uri,
          headers: _headers(token),
          body: json.encode({'status': status}),
        )
        .timeout(const Duration(seconds: 12));

    if (r.statusCode >= 200 && r.statusCode < 300) {
      return; // ✅ Succès (200/204)
    }
    throw ApiException('Erreur ${r.statusCode} — ${r.body}');
  }

  Future<void> createJob({
    required String companyId,
    required String title,
    required String description,
    required String salary,
    required String jobType,
    required String address,
    required String postalCode,
    double? latitude,
    double? longitude,
    String? imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) throw Exception('Aucun token');

    final uri = Uri.parse('$_baseUrl/companies/job');

    final body = {
      'title': title,
      'description': description,
      'salary': salary,
      'job_type': jobType,
      'company_id': companyId,
      'address': address,
      'postal_code': postalCode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
    };

    final r = await _client.post(
      uri,
      headers: _headers(token),
      body: json.encode(body),
    ).timeout(const Duration(seconds: 12));

    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw ApiException('Création échouée (${r.statusCode}) — ${r.body}');
    }
  }

  Future<String> createOrGetConversation({
    required String candidateUserId, // user_id du candidat (UUID)
    required String companyId,       // company_id (UUID)
  }) async {
    // Choisis l’URL qui correspond à ton back:
    // ex. POST /conversations   OU   POST /companies/:companyId/conversations
    final uri = Uri.parse('$_chatUrl/chat/list');

    final body = json.encode({
      'user_id': candidateUserId,
      'company_id'  : companyId,
    });

    final r = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    ).timeout(const Duration(seconds: 12));

    if (r.statusCode >= 200 && r.statusCode < 300) {
      // Le back peut renvoyer { chat_id } ou { id }.
      final Map<String, dynamic> data = json.decode(r.body);
      final chatId = (data['id'])?.toString();
      if (chatId != null && chatId.isNotEmpty) return chatId;

      // Certains back renvoient { error, chat_id } si déjà existant
      final existing = data['error'] != null ? data['chat_id']?.toString() : null;
      if (existing != null && existing.isNotEmpty) return existing;

      throw ApiException('Réponse inattendue: ${r.body}');
    }
    if (r.statusCode == 401) throw ApiException('Non autorisé (401).');
    throw ApiException('Erreur serveur (${r.statusCode}) — ${r.body}');
  }

  Future<String> currentUserId() async {
    final (_, userId) = await _auth();
    return userId;
  }

  // Récupère l'URL du CV d'une candidature
  Future<String?> getCvUrl({required String applicationId}) async {
    final (token, _) = await _auth();
    final uri = Uri.parse('$_baseUrl/applications/$applicationId/cv');

    final r = await _client
        .get(uri, headers: _headers(token))
        .timeout(const Duration(seconds: 12));

    if (r.statusCode == 404) return null; // pas de CV
    if (r.statusCode != 200) {
      throw ApiException('CV: erreur ${r.statusCode}');
    }

    final body = json.decode(r.body) as Map<String, dynamic>;
    final url = (body['url'] ?? body['cv_url'] ?? body['cvUrl'] ?? '').toString();
    return url.isEmpty ? null : url;
  }


  Future<Map<String, String>?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      print('🌍 Reverse geocoding pour: lat=$lat, lng=$lng');
      
      
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyCzRQdPz89Iz323Y9c9-HQWV_fjtDMSDjY&language=fr'
      );

      print('🔗 URL de reverse geocoding: $uri');
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      
      print('📡 Réponse reverse geocoding: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📋 Données reçues: $data');
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final address = result['formatted_address'];
          final components = result['address_components'] as List;
          
          String? postalCode;
          for (var component in components) {
            if (component['types'].contains('postal_code')) {
              postalCode = component['long_name'];
              break;
            }
          }
          
        final resultData = <String, String>{
          'address': address,
          'postal_code': postalCode ?? '',
        };
          
          print('✅ Reverse geocoding réussi: $resultData');
          return resultData;
        } else {
          print('❌ Aucun résultat trouvé dans la réponse');
        }
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      print('❌ Exception dans reverse geocoding: $e');
      throw ApiException('Erreur lors de la récupération de l\'adresse: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAddressSuggestions(String query) async {
    try {
      if (query.length < 3) return [];
      
      print('🔍 Autocomplétion pour: "$query"');
      
      
      final encodedQuery = Uri.encodeComponent('$query France');
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$encodedQuery&key=AIzaSyCzRQdPz89Iz323Y9c9-HQWV_fjtDMSDjY&types=address&components=country:fr'
      );

      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['predictions'] != null) {
          final List<Map<String, dynamic>> suggestions = [];
          
          for (var prediction in data['predictions']) {
            final placeId = prediction['place_id'];
            final description = prediction['description'];
            
            final details = await _getPlaceDetails(placeId);
            if (details != null) {
              suggestions.add({
                'address': description,
                'postal_code': details['postal_code'],
                'latitude': details['latitude'],
                'longitude': details['longitude'],
              });
            }
          }
          return suggestions;
        }
      }
      return [];
    } catch (e) {
      throw ApiException('Erreur lors de l\'autocomplétion: $e');
    }
  }

  Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyCzRQdPz89Iz323Y9c9-HQWV_fjtDMSDjY&fields=address_components,geometry'
      );

      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['result'] != null) {
          final result = data['result'];
          final components = result['address_components'] as List;
          final geometry = result['geometry']['location'];
          
          String? postalCode;
          for (var component in components) {
            if (component['types'].contains('postal_code')) {
              postalCode = component['long_name'];
              break;
            }
          }
          
          return {
            'postal_code': postalCode ?? '',
            'latitude': geometry['lat'].toDouble(),
            'longitude': geometry['lng'].toDouble(),
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }


  Future<void> deleteJob(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) throw Exception('Aucun token');

    final uri = Uri.parse('$_baseUrl/companies/job/$jobId');
    final r = await _client.delete(uri, headers: _headers(token)).timeout(const Duration(seconds: 12));

    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw ApiException('Suppression échouée (${r.statusCode}) — ${r.body}');
    }
  }

  void dispose() => _client.close();
}