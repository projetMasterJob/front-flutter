import 'package:flutter/material.dart';

class MentionLegalePage extends StatelessWidget {
  const MentionLegalePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentions légales'),
        backgroundColor: Color(0xFF0084F7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mentions légales',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0084F7),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Dernière mise à jour : 15 janvier 2025',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            
            _buildSection(
              'Éditeur',
              'JobAzur\nApplication mobile de recherche d\'emploi\n\nAdresse : 123 Rue de l\'Emploi, 06300 Nice\nEmail : contact@JobAzur.com\nTéléphone : +33 1 23 45 67 89',
            ),
            
            _buildSection(
              'Directeur de publication',
              'Le directeur de publication est le responsable de la communication de JobAzur, en la personne de son représentant légal.',
            ),
            
            _buildSection(
              'Propriété intellectuelle',
              'L\'ensemble du contenu de l\'application JobAzur (textes, images, logos, design, code source) est protégé par le droit d\'auteur et appartient à JobAzur ou à ses partenaires. Toute reproduction, représentation, modification, publication, adaptation totale ou partielle des éléments de l\'application, quel que soit le moyen ou le procédé utilisé, est interdite, sauf autorisation écrite préalable.',
            ),
            
            _buildSection(
              'Liens hypertextes',
              'L\'application JobAzur peut contenir des liens vers d\'autres sites web. JobAzur n\'exerce aucun contrôle sur ces sites et décline toute responsabilité quant à leur contenu.',
            ),
            
            _buildSection(
              'Protection des données personnelles',
              'Conformément au Règlement Général sur la Protection des Données (RGPD), vous disposez d\'un droit d\'accès, de rectification, de suppression et d\'opposition aux données personnelles vous concernant. Pour exercer ces droits, contactez-nous à l\'adresse : privacy@JobAzur.com',
            ),
            
            _buildSection(
              'Cookies',
              'L\'application JobAzur utilise des cookies pour améliorer l\'expérience utilisateur. Ces cookies ne collectent aucune information personnelle identifiable et sont utilisés uniquement pour des fonctionnalités techniques.',
            ),
            
            _buildSection(
              'Limitation de responsabilité',
              'JobAzur s\'efforce d\'assurer au mieux l\'exactitude et la mise à jour des informations diffusées sur l\'application, mais ne peut garantir l\'exactitude, la complétude, l\'actualité des informations diffusées sur son application. JobAzur ne pourra être tenu responsable de tout dommage direct ou indirect résultant de l\'utilisation de l\'application.',
            ),
            
            _buildSection(
              'Droit applicable',
              'Les présentes mentions légales sont soumises au droit français. En cas de litige, les tribunaux français seront seuls compétents.',
            ),
            
            _buildSection(
              'Contact',
              'Pour toute question concernant ces mentions légales, vous pouvez nous contacter :\n\nEmail : legal@JobAzur.com\nAdresse : 123 Rue de l\'Emploi, 06300 Nice\nTéléphone : +33 1 23 45 67 89',
            ),
            
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                'Ces mentions légales sont conformes aux exigences légales françaises et européennes en vigueur.',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 