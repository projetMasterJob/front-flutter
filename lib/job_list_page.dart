// jobs_list_page.dart
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/company_service.dart';
import '../models/job.dart';

class JobsListPage extends StatefulWidget {
  const JobsListPage({super.key});
  @override
  State<JobsListPage> createState() => _JobsListPageState();
}

class _JobsListPageState extends State<JobsListPage> {
  final _service = CompanyService();
  final _controller = ScrollController();

  final _items = <Job>[];
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
      final pageItems = await _service.fetchCompanyJobs(page: _page, limit: _limit);
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
      final pageItems = await _service.fetchCompanyJobs(page: next, limit: _limit);
      setState(() {
        _page = next;
        _items.addAll(pageItems);
        _hasMore = pageItems.length == _limit;
      });
    } catch (_) {
      // silencieux
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  void _onScroll() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  String _when(String postedAt) {
    try {
      return timeago.format(DateTime.parse(postedAt).toLocal(), locale: 'fr_short');
    } catch (_) {
      return postedAt; // déjà “humain” ?
    }
  }

  String _jobTypeLabel(String t) {
    switch (t.toLowerCase()) {
      case 'full_time': return 'Temps plein';
      case 'part_time': return 'Temps partiel';
      case 'internship': return 'Intérim';
      case 'contrat': return 'Contrat';
      default: return t;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Emplois publiés')),
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
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Emplois publiés')),
      body: RefreshIndicator(
        onRefresh: _loadFirst,
        child: ListView.separated(
          controller: _controller,
          padding: const EdgeInsets.all(12),
          itemCount: _items.length + (_loadingMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index >= _items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final j = _items[index];

            final title = j.title;
            final desc  = j.description;
            final type  = _jobTypeLabel(j.jobType);
            final when  = _when(j.postedAt);
            final salary = j.salary;

            return _JobCard(
              title: title,
              description: desc,
              bottomLine: "$type • $when",
              badgeLabel: salary.isEmpty ? '—' : salary + ' €',
            );
          },
        ),
      ),
    );
  }
}

class _JobCard extends StatefulWidget {
  const _JobCard({
    required this.title,
    required this.description,
    required this.bottomLine,
    required this.badgeLabel,
    this.onEdit,
    this.onDelete,
  });

  final String title;
  final String description;
  final String bottomLine; // ex: "CDI • il y a 2 j"
  final String badgeLabel; // ex: "2200 €"
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> with TickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
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
          // Ligne principale
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.work_outline),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),

                  // Description expandable
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Text(
                        widget.description,
                        maxLines: _expanded ? null : 2,
                        overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded ? 'Lire moins' : 'Lire plus',
                      style: const TextStyle(color: Color(0xFF1A73E8), fontWeight: FontWeight.w600),
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(widget.bottomLine, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ]),
              ),
              const SizedBox(width: 12),
              // Badge salaire
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(20)),
                child: Text(widget.badgeLabel, style: const TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.w600)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Boutons action
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _PillButton(icon: Icons.edit, label: 'Modifier', bg: const Color(0xFF1A73E8), fg: Colors.white, onTap: widget.onEdit),
              const SizedBox(width: 8),
              _PillButton(icon: Icons.delete_outline, label: 'Supprimer', bg: const Color(0xFFE53935), fg: Colors.white, onTap: widget.onDelete),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
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

