import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Controllers pour gérer les champs de texte
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isCompany = false;

  Future<void> SignInUser(String first_name, String last_name, String email, String password, String address, String phone) async {
    final url = Uri.parse('https://7f0385706372.ngrok-free.app/api/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'first_name': first_name, 
                          'last_name': last_name, 
                          'email': email, 
                          'password': password, 
                          'address': address, 
                          'phone': phone, 
                          'role': isCompany
                        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Inscription réussie ! Données : $data');
        // Navigator.pushReplacement... etc
      } else {
        // Affiche une erreur à l'utilisateur
        print('Erreur inscription : ${response.body}');
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Erreur'),
            content: Text("Échec de l'inscription. Vérifie tes identifiants."),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FCF9),
      body: SafeArea(
        child: Column(
          children: [
            // Logo
            SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 250,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Switch enreprise
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Text(
                    "Êtes-vous une entreprise ?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Switch(
                    value: isCompany,
                    onChanged: (value) {
                      setState(() {
                        isCompany = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Formulaire scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelText: 'Prénom',
                          hintText: 'votre prénom',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom de famille',
                          hintText: 'votre nom de famille',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: adresseController,
                        decoration: InputDecoration(
                          labelText: 'Adresse postale',
                          hintText: 'votre adresse postale',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Téléphone',
                          hintText: 'votre numéro de téléphone',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Adresse mail',
                          hintText: 'votre adresse mail',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          hintText: 'votre mot de passe',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bouton inscription
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  SignInUser(
                    firstNameController.text,
                    lastNameController.text,
                    emailController.text,
                    passwordController.text,
                    adresseController.text,
                    phoneController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Inscription",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
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