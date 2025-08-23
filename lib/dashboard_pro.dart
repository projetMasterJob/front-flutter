import 'package:flutter/material.dart';
import 'models/company_dashboard_data.dart';
import 'services/company_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;
import 'job_list_page.dart';
import 'application_list_page.dart';
import 'new_job_page.dart';

import 'auth/services.dart';
import 'auth/access_compat.dart';

class CompanyDashboardPage extends StatefulWidget {
  const CompanyDashboardPage({super.key});
  @override
  State<CompanyDashboardPage> createState() => _CompanyDashboardPageState();
}

class _CompanyDashboardPageState extends State<CompanyDashboardPage> {
  late final CompanyService _service;
  late Future<CompanyDashboardData> _future;

  @override
  void initState() {
    super.initState();
    _service = CompanyService();
    _future = _service.fetchDashboardForCurrentUser();

    Future<void> verifyTokenStorage() async {
      final accessSecure = await tokenStore.readAccess();
      final refreshSecure = await tokenStore.readRefresh();
      final accessPrefs  = await AccessCompat.get(); // option compat

      debugPrint('ACCESS (SecureStorage): ${accessSecure != null ? 'OK' : 'ABSENT'}');
      debugPrint('REFRESH (SecureStorage): ${refreshSecure != null ? 'OK' : 'ABSENT'}');
      debugPrint('ACCESS (SharedPrefs)  : ${accessPrefs != null ? 'OK' : 'ABSENT'}');

      // Facultatif : afficher un snippet (évite d'imprimer le token entier)
      if (accessSecure != null) {
        debugPrint('ACCESS snippet: ${accessSecure.substring(0, 24)}...');
      }
      if (refreshSecure != null) {
        debugPrint('REFRESH length: ${refreshSecure.length}');
      }
    }
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.fetchDashboardForCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final api = CompanyService();

    return FutureBuilder<CompanyDashboardData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // État de chargement
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
            backgroundColor: Colors.white,
          );
        }

        if (snapshot.hasError) {
          // État d'erreur + bouton réessayer
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Force un rebuild en poussant/remplaçant la route
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                CompanyDashboardPage(),
                            transitionDuration: Duration.zero,
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final c = data.company;
        final extraSpace =
          MediaQuery.of(context).padding.bottom + 56.0 + 16.0;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final created = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NewJobPage(companyId: c.id)),
              );
              if (created == true && mounted) {
                await _reload();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Annonce créée')),
                );
              }
            },
            icon: const Icon(Icons.add),
            label: const Text("Nouvelle annonce"),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: extraSpace),
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Bandeau bleu
                      Container(
                        color: const Color(0xFF0084F7),
                        height: 110,
                        width: double.infinity,
                      ),
                      // Carte infos entreprise
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 50),
                            Text(
                              c.name,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Membre depuis le ${c.createdAt}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Section Informations
                      _buildInfoSection(c.address, c.phone, c.email),

                      const SizedBox(height: 10),

                      // Section Emplois publiés
                      _buildJobSection(
                        data.jobs
                          .map((j) => {
                            "title": j.title,
                            "description": j.description,
                            "salary": j.salary,
                            "job_type": j.jobType,
                            "posted_at": j.postedAt,
                            "applications_count": j.applicationsCount,
                          })
                          .toList(),
                      ),

                      const SizedBox(height: 10),

                      // Section Candidatures reçues
                      _buildApplicationsSection(
                        data.applications
                          .map((a) => {
                            'name': a.fullName,
                            'job' : '—',
                            'date': timeago.format(a.appliedAt.toLocal(), locale: 'fr_short'),
                            'status': a.statusLabel,
                          })
                          .toList(),
                          onSeeAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ApplicationListPage(companyId: c.id), // ⬅️ pas de `const`
                              ),
                            );
                          },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),

                  // Avatar circulaire (initiales)
                  Positioned(
                    top: 40,
                    left: 32,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F0FB),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          c.name.isNotEmpty
                              ? "${c.name[0]}${c.name.split(" ").length > 1 ? c.name.split(" ").last[0] : ''}"
                              : '',
                          style: const TextStyle(
                              fontSize: 40, color: Color(0xFF2196F3), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  // Badge vérifié
                  if (c.verified)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[400],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Vérifié',
                              style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== WIDGETS PRIVÉS DANS LA MÊME CLASSE =====

  Widget _buildInfoSection(String address, String phone, String email) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Informations de l’entreprise", "Modifier", () {
            // TODO: action modifier
          }),
          const SizedBox(height: 12),
          _infoLine("Adresse", address),
          _infoLine("Téléphone", phone),
          _infoLine("Email", email),
        ],
      ),
    );
  }

  Widget _buildJobSection(List<Map<String, dynamic>> jobs) {
    String _fmtType(dynamic t) {
      final s = (t ?? '').toString().toLowerCase();
      switch (s) {
        case 'full_time': return 'Temps plein';
        case 'part_time': return 'Temps partiel';
        case 'freelance': return 'Freelance';
        case 'internship': return 'Stage';
        default: return (t ?? '—').toString();
      }
    }

    String _fmtDate(dynamic v) {
      if (v == null) return '—';
      if (v is DateTime) return timeago.format(v.toLocal(), locale: 'fr_short');
      try {
        return timeago.format(DateTime.parse(v.toString()).toLocal(), locale: 'fr_short');
      } catch (_) {
        return v.toString();
      }
    }

    String _trailing(Map<String, dynamic> job) {
      if (job.containsKey('applications_count')) return "${job['applications_count']} cand.";
      if (job['salary'] != null && job['salary'].toString().isNotEmpty) {
        return job['salary'].toString();
      }
      return '';
      }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Emplois publiés", "Voir tout", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const JobsListPage()));
          }),
          const SizedBox(height: 12),
          if (jobs.isEmpty)
            const Text("Aucun emploi publié")
          else
            Column(
              children: jobs.map((job) {
                final title = (job["title"] ?? '').toString();
                final type  = job["type"] ?? job["job_type"];
                final date  = job["date"] ?? job["posted_at"];
                final loc   = job["location"];

                final subtitleParts = <String>[];
                if (loc != null && loc.toString().isNotEmpty) subtitleParts.add(loc.toString());
                subtitleParts.add(_fmtType(type));
                subtitleParts.add(_fmtDate(date));

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.work_outline, color: Colors.blue),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(subtitleParts.join(' • ')),
                  trailing: Text(
                    _trailing(job),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildApplicationsSection(List<Map<String, dynamic>> applications, {
      required VoidCallback onSeeAll, // ⬅️ nouveau
  }) 
  {
    Color _statusColor(String s) {
      switch (s.toLowerCase()) {
        case 'à étudier':
        case 'a etudier':
        case 'pending':
          return Colors.amber;
        case 'acceptée':
        case 'acceptee':
        case 'accepted':
          return Colors.green;
        case 'refusée':
        case 'refusee':
        case 'rejected':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    String _safeStr(dynamic v, [String fallback = '—']) {
      final s = v?.toString().trim() ?? '';
      return s.isEmpty ? fallback : s;
    }

    String _initial(String name) {
      final s = name.trim();
      return s.isEmpty ? '?' : s.characters.first.toUpperCase();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Candidatures reçues", "Voir tout", onSeeAll),
          const SizedBox(height: 12),
          if (applications.isEmpty)
            const Text("Aucune candidature")
          else
            Column(
              children: applications.map((app) {
                final name   = _safeStr(app['name'], 'Inconnu');
                final job    = _safeStr(app['job']);
                final date   = _safeStr(app['date']);
                final status = _safeStr(app['status'], 'À étudier');

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: Text(_initial(name)),
                  ),
                  title: Text(name),
                  subtitle: Text("$job • $date"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(status),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }


  // ===== MÉTHODES UTILITAIRES =====

  BoxDecoration _whiteBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 1,
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        GestureDetector(
          onTap: onTap,
          child: Text(action,
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ],
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}