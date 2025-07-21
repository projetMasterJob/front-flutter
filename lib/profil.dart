import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                // Bandeau bleu
                Container(
                  color: Color(0xFF0084F7),
                  height: 110,
                  width: double.infinity,
                ),
                // Section sous bandeau
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        'Jean Moreau',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Membre depuis le 1 mai 2024',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Passionné par le secteur de la restauration, je recherche un emploi stable et épanouissant.\nSérieux, motivé et doté d’un excellent relationnel, je souhaite rejoindre une équipe dynamique.\nDisponible immédiatement, je m’adapte facilement et aime relever de nouveaux défis.\nMon objectif : m’investir sur le long terme dans un établissement de qualité.",
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                            label: const Text('Mon CV', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.assignment, color: Colors.white),
                            label: const Text('Mes Candidatures', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Section Mes informations
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Mes informations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          Text('Modifier', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Adresse', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const Text('12 rue des Alpes, 06000 Nice - France', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      const Text('Téléphone', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const Text('0123456789', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      const Text('Email', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const Text('jean.dupont@email.com', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      const Text('Mot de passe', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const Text('●●●●●●●●', style: TextStyle(fontSize: 13, letterSpacing: 2,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Section Préférences
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Préférences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Image.asset(
                              'assets/images/preference.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Nouvelles offres par email', style: TextStyle(fontSize: 13)),
                          Switch(value: false, onChanged: null, activeColor: Color(0xFF0084F7)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Color(0xFFF5F5F5),
                        margin: EdgeInsets.symmetric(horizontal: 0),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Notifications push nouvelles offres', style: TextStyle(fontSize: 13)),
                          Switch(value: true, onChanged: null, activeColor: Color(0xFF0084F7)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Color(0xFFF5F5F5),
                        margin: EdgeInsets.symmetric(horizontal: 0),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Thème de l’application', style: TextStyle(fontSize: 13)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: const Text('Clair', style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Color(0xFFF5F5F5),
                        margin: EdgeInsets.symmetric(horizontal: 0),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Profil visible aux recruteurs', style: TextStyle(fontSize: 13)),
                          Switch(value: true, onChanged: null, activeColor: Color(0xFF0084)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Section Centre d'aide
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Centre d’aide',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Image.asset(
                              'assets/images/support.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          children: const [
                            Icon(Icons.mail_outline, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('Contacter le support', style: TextStyle(color: Colors.blue, fontSize: 16)),
                            ),
                            Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          children: const [
                            Icon(Icons.description_outlined, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('Condition d’utilisation', style: TextStyle(color: Colors.blue, fontSize: 16)),
                            ),
                            Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          children: const [
                            Icon(Icons.description_outlined, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('Mentions légales', style: TextStyle(color: Colors.blue, fontSize: 16)),
                            ),
                            Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE0E0E0)),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Se déconnecter', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE0E0E0)),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('Supprimer mon compte', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            // Avatar
            Positioned(
              top: 40,
              left: 32,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Color(0xFFE3F0FB),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'JM',
                    style: TextStyle(fontSize: 40, color: Color(0xFF2196F3), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            // Badge vérifié
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
                    Text('Vérifié', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 