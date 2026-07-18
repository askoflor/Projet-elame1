import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProviderCard extends StatelessWidget {
  final String initials;
  final String name;
  final String specialty;
  final String location;
  final bool isAvailable;
  final bool isCertified;
  final List<String> tags;
  final Color avatarColor;
  final Color avatarBgColor;
  final VoidCallback? onTap;

  const ProviderCard({
    super.key,
    required this.initials,
    required this.name,
    required this.specialty,
    required this.location,
    required this.isAvailable,
    required this.isCertified,
    required this.tags,
    required this.avatarColor,
    required this.avatarBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _HoverButton(
      onTap: onTap ?? () => context.go('/profil'),
      builder: (isHovered) => AnimatedSlide(
        offset: Offset(0, isHovered ? -0.03 : 0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8ECF2), width: 1),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              _buildTags(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: avatarBgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: avatarColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCertified) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      size: 14,
                      color: Color(0xFF2563EB),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$specialty · $location',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              _buildBadge(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
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
              fontSize: 11,
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
