import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  // Controllers pour gérer les champs utilisateur
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Controllers pour gérer les champs de texte de l'entreprise
  final companyNameController = TextEditingController();
  final companyDescController = TextEditingController();
  final companyWebsiteController = TextEditingController();

  bool isCompany = false;
  String? loginError;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    adresseController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    companyNameController.dispose();
    companyDescController.dispose();
    companyWebsiteController.dispose();
    super.dispose();
  }

  Future<void> registerUser(
    String firstName, 
    String lastName, 
    String address, 
    String phone, 
    String userType, 
    String email, 
    String password, {
    String? companyName,
    String? companyDescription,
    String? companyWebsite,
    String? companyLogoPath
  }) async {
    setState(() {
      loginError = null;
    });

    final Map<String, dynamic> payload = {
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'address': address.trim(),
      'phone': phone.trim(),
      'role': isCompany ? 'pro' : 'user',
    };

    // Si entreprise, on ajoute l'objet company
    if (isCompany) {
      payload['company'] = {
        'name': companyNameController.text.trim(),
        'description': companyDescController.text.trim(),
        'website': companyWebsiteController.text.trim(),
      };
    }

    try {
      final response = await http.post(
        Uri.parse('https://auth-service-kohl.vercel.app/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
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
                    height: 200,
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
                      if(isCompany) ...[
                        SizedBox(height: 15),
                        _buildCompanySection(),
                      ],
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
                      // Nouveaux paramètres (à ajouter dans la signature de registerUser)
                      companyName: isCompany ? companyNameController.text.trim() : null,
                      companyDescription: isCompany ? companyDescController.text.trim() : null,
                      companyWebsite: isCompany ? companyWebsiteController.text.trim() : null,
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
          ],
        ),
      ),
    );
  }

  // Section entreprise
  Widget _buildCompanySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Divider(),
        const SizedBox(height: 10),
        const Text(
          "Informations entreprise",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),

        // Nom de l’entreprise
        TextFormField(
          controller: companyNameController,
          decoration: const InputDecoration(
            labelText: 'Nom de l’entreprise *',
            hintText: 'ex: Acme SAS',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (!isCompany) return null;
            if (value == null || value.trim().isEmpty) {
              return "Veuillez entrer le nom de l’entreprise";
            }
            return null;
          },
        ),
        const SizedBox(height: 15),

        // Description
        TextFormField(
          controller: companyDescController,
          decoration: const InputDecoration(
            labelText: 'Description *',
            hintText: 'Décrivez brièvement votre activité',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (!isCompany) return null;
            if (value == null || value.trim().isEmpty) {
              return "Veuillez entrer une description";
            }
            return null;
          },
        ),
        const SizedBox(height: 15),

        // Site web
        TextFormField(
          controller: companyWebsiteController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Site web (URL) *',
            hintText: 'https://exemple.com',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (!isCompany) return null;
            if (value == null || value.trim().isEmpty) {
              return "Veuillez entrer l’URL du site";
            }
            final urlReg = RegExp(r'^(https?:\/\/)?([^\s.]+\.[^\s]{2,}|localhost)(\/\S*)?$');
            if (!urlReg.hasMatch(value.trim())) {
              return "URL invalide (ex: https://exemple.com)";
            }
            return null;
          },
        ),        
      ],
    );
  }

}