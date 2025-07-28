import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:front_flutter/sign_in_screen.dart';
import 'home_tab.dart';
import 'template.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  ResetPasswordScreen({required this.token});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();

  String? resetPasswordError;

  Future<void> passwordReset(String password) async {
    setState(() {
      resetPasswordError = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://auth-service-kohl.vercel.app/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'password': password
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Réinitialisation du mot de passe réussie ! Données : $data');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Succès'),
            content: Text('Votre mot de passe a été réinitialisé avec succès.'),
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
        print('Erreur lors de la réinitialisation du mot de passe : ${response.body}');
        setState(() {
          resetPasswordError = "Erreur lors de la réinitialisation du mot de passe";
        });
      }
    } catch (e) {
      print('Erreur réseau : $e');
      setState(() {
        resetPasswordError = "Erreur de connexion au serveur";
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
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        hintText: 'votre mot de passe',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer votre mot de passe";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: passwordConfirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirmer votre mot de passe',
                        hintText: 'confirmez votre mot de passe',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez confirmer votre mot de passe";
                        }
                        if (value != passwordController.text) {
                          return "Les mots de passe ne correspondent pas";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (resetPasswordError != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  resetPasswordError!,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            SizedBox(height: 50),

            // Bouton d'envoi de réinitialisation
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  passwordReset(
                    passwordController.text
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
                "Modifier le mot de passe",
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