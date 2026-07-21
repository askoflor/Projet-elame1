import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/widgets/micro_interactions.dart';

class TestimonialCard extends StatelessWidget {
  final String initials;
  final String name;
  final String text;
  final String service;
  final Color avatarColor;
  final Color avatarBgColor;

  const TestimonialCard({
    super.key,
    required this.initials,
    required this.name,
    required this.text,
    required this.service,
    required this.avatarColor,
    required this.avatarBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return SlideOnHover(
      offset: const Offset(0, -0.03),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8ECF2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTop(),
            const SizedBox(height: 12),
            Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              service,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTop() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: avatarBgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: avatarColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Nom
        Flexible(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
