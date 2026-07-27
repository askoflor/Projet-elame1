import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const String _bannerImageUrl =
    'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=1600&q=75';

class ActivityBannerSection extends StatelessWidget {
  const ActivityBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: isMobile ? 260 : 380,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _bannerImageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: const Color(0xFF1E293B),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E3A8A), Color(0xFF1E293B)],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.build_circle_outlined, color: Colors.white24, size: 64),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Colors.black.withOpacity(0.75),
                          Colors.black.withOpacity(0.15),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: isMobile ? 20 : 48,
                    right: isMobile ? 20 : 48,
                    bottom: isMobile ? 20 : 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Des professionnels qualifiés, sur le terrain',
                          style: GoogleFonts.sora(
                            fontSize: isMobile ? 20 : 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: isMobile ? double.infinity : 480,
                          child: Text(
                            'Électriciens, plombiers, techniciens : notre communauté de prestataires intervient chaque jour partout au Cameroun.',
                            style: GoogleFonts.dmSans(
                              fontSize: isMobile ? 13 : 15,
                              color: Colors.white.withOpacity(0.85),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
