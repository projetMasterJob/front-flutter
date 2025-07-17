import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:front_flutter/sign_in_screen.dart';
import 'list_chat.dart';
import 'home_tab.dart';

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
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse(
        'https://3e75-2001-861-44c2-15b0-8507-f178-6801-b974.ngrok-free.app/api/auth/login');

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
         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeTabPage()),
        );
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
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text('OK')),
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
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('OK')),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5FCF9),
      body: SafeArea(
        child: Column(
          children: [
            // Logo
            SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    './assets/images/logo.png',
                    height: 250,
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            SizedBox(height: 10),

            // Formulaire
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Adresse mail',
                        hintText: 'votre adresse mail',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        hintText: 'votre mot de passe',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.visibility),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lien mot de passe oublié
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 30),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    print("Mot de passe oublié");
                  },
                  child: Text(
                    "Identifiants oubliés ?",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Bouton connexion
            ElevatedButton(
              onPressed: () {
                loginUser(emailController.text, passwordController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Connexion",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListChat(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Chat",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            SizedBox(height: 100),

            // Bouton inscription
            ElevatedButton(
              onPressed: () {
                print("Inscription");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Inscription",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            Spacer(),

            // Mentions légales
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
      ),
    );
  }
}
