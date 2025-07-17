import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class ListChat extends StatefulWidget {
  const ListChat({super.key});

  @override
  State<ListChat> createState() => _ListChatState();
}

class _ListChatState extends State<ListChat> {
  final String userId = '9d6ebe6f-8547-42ea-99f6-c65367c4c1c6';
  List<dynamic> chats = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  Future<void> fetchChats() async {
    final url =
        Uri.parse('http://10.0.2.2:3001/api/chat/$userId/listes-messages');

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
                              // TODO: Ajouter navigation vers la conversation
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
