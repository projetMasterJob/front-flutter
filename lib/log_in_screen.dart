import 'package:flutter/material.dart';
import 'home_map.dart';

class LogInScreen extends StatefulWidget {
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  // Controllers pour gérer les champs de texte
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeMapPage()),
                    );
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
        ],
      ),
    );
  }
}