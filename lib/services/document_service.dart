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
        final List<dynamic> documents = json.decode(response.body);
        return documents.cast<Map<String, dynamic>>();
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
        Uri.parse('$baseUrl/api/documents/user/$userId/cv'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
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

  Future<String> getDownloadUrl(String documentId, String userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/documents/$documentId/download?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Download response data: $data');
        final url = data['url'];
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
}
