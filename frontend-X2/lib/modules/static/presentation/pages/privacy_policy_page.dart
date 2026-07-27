import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/static_page_scaffold.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageScaffold(
      title: 'Politique de confidentialité',
      subtitle: 'Dernière mise à jour : Juillet 2026',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _notice(
            'Cette politique décrit, de façon générale, la manière dont NZELA-SERVICE collecte, utilise et '
            'protège les données personnelles de ses utilisateurs, dans le respect des principes de protection '
            'des données personnelles applicables au Cameroun (notamment la loi n° 2010/012 du 21 décembre 2010 '
            'relative à la cybersécurité et à la cybercriminalité) ainsi que des bonnes pratiques internationales '
            'en la matière. Ce document a une portée informative et sera révisé au fur et à mesure de l\'évolution '
            'du service et de la réglementation applicable.',
          ),
          const SizedBox(height: 28),
          _section(
            '1. Responsable du traitement',
            'Les données personnelles collectées via NZELA-SERVICE sont traitées par l\'exploitant de la '
                'plateforme, dans le cadre de la mise en relation entre clients et prestataires de services '
                'techniques.',
          ),
          _section(
            '2. Données que nous collectons',
            'Nous collectons les données que vous nous fournissez directement lors de la création de votre '
                'compte et de l\'utilisation de la plateforme :',
            bullets: const [
              'Données d\'identification : nom, prénom, adresse e-mail, numéro de téléphone.',
              'Données de profil prestataire : métier, ville, compétences, certifications déclarées.',
              'Données liées aux interventions : adresse d\'intervention, dates, créneaux, montants convenus.',
              'Données de paiement : transactions effectuées via Orange Money, MTN Mobile Money ou Wave '
                  '(NZELA-SERVICE ne stocke pas les identifiants ou codes secrets de ces services).',
              'Données techniques : type d\'appareil, navigateur, adresse IP, journaux de connexion.',
            ],
          ),
          _section(
            '3. Finalités du traitement',
            'Vos données sont utilisées pour :',
            bullets: const [
              'Créer et gérer votre compte utilisateur (client ou prestataire).',
              'Mettre en relation clients et prestataires et faciliter la prise de rendez-vous.',
              'Traiter les paiements liés aux interventions réalisées.',
              'Assurer le support, la sécurité et la prévention de la fraude sur la plateforme.',
              'Vous informer de l\'avancement de vos réservations et interventions.',
              'Améliorer la qualité et l\'ergonomie du service.',
            ],
          ),
          _section(
            '4. Base légale du traitement',
            'Le traitement de vos données repose sur l\'exécution du contrat qui vous lie à NZELA-SERVICE '
                'lorsque vous créez un compte, sur votre consentement lorsque celui-ci est requis (par exemple '
                'pour certaines communications), ainsi que sur l\'intérêt légitime de la plateforme à assurer '
                'son bon fonctionnement et sa sécurité.',
          ),
          _section(
            '5. Partage des données',
            'Vos données ne sont partagées qu\'avec les tiers strictement nécessaires au fonctionnement du '
                'service :',
            bullets: const [
              'Les prestataires ou clients concernés par une réservation (nom, coordonnées, adresse '
                  'd\'intervention).',
              'Les opérateurs de paiement mobile (Orange Money, MTN Mobile Money, Wave) pour le traitement des '
                  'transactions.',
              'Les prestataires techniques qui hébergent et sécurisent la plateforme.',
            ],
            footer: 'NZELA-SERVICE ne vend ni ne loue vos données personnelles à des tiers à des fins '
                'commerciales.',
          ),
          _section(
            '6. Durée de conservation',
            'Vos données sont conservées pendant la durée de votre inscription sur la plateforme, puis '
                'archivées ou supprimées dans un délai raisonnable après la clôture de votre compte, sauf '
                'obligation légale de conservation plus longue (notamment à des fins comptables ou fiscales).',
          ),
          _section(
            '7. Vos droits',
            'Conformément aux principes de protection des données personnelles, vous disposez des droits '
                'suivants sur vos données :',
            bullets: const [
              'Droit d\'accès à vos données personnelles.',
              'Droit de rectification des données inexactes ou incomplètes.',
              'Droit à l\'effacement de vos données, sous réserve des obligations légales de conservation.',
              'Droit d\'opposition à certains traitements, notamment à des fins de prospection.',
              'Droit à la portabilité de vos données, lorsque cela est techniquement possible.',
            ],
            footer: 'Pour exercer ces droits, vous pouvez nous contacter depuis la rubrique Contact du pied de '
                'page.',
          ),
          _section(
            '8. Sécurité des données',
            'NZELA-SERVICE met en œuvre des mesures techniques et organisationnelles raisonnables pour '
                'protéger vos données personnelles contre l\'accès non autorisé, la perte, l\'altération ou la '
                'divulgation.',
          ),
          _section(
            '9. Cookies',
            'La plateforme peut utiliser des cookies ou technologies similaires afin d\'assurer le bon '
                'fonctionnement du service, de mémoriser vos préférences et d\'améliorer votre expérience de '
                'navigation.',
          ),
          _section(
            '10. Modifications de cette politique',
            'Cette politique de confidentialité peut être mise à jour périodiquement pour refléter les '
                'évolutions du service ou de la réglementation applicable. La date de dernière mise à jour est '
                'indiquée en haut de cette page.',
          ),
          _section(
            '11. Contact',
            'Pour toute question relative à cette politique ou au traitement de vos données personnelles, '
                'vous pouvez nous contacter via la rubrique Contact du pied de page.',
          ),
        ],
      ),
    );
  }

  Widget _notice(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF1E3A8A), height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String intro, {List<String>? bullets, String? footer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 10),
          Text(
            intro,
            style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF475569), height: 1.7),
          ),
          if (bullets != null) ...[
            const SizedBox(height: 10),
            ...bullets.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6, right: 10),
                        child: Icon(Icons.circle, size: 5, color: Color(0xFF2563EB)),
                      ),
                      Expanded(
                        child: Text(
                          b,
                          style: GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF475569), height: 1.6),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (footer != null) ...[
            const SizedBox(height: 10),
            Text(
              footer,
              style: GoogleFonts.dmSans(fontSize: 13.5, fontStyle: FontStyle.italic, color: const Color(0xFF64748B), height: 1.6),
            ),
          ],
        ],
      ),
    );
  }
}
