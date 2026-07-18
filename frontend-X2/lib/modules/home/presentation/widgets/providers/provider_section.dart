import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/localization/translation_provider.dart';
import 'provider_card.dart';

class ProviderSection extends StatelessWidget {
  const ProviderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          const SizedBox(height: 28),
          _buildProviderGrid(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('providers.sectionTitle'),
              style: GoogleFonts.sora(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('providers.sectionSubtitle'),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        _HoverButton(
          onTap: () => context.go('/recherche'),
          builder: (isHovered) => AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isHovered
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE8ECF2),
              ),
            ),
            child: Text(
              context.tr('providers.voirTout'),
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isHovered
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderGrid() {
    final providers = [
      {
        'initials': 'KM',
        'name': 'Kofi Mensah',
        'specialty': 'Électricien certifié',
        'location': 'Douala',
        'isAvailable': true,
        'isCertified': true,
        'tags': ['Fourniture d\'equipements', 'Dépannage', 'Tableau élec.'],
        'avatarColor': const Color(0xFF2563EB),
        'avatarBgColor': const Color(0xFFDBEAFE),
      },
      {
        'initials': 'AM',
        'name': 'Amara Mbaye',
        'specialty': 'Plombier',
        'location': 'Douala Akwa',
        'isAvailable': false,
        'isCertified': false,
        'tags': ['Fuites', 'Installations', 'Urgences'],
        'avatarColor': const Color(0xFF16A34A),
        'avatarBgColor': const Color(0xFFDCFCE7),
      },
      {
        'initials': 'FD',
        'name': 'Fatou Diallo',
        'specialty': 'Technicienne Clim',
        'location': 'Douala',
        'isAvailable': true,
        'isCertified': true,
        'tags': ['Climatisation', 'Entretien', 'Réfrigération'],
        'avatarColor': const Color(0xFF9333EA),
        'avatarBgColor': const Color(0xFFF3E8FF),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 2;
        }

        final serviceIndices = [0, 1, 2];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 300 / 150,
          ),
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final p = providers[index];
            return ProviderCard(
              initials: p['initials'] as String,
              name: p['name'] as String,
              specialty: p['specialty'] as String,
              location: p['location'] as String,
              isAvailable: p['isAvailable'] as bool,
              isCertified: p['isCertified'] as bool,
              tags: p['tags'] as List<String>,
              avatarColor: p['avatarColor'] as Color,
              avatarBgColor: p['avatarBgColor'] as Color,
              onTap: () => context.push('/reservation', extra: serviceIndices[index]),
            );
          },
        );
      },
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
