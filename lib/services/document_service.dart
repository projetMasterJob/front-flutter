import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentService {
  final String baseUrl;
  DocumentService({String? baseUrl})
      : baseUrl = baseUrl ?? 'https://document-service-one.vercel.app';
  
  Future<String?> _getAuthToken() async {
    print('🔐 Flutter: Getting auth token...');
    final prefs = await SharedPreferences.getInstance();
    // Essaie d'abord access_token, puis token
    final token = prefs.getString('access_token') ?? prefs.getString('token');
    print('🔐 Flutter: Token found: ${token != null ? 'YES' : 'NO'}');
    print('🔐 Flutter: Token length: ${token?.length ?? 0}');
    print('🔐 Flutter: Token preview: ${token != null ? '${token.substring(0, token.length > 20 ? 20 : token.length)}...' : 'NULL'}');
    return token;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    print('🔐 Flutter: Building auth headers...');
    final token = await _getAuthToken();
    if (token == null) {
      print('❌ Flutter: NO TOKEN FOUND!');
      throw Exception('No authentication token found');
    }
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    print('🔐 Flutter: Headers built: ${headers.keys.toList()}');
    return headers;
  }

  Future<Map<String, String>> _getMultipartHeaders() async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> getUserDocuments(String userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/documents/user/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = (body['data'] ?? []) as List<dynamic>;
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } else {
        throw Exception('Failed to load documents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading documents: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserCV(String userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/documents/cv/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> data = Map<String, dynamic>.from(body['data'] as Map);
        return data;
      } else if (response.statusCode == 404) {
        return null; // No CV found
      } else {
        throw Exception('Failed to load CV: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading CV: $e');
    }
  }

  Future<Map<String, dynamic>> uploadDocument({
    required File file,
    required String title,
    required String userId,
    String type = 'cv',
  }) async {
    try {
      final headers = await _getMultipartHeaders();
      
      // Debug: afficher les informations du fichier
      print('Uploading file: ${file.path}');
      print('File size: ${await file.length()} bytes');
      print('File extension: ${file.path.split('.').last}');
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/documents/upload'),
      );

      request.headers.addAll(headers);
      request.fields['title'] = title;
      request.fields['userId'] = userId;
      request.fields['type'] = type;
      
      // Utiliser le nom de fichier original et spécifier le type MIME
      final fileName = file.path.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', 
          file.path,
          filename: fileName,
          contentType: MediaType('application', 'pdf'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 413) {
        throw Exception('FILE_TOO_LARGE_413');
      } else {
        print('Upload failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Upload failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Error uploading document: $e');
    }
  }

  Future<String> getDocumentDownloadUrl(String documentId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/documents/$documentId/download'),
        headers: headers,
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
        print('Download response data: $body');
        final String url = (body['data'] as Map)['url'] as String;
        print('Extracted URL: $url');
        return url;
      } else {
        print('Download URL request failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to get download URL: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Timeout while getting download URL');
    } catch (e) {
      print('getDownloadUrl error: $e');
      throw Exception('Error getting download URL: $e');
    }
  }

  Future<String> getCvDownloadUrl(String userId) async {
    try {
      print('🚀 Flutter: Starting getCvDownloadUrl for userId: $userId');
      
      final headers = await _getAuthHeaders();
      final url = '$baseUrl/api/documents/cv/$userId/download';
      
      print('🔍 Flutter: Base URL: $baseUrl');
      print('🔍 Flutter: Full URL: $url');
      print('🔍 Flutter: Headers: $headers');
      print('🔍 Flutter: Token length: ${headers['Authorization']?.length ?? 0}');
      
      print('⏱️ Flutter: Starting HTTP request...');
      final stopwatch = Stopwatch()..start();
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 60)); // Augmenté à 60 secondes

      stopwatch.stop();
      print('⏱️ Flutter: Request completed in ${stopwatch.elapsedMilliseconds}ms');
      print('🔍 Flutter: Response status: ${response.statusCode}');
      print('🔍 Flutter: Response headers: ${response.headers}');
      print('🔍 Flutter: Response body length: ${response.body.length}');
      print('🔍 Flutter: Response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        print('✅ Flutter: Parsing response body...');
        final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
        print('🔍 Flutter: Parsed body keys: ${body.keys.toList()}');
        
        if (body.containsKey('data')) {
          final data = body['data'] as Map<String, dynamic>;
          print('🔍 Flutter: Data keys: ${data.keys.toList()}');
          
          if (data.containsKey('url')) {
            final String downloadUrl = data['url'] as String;
            print('✅ Flutter: Successfully extracted download URL');
            print('🔍 Flutter: Download URL length: ${downloadUrl.length}');
            print('🔍 Flutter: Download URL preview: ${downloadUrl.substring(0, downloadUrl.length > 100 ? 100 : downloadUrl.length)}...');
            return downloadUrl;
          } else {
            print('❌ Flutter: No URL found in data');
            throw Exception('No URL found in response data');
          }
        } else {
          print('❌ Flutter: No data field in response');
          throw Exception('No data field in response');
        }
      } else {
        print('❌ Flutter: HTTP error status: ${response.statusCode}');
        print('❌ Flutter: Error response body: ${response.body}');
        throw Exception('Failed to get CV download URL: ${response.statusCode}');
      }
    } on TimeoutException {
      print('⏰ Flutter: TIMEOUT EXCEPTION - Request took longer than 60 seconds');
      print('❌ Flutter: Timeout while getting CV download URL');
      throw Exception('Timeout while getting CV download URL');
    } catch (e) {
      print('💥 Flutter: EXCEPTION caught: $e');
      print('💥 Flutter: Exception type: ${e.runtimeType}');
      print('💥 Flutter: Exception stack trace: ${StackTrace.current}');
      throw Exception('Error getting CV download URL: $e');
    }
  }

  Future<void> deleteDocument(String documentId, String userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/documents/$documentId?userId=$userId'),
        headers: headers,
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Timeout while deleting document');
    } catch (e) {
      throw Exception('Error deleting document: $e');
    }
  }

  Future<void> deleteUserCv(String userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/documents/user/$userId/all'),
        headers: headers,
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception('Delete CV failed: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Timeout while deleting CV');
    } catch (e) {
      throw Exception('Error deleting CV: $e');
    }
  }
}
