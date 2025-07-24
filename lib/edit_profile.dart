import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? userInfo;
  bool isLoading = true;
  bool isSaving = false;

  // Controllers pour les champs de texte
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Variables pour afficher/masquer les mots de passe
  bool showOldPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  Map<String, String> originalValues = {};
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  // Méthode pour obtenir l'instance de SharedPreferences
  Future<SharedPreferences> get _prefsInstance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> loadUserInfo() async {
    try {
      final prefs = await _prefsInstance;
      final userInfoJson = prefs.getString('userinfo');
      
      if (userInfoJson != null) {
        setState(() {
          userInfo = jsonDecode(userInfoJson);
          _populateFields();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _populateFields() {
    if (userInfo != null) {
      firstNameController.text = userInfo!['first_name'] ?? '';
      lastNameController.text = userInfo!['last_name'] ?? '';
      descriptionController.text = userInfo!['description'] ?? '';
      addressController.text = userInfo!['address'] ?? '';
      phoneController.text = userInfo!['phone'] ?? '';
      emailController.text = userInfo!['email'] ?? '';

      // Stocker les valeurs originales pour comparaison
      originalValues = {
        'first_name': userInfo!['first_name'] ?? '',
        'last_name': userInfo!['last_name'] ?? '',
        'description': userInfo!['description'] ?? '',
        'address': userInfo!['address'] ?? '',
        'phone': userInfo!['phone'] ?? '',
        'email': userInfo!['email'] ?? '',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Modifier mon profil'),
        backgroundColor: Color(0xFF0084F7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Informations personnelles
                    _buildSection(
                      'Informations personnelles',
                      [
                        _buildTextField(
                          controller: firstNameController,
                          label: 'Prénom',
                          maxLength: 50,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre prénom';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: lastNameController,
                          label: 'Nom',
                          maxLength: 50,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre nom';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: descriptionController,
                          label: 'Description',
                          maxLength: 126,
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une description';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: addressController,
                          label: 'Adresse',
                          maxLength: 50,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre adresse';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: phoneController,
                          label: 'Téléphone',
                          maxLength: 10,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre numéro de téléphone';
                            }
                            final trimmedValue = value.trim();
                            if (!RegExp(r'^[0-9]{10}$').hasMatch(trimmedValue)) {
                              return 'Veuillez entrer un numéro valide (10 chiffres)';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: emailController,
                          label: 'Email',
                          maxLength: 100,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            final trimmedValue = value.trim();
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(trimmedValue)) {
                              return 'Veuillez entrer un email valide';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Section Mot de passe
                    _buildSection(
                      'Changer le mot de passe',
                      [
                        _buildPasswordField(
                          controller: oldPasswordController,
                          label: 'Ancien mot de passe',
                          showPassword: showOldPassword,
                          onToggle: () {
                            setState(() {
                              showOldPassword = !showOldPassword;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        _buildPasswordField(
                          controller: newPasswordController,
                          label: 'Nouveau mot de passe',
                          showPassword: showNewPassword,
                          onToggle: () {
                            setState(() {
                              showNewPassword = !showNewPassword;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        _buildPasswordField(
                          controller: confirmPasswordController,
                          label: 'Confirmer le nouveau mot de passe',
                          showPassword: showConfirmPassword,
                          onToggle: () {
                            setState(() {
                              showConfirmPassword = !showConfirmPassword;
                            });
                          },
                          validator: (value) {
                            if (newPasswordController.text.isNotEmpty && value != newPasswordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    // Bouton Modifier
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0084F7),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isSaving
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Modifier',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0084F7),
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF0084F7), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool showPassword,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF0084F7), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Récupérer l'ID utilisateur
      final prefs = await _prefsInstance;
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('ID utilisateur non trouvé');
      }

      // Préparer les données à envoyer (seulement les champs modifiés)
      final updateData = <String, dynamic>{};

      // Vérifier quels champs ont été modifiés
      if (firstNameController.text != originalValues['first_name']) {
        updateData['first_name'] = firstNameController.text;
      }
      if (lastNameController.text != originalValues['last_name']) {
        updateData['last_name'] = lastNameController.text;
      }
      if (descriptionController.text != originalValues['description']) {
        updateData['description'] = descriptionController.text;
      }
      if (addressController.text != originalValues['address']) {
        updateData['address'] = addressController.text;
      }
      if (phoneController.text.trim() != originalValues['phone']) {
        updateData['phone'] = phoneController.text.trim();
      }
      if (emailController.text.trim() != originalValues['email']) {
        updateData['email'] = emailController.text.trim();
      }

      // Vérification des mots de passe
      final hasPasswordFields = oldPasswordController.text.isNotEmpty || 
                               newPasswordController.text.isNotEmpty || 
                               confirmPasswordController.text.isNotEmpty;
      
      if (hasPasswordFields) {
        // Si au moins un champ de mot de passe est rempli, tous doivent être remplis
        if (oldPasswordController.text.isEmpty || 
            newPasswordController.text.isEmpty || 
            confirmPasswordController.text.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tous les champs de mot de passe doivent être remplis ou vides.')),
            );
          }
          return;
        }

        // Vérifier que l'ancien mot de passe n'est pas vide
        if (oldPasswordController.text.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('L\'ancien mot de passe ne peut pas être vide')),
            );
          }
          return;
        }

        // Vérifier que le nouveau mot de passe et la confirmation correspondent
        if (newPasswordController.text != confirmPasswordController.text) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Le nouveau mot de passe et la confirmation ne correspondent pas')),
            );
          }
          return;
        }

        // Vérifier l'ancien mot de passe avec l'API de login
        final email = prefs.getString('userinfo');
        if (email == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Impossible de récupérer l\'email utilisateur')),
            );
          }
          return;
        }

        final userInfoJson = jsonDecode(email);
        final userEmail = userInfoJson['email'];

        final loginResponse = await http.post(
          Uri.parse('https://auth-service-kohl.vercel.app/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': userEmail,
            'password': oldPasswordController.text,
          }),
        );

        if (loginResponse.statusCode != 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mot de passe actuel incorrect')),
            );
          }
          return;
        }

        // Ajouter les mots de passe à l'update
        updateData['oldPassword'] = oldPasswordController.text;
        updateData['newPassword'] = newPasswordController.text;
      }

      // Vérifier s'il y a des modifications
      if (updateData.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aucune modification détectée')),
          );
        }
        return;
      }

      final token = prefs.getString('token');
      
      final response = await http.put(
        Uri.parse('http://10.0.2.2:5000/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        // Récupérer les nouvelles informations utilisateur depuis l'API
        await refreshUserInfo(userId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profil mis à jour avec succès')),
          );
          Navigator.of(context).pop();
        }
      } else {
        final errorData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorData['error'] ?? 'Erreur lors de la mise à jour')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // Méthode pour rafraîchir les informations utilisateur depuis l'API
  Future<void> refreshUserInfo(String userId) async {
    try {
      final tokenPrefs = await _prefsInstance;
      final token = tokenPrefs.getString('token');
      
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final updatedUserInfo = jsonDecode(response.body);
        final sharedPrefs = await _prefsInstance;
        await sharedPrefs.setString('userinfo', jsonEncode(updatedUserInfo));
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors du rafraîchissement des informations, veuillez réessayer plus tard.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Erreur lors du rafraîchissement des informations.")),
      );
    }
  }

  // Méthode pour libérer les ressources
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
} 