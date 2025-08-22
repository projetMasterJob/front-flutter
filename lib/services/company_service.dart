// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  String get _baseUrl => dotenv.get('BASE_URL', fallback: 'http://192.168.1.57:5000/api');
  String get _chatUrl => dotenv.get('CHAT_URL');

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
    final results = await Future.wait([
      fetchCompanyInfo(),
      fetchCompanyJobs(page: 1, limit: 10),
      fetchCompanyApplications(page: 1, limit: 10),
    ]);
    return CompanyDashboardData(
      company: results[0] as Company,
      jobs: results[1] as List<Job>,
      applications: results[2] as List<Application>,
    );
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
    required String companyId,        // UUID
    required String title,
    required String description,
    required String salary,           // "2200" (tu peux passer Number si ton back accepte)
    required String jobType,          // 'full_time' | 'part_time' | 'interim'
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


  void dispose() => _client.close();
}