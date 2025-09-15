import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'services/document_service.dart';

class CVManagementScreen extends StatefulWidget {
  final String userId;

  const CVManagementScreen({super.key, required this.userId});

  @override
  _CVManagementScreenState createState() => _CVManagementScreenState();
}

class _CVManagementScreenState extends State<CVManagementScreen> {
  final DocumentService _documentService = DocumentService();
  List<Map<String, dynamic>> _documents = [];
  Map<String, dynamic>? _currentCV;
  bool _isLoading = false;
  bool _isUploading = false;
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5 Mo

  String _extractErrorMessage(dynamic error) {
    final errorString = error.toString();
    
    try {
      final Map<String, dynamic> errorMap = json.decode(errorString);
      
      // Chercher différents champs possibles pour le message
      if (errorMap['message'] != null) {
        return errorMap['message'].toString();
      }
      if (errorMap['error'] != null) {
        return errorMap['error'].toString();
      }
      if (errorMap['detail'] != null) {
        return errorMap['detail'].toString();
      }
      if (errorMap['msg'] != null) {
        return errorMap['msg'].toString();
      }
      
      // Si c'est un objet avec des données, essayer de trouver un message utile
      if (errorMap.isNotEmpty) {
        final firstValue = errorMap.values.first;
        if (firstValue is String && firstValue.isNotEmpty) {
          return firstValue;
        }
      }
      
      return 'Erreur inconnue';
    } catch (_) {
      // Si ce n'est pas du JSON valide, nettoyer le message
      String cleanMessage = errorString;
      
      // Supprimer les préfixes d'erreur courants
      cleanMessage = cleanMessage.replaceAll(RegExp(r'^Exception:\s*'), '');
      cleanMessage = cleanMessage.replaceAll(RegExp(r'^Error:\s*'), '');
      cleanMessage = cleanMessage.replaceAll(RegExp(r'^HttpException:\s*'), '');
      
      // Si le message contient encore du JSON brut, essayer d'extraire le message
      if (cleanMessage.contains('{') && cleanMessage.contains('}')) {
        try {
          final match = RegExp(r'"message":\s*"([^"]+)"').firstMatch(cleanMessage);
          if (match != null) {
            return match.group(1) ?? cleanMessage;
          }
          
          final match2 = RegExp(r'"error":\s*"([^"]+)"').firstMatch(cleanMessage);
          if (match2 != null) {
            return match2.group(1) ?? cleanMessage;
          }
        } catch (_) {
          // Ignorer les erreurs de regex
        }
      }
      
      return cleanMessage.isEmpty ? 'Erreur inconnue' : cleanMessage;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> documents = await _documentService.getUserDocuments(widget.userId);
      final Map<String, dynamic>? cv = await _documentService.getUserCV(widget.userId);
      
      setState(() {
        _documents = documents;
        _currentCV = cv;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement: ${_extractErrorMessage(e)}')),
      );
    }
  }

  Future<void> _pickAndUploadCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        
        // Debug: afficher les informations du fichier sélectionné
        print('File selected: ${file.path}');
        print('File exists: ${await file.exists()}');
        final int sizeBytes = await file.length();
        print('File size: $sizeBytes bytes');
        print('File extension: ${file.path.split('.').last.toLowerCase()}');
        
        // Vérifier que c'est bien un PDF
        if (file.path.split('.').last.toLowerCase() != 'pdf') {
          throw Exception('Seuls les fichiers PDF sont acceptés');
        }

        // Vérifier la taille max 5 Mo (client-side)
        if (sizeBytes > _maxFileSizeBytes) {
          await _showTooLargeDialog(sizeBytes);
          return;
        }
        
        setState(() {
          _isUploading = true;
        });

        await _documentService.uploadDocument(
          file: file,
          title: 'Mon CV',
          userId: widget.userId,
          type: 'cv',
        );

        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV uploadé avec succès!')),
        );

        _loadDocuments(); // Reload the list
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      final String err = e.toString().toLowerCase();
      if (err.contains('file_too_large') || err.contains('413') || err.contains('payload') || err.contains('entity too large')) {
        await _showTooLargeDialog(null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Un CV est déjà rattaché à votre profil. Supprimez le et réessayez.')),
        );
      }
    }
  }

    Future<void> _downloadCV(String documentId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final String downloadUrl = await _documentService.getDocumentDownloadUrl(documentId);
      
      // Debug: afficher l'URL de téléchargement
      print('Download URL: $downloadUrl');
      
             // Essayer d'ouvrir l'URL directement avec différents modes
       try {
         // Essayer d'abord avec LaunchMode.externalApplication (plus fiable pour les PDFs)
         try {
           await launchUrl(
             Uri.parse(downloadUrl),
             mode: LaunchMode.externalApplication,
           );
           
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('CV ouvert dans l\'application par défaut!')),
           );
           return;
         } catch (e2) {
           print('External application failed: $e2');
           
           // Essayer avec LaunchMode.externalNonBrowserApplication
           try {
             await launchUrl(
               Uri.parse(downloadUrl),
               mode: LaunchMode.externalNonBrowserApplication,
             );
             
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('CV ouvert dans l\'application par défaut!')),
             );
             return;
           } catch (e3) {
             print('ExternalNonBrowserApplication failed: $e3');
             
             // Essayer avec LaunchMode.inAppWebView
             try {
               await launchUrl(
                 Uri.parse(downloadUrl),
                 mode: LaunchMode.inAppWebView,
               );
               
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('CV ouvert dans l\'app!')),
               );
               return;
             } catch (e4) {
               print('InAppWebView failed: $e4');
               
               // Dernier essai avec LaunchMode.platformDefault
               try {
                 await launchUrl(
                   Uri.parse(downloadUrl),
                   mode: LaunchMode.platformDefault,
                 );
                 
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('CV ouvert!')),
                 );
                 return;
               } catch (e5) {
                 print('Platform default failed: $e5');
               }
             }
           }
         }
         
         // Si aucun mode ne fonctionne
         throw Exception('Impossible d\'ouvrir l\'URL de téléchargement');
         
       } catch (e2) {
         print('URL launch failed: $e2');
         throw Exception('Erreur lors de l\'ouverture du CV: $e2');
       }
      
    } catch (e) {
      print('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléchargement: ${_extractErrorMessage(e)}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCV(String documentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce CV ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _documentService.deleteDocument(documentId, widget.userId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV supprimé avec succès!')),
        );
        _loadDocuments(); // Reload the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: ${_extractErrorMessage(e)}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des CV'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDocuments,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Upload section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.upload_file,
                              size: 48,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Uploader un nouveau CV',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Formats acceptés: PDF uniquement — 5 Mo max',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _isUploading ? null : _pickAndUploadCV,
                              icon: _isUploading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.upload),
                              label: Text(_isUploading ? 'Upload en cours...' : 'Sélectionner un CV'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Current CV section
                    if (_currentCV != null) ...[
                      const Text(
                        'CV actuel',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.description, color: Colors.blue),
                          title: Text(_safeTitle(_currentCV!['title'], fallback: 'Mon CV')),
                          subtitle: Text(
                            'Uploadé le ${_formatDate(_currentCV!['uploadedAt'])}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download, color: Colors.green),
                                onPressed: () async {
                                  try {
                                    setState(() { _isLoading = true; });
                                    final String url = await _documentService.getCvDownloadUrl(widget.userId);
                                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erreur téléchargement CV: ${_extractErrorMessage(e)}')),
                                    );
                                  } finally {
                                    setState(() { _isLoading = false; });
                                  }
                                },
                                tooltip: 'Télécharger',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmer la suppression'),
                                      content: const Text('Supprimer votre CV actuel ?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')), 
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    try {
                                      setState(() { _isLoading = true; });
                                      await _documentService.deleteUserCv(widget.userId);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('CV supprimé avec succès!')),
                                      );
                                      _loadDocuments();
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erreur lors de la suppression: ${_extractErrorMessage(e)}')),
                                      );
                                    } finally {
                                      setState(() { _isLoading = false; });
                                    }
                                  }
                                },
                                tooltip: 'Supprimer',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Date inconnue';
    try {
      if (value is String) {
        final date = DateTime.tryParse(value);
        if (date != null) {
          return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
        }
      }
      if (value is int) {
        // Assume milliseconds since epoch
        final date = DateTime.fromMillisecondsSinceEpoch(value);
        return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
      // Unsupported shape (e.g., Buffer map)
      return 'Date invalide';
    } catch (e) {
      return 'Date invalide';
    }
  }

  String _safeTitle(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is String) return value;
    // Gestion des objets de type Buffer renvoyés éventuellement par le back
    if (value is Map && value['type'] == 'Buffer') return fallback;
    return value.toString();
  }

  Future<void> _showTooLargeDialog(int? sizeBytes) async {
    final String sizeMo = sizeBytes != null ? (sizeBytes / (1024 * 1024)).toStringAsFixed(1) : '';
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fichier trop volumineux'),
        content: Text('Votre fichier ${sizeMo.isNotEmpty ? '(${sizeMo} Mo) ' : ''}est trop lourd. La taille maximale autorisée est de 5 Mo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
