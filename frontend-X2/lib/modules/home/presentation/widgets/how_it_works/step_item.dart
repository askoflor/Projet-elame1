import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StepItem extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;
  final bool isActive;

  const StepItem({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFFF97316) : const Color(0xFF2563EB);
    final borderColor = isActive
        ? const Color(0xFFFDBA74)
        : const Color(0xFFBFCFFD);
    final shadowColor = isActive
        ? const Color(0xFFF97316).withOpacity(0.15)
        : const Color(0xFF2563EB).withOpacity(0.15);

    return SizedBox(
      width: 218,
      child: Column(
        children: [
          // Cercle numéro
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: GoogleFonts.sora(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Titre
          Text(
            title,
            style: GoogleFonts.sora(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Description
          Text(
            description,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
