import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:front_flutter/sign_in_screen.dart';
import 'home_tab.dart';
import 'template.dart';

class LostIdScreen extends StatefulWidget {
  @override
  _LostIdScreenState createState() => _LostIdScreenState();
}

class _LostIdScreenState extends State<LostIdScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  String? lostIdError;

  Future<void> requestPasswordReset(String email) async {
    setState(() {
      lostIdError = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://auth-service-kohl.vercel.app/api/auth/request-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Envoi de l\'email de réinitialisation réussi ! Données : $data');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Succès'),
            content: Text('Si une adresse mail correspond à votre compte, un mail de réinitialisation a été envoyé.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        print('Erreur lors de l\'envoi de l\'email de réinitialisation : ${response.body}');
        setState(() {
          lostIdError = "Erreur lors de l'envoi de l'email de réinitialisation";
        });
      }
    } catch (e) {
      print('Erreur réseau : $e');
      setState(() {
        lostIdError = "Erreur de connexion au serveur";
      });
    }
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 247, 247),
      body: SafeArea(
        child: Column(
          children: [
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
            SizedBox(height: 80),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Adresse mail *',
                        hintText: 'votre adresse mail',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer votre adresse mail";
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Format d'adresse mail invalide";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (lostIdError != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  lostIdError!,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            SizedBox(height: 50),

            // Bouton d'envoi de réinitialisation
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  requestPasswordReset(
                    emailController.text
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Envoyer le mail de réinitialisation",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            Spacer(),

            // Mentions légales
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
      ),
    );
  }
}