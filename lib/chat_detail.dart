import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'detail_company.dart';
import 'detail_job.dart';

class ChatDetail extends StatefulWidget {
  final String chatId;
  final String userId;
  final String? companyName;
  final String? companyHandle;
  final String? companyId;

  const ChatDetail({
    super.key,
    required this.chatId,
    required this.userId,
    this.companyName,
    this.companyHandle,
    this.companyId,
  });

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  String? error;

  // Sélection pour suppression
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

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
        // tri ancien -> récent
        data.sort((a, b) => DateTime.parse(a['sent_at'])
            .compareTo(DateTime.parse(b['sent_at'])));
        setState(() {
          messages = data
              .map<Map<String, dynamic>>(
                  (e) => Map<String, dynamic>.from(e as Map))
              .toList();
          isLoading = false;
          error = null;
        });
        _scrollToEnd();
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

    final url = Uri.parse(
        'https://chat-service-six-red.vercel.app/api/chat/send-message');
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
        await fetchMessages();
      } else {
        log('Erreur envoi message : ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur lors de l'envoi du message.")),
          );
        }
      }
    } catch (e) {
      log('Exception envoi message : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de l'envoi du message.")),
        );
      }
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    // Ne supprimer que mes messages
    final toDelete = messages.where((m) {
      final id = m['id']?.toString();
      final sender = m['sender_id']?.toString();
      return id != null && _selectedIds.contains(id) && sender == widget.userId;
    }).toList();

    if (toDelete.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Aucun de vos messages n'est sélectionné.")),
      );
      setState(() {
        _selectionMode = false;
        _selectedIds.clear();
      });
      return;
    }

    // Suppression locale immédiate (UX)
    setState(() {
      messages.removeWhere((m) => toDelete.any((x) => x['id'] == m['id']));
      _selectionMode = false;
      _selectedIds.clear();
    });

    // Suppression distante (tâche de fond)
    for (final m in toDelete) {
      final id = m['id']?.toString();
      if (id == null) continue;
      _deleteOnServer(id).catchError((e) {
        log('Delete $id failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Suppression distante échouée pour $id")),
          );
        }
      });
    }
  }

  Future<void> _deleteOnServer(String id) async {
    final url =
        Uri.parse('https://chat-service-six-red.vercel.app/api/chat/$id');
    final res = await http.delete(url);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('HTTP ${res.statusCode}');
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent + 120);
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.companyName ?? 'Conversation';
    final handle = widget.companyHandle ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.3,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (handle.isNotEmpty)
              Text(handle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.black54)),
          ],
        ),
        actions: [
          if (_selectionMode) ...[
            TextButton(
              onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
              child: Text(
                'Supprimer${_selectedIds.isEmpty ? '' : ' (${_selectedIds.length})'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => setState(() {
                _selectionMode = false;
                _selectedIds.clear();
              }),
              child: const Text('Annuler',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ] else
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'delete') {
                  setState(() {
                    _selectionMode = true;
                    _selectedIds.clear();
                  });
                } else if (v == 'info') {
                  _navigateToCompanyDetail();
                }
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                PopupMenuItem(value: 'info', child: Text('Info')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchMessages,
                    child: ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final cur = _parseDate(msg['sent_at']);
                        final prev = index > 0
                            ? _parseDate(messages[index - 1]['sent_at'])
                            : null;
                        final showChip = prev == null ||
                            cur == null ||
                            (cur.year != prev.year ||
                                cur.month != prev.month ||
                                cur.day != prev.day);
                        return _messageRow(msg, showDateChip: showChip);
                      },
                    ),
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE6E6E9))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => sendMessage(),
                  decoration: const InputDecoration.collapsed(
                      hintText: 'Tapez un message...'),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.send_rounded),
              color: Colors.black54,
              tooltip: 'Envoyer',
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageRow(Map<String, dynamic> msg, {required bool showDateChip}) {
    final id = msg['id']?.toString() ?? '';
    final content = msg['content']?.toString() ?? '';
    final when = _parseDate(msg['sent_at']);
    final isMe = msg['sender_id']?.toString() == widget.userId;
    final selected = _selectedIds.contains(id);

    final bubbleColor =
        isMe ? const Color(0xFF1E73FF) : const Color(0xFFF2F2F7);
    final textColor = isMe ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDateChip)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4)
                  ],
                ),
                child: Text(_formatDayLabel(when),
                    style: const TextStyle(color: Colors.black54)),
              ),
            ),
          ),
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) const SizedBox(width: 8),
            GestureDetector(
              onTap: _selectionMode && isMe
                  ? () {
                      setState(() {
                        if (selected) {
                          _selectedIds.remove(id);
                        } else {
                          _selectedIds.add(id);
                        }
                      });
                    }
                  : null,
              onLongPress: isMe
                  ? () {
                      setState(() {
                        _selectionMode = true;
                        _selectedIds.add(id);
                      });
                    }
                  : null,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _selectionMode && selected
                      ? (isMe
                          ? const Color(0xFF1555CA)
                          : const Color(0xFFE6E6EB))
                      : bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe
                        ? const Radius.circular(16)
                        : const Radius.circular(4),
                    bottomRight: isMe
                        ? const Radius.circular(4)
                        : const Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Text('Moi', // libellé côté reçu si besoin
                          style: TextStyle(
                              color: textColor.withOpacity(0.8),
                              fontWeight: FontWeight.w600)),
                    if (!isMe) const SizedBox(height: 2),
                    Text(content, style: TextStyle(color: textColor)),
                    const SizedBox(height: 4),
                    Text(
                      when != null ? DateFormat('HH:mm').format(when) : '',
                      style: TextStyle(
                          color: textColor.withOpacity(0.7), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) {
      return DateTime.tryParse(v);
    }
    return null;
  }

  String _formatDayLabel(DateTime? d) {
    if (d == null) return '';
    final now = DateTime.now();
    final justDate = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);
    if (justDate == today) return "Aujourd'hui";
    return DateFormat('dd/MM/yyyy').format(d);
  }

  void _navigateToCompanyDetail() {
    if (widget.companyId != null && widget.companyId!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailCompanyPage(
            companyId: widget.companyId!,
            onNavigateToDetail: (String type, {String? id}) {
              if (type == 'job' && id != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailJobPage(
                      jobId: id,
                      onNavigateToDetail: (String type, {String? id}) {
                        // Gérer la navigation si nécessaire
                      },
                      onBack: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              }
            },
            onBack: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informations de l\'entreprise non disponibles'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }
}
