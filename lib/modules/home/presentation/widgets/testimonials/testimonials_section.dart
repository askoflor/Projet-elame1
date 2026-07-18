import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'testimonials_card.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Column(
        children: [
              Text(
                'Ce que disent nos clients',
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
                'Plus de 18 000 interventions réussies',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildGrid(),
            ],
          ),
    );
  }

  Widget _buildGrid() {
    final testimonials = [
      {
        'initials': 'PC',
        'name': 'Pierre Chevalier',
        'text':
            '"Intervention rapide et propre. L\'électricien est arrivé en 25 minutes. Je recommande vivement ServiceConnect pour tout dépannage urgent."',
        'service': 'Service Électricité · Il y a 3 jours',
        'avatarColor': const Color(0xFF2563EB),
        'avatarBgColor': const Color(0xFFDBEAFE),
      },
      {
        'initials': 'MN',
        'name': 'Marie Nkeng',
        'text':
            '"Plombier très professionnel, il a résolu la fuite en moins d\'une heure. Le paiement via MTN Mobile Money était très pratique."',
        'service': 'Service Plomberie · Il y a 1 semaine',
        'avatarColor': const Color(0xFF16A34A),
        'avatarBgColor': const Color(0xFFDCFCE7),
      },
      {
        'initials': 'JB',
        'name': 'Jean Biya',
        'text':
            '"Ma climatisation remise en état en un temps record. La technicienne était certifiée et très compétente. Excellent service !"',
        'service': 'Service Climatisation · Il y a 2 semaines',
        'avatarColor': const Color(0xFFEA580C),
        'avatarBgColor': const Color(0xFFFFF7ED),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 280 / 190,
          ),
          itemCount: testimonials.length,
          itemBuilder: (context, index) {
            final t = testimonials[index];
            return TestimonialCard(
              initials: t['initials'] as String,
              name: t['name'] as String,
              text: t['text'] as String,
              service: t['service'] as String,
              avatarColor: t['avatarColor'] as Color,
              avatarBgColor: t['avatarBgColor'] as Color,
            );
          },
        );
      },
    );
  }
}
