// applications_list_page.dart
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'services/company_service.dart';
import 'models/application.dart';

import 'chat_detail.dart';

class ApplicationListPage extends StatefulWidget {
  const ApplicationListPage({super.key, required this.companyId});
  final String companyId;

  @override
  State<ApplicationListPage> createState() => _ApplicationListPageState();
}

class _ApplicationListPageState extends State<ApplicationListPage> {
  final _service = CompanyService();
  final _controller = ScrollController();
  String? _companyUserId;

  final _items = <Application>[];
  final _processing = <String>{};
  int _page = 1;
  final int _limit = 20;
  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFirst();
    _controller.addListener(_onScroll);
    _loadCompanyUserId();
  }

  @override
  void dispose() {
    _controller.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadFirst() async {
    setState(() {
      _initialLoading = true;
      _error = null;
      _page = 1;
      _hasMore = true;
      _items.clear();
    });
    try {
      final pageItems = await _service.fetchCompanyApplications(page: _page, limit: _limit);
      setState(() {
        _items.addAll(pageItems);
        _hasMore = pageItems.length == _limit;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _initialLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final next = _page + 1;
      final pageItems = await _service.fetchCompanyApplications(page: next, limit: _limit);
      setState(() {
        _page = next;
        _items.addAll(pageItems);
        _hasMore = pageItems.length == _limit;
      });
    } catch (_) {} finally {
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _changeStatus(Application a, String newStatus) async {
    if (_processing.contains(a.id)) return;
    setState(() => _processing.add(a.id));

    final idx = _items.indexWhere((x) => x.id == a.id);
    final old = a.status;
    if (idx != -1) setState(() => _items[idx] = a.copyWith(status: newStatus));

    try {
      await _service.updateApplicationStatus(applicationId: a.id, status: newStatus);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Candidature ${newStatus == 'accepted' ? 'acceptée' : 'refusée'}')),
      );
    } catch (e) {
      // ❌ Rollback seulement si le PUT a échoué
      if (idx != -1) setState(() => _items[idx] = _items[idx].copyWith(status: old));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _processing.remove(a.id));
    }
  }

  Future<void> _loadCompanyUserId() async {
    try {
      final uid = await _service.currentUserId();
      if (mounted) setState(() => _companyUserId = uid);
    } catch (e) {
      // Option : afficher un message, mais on pourra aussi re-tenter au clic
      debugPrint('companyUserId load error: $e');
    }
  }

  void _onScroll() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
      case 'à étudier':
      case 'a etudier':
        return Colors.amber;
      case 'accepted':
      case 'acceptée':
      case 'acceptee':
        return Colors.green;
      case 'rejected':
      case 'refusée':
      case 'refusee':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool _isProcessing(Application a) => _processing.contains(a.id);

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Candidatures reçues')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadFirst,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Candidatures reçues')),
      body: RefreshIndicator(
        onRefresh: _loadFirst,
        child: ListView.separated(
          controller: _controller,
          padding: const EdgeInsets.all(12),
          itemCount: _items.length + (_loadingMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index >= _items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final a = _items[index];

            final name = a is Application ? a.fullName : '';
            final email = a.email;
            final phone = a.phone;
            final when = timeago.format(a.appliedAt.toLocal(), locale: 'fr_short');
            final statusLabel = a.statusLabel;
            final color = _statusColor(statusLabel);

            // Champs optionnels que tu ajouteras côté API/modèle :
            final jobTitle = (a as dynamic)?.jobTitle as String?;   // peut être null pour l’instant
            final cvUrl    = (a as dynamic)?.cvUrl as String?;      // idem

            return _ApplicationCard(
              key: ValueKey<String>(a.id),
              name: name,
              email: email,
              phone: phone,
              when: when,
              statusLabel: statusLabel,
              statusColor: color,
              jobTitle: jobTitle ?? 'Intitulé du poste',
              description: a.description ?? '',
              onTapCv: () {
                // TODO: télécharge/ou ouvre le CV (brancher ton action)
                if ((a.cvUrl).isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CV non disponible')));
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Télécharger le CV (à brancher)')));
              },
              onAccept: _isProcessing(a) || a.status.toLowerCase() == 'accepted'
                  ? null
                  : () => _changeStatus(a, 'accepted'),

              onReject: _isProcessing(a) || a.status.toLowerCase() == 'rejected'
                  ? null
                  : () => _changeStatus(a, 'rejected'),
              onMessage: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  final chatId = await _service.createOrGetConversation(
                    candidateUserId: a.userId,          // depuis Application.userId
                    companyId: widget.companyId,        // passé à la page
                  );
                  if (!mounted) return;
                  Navigator.pop(context); // ferme le loader

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetail(
                        chatId: chatId,
                        userId: _companyUserId!,
                      ),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context); // ferme le loader
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Impossible d’ouvrir la conversation : $e')),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatefulWidget {
  const _ApplicationCard({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.when,
    required this.statusLabel,
    required this.statusColor,
    required this.jobTitle,
    this.description = '',       // 🆕 bio/description candidat (peut être vide)
    this.onTapCv,
    this.onAccept,
    this.onReject,
    this.onMessage,
  });

  final String name;
  final String email;
  final String phone;
  final String when;
  final String statusLabel;
  final Color statusColor;
  final String jobTitle;
  final String description;      // 🆕
  final VoidCallback? onTapCv;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onMessage;

  @override
  State<_ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<_ApplicationCard> {
  bool _descExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cvDisabled = widget.onTapCv == null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne principale (avatar + infos candidat + statut/when)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: Colors.grey[200],
                child: Text(widget.name.isNotEmpty ? widget.name.characters.first.toUpperCase() : '?'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.email_outlined, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Expanded(child: Text(widget.email, overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.phone_outlined, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(widget.phone),
                  ]),
                ]),
              ),
              const SizedBox(width: 12),
              // Statut + when (badge)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: widget.statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(widget.statusLabel, style: TextStyle(color: widget.statusColor, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 6),
                  Text(widget.when, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🆕 Description candidat (expand/collapse), AVANT les boutons
          if (widget.description.trim().isNotEmpty) ...[
            GestureDetector(
              onTap: () => setState(() => _descExpanded = !_descExpanded),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Text(
                  widget.description,
                  maxLines: _descExpanded ? null : 3,
                  overflow: _descExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () => setState(() => _descExpanded = !_descExpanded),
              child: Text(
                _descExpanded ? 'Lire moins' : 'Lire plus',
                style: const TextStyle(color: Color(0xFF1A73E8), fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Boutons d'action (CV / Accepter / Refuser)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionIconPill(
                icon: Icons.chat_bubble_outline,
                bg: const Color(0xFF1A73E8),
                fg: Colors.white,
                onTap: widget.onMessage,
                tooltip: 'Message',
              ),
              const SizedBox(width: 8),
              _ActionPillButton(
                icon: Icons.file_download_outlined,
                label: 'CV',
                bg: cvDisabled ? Colors.grey[300]! : const Color(0xFF1A73E8),
                fg: cvDisabled ? Colors.black54 : Colors.white,
                onTap: widget.onTapCv,
              ),
              const SizedBox(width: 8),
              _ActionPillButton(
                icon: Icons.check,
                label: 'Accepter',
                bg: const Color(0xFF2E7D32), // vert
                fg: Colors.white,
                onTap: widget.onAccept,
              ),
              const SizedBox(width: 8),
              _ActionPillButton(
                icon: Icons.close,
                label: 'Refuser',
                bg: const Color(0xFFC62828), // rouge
                fg: Colors.white,
                onTap: widget.onReject,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Sous-encadré "poste"
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6FAFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE3F0FF)),
            ),
            child: Row(
              children: [
                const Icon(Icons.work_outline, color: Color(0xFF1976D2)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.jobTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPillButton extends StatelessWidget {
  const _ActionPillButton({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          // si tu veux un état visuel désactivé plus marqué :
          // color: disabled ? Colors.grey[300] : bg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ActionIconPill extends StatelessWidget {
  const _ActionIconPill({
    required this.icon,
    required this.bg,
    required this.fg,
    this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 40, // pill compacte
        height: 36,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: fg),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}
