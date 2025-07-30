import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:front_flutter/sign_in_screen.dart';
import 'home_tab.dart';
import 'template.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LogInScreen extends StatefulWidget {
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  // Controllers pour gérer les champs de texte
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? loginError;

  Future<void> loginUser(String email, String password) async {
    setState(() { 
      _isLoading = true;
      loginError = null;
    });

    try {
      print('LOGIN: Début de la requête de connexion');
      final response = await http.post(
        Uri.parse('https://auth-service-kohl.vercel.app/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print('LOGIN: Réponse reçue, status code: ${response.statusCode}');
      print('LOGIN: Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        print('LOGIN: Connexion réussie, décodage des données');
        // Connexion réussie, décoder le token et les données
        final data = jsonDecode(response.body);
        final accessToken = data['accessToken'];
        print('LOGIN: Token récupéré: ${accessToken != null ? "Oui" : "Non"}');

        if (accessToken != null) {
          try {
            print('LOGIN: Décodage du JWT token');
            final decodedToken = JwtDecoder.decode(accessToken);
            print('LOGIN: Token décodé, ID utilisateur: ${decodedToken['id']}');
            
            print('LOGIN: Sauvegarde des données utilisateur');
            await _saveUserData(accessToken, decodedToken);
            print('LOGIN: Données sauvegardées avec succès');
            
            print('LOGIN: Récupération des informations utilisateur');
            await getUserLoginInfos(decodedToken['id'].toString());
            print('LOGIN: Informations utilisateur récupérées avec succès');

            print('LOGIN: Navigation vers la page d\'accueil');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TemplatePage(selectedIndex: 0)),
            );

          } catch (e) {
            print('LOGIN: Erreur dans le bloc interne: $e');
            setState(() {
              loginError = "Une erreur est survenue lors de la connexion, veuillez réessayer.";
            });
          }
        } else {
          print('LOGIN: Token null dans la réponse');
          setState(() {
            loginError = "Réponse invalide du serveur";
          });
        }
      } else {
        print('LOGIN: Échec de la connexion, status: ${response.statusCode}');
        setState(() {
          loginError = "Identifiants incorrects";
        });
      }
    } catch (e) {
      setState(() {
        loginError = "Erreur de connexion au serveur";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Méthode pour sauvegarder le token et l'ID utilisateur dans SharedPreferences
  Future<void> _saveUserData(String accessToken, Map<String, dynamic> decodedToken) async {
    try {
      print('SAVE_DATA: Récupération de SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      
      print('SAVE_DATA: Sauvegarde du token');
      await prefs.setString('access_token', accessToken);
      await prefs.setString('token', accessToken);
      
      final userId = decodedToken['id'].toString();
      print('SAVE_DATA: Sauvegarde de l\'ID utilisateur: $userId');
      await prefs.setString('user_id', userId);
      print('SAVE_DATA: Toutes les données sauvegardées avec succès');

    } catch (e) {
      print('SAVE_DATA: Erreur lors de la sauvegarde: $e');
      throw e;
    }
  }

  // Méthode pour récupérer et sauvegarder les informations utilisateur depuis jobazur-api
  Future<void> getUserLoginInfos(String userId) async {
    try {
      print('GET_USER_INFO: Récupération du token pour l\'utilisateur $userId');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      print('GET_USER_INFO: Token récupéré: ${token != null ? "Oui" : "Non"}');
      
      print('GET_USER_INFO: Envoi de la requête vers l\'API utilisateur');
      final response = await http.get(
        Uri.parse('https://gestion-service.vercel.app/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('GET_USER_INFO: Réponse reçue, status code: ${response.statusCode}');
      print('GET_USER_INFO: Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        print('GET_USER_INFO: Décodage des données utilisateur');
        final userData = jsonDecode(response.body);
        print('GET_USER_INFO: Données décodées: ${userData.toString()}');
        
        // Stocker les informations utilisateur dans SharedPreferences
        print('GET_USER_INFO: Sauvegarde des informations utilisateur');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userinfo', jsonEncode(userData));
        print('GET_USER_INFO: Informations utilisateur sauvegardées avec succès');
        
      } else {
        print('GET_USER_INFO: Erreur API, status: ${response.statusCode}');
        throw Exception('Erreur lors de la récupération des informations utilisateur');
      }
    } catch (e) {
      print('GET_USER_INFO: Exception attrapée: $e');
      throw e;
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
            SizedBox(height: 10),

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
                    SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe *',
                        hintText: 'votre mot de passe',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.visibility),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer votre mot de passe";
                        }
                        return null;
                      },
                    ),
                  ],
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
                if (_formKey.currentState!.validate()) {
                  loginUser(
                    emailController.text,
                    passwordController.text,
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
                "Connexion",
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