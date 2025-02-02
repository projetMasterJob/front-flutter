import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenue"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_home.png',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("Se connecter");
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
    );
    throw UnimplementedError();
  }
}