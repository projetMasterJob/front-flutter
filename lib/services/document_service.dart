import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentService {
  static const String baseUrl = 'https://document-service-one.vercel.app';
  
Future<String?> _getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  // Essaie d'abord access_token, puis token
  final token = prefs.getString('access_token') ?? prefs.getString('token');
  print('Token récupéré: $token'); // Debug
  return token;
}

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> _getMultipartHeaders() async {
    final token = await _getAuthToken();
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
      );

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
    } catch (e) {
      print('getDownloadUrl error: $e');
      throw Exception('Error getting download URL: $e');
    }
  }

  Future<String> getCvDownloadUrl(String userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/documents/cv/$userId/download'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
        final String url = (body['data'] as Map)['url'] as String;
        return url;
      } else {
        throw Exception('Failed to get CV download URL: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting CV download URL: $e');
    }
  }

  Future<void> deleteDocument(String documentId, String userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/documents/$documentId?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Delete failed: ${response.statusCode}');
      }
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
      );

      if (response.statusCode != 200) {
        throw Exception('Delete CV failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting CV: $e');
    }
  }
}
