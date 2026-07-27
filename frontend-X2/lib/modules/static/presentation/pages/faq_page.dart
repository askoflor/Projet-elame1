import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/static_page_scaffold.dart';

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}

const _faqItems = [
  _FaqItem(
    'Comment réserver un prestataire ?',
    'Recherchez un métier ou un service depuis la page d\'accueil, choisissez un prestataire selon sa ville, '
        'ses avis et ses disponibilités, puis sélectionnez un créneau directement dans son calendrier. Vous '
        'décrivez ensuite votre besoin et confirmez la demande.',
  ),
  _FaqItem(
    'Comment se déroule le paiement ?',
    'Le prestataire vous contacte pour convenir du tarif de l\'intervention. Une fois ce montant validé et '
        'l\'intervention en cours, le paiement s\'effectue en ligne via Orange Money, MTN Mobile Money ou Wave.',
  ),
  _FaqItem(
    'Quels moyens de paiement sont acceptés ?',
    'NZELA-SERVICE accepte Orange Money, MTN Mobile Money et Wave. D\'autres moyens de paiement pourront être '
        'ajoutés progressivement.',
  ),
  _FaqItem(
    'Comment devenir prestataire sur la plateforme ?',
    'Cliquez sur « Devenir prestataire », créez votre compte en précisant votre métier, votre ville et vos '
        'coordonnées. Votre profil devient alors visible dans les résultats de recherche correspondant à votre '
        'spécialité.',
  ),
  _FaqItem(
    'La plateforme prend-elle une commission ?',
    'Oui, une commission de 5% est prélevée sur le montant de chaque intervention réglée via la plateforme. '
        'Elle couvre les frais de fonctionnement du service (hébergement, paiement sécurisé, support).',
  ),
  _FaqItem(
    'Que se passe-t-il si je dois annuler un rendez-vous ?',
    'Vous pouvez échanger directement avec le prestataire ou le client concerné pour reprogrammer '
        'l\'intervention. Nous recommandons de prévenir le plus tôt possible en cas d\'imprévu.',
  ),
  _FaqItem(
    'Comment sont sélectionnés les prestataires ?',
    'Chaque prestataire renseigne son métier, ses compétences et ses certifications lors de son inscription. '
        'Les certifications ajoutées sont marquées « en attente de vérification » jusqu\'à leur validation.',
  ),
  _FaqItem(
    'Comment contacter le support ?',
    'Pour toute question non couverte ici, vous pouvez nous écrire depuis la rubrique Contact du pied de page.',
  ),
];

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageScaffold(
      title: 'Questions fréquentes',
      subtitle: 'Tout ce qu\'il faut savoir pour utiliser NZELA-SERVICE.',
      child: Column(
        children: _faqItems.map((item) => _FaqTile(item: item)).toList(),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: GoogleFonts.sora(fontSize: 14.5, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.item.answer,
                  style: GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF64748B), height: 1.6),
                ),
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
