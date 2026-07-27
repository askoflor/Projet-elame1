import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/static_page_scaffold.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageScaffold(
      title: 'À propos de NZELA-SERVICE',
      subtitle: 'La plateforme qui met en relation clients et prestataires techniques au Cameroun.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _paragraph(
            'NZELA-SERVICE est une plateforme numérique conçue pour simplifier la recherche et la '
            'réservation de prestataires techniques qualifiés : électriciens, plombiers, techniciens en '
            'climatisation, peintres, menuisiers et bien d\'autres corps de métier. Notre objectif est simple : '
            'permettre à chacun de trouver rapidement un professionnel disponible et de confiance, où qu\'il se '
            'trouve au Cameroun.',
          ),
          const SizedBox(height: 28),
          _sectionTitle('Notre mission'),
          _paragraph(
            'Nous voulons rendre l\'accès aux services techniques du quotidien aussi simple qu\'une réservation en '
            'ligne : recherche par métier et par ville, consultation des disponibilités en temps réel, prise de '
            'rendez-vous directement depuis le profil du prestataire, et paiement sécurisé via Orange Money, MTN '
            'Mobile Money ou Wave.',
          ),
          const SizedBox(height: 28),
          _sectionTitle('Comment ça marche'),
          _bulletList(const [
            'Le client décrit son besoin et choisit un prestataire selon sa spécialité, sa ville et ses avis.',
            'Il réserve un créneau directement dans le calendrier du prestataire.',
            'Le prestataire échange avec le client, chiffre l\'intervention et confirme le rendez-vous.',
            'Une fois l\'intervention terminée, le client règle en ligne et peut noter le prestataire.',
          ]),
          const SizedBox(height: 28),
          _sectionTitle('Nos valeurs'),
          _bulletList(const [
            'Confiance : des profils vérifiés et des avis authentiques laissés par de vrais clients.',
            'Simplicité : un parcours de réservation pensé pour aller à l\'essentiel.',
            'Transparence : un tarif convenu avant l\'intervention, sans surprise.',
            'Proximité : des prestataires locaux, disponibles près de chez vous.',
          ]),
          const SizedBox(height: 28),
          _sectionTitle('Rejoindre l\'aventure'),
          _paragraph(
            'Vous êtes un professionnel technique et souhaitez développer votre clientèle ? '
            'Créez votre profil prestataire en quelques minutes et commencez à recevoir des demandes.',
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: GoogleFonts.sora(fontSize: 19, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
        ),
      );

  Widget _paragraph(String text) => Text(
        text,
        style: GoogleFonts.dmSans(fontSize: 14.5, color: const Color(0xFF475569), height: 1.7),
      );

  Widget _bulletList(List<String> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6, right: 10),
                        child: Icon(Icons.circle, size: 6, color: Color(0xFF2563EB)),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.dmSans(fontSize: 14.5, color: const Color(0xFF475569), height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      );
}
