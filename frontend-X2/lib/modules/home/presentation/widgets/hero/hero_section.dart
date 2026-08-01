import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/localization/translation_provider.dart';
import 'search_bar.dart' as custom;

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 72, bottom: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF), Color(0xFF2563EB)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Column(
        children: [
          // Badge
          _buildBadge(),
          const SizedBox(height: 24),

          // Titre
          _buildTitle(context),
          const SizedBox(height: 16),

          // Paragraphe
          _buildSubtitle(),
          const SizedBox(height: 36),

          // Search bar
          const Center(child: custom.SearchBar()),

          const SizedBox(height: 15),

          // Stats
          _buildStats(context),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF4ADE80),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Disponible 24h/24 · 7j/7',
            style: GoogleFonts.sora(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.sora(
          fontSize: 42,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -1,
          height: 1.2,
        ),
        children: [
          const TextSpan(text: 'Trouvez un professionnel\ndisponible en '),
          TextSpan(
            text: context.tr('hero.titleHighlight'),
            style: const TextStyle(color: Color(0xFFF97316)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Plombiers, électriciens, frigoristes, techniciens et bien plus près de chez vous.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 17,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final stats = [
      {'value': '2 400+', 'label': context.tr('hero.stat1Label')},
      {'value': '18 000+', 'label': context.tr('hero.stat2Label')},
      {'value': '4.8/5', 'label': context.tr('hero.stat3Label')},
      {'value': '< 30 min', 'label': context.tr('hero.stat4Label')},
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      children: stats.map((stat) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              Text(
                stat['value']!,
                style: GoogleFonts.sora(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                stat['label']!,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
