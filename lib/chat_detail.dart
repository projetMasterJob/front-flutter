import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class ChatDetail extends StatefulWidget {
  final String chatId;
  final String userId;
  final String? companyName;
  final String? companyHandle;

  const ChatDetail({
    super.key,
    required this.chatId,
    required this.userId,
    this.companyName,
    this.companyHandle,
  });

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> messages = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final url = Uri.parse(
        'https://chat-service-six-red.vercel.app/api/chat/${widget.chatId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Tri par date (ancien > récent)
        data.sort((a, b) => DateTime.parse(a['sent_at'])
            .compareTo(DateTime.parse(b['sent_at'])));

        setState(() {
          messages = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Erreur API : ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      log('Erreur API : $e');
      setState(() {
        error = 'Erreur de chargement';
        isLoading = false;
      });
    }
  }

  Future<void> sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final url = Uri.parse('https://chat-service-six-red.vercel.app/api/chat/');

    final body = {
      'chat_id': widget.chatId,
      'sender_id': widget.userId,
      'content': content,
      'sent_at': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _controller.clear();
        fetchMessages();
      } else {
        log('Erreur envoi message : ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'envoi du message.")),
        );
      }
    } catch (e) {
      log('Exception envoi message : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de l'envoi du message.")),
      );
    }
  }

  Widget _buildSentMessage(String content, String date) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(content, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text(date,
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedMessage(String content, String date) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content, style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 4),
            Text(date,
                style: const TextStyle(color: Colors.black54, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Écrire un message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.companyName ?? 'Conversation';
    final handle = widget.companyHandle ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            if (handle.isNotEmpty)
              Text(handle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error!))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final senderId = message['sender_id'];
                          final content = message['content'];
                          final sentAt = message['sent_at'];
                          final isMe = senderId == widget.userId;

                          return isMe
                              ? _buildSentMessage(content, sentAt)
                              : _buildReceivedMessage(content, sentAt);
                        },
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }
}
