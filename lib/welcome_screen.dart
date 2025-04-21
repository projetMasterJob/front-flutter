import 'package:flutter/material.dart';
import 'listChat.dart';

class WelcomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenue"),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Image placée en haut
              Padding(
                padding: EdgeInsets.only(top: 50), // Ajuste la hauteur depuis le haut
                child: Center(
                  child: Image.asset(
                    'assets/images/logo_home.png',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),

              // Espacement pour éviter que l'image colle aux boutons
              SizedBox(height: 50),

              // Boutons centrés
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChatScreen()),
                          );
                        },
                        child: Text("Se connecter"),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          print("S'inscrire");
                        },
                        child: Text("S'inscrire"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bouton "Mentions légales" fixé en bas
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
    throw UnimplementedError();
  }
}