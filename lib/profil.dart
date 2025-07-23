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
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
      ];
      return 'Membre depuis le ${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Membre depuis le 20 juillet 2025';
    }
  }

  // Méthode pour se déconnecter
  Future<void> logout() async {
    try {
      // Afficher une boîte de dialogue de confirmation
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
        // Supprimer toutes les données des SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        print('🔍 Déconnexion effectuée - SharedPreferences supprimées');
        
        // Naviguer vers la page de login sans possibilité de retour
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LogInScreen()),
          (route) => false, // Supprime toutes les routes de la pile
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la déconnexion : $e")),
      );
      // En cas d'erreur, naviguer quand même vers la page de login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LogInScreen()),
        (route) => false,
      );
    }
  }

  // Méthode pour supprimer le compte
  Future<void> deleteAccount() async {
    try {
      // Afficher une boîte de dialogue de confirmation
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
        // Récupérer l'ID utilisateur depuis les SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('user_id');
        
        if (userId != null) {
          // Appel API pour supprimer l'utilisateur
          final response = await http.delete(
            Uri.parse('http://10.0.2.2:5000/api/users/$userId'),
            headers: {
              'Content-Type': 'application/json',
            },
          );

          print('🔍 Réponse suppression compte - Status: ${response.statusCode}');
          print('🔍 Réponse suppression compte - Body: ${response.body}');

          if (response.statusCode == 200) {
            print('🔍 Compte supprimé avec succès');
          } else {
            print('🔍 Erreur lors de la suppression du compte : ${response.statusCode}');
          }
        }

        // Supprimer toutes les données des SharedPreferences
        await prefs.clear();
        
        print('🔍 Suppression de compte effectuée - SharedPreferences supprimées');
        
        // Naviguer vers la page de login sans possibilité de retour
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LogInScreen()),
          (route) => false, // Supprime toutes les routes de la pile
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression du compte : $e")),
      );
      // En cas d'erreur, supprimer quand même les SharedPreferences et rediriger
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
                      Text(
                        userInfo != null 
                            ? '${userInfo!['first_name']} ${userInfo!['last_name']}'
                            : '',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userInfo != null 
                            ? _formatDate(userInfo!['created_at'])
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
                        children: [
                          Text('Mes informations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditProfilePage()),
                              );
                              // Recharger les données après retour de la page de modification
                              _loadUserInfo();
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
                // Section Préférences
                // Container(
                //   margin: const EdgeInsets.symmetric(horizontal: 10),
                //   padding: const EdgeInsets.all(10),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(12),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withValues(alpha: 0.1),
                //         blurRadius: 1,
                //       ),
                //     ],
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           const Text('Préférences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                //           Padding(
                //             padding: const EdgeInsets.only(right: 2),
                //             child: Image.asset(
                //               'assets/images/preference.png',
                //               width: 24,
                //               height: 24,
                //             ),
                //           ),
                //         ],
                //       ),
                //       const SizedBox(height: 14),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           const Text('Nouvelles offres par email', style: TextStyle(fontSize: 13)),
                //           Switch(value: false, onChanged: null, activeColor: Color(0xFF0084F7)),
                //         ],
                //       ),
                //       SizedBox(height: 10),
                //       Container(
                //         width: double.infinity,
                //         height: 1,
                //         color: Color(0xFFF5F5F5),
                //         margin: EdgeInsets.symmetric(horizontal: 0),
                //       ),
                //       SizedBox(height: 10),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           const Text('Notifications push nouvelles offres', style: TextStyle(fontSize: 13)),
                //           Switch(value: true, onChanged: null, activeColor: Color(0xFF0084F7)),
                //         ],
                //       ),
                //       SizedBox(height: 10),
                //       Container(
                //         width: double.infinity,
                //         height: 1,
                //         color: Color(0xFFF5F5F5),
                //         margin: EdgeInsets.symmetric(horizontal: 0),
                //       ),
                //       SizedBox(height: 10),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           const Text('Thème de l’application', style: TextStyle(fontSize: 13)),
                //           Container(
                //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                //             decoration: BoxDecoration(
                //               color: Colors.grey[200],
                //               borderRadius: BorderRadius.circular(8),
                //               border: Border.all(color: Colors.grey.shade400),
                //             ),
                //             child: const Text('Clair', style: TextStyle(fontSize: 13)),
                //           ),
                //         ],
                //       ),
                //       SizedBox(height: 10),
                //       Container(
                //         width: double.infinity,
                //         height: 1,
                //         color: Color(0xFFF5F5F5),
                //         margin: EdgeInsets.symmetric(horizontal: 0),
                //       ),
                //       SizedBox(height: 10),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           const Text('Profil visible aux recruteurs', style: TextStyle(fontSize: 13)),
                //           Switch(value: true, onChanged: null, activeColor: Color(0xFF0084)),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 10),
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
                            path: 'support@jobexplorer.com',
                            queryParameters: {'subject': 'Support JobExplorer'},
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
            // Badge vérifié
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