import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'services/document_service.dart';

class CVManagementScreen extends StatefulWidget {
  final String userId;

  const CVManagementScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CVManagementScreenState createState() => _CVManagementScreenState();
}

class _CVManagementScreenState extends State<CVManagementScreen> {
  final DocumentService _documentService = DocumentService();
  List<Map<String, dynamic>> _documents = [];
  Map<String, dynamic>? _currentCV;
  bool _isLoading = false;
  bool _isUploading = false;

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
      final documents = await _documentService.getUserDocuments(widget.userId);
      final cv = await _documentService.getUserCV(widget.userId);
      
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
        SnackBar(content: Text('Erreur lors du chargement: $e')),
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
        print('File size: ${await file.length()} bytes');
        print('File extension: ${file.path.split('.').last.toLowerCase()}');
        
        // Vérifier que c'est bien un PDF
        if (file.path.split('.').last.toLowerCase() != 'pdf') {
          throw Exception('Seuls les fichiers PDF sont acceptés');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'upload: $e')),
      );
    }
  }

    Future<void> _downloadCV(String documentId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final downloadUrl = await _documentService.getDownloadUrl(documentId, widget.userId);
      
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
        SnackBar(content: Text('Erreur lors du téléchargement: $e')),
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
            child: const Text('Supprimer'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
          SnackBar(content: Text('Erreur lors de la suppression: $e')),
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
                              'Formats acceptés: PDF uniquement',
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
                          title: Text(_currentCV!['title'] ?? 'Mon CV'),
                          subtitle: Text(
                            'Uploadé le ${_formatDate(_currentCV!['uploadedAt'])}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download, color: Colors.green),
                                onPressed: () => _downloadCV(_currentCV!['id']),
                                tooltip: 'Télécharger',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCV(_currentCV!['id']),
                                tooltip: 'Supprimer',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // All documents section
                    if (_documents.isNotEmpty) ...[
                      const Text(
                        'Tous les documents',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._documents.map((doc) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(doc['title'] ?? 'Document'),
                          subtitle: Text(
                            'Type: ${doc['type'] ?? 'unknown'} - Uploadé le ${_formatDate(doc['uploadedAt'])}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download, color: Colors.green),
                                onPressed: () => _downloadCV(doc['id']),
                                tooltip: 'Télécharger',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCV(doc['id']),
                                tooltip: 'Supprimer',
                              ),
                            ],
                          ),
                        ),
                      )).toList(),
                    ],
                    
                    // Empty state
                    if (_documents.isEmpty && _currentCV == null) ...[
                      const SizedBox(height: 48),
                      const Icon(
                        Icons.folder_open,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucun CV trouvé',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Uploader votre premier CV pour commencer',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Date invalide';
    }
  }
}
