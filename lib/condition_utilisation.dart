import 'package:flutter/material.dart';

class ConditionUtilisationPage extends StatelessWidget {
  const ConditionUtilisationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
        backgroundColor: const Color(0xFF0084F7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conditions d\'utilisation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0084F7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dernière mise à jour : 15 janvier 2025',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            
            _buildSection(
              '1. Acceptation des conditions',
              'En utilisant l\'application JobAzur, vous acceptez d\'être lié par ces conditions d\'utilisation. Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser l\'application.',
            ),
            
            _buildSection(
              '2. Description du service',
              'JobAzur est une plateforme de recherche d\'emploi qui met en relation les candidats avec les entreprises. L\'application permet de consulter des offres d\'emploi, postuler à des candidatures et communiquer avec les recruteurs.',
            ),
            
            _buildSection(
              '3. Inscription et compte utilisateur',
              'Pour utiliser certaines fonctionnalités, vous devez créer un compte. Vous êtes responsable de maintenir la confidentialité de vos informations de connexion et de toutes les activités qui se produisent sous votre compte.',
            ),
            
            _buildSection(
              '4. Utilisation acceptable',
              'Vous vous engagez à utiliser l\'application uniquement à des fins légales et appropriées. Il est interdit d\'utiliser le service pour transmettre du contenu illégal, offensant ou nuisible.',
            ),
            
            _buildSection(
              '5. Contenu utilisateur',
              'Vous conservez la propriété du contenu que vous publiez. En publiant du contenu, vous accordez à JobAzur une licence non exclusive pour utiliser, reproduire et distribuer ce contenu dans le cadre du service.',
            ),
            
            _buildSection(
              '6. Protection de la vie privée',
              'Vos données personnelles sont collectées et traitées conformément à notre politique de confidentialité. Nous utilisons notamment AWS (Amazon Web Services) comme sous-traitant pour l\'hébergement sécurisé de certains fichiers (ex.: CV). Pour en savoir plus (région, sécurité, durée de conservation et droits), consultez la Politique de confidentialité.',
            ),
            
            _buildSection(
              '7. Limitation de responsabilité',
              'JobAzur s\'efforce de fournir un service fiable, mais ne peut garantir que le service sera ininterrompu ou exempt d\'erreurs. Nous ne sommes pas responsables des décisions d\'embauche des entreprises.',
            ),
            
            _buildSection(
              '8. Modifications des conditions',
              'Nous nous réservons le droit de modifier ces conditions à tout moment. Les modifications prendront effet immédiatement après leur publication. Votre utilisation continue du service constitue votre acceptation des nouvelles conditions.',
            ),
            
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                'En utilisant JobAzur, vous confirmez avoir lu, compris et accepté ces conditions d\'utilisation.',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.blue[700],
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
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
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