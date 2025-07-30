import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'log_in_screen.dart';
import 'edit_profile.dart';
import 'condition_utilisation.dart';
import 'mention_legale.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? userInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  // Méthode pour récupérer les informations de l'utilisateur
  Future<void> loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoJson = prefs.getString('userinfo');
      
      if (userInfoJson != null) {
        setState(() {
          userInfo = jsonDecode(userInfoJson);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Méthode pour formater la date de création du compte
  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
      ];
      return 'Membre depuis le ${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '';
    }
  }

  // Méthode pour se déconnecter avec une dialog, on supprime les SharedPreferences et on redirige vers la page de login
  Future<void> logout() async {
    try {
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Déconnexion'),
            content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Déconnecter', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (shouldLogout == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
                
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LogInScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la déconnexion : $e")),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LogInScreen()),
        (route) => false,
      );
    }
  }

  // Méthode pour supprimer le compte
  // on affiche une dialog de confirmation pour supprimer le compte
  // ensuite on supprime le compte via l'API et on supprime les SharedPreferences et on redirige vers la page de login
  Future<void> deleteAccount() async {
    try {
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Supprimer mon compte'),
            content: Text('Vos données seront définitivement perdues et vous serez redirigé vers la page de connexion. Cette action est irréversible.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('OK', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (shouldDelete == true) {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('user_id');
        
        if (userId != null) {
          final token = prefs.getString('token');
          
          final response = await http.delete(
            Uri.parse('https://gestion-service.vercel.app/api/users/$userId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (response.statusCode != 200) {
            throw Exception('Erreur lors de la suppression du compte: ${response.statusCode}');
          }
        }

        await prefs.clear();
                
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LogInScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression du compte : $e")),
      );
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } catch (e2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la suppression des données locales : $e2")),
        );
      }
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LogInScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: Color(0xFF0084F7),
                  height: 110,
                  width: double.infinity,
                ),
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
                      Text(
                        userInfo != null 
                            ? '${userInfo!['first_name']} ${userInfo!['last_name']}'
                            : '',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userInfo != null 
                            ? formatDate(userInfo!['created_at'])
                            : '',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userInfo != null && userInfo!['description'] != null
                            ? userInfo!['description']
                            : "",
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
                        children: [
                          Text('Mes informations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditProfilePage()),
                              );
                              loadUserInfo();
                            },
                            child: Text('Modifier', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Adresse', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Text(
                        userInfo != null ? userInfo!['address'] : '',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)
                      ),
                      const SizedBox(height: 10),
                      const Text('Téléphone', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Text(
                        userInfo != null ? userInfo!['phone'] : '',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)
                      ),
                      const SizedBox(height: 10),
                      const Text('Email', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Text(
                        userInfo != null ? userInfo!['email'] : '',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)
                      ),
                      const SizedBox(height: 10),
                      const Text('Mot de passe', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const Text('●●●●●●●●', style: TextStyle(fontSize: 13, letterSpacing: 2,
                              fontWeight: FontWeight.w500)),
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
                        onTap: () async {
                          final Uri uri = Uri(
                            scheme: 'mailto',
                            path: 'support@JobAzur.com',
                            queryParameters: {'subject': 'Support JobAzur'},
                          );
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Impossible d\'ouvrir le client de messagerie. Veuillez l\'ouvrir manuellement.')),
                            );
                          }
                        },
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ConditionUtilisationPage()),
                          );
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.description_outlined, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('Condition d\'utilisation', style: TextStyle(color: Colors.blue, fontSize: 16)),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MentionLegalePage()),
                          );
                        },
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
                    onTap: logout,
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
                    onTap: deleteAccount,
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
                    userInfo != null 
                        ? '${userInfo!['first_name'][0]}${userInfo!['last_name'][0]}'
                        : '',
                    style: TextStyle(fontSize: 40, color: Color(0xFF2196F3), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            if (userInfo != null && userInfo!['is_verified'] == true)
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