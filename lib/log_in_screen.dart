import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:front_flutter/sign_in_screen.dart';
// import 'home_tab.dart';
import 'template.dart';
import 'dashboard_pro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isNavigatingToSignup = false;
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
            await _saveUserData(accessToken, decodedToken);
            await getUserLoginInfos(decodedToken['id'].toString());

            final role = decodedToken['role']?.toString().toLowerCase();
            if (role == 'pro') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CompanyDashboardPage()),
              );
            } else {
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
      backgroundColor: const Color.fromARGB(255, 247, 247, 247),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          './assets/images/logo.png',
                          height: 200,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Adresse mail',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
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
                            const SizedBox(height: 20),
                            const Text(
                              'Mot de passe',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe *',
                                hintText: 'votre mot de passe',
                                border: const OutlineInputBorder(),
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
                  ),
                  if (loginError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        loginError!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Bouton connexion
                  ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      if (_formKey.currentState!.validate()) {
                        loginUser(
                          emailController.text,
                          passwordController.text,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Connexion...",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          )
                        : const Text(
                            "Connexion",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Bouton inscription
                  ElevatedButton(
                    onPressed: _isNavigatingToSignup ? null : () async {
                      setState(() {
                        _isNavigatingToSignup = true;
                      });
                      
                      await Future.delayed(const Duration(milliseconds: 500));
                      
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInScreen()),
                        );
                      }
                      
                      setState(() {
                        _isNavigatingToSignup = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isNavigatingToSignup
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Inscription",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}