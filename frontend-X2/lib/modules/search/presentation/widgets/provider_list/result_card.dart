import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/localization/translation_provider.dart';

class ResultCard extends StatelessWidget {
  final String initials;
  final String name;
  final String specialty;
  final String location;
  final int interventions;
  final bool isAvailable;
  final bool isCertified;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final String price;
  final Color avatarColor;
  final Color avatarBgColor;
  final bool isSelected;
  final VoidCallback onTap;

  const ResultCard({
    super.key,
    required this.initials,
    required this.name,
    required this.specialty,
    required this.location,
    required this.interventions,
    required this.isAvailable,
    required this.isCertified,
    required this.tags,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.avatarColor,
    required this.avatarBgColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _HoverButton(
      onTap: onTap,
      builder: (isHovered) => LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHovered
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE8ECF2),
                width: isHovered ? 1.5 : 1,
              ),
              boxShadow: isHovered || isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: isCompact ? _buildCompactLayout() : _buildWideLayout(),
          );
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(),
        const SizedBox(width: 14),
        Expanded(child: _buildInfo()),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(),
        const SizedBox(width: 14),
        Expanded(child: _buildInfo()),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: avatarBgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: avatarColor,
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom + badges
        Row(
          children: [
            Text(
              name,
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(width: 8),
            if (isCertified) ...[
              _buildCertifiedBadge(),
              const SizedBox(width: 6),
            ],
            _buildBadge(),
          ],
        ),
        const SizedBox(height: 2),
        // Spécialité + localisation + interventions
        Text(
          '$specialty · $location · $interventions interventions',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        // Tags
        _buildTags(),
        const SizedBox(height: 8),
        // Note
        _buildStars(),
      ],
    );
  }

  Widget _buildCertifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified,
            size: 11,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 3),
          Text(
            'Certifié',
            style: GoogleFonts.sora(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isAvailable
                  ? const Color(0xFF059669)
                  : const Color(0xFFF97316),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isAvailable ? 'Disponible' : 'En mission',
            style: GoogleFonts.sora(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isAvailable
                  ? const Color(0xFF059669)
                  : const Color(0xFFF97316),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: tags.asMap().entries.map((entry) {
        final isLast = entry.key == tags.length - 1;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isLast ? const Color(0xFFE8ECF2) : const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            entry.value,
            style: GoogleFonts.sora(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isLast ? const Color(0xFF64748B) : const Color(0xFF2563EB),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStars() {
    return Row(
      children: [
        const Icon(Icons.star, color: Color(0xFFFBBF24), size: 13),
        const SizedBox(width: 2),
        Text(
          '$rating ($reviewCount avis)',
          style: GoogleFonts.sora(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _HoverButton extends StatefulWidget {
  final Widget Function(bool isHovered) builder;
  final VoidCallback onTap;

  const _HoverButton({required this.builder, required this.onTap});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: widget.builder(isHovered),
      ),
    );
  }
}
