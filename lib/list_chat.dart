import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_detail.dart'; // ⬅️ adapte le chemin si besoin (ex: 'pages/chat_detail.dart')

class ListChat extends StatefulWidget {
  const ListChat({super.key});

  @override
  State<ListChat> createState() => _ListChatState();
}

class _ListChatState extends State<ListChat> {
  String? _userId;
  Future<List<Map<String, dynamic>>>? _future;

  bool _editMode = false;
  bool _busy = false;
  final Set<String> _selectedIds = {};

  // --- Bases d’URL (NE PAS MODIFIER) ---
  static const String _apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://chat-service-six-red.vercel.app', // émulateur Android
  );
  static const String _companiesBase = 'https://gestion-service.vercel.app';

  // --- Cache entreprise pour éviter des requêtes doublons ---
  final Map<String, _CompanyInfo?> _companyCache = {};
  final Map<String, Future<_CompanyInfo?>> _companyInFlight = {};

  @override
  void initState() {
    super.initState();
    _initFromPrefs();
  }

  Future<void> _initFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id') ??
        prefs.getString('userId') ??
        prefs.getString('idUser');

    setState(() {
      _userId = id;
    });

    if (id != null && id.isNotEmpty) {
      final f = _fetchChats(id); // prépare le Future
      setState(() {
        _future = f;
      }); // ← NE renvoie rien
    } else {
      final f = Future.value(const <Map<String, dynamic>>[]);
      setState(() {
        _future = f;
      }); // ← idem
    }
  }

  Future<List<Map<String, dynamic>>> _fetchChats(String userId) async {
    final uri = Uri.parse('$_apiBase/api/chat/list/$userId');
    final r = await http.get(uri);
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode} ${r.reasonPhrase}');
    }

    dynamic decoded;
    try {
      decoded = json.decode(r.body);
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }

    List<dynamic> list = const [];
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map) {
      for (final k in ['rows', 'data', 'chats', 'conversations', 'items']) {
        if (decoded[k] is List) {
          list = decoded[k] as List;
          break;
        }
      }
    }

    return list
        .whereType<Map>()
        .map<Map<String, dynamic>>(
            (e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList(growable: false);
  }

  Future<_CompanyInfo?> _getCompany(String? companyId) {
    if (companyId == null || companyId.isEmpty) return Future.value(null);
    if (_companyCache.containsKey(companyId)) {
      return Future.value(_companyCache[companyId]);
    }
    if (_companyInFlight.containsKey(companyId)) {
      return _companyInFlight[companyId]!;
    }
    final fut = _fetchCompany(companyId).then((info) {
      _companyCache[companyId] = info;
      _companyInFlight.remove(companyId);
      return info;
    }).catchError((_) {
      _companyInFlight.remove(companyId);
      return null;
    });
    _companyInFlight[companyId] = fut;
    return fut;
  }

  Future<_CompanyInfo?> _fetchCompany(String companyId) async {
    final uri = Uri.parse('$_companiesBase/api/companies/inf/$companyId');
    final r = await http.get(uri);
    if (r.statusCode != 200) return null;
    final jsonMap = json.decode(r.body);
    if (jsonMap is! Map) return null;
    return _CompanyInfo.fromMap(
        jsonMap.map((k, v) => MapEntry(k.toString(), v)));
  }

  Future<String?> _getLastMessage(String chatId) async {
    try {
      final uri = Uri.parse('$_apiBase/api/chat/$chatId');
      final r = await http.get(uri);
      if (r.statusCode != 200) return null;
      
      final List<dynamic> messages = json.decode(r.body);
      if (messages.isEmpty) return null;
      
      messages.sort((a, b) {
        final aTime = DateTime.tryParse(a['sent_at'] ?? '') ?? DateTime(1970);
        final bTime = DateTime.tryParse(b['sent_at'] ?? '') ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });
      
      return messages.first['content']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> _refresh() async {
    if ((_userId ?? '').isEmpty) return;
    final f = _fetchChats(_userId!); // prépare le Future
    setState(() {
      _future = f;
    }); // ← callback synchrone, retourne void
    await f; // si tu veux attendre la fin du chargement
  }

  void _toggleEdit() {
    setState(() {
      _editMode = !_editMode;
      if (!_editMode) _selectedIds.clear();
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la conversation ?'),
        content: Text(_selectedIds.length == 1
            ? 'Cette conversation sera supprimée définitivement.'
            : '${_selectedIds.length} conversations seront supprimées définitivement.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      for (final id in _selectedIds) {
        final uri = Uri.parse('$_apiBase/api/chat/list/$id');
        final r = await http.delete(uri);
        if (r.statusCode != 200 && r.statusCode != 404) {
          throw Exception('DELETE $id -> ${r.statusCode}');
        }
      }
      _selectedIds.clear();
      await _refresh();
      if (!mounted) return;
      setState(() {
        _busy = false;
        _editMode = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Suppression échouée: $e')),
      );
    }
  }

  PreferredSizeWidget _buildInboxBar() {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.black,
        );
    return AppBar(
      backgroundColor: const Color(0xFFF7F7F7),
      elevation: 0,
      centerTitle: true,
      leadingWidth: 96,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: _editMode
              ? IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: _selectedIds.isNotEmpty
                          ? Colors.red
                          : Colors.black26),
                  onPressed: _selectedIds.isNotEmpty ? _deleteSelected : null,
                  tooltip: 'Supprimer',
                )
              : TextButton(
                  onPressed: _toggleEdit,
                  child: const Text('Modifier',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.blue)),
                ),
        ),
      ),
      title: Text('Boîte de réception', style: titleStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF1F1F2);
    return Scaffold(
      backgroundColor: bg,
      appBar: _buildInboxBar(),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const _LoadingList();
                }
                if (snap.hasError) {
                  return _ErrorView(
                    message: 'Impossible de charger vos messages.',
                    details: '${snap.error}',
                    onRetry: _refresh,
                  );
                }
                final items = snap.data ?? const <Map<String, dynamic>>[];
                if ((_userId ?? '').isEmpty) {
                  return const _EmptyView(
                    title: 'Utilisateur non connecté',
                    subtitle: 'Aucun identifiant trouvé en local.',
                  );
                }
                if (items.isEmpty) {
                  return const _EmptyView(
                    title: 'Boîte de réception vide',
                    subtitle: 'Vos conversations apparaîtront ici.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(top: 4),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Colors.black12),
                  itemBuilder: (_, i) {
                    final m = items[i];
                    final chatId =
                        _pick(m, ['id', 'chat_id', 'id_chat', 'idChat']) ??
                            '$i';
                    final companyId =
                        _pick(m, ['company_id', 'entreprise_id', 'companyId']);
                    final lastMessage = _pick(m, [
                          'lastMessage',
                          'last_message',
                          'message',
                          'content',
                          'dernier_message'
                        ]) ??
                        'Message';
                    final updatedAt = _date(m, [
                      'updatedAt',
                      'updated_at',
                      'sent_at',
                      'created_at',
                      'date',
                      'timestamp',
                    ]);
                    final unread = _bool(m, [
                          'unread',
                          'is_unread',
                          'non_lu',
                          'hasUnread',
                          'has_unread'
                        ]) ??
                        false;

                    final selected = _selectedIds.contains(chatId);

                    return FutureBuilder<_CompanyInfo?>(
                      future: _getCompany(companyId),
                      builder: (context, compSnap) {
                        final company = compSnap.data;
                        final displayName = company?.name ??
                            _pick(m, [
                              'company_name',
                              'entreprise',
                              'companyName',
                              'name'
                            ]) ??
                            'Conversation';
                        final handle = displayName.isNotEmpty
                            ? '@${displayName.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), "")}'
                            : '';
                        final imageUrl = company?.imageUrl;

                        return FutureBuilder<String?>(
                          future: _getLastMessage(chatId),
                          builder: (context, messageSnap) {
                            final actualLastMessage = messageSnap.data ?? lastMessage;
                            return _ConversationRow(
                              title: displayName,
                              avatarUrl: imageUrl,
                              lastMessage: actualLastMessage,
                              updatedAt: updatedAt,
                              unread: unread,
                              editMode: _editMode,
                              selected: selected,
                              onPressed: () {
                                if (_editMode) {
                                  _toggleSelect(chatId);
                                  return;
                                }
                                if ((_userId ?? '').isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Utilisateur introuvable")),
                                  );
                                  return;
                                }
                                // 👉 Navigation demandée (MaterialPageRoute → ChatDetail)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetail(
                                      chatId: chatId,
                                      userId: _userId!,
                                      companyName: displayName,
                                      companyHandle: handle,
                                    ),
                                  ),
                                );
                              },
                              onChanged: (v) => _toggleSelect(chatId),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (_editMode)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, -2))
                    ],
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() => _editMode = false),
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Annuler'),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ================== UI Widgets ==================

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({
    required this.title,
    required this.avatarUrl,
    required this.lastMessage,
    required this.updatedAt,
    required this.unread,
    required this.editMode,
    required this.selected,
    required this.onPressed,
    required this.onChanged,
  });

  final String title;
  final String? avatarUrl;
  final String lastMessage;
  final DateTime? updatedAt;
  final bool unread;

  final bool editMode;
  final bool selected;
  final VoidCallback onPressed;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final txt = Theme.of(context).textTheme;
    final handle = title.isNotEmpty
        ? '@${title.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), "")}'
        : '';

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              if (editMode) ...[
                Checkbox.adaptive(value: selected, onChanged: onChanged),
                const SizedBox(width: 4),
              ],
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _Avatar(
                      imageUrl: avatarUrl,
                      fallbackLetter:
                          title.isNotEmpty ? title[0].toUpperCase() : 'C'),
                  if (unread)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: title,
                                  style: txt.titleMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (handle.isNotEmpty)
                                  const TextSpan(text: '  '),
                                if (handle.isNotEmpty)
                                  TextSpan(
                                    text: handle,
                                    style: txt.bodySmall
                                        ?.copyWith(color: Colors.black38),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_fmtTime(updatedAt),
                            style:
                                txt.bodySmall?.copyWith(color: Colors.black45)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: txt.bodyMedium?.copyWith(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl, required this.fallbackLetter});
  final String? imageUrl;
  final String fallbackLetter;

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFE6E9EF),
      child: Text(fallbackLetter,
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w600)),
    );

    if (imageUrl?.isEmpty ?? true) return avatar;

    return ClipOval(
      child: Image.network(
        imageUrl!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => avatar,
      ),
    );
  }
}

/// ================== Helpers & états ==================

String? _pick(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = m[k];
    if (v == null) continue;
    if (v is String && v.trim().isEmpty) continue;
    return v.toString();
  }
  return null;
}

bool? _bool(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = m[k];
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes' || s == 'oui') return true;
      if (s == 'false' || s == '0' || s == 'no' || s == 'non') return false;
    }
  }
  return null;
}

DateTime? _date(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = m[k];
    if (v == null) continue;
    if (v is DateTime) return v;
    if (v is int) {
      if (v > 1000000000000) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.fromMillisecondsSinceEpoch(v * 1000);
    }
    if (v is String) {
      final d = DateTime.tryParse(v);
      if (d != null) return d;
    }
  }
  return null;
}

String _fmtTime(DateTime? dt) {
  if (dt == null) return '';
  return DateFormat('HH:mm').format(dt);
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 8,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Colors.black12),
      itemBuilder: (_, __) => Container(color: Colors.white, height: 64),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final txt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mail_outline, size: 40, color: Colors.black26),
            const SizedBox(height: 12),
            Text(title, style: txt.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  style: txt.bodySmall?.copyWith(color: Colors.black54),
                  textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.details, this.onRetry});
  final String message;
  final String? details;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final txt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, style: txt.titleMedium, textAlign: TextAlign.center),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(details!,
                  style: txt.bodySmall?.copyWith(color: Colors.black54),
                  textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),
            if (onRetry != null)
              FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

/// ================== Modèle entreprise ==================

class _CompanyInfo {
  final String id;
  final String name;
  final String? imageUrl;

  const _CompanyInfo({required this.id, required this.name, this.imageUrl});

  factory _CompanyInfo.fromMap(Map<String, dynamic> m) {
    String? s(dynamic v) => v == null ? null : v.toString();
    return _CompanyInfo(
      id: s(m['id']) ?? '',
      name: s(m['name']) ?? '',
      imageUrl: s(m['image_url']),
    );
  }
}
