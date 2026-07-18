import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Header
          _buildHeader(),
          // Map body
          Expanded(child: _buildMapBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8ECF2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Carte interactive',
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {},
              child: Text(
                'Agrandir',
                style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F0FE),
            Color(0xFFF0F4F8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Pins
          _buildPin(
            initials: 'KM',
            label: 'Kofi · 1.2 km',
            left: 120,
            top: 135,
            color: const Color(0xFF2563EB),
            bgColor: const Color(0xFFDBEAFE),
          ),
          _buildPin(
            initials: 'SM',
            label: 'Samuel · 2.8 km',
            left: 170,
            top: 220,
            color: const Color(0xFFD97706),
            bgColor: const Color(0xFFFEF3C7),
          ),
          _buildPin(
            initials: 'FD',
            label: 'Fatou · 3.5 km',
            left: 100,
            top: 300,
            color: const Color(0xFF9333EA),
            bgColor: const Color(0xFFF3E8FF),
          ),
          // Point central (localisation utilisateur)
          Positioned(
            left: 145,
            top: 205,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.2),
                    blurRadius: 0,
                    spreadRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          // Info box en bas
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: _buildInfoBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildPin({
    required String initials,
    required String label,
    required double left,
    required double top,
    required Color color,
    required Color bgColor,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Column(
        children: [
          // Cercle avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.sora(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: GoogleFonts.sora(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Douala, Cameroun',
                style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                '156 prestataires dans ce secteur',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
