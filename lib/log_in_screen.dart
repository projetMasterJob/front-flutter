import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:front_flutter/sign_in_screen.dart';
import 'package:front_flutter/dashboard_pro.dart';
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? loginError;

  Future<void> loginUser(String email, String password) async {
    setState(() { 
      _isLoading = true;
      loginError = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://auth-service-kohl.vercel.app/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['accessToken'];

        if (accessToken != null) {
          try {
            final decodedToken = JwtDecoder.decode(accessToken);
            print(decodedToken);
            await _saveUserData(accessToken, decodedToken);
            await getUserLoginInfos(decodedToken['id'].toString());

            final role = decodedToken['role']?.toString().toLowerCase();

            if(role == "pro")
            {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CompanyDashboardPage()),
              );
            }
            else
            {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TemplatePage(selectedIndex: 0)),
              );
            }
          } catch (e) {
            setState(() {
              loginError = "Une erreur est survenue lors de la connexion, veuillez réessayer.";
            });
          }
        } else {
          setState(() {
            loginError = "Réponse invalide du serveur";
          });
        }
      } else {
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

  Future<void> _saveUserData(String accessToken, Map<String, dynamic> decodedToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('access_token', accessToken);
      await prefs.setString('token', accessToken);
      
      final userId = decodedToken['id'].toString();
      await prefs.setString('user_id', userId);

    } catch (e) {
      throw e;
    }
  }

  Future<void> getUserLoginInfos(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      final response = await http.get(
        Uri.parse('https://gestion-service.vercel.app/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userinfo', jsonEncode(userData));
        
      } else {
        throw Exception('Erreur lors de la récupération des informations utilisateur');
      }
    } catch (e) {
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
                    height: 200,
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
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe *',
                        hintText: 'votre mot de passe',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
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