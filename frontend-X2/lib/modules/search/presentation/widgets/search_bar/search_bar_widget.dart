import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _serviceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 71,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // Champ service
          Expanded(
            flex: 10,
            child: _buildSearchField(
              controller: _serviceController,
              hint: 'Électricien, plombier, technicien...',
              icon: Icons.search,
            ),
          ),
          const SizedBox(width: 12),
          // Champ localisation
          Expanded(
            flex: 6,
            child: _buildSearchField(
              controller: _locationController,
              hint: 'Douala, Cameroun',
              icon: Icons.location_on_outlined,
            ),
          ),
          const SizedBox(width: 12),
          // Bouton Rechercher
          _buildButton(
            label: 'Rechercher',
            color: const Color(0xFF2563EB),
            onTap: () => context.go('/recherche'),
          ),
          const SizedBox(width: 8),
          // Bouton Urgence
          _buildButton(
            label: 'Urgence',
            color: const Color(0xFFF97316),
            onTap: () => context.go('/recherche'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      height: 39,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.sora(
                fontSize: 13,
                color: const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.sora(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _HoverButton(
      onTap: onTap,
      builder: (isHovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 33,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isHovered ? color.withOpacity(0.85) : color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.sora(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
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
