import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Conditions d'utilisation"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'La politique de confidentialité de Jobazur',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Chez Jobazur, nous accordons une importance primordiale à la protection de vos données personnelles et au respect du RGPD (Règlement Général sur la Protection des Données). Cette politique décrit de manière claire et transparente comment nous collectons, utilisons, stockons et protégeons vos informations.",
                style: TextStyle(height: 1.4),
              ),

              const SizedBox(height: 20),
              const _SectionTitle('1. Responsable du traitement'),
              const _SectionText(
                "Jobazur est responsable du traitement des données personnelles que vous nous confiez lorsque vous créez un compte, utilisez nos services ou postulez à des offres.",
              ),

              const SizedBox(height: 14),
              const _SectionTitle('2. Données collectées'),
              const _SectionText(
                "- Données d'identité: prénom, nom, adresse e-mail, téléphone, adresse postale\n- Données de compte: rôle (candidat, professionnel), identifiants de connexion\n- Données de candidature et documents: CV, lettre de motivation, informations de profil\n- Données techniques: logs nécessaires au bon fonctionnement et à la sécurité",
              ),

              const SizedBox(height: 14),
              const _SectionTitle("3. Finalités et bases légales"),
              const _SectionText(
                "Nous utilisons vos données pour: (i) fournir le service (création de compte, candidature, gestion des profils), (ii) assurer la sécurité (authentification, détection d'abus), et (iii) respecter nos obligations légales. Les bases légales incluent l'exécution du contrat (utilisation du site), le consentement (certaines fonctionnalités) et l'intérêt légitime (sécurité).",
              ),

              const SizedBox(height: 14),
              const _SectionTitle('4. Stockage et sécurité (AWS S3, chiffrement)'),
              const _SectionText(
                "Les documents (ex: CV) sont stockés de manière sécurisée sur AWS S3. Les données sensibles côté application peuvent être chiffrées et pseudonymisées. L'accès aux documents est strictement contrôlé (propriétaire, administrateur, ou recruteur autorisé lorsqu'une candidature existe).",
              ),

              const SizedBox(height: 14),
              const _SectionTitle('5. Durée de conservation et suppression'),
              const _SectionText(
                "Nous conservons vos données uniquement le temps nécessaire à la fourniture du service et au respect de la loi. Si vous supprimez votre compte, nous supprimons vos données et documents associés (y compris les fichiers S3) de manière définitive, sauf obligation légale contraire.",
              ),

              const SizedBox(height: 14),
              const _SectionTitle('6. Vos droits (RGPD)'),
              const _SectionText(
                "Vous disposez des droits d'accès, de rectification, d'effacement, de limitation, d'opposition et de portabilité. Vous pouvez exercer ces droits depuis les paramètres de votre compte ou en nous contactant (voir contact ci-dessous).",
              ),

              const SizedBox(height: 14),
              const _SectionTitle('7. Paramètres du compte et suppression'),
              const _SectionText(
                "Pour supprimer votre compte, rendez-vous dans les paramètres de l'application. La suppression entraîne la suppression de vos données et documents, conformément à la section 5.",
              ),

              const SizedBox(height: 14),
              const _SectionTitle('8. Partage et sous-traitants'),
              const _SectionText(
                "Nous ne vendons pas vos données. Nous pouvons partager certaines informations avec des prestataires de confiance (hébergement, stockage, analyse de sécurité) strictement nécessaires à la fourniture du service, sous contrat et en conformité avec le RGPD.",
              ),

              const SizedBox(height: 14),
              const _SectionTitle('9. Journalisation, sécurité et incident'),
              const _SectionText(
                "Nous journalisons les accès et actions pour la sécurité et l'audit. En cas d'incident de sécurité affectant vos données, nous suivrons les obligations légales de notification.",
              ),

              const SizedBox(height: 14),
              const _SectionTitle('10. Contact'),
              const _SectionText(
                "Pour toute question ou demande relative à la protection des données, contactez-nous: jobazur@contact.fr",
              ),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Dernière mise à jour: août 2025',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w700));
  }
}

class _SectionText extends StatelessWidget {
  const _SectionText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(height: 1.5));
  }
}
