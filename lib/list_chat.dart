import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_detail.dart';

class ListChat extends StatefulWidget {
  const ListChat({super.key});

  @override
  State<ListChat> createState() => _ListChatState();
}

class _ListChatState extends State<ListChat> {
  String? userId;
  List<dynamic> chats = [];
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
                            title: Text('Company ID : $companyId'),
                            subtitle: Text('Date : $createdAt'),
                            trailing: const Icon(Icons.chat_bubble_outline),
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
                    ),
    );
  }
}
