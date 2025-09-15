import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';

class PDFViewerPage extends StatefulWidget {
  final String url;

  const PDFViewerPage({super.key, required this.url});

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _downloadAndOpenPDF();
  }

  Future<void> _downloadAndOpenPDF() async {
    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/cv_preview.pdf');
      
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        
        await OpenFile.open(file.path);
        Navigator.pop(context);
      } else {
        setState(() {
          _error = 'Erreur téléchargement PDF';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aperçu CV'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Téléchargement et ouverture du PDF...'),
                ],
              ),
            ),
    );
  }
}
