import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LogInScreen extends StatefulWidget {
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  // Controllers pour gérer les champs de texte
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> loginUser(String email, String password) async {
    setState(() { _isLoading = true; });
    final url = Uri.parse('https://3e75-2001-861-44c2-15b0-8507-f178-6801-b974.ngrok-free.app/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Connexion réussie, tu peux décoder le token ou user info ici :
        final data = jsonDecode(response.body);
        // Par exemple, sauvegarder le token, naviguer, etc.
        print('Connexion réussie ! Données : $data');
        // Navigator.pushReplacement... etc
      } else {
        // Affiche une erreur à l'utilisateur
        print('Erreur de connexion : ${response.body}');
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Erreur'),
            content: Text('Échec de la connexion. Vérifie tes identifiants.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      print('Erreur réseau : $e');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Erreur réseau'),
          content: Text('Impossible de se connecter au serveur.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
          ],
        ),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Logo en haut
              Padding(
                padding: EdgeInsets.only(top: 50), // Ajuste l'espacement
                child: Center(
                  child: Image.asset(
                    'assets/images/logo_home.png',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),

              // Espacement entre l'image et les champs
              SizedBox(height: 30),

              // Champ email
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Adresse Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Champ mot de passe
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: passwordController,
                  obscureText: true, // Cache le texte du mot de passe
                  decoration: InputDecoration(
                    labelText: 'Mot de Passe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Bouton de connexion
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {
                    // Ajouter ici la logique de connexion
                    print('Connexion avec ${emailController.text} et ${passwordController.text}');
                  },
                  child: Text('Se connecter'),
                ),
              ),
            ],
          ),

          // Bouton "Mentions légales" en bas
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              padding: EdgeInsets.symmetric(vertical: 15),
              child: TextButton(
                onPressed: () {
                  print("Mentions légales");
                },
                child: Text(
                  "Mentions légales",
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ),
          ),
          if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}