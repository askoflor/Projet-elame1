import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/localization/translation_provider.dart';
import 'footer_hover_text.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;
            return Column(
              children: [
                _buildFooterGrid(context, isMobile),
                const SizedBox(height: 40),
                _buildFooterBottom(context, isMobile),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooterGrid(BuildContext context, bool isMobile) {
    final servicesColumn = _buildColumn(context.tr('footer.servicesTitle'), [
      _FooterLink(context.tr('footer.electricite'), '/recherche'),
      _FooterLink(context.tr('footer.plomberie'), '/recherche'),
      _FooterLink(context.tr('footer.climatisation'), '/recherche'),
      _FooterLink(context.tr('footer.maintenance'), '/recherche'),
      _FooterLink(context.tr('footer.jardinage'), '/recherche'),
    ]);
    final entrepriseColumn = _buildColumn(context.tr('footer.entrepriseTitle'), [
      _FooterLink(context.tr('footer.aPropos'), '/a-propos'),
      _FooterLink(context.tr('footer.devenirPrestataire'), '/register'),
      _FooterLink(context.tr('footer.partenaires'), '/'),
      _FooterLink(context.tr('footer.blog'), '/'),
      _FooterLink(context.tr('footer.presse'), '/'),
    ]);
    final supportColumn = _buildColumn(context.tr('footer.supportTitle'), [
      _FooterLink(context.tr('footer.faq'), '/faq'),
      _FooterLink(context.tr('footer.contact'), '/'),
      _FooterLink(context.tr('footer.conditions'), '/'),
      _FooterLink(context.tr('footer.confidentialite'), '/confidentialite'),
      _FooterLink(context.tr('footer.cookies'), '/'),
    ]);

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBrand(),
          const SizedBox(height: 28),
          servicesColumn,
          const SizedBox(height: 24),
          entrepriseColumn,
          const SizedBox(height: 24),
          supportColumn,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildBrand()),
        const SizedBox(width: 40),
        Expanded(child: servicesColumn),
        const SizedBox(width: 40),
        Expanded(child: entrepriseColumn),
        const SizedBox(width: 40),
        Expanded(child: supportColumn),
      ],
    );
  }

  Widget _buildBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Sora',
            ),
            children: [
              TextSpan(
                text: 'NZELA-',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'SERVICE',
                style: TextStyle(color: Color(0xFFF97316)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Description
        Text(
          'La plateforme de référence pour trouver des prestataires techniques qualifiés en Afrique.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: Colors.white.withOpacity(0.5),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        // Réseaux sociaux
        _buildSocials(),
      ],
    );
  }

  Widget _buildSocials() {
    final icons = [
      Icons.facebook,
      Icons.telegram,
      Icons.linked_camera,
      Icons.tiktok,
    ];

    return Row(
      children: icons.map((icon) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _SocialButton(icon: icon),
        );
      }).toList(),
    );
  }

  Widget _buildColumn(String title, List<_FooterLink> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.sora(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FooterHoverText(text: link.label, route: link.route),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterBottom(BuildContext context, bool isMobile) {
    final copyright = Text(
      '© 2025 NZELA-SERVICE. Tous droits réservés.',
      style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white.withOpacity(0.4)),
    );
    final availableOn = Text(
      context.tr('footer.availableOn'),
      style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white.withOpacity(0.4)),
    );
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copyright, const SizedBox(height: 8), availableOn],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: copyright),
                const SizedBox(width: 12),
                Flexible(child: availableOn),
              ],
            ),
    );
  }
}

class _FooterLink {
  final String label;
  final String route;
  const _FooterLink(this.label, this.route);
}

class _SocialButton extends StatefulWidget {
  final IconData icon;

  const _SocialButton({required this.icon});

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isHovered
                ? Colors.white.withOpacity(0.15)
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
