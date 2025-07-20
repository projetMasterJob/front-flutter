import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  // Controllers pour gérer les champs de texte
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isCompany = false;
  String? loginError;

  Future<void> registerUser(String firstName, String lastName, String address, String phone, String userType, String email, String password) async {
    setState(() {
      loginError = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://auth-service-kohl.vercel.app/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'address': address,
          'phone': phone,
          'role': userType,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Inscription réussie ! Données : $data');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Succès'),
            content: Text('Inscription réussie ! Veuillez vérifier votre email pour confirmer votre compte.'),
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
        print('Erreur lors de l\'inscription : ${response.body}');
        setState(() {
          loginError = "Erreur lors de l'inscription";
        });
      }
    } catch (e) {
      print('Erreur réseau : $e');
      setState(() {
        loginError = "Erreur de connexion au serveur";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FCF9),
      body: SafeArea(
        child: Column(
          children: [
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

            // Switch "Êtes-vous une entreprise ?"
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

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelText: 'Prénom *',
                          hintText: 'votre prénom',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez entrer votre prénom";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom de famille *',
                          hintText: 'votre nom de famille',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez entrer votre nom de famille";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: adresseController,
                        decoration: InputDecoration(
                          labelText: 'Adresse postale *',
                          hintText: 'votre adresse postale',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez entrer votre adresse postale";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Téléphone *',
                          hintText: 'votre numéro de téléphone',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez entrer votre téléphone";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
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
                      SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          hintText: 'votre mot de passe',
                          border: OutlineInputBorder(),
                        ),
                          validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez entrer votre mot de passe";
                          }
                          if (value.length < 6) {
                            return "Mot de passe trop court";
                          }
                          // Au moins une majuscule
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return "Ajoutez au moins une majuscule";
                          }
                          // Au moins une minuscule
                          if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return "Ajoutez au moins une minuscule";
                          }
                          // Au moins un chiffre
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return "Ajoutez au moins un chiffre";
                          }
                          // Au moins un caractère spécial
                          if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                            return "Ajoutez au moins un caractère spécial";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (loginError != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  loginError!,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            // Bouton inscription
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    registerUser(
                      firstNameController.text,
                      lastNameController.text,
                      adresseController.text,
                      phoneController.text,
                      isCompany ? 'pro' : 'user',
                      emailController.text,
                      passwordController.text,
                    );
                  }
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