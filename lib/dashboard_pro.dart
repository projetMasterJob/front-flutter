import 'package:flutter/material.dart';

class CompanyDashboardPage extends StatelessWidget {
  const CompanyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Données d’exemple (à remplacer par tes données réelles)
    final companyName = "DevFactory";
    final memberSince = "20 juillet 2025";
    final tagline = "Créateur d’applications mobiles de A à Z";
    final address = "4 Chemin du rêve";
    final phone = "0622222222";
    final email = "contact@devfactory.io";
    final verified = true;

    final jobs = [
      {
        "title": "Flutter Developer",
        "location": "Lyon (Hybrid)",
        "type": "CDI",
        "date": "il y a 2 j",
        "candidats": 12
      },
      {
        "title": "Backend Node.js",
        "location": "Remote",
        "type": "Freelance",
        "date": "il y a 10 j",
        "candidats": 5
      },
    ];

    final applications = [
      {
        "name": "Alexandre O.",
        "job": "Flutter Developer",
        "date": "il y a 6 h",
        "status": "Nouveau"
      },
      {
        "name": "Sophie M.",
        "job": "Backend Node.js",
        "date": "il y a 1 j",
        "status": "À étudier"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Créer une nouvelle annonce")),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Nouvelle annonce"),
      ),
      body: SingleChildScrollView(
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
                      topLeft: Radius.circular(0), // pas d'arrondi en haut
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
                        companyName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Membre depuis le $memberSince",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        tagline,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Section Informations
                _buildInfoSection(address, phone, email),

                const SizedBox(height: 10),

                // Section Emplois publiés
                _buildJobSection(jobs),

                const SizedBox(height: 10),

                // Section Candidatures reçues
                _buildApplicationsSection(applications),

                const SizedBox(height: 20),
              ],
            ),

            // Avatar circulaire
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
                    companyName.isNotEmpty
                        ? "${companyName[0]}${companyName.split(" ").length > 1 ? companyName.split(" ").last[0] : ''}"
                        : '',
                    style: const TextStyle(
                        fontSize: 40, color: Color(0xFF2196F3), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            // Badge vérifié
            if (verified)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('Vérifié',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
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
          _infoLine("Mot de passe", "●●●●●●●●"),
        ],
      ),
    );
  }

  Widget _buildJobSection(List<Map<String, dynamic>> jobs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Emplois publiés", "Voir tout", () {
            // TODO: action voir tout
          }),
          const SizedBox(height: 12),
          if (jobs.isEmpty)
            const Text("Aucun emploi publié")
          else
            Column(
              children: jobs
                  .map((job) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.work_outline, color: Colors.blue),
                        title: Text(job["title"],
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text("${job["location"]} • ${job["type"]} • ${job["date"]}"),
                        trailing: Text("${job["candidats"]} cand.",
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildApplicationsSection(List<Map<String, dynamic>> applications) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Candidatures reçues", "Voir tout", () {
            // TODO: action voir tout
          }),
          const SizedBox(height: 12),
          if (applications.isEmpty)
            const Text("Aucune candidature")
          else
            Column(
              children: applications
                  .map((app) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: Text(app["name"][0]),
                        ),
                        title: Text(app["name"]),
                        subtitle: Text("${app["job"]} • ${app["date"]}"),
                        trailing: Text(app["status"],
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
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