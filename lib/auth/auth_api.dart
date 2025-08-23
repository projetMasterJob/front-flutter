import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_store.dart';

class AuthApi {
  final String baseUrl; // ex: https://auth-service-kohl.vercel.app/api/auth
  const AuthApi({required this.baseUrl});

  Future<TokenPair> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw Exception('BAD_CREDENTIALS');
    }
    return TokenPair.fromJson(jsonDecode(res.body));
  }

  Future<TokenPair> refresh(String refreshToken) async {
    final res = await http.post(
      Uri.parse('$baseUrl/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}), // adapte si ton back attend "token"
    );

    if (res.statusCode == 200) {
      return TokenPair.fromJson(jsonDecode(res.body));
    }
    // essaie de remonter un code d’erreur s’il existe
    try {
      final body = jsonDecode(res.body);
      throw AuthApiException(body['code']?.toString() ?? 'REFRESH_FAILED');
    } catch (_) {
      throw AuthApiException('REFRESH_FAILED');
    }
  }
}

class AuthApiException implements Exception {
  final String code;
  AuthApiException(this.code);
}
