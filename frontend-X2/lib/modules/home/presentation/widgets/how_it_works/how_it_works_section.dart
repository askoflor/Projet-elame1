import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/widgets/micro_interactions.dart';
import '../../../../../core/localization/translation_provider.dart';
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
                context.tr('howItWorks.sectionTitle'),
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
                context.tr('howItWorks.sectionSubtitle'),
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildSteps(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSteps(BuildContext context) {
    final steps = [
      {
        'number': 1,
        'title': context.tr('howItWorks.step1Title'),
        'description': context.tr('howItWorks.step1Desc'),
        'isActive': false,
      },
      {
        'number': 2,
        'title': context.tr('howItWorks.step2Title'),
        'description': context.tr('howItWorks.step2Desc'),
        'isActive': false,
      },
      {
        'number': 3,
        'title': context.tr('howItWorks.step3Title'),
        'description': context.tr('howItWorks.step3Desc'),
        'isActive': true,
      },
      {
        'number': 4,
        'title': context.tr('howItWorks.step4Title'),
        'description': context.tr('howItWorks.step4Desc'),
        'isActive': true,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final isTablet = !isMobile && constraints.maxWidth < 1000;

        final items = steps.map((step) {
          return SlideOnHover(
            offset: const Offset(0, -0.04),
            child: StepItem(
              stepNumber: step['number'] as int,
              title: step['title'] as String,
              description: step['description'] as String,
              isActive: step['isActive'] as bool,
            ),
          );
        }).toList();

        if (isMobile) {
          return Column(
            children: [
              for (final item in items) ...[
                item,
                const SizedBox(height: 24),
              ],
            ],
          );
        }

        if (isTablet) {
          return Wrap(
            spacing: 24,
            runSpacing: 24,
            children: items.map((item) => SizedBox(width: 280, child: item)).toList(),
          );
        }

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
              children: items.map((item) => Expanded(child: item)).toList(),
            ),
          ],
        );
      },
    );
  }
}
