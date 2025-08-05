import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'chat_detail.dart';

class ListChat extends StatefulWidget {
  const ListChat({super.key});

  @override
  State<ListChat> createState() => _ListChatState();
}

class _ListChatState extends State<ListChat> {
  String? userId;
  List<dynamic> chats = [];
  Map<String, String> companyNames = {}; // Cache simple
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchChats();
  }

  Future<void> _loadUserIdAndFetchChats() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');
    if (userId != null) {
      fetchChats();
    } else {
      setState(() {
        error = 'ID utilisateur non trouvé';
        isLoading = false;
      });
    }
  }

  Future<void> fetchChats() async {
    if (userId == null) return;
    
    final url = Uri.parse(
        'https://chat-service-six-red.vercel.app/api/chat/list/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          chats = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Erreur API : ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      log('Erreur : $e');
      setState(() {
        error = 'Erreur de connexion';
        isLoading = false;
      });
    }
  }

  Future<String> _getCompanyName(String companyId) async {
    if (companyNames.containsKey(companyId)) {
      return companyNames[companyId]!;
    }

    try {
      final response = await http.get(
        Uri.parse('https://cartographielocal.vercel.app/companies/$companyId')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final name = data['name'] ?? companyId;
        companyNames[companyId] = name;
        return name;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération du nom de l\'entreprise')),
      );
    }
    
    return '';
  }

  String formatChatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yyyy - HH:mm');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des conversations'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : chats.isEmpty
                  ? const Center(child: Text('Aucune conversation trouvée.'))
                  : ListView.separated(
                      itemCount: chats.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        final companyId = chat['company_id'];
                        final createdAt = chat['created_at'];

                        return FutureBuilder<String>(
                          future: _getCompanyName(companyId),
                          builder: (context, snapshot) {
                            final companyName = snapshot.data ?? 'Chargement...';
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                title: Text(companyName, style: TextStyle(fontSize: 13, color: Colors.black)),
                                subtitle: Text(formatChatDate(createdAt), style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                                trailing: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                                onTap: () {
                                  final chatId = chat['id'];
                                  if (userId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatDetail(
                                          chatId: chatId,
                                          userId: userId!,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
