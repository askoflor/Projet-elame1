import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/localization/translation_provider.dart';
import 'dart:async';
import '../../../../../core/widgets/micro_interactions.dart';

class PartnersSection extends StatefulWidget {
  const PartnersSection({super.key});

  @override
  State<PartnersSection> createState() => _PartnersSectionState();
}

class _PartnersSectionState extends State<PartnersSection> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  // TODO: ajouter les prochains partenaires ici au fur et a mesure (nom + chemin de l'image).
  final List<Map<String, String>> partners = [
    {'name': 'Suwelleh Farm', 'image': 'assets/images/partner-suwelleh-farm.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(currentScroll + 0.8);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // On duplique la liste pour un effet de boucle infinie fluide
    final loopedPartners = [...partners, ...partners, ...partners];

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          // Titre
          Text(
            context.tr('partners.sectionTitle'),
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
            context.tr('partners.sectionSubtitle'),
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Carrousel défilant
          SizedBox(
            height: 90,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Permet le scroll manuel sans bug avec l'auto-scroll
                return false;
              },
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: loopedPartners.length,
                itemBuilder: (context, index) {
                  final partner = loopedPartners[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPartnerLogo(
                      name: partner['name']!,
                      imagePath: partner['image']!,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerLogo({
    required String name,
    required String imagePath,
  }) {
    return ScaleOnHover(
      scale: 1.05,
      child: Container(
        width: 150,
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8ECF2)),
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          semanticLabel: name,
        ),
      ),
    );
  }
}
