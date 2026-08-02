import 'package:flutter/material.dart';
import '../localization/translation_provider.dart';

/// Barre de pagination generique reutilisee par les listes d'interventions
/// (espace client et espace prestataire).
class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavIcon(
            icon: Icons.chevron_left_rounded,
            onTap: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
          ),
          const SizedBox(width: 12),
          Text(
            '${context.tr('pagination.page')} ${currentPage + 1} / $totalPages',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B), fontFamily: 'DM Sans'),
          ),
          const SizedBox(width: 12),
          _NavIcon(
            icon: Icons.chevron_right_rounded,
            onTap: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _NavIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE8ECF2)),
          ),
          child: Icon(icon, size: 18, color: enabled ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
        ),
      ),
    );
  }
}
