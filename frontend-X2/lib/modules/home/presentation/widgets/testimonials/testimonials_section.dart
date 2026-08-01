import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/localization/translation_provider.dart';
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
                context.tr('testimonials.sectionTitle'),
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
                context.tr('testimonials.sectionSubtitle'),
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildGrid(context),
            ],
          ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final testimonials = [
      {
        'initials': 'PC',
        'name': 'Pierre Chevalier',
        'text': context.tr('testimonials.t1Text'),
        'service': context.tr('testimonials.t1Service'),
        'avatarColor': const Color(0xFF2563EB),
        'avatarBgColor': const Color(0xFFDBEAFE),
      },
      {
        'initials': 'MN',
        'name': 'Marie Nkeng',
        'text': context.tr('testimonials.t2Text'),
        'service': context.tr('testimonials.t2Service'),
        'avatarColor': const Color(0xFF16A34A),
        'avatarBgColor': const Color(0xFFDCFCE7),
      },
      {
        'initials': 'JB',
        'name': 'Jean Biya',
        'text': context.tr('testimonials.t3Text'),
        'service': context.tr('testimonials.t3Service'),
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
