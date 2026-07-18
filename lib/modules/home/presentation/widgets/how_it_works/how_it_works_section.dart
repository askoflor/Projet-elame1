import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/widgets/micro_interactions.dart';
import 'step_item.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            children: [
              Text(
                'Comment ça marche ?',
                style: GoogleFonts.sora(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Trouver un prestataire n\'a jamais été aussi simple',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildSteps(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSteps() {
    final steps = [
      {
        'number': 1,
        'title': 'Décrivez votre besoin',
        'description': 'Précisez le type d\'intervention et votre localisation',
        'isActive': false,
      },
      {
        'number': 2,
        'title': 'Choisissez un prestataire',
        'description': 'Parcourez les profils, notes et disponibilités',
        'isActive': false,
      },
      {
        'number': 3,
        'title': 'Paiement sécurisé',
        'description': 'Payez via Orange Money, MTN ou Wave',
        'isActive': true,
      },
      {
        'number': 4,
        'title': 'Intervention réalisée',
        'description': 'Votre prestataire intervient et vous évaluez',
        'isActive': true,
      },
    ];

    return Stack(
      children: [
        // Ligne de connexion en arrière plan
        Positioned(
          top: 27,
          left: 0,
          right: 0,
          child: Row(
            children: [
              const SizedBox(width: 128),
              Expanded(
                child: Container(
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF2563EB),
                        Color(0xFF2563EB),
                        Color(0xFFF97316),
                        Color(0xFFF97316),
                      ],
                      stops: [0.0, 0.33, 0.66, 1.0],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 128),
            ],
          ),
        ),
        // Steps au dessus
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: steps.map((step) {
            return Expanded(
              child: SlideOnHover(
                offset: const Offset(0, -0.04),
                child: StepItem(
                  stepNumber: step['number'] as int,
                  title: step['title'] as String,
                  description: step['description'] as String,
                  isActive: step['isActive'] as bool,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
