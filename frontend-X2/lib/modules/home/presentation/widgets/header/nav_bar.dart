import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../auth/domain/auth_provider.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  bool get isLoggedIn =>
      context.watch<AuthProvider>().isAuthenticated;

  final List<String> allMenuItems = [
    'Accueil',
    'Recherche',
    'Profil',
    'Réservation',
    'Paiement',
    'Espace Client',
    'Prestataire',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final location = GoRouterState.of(context).uri.toString();
    final currentItem = _getCurrentItem(location);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8ECF2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildLogo(),
            ),
          ),
          if (!isMobile)
            Expanded(
              flex: 2,
              child: Center(child: _buildNavTabs(currentItem)),
            ),
          if (!isMobile)
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isLoggedIn) _buildButtons(),
                  ],
                ),
              ),
            ),
          if (isMobile) ...[
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildMobileMenu(currentItem),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/'),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              fontFamily: 'Sora',
            ),
            children: [
              TextSpan(
                text: 'Service',
                style: TextStyle(color: Color(0xFF2563EB)),
              ),
              TextSpan(
                text: 'Connect',
                style: TextStyle(color: Color(0xFFF97316)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTabs(String currentItem) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: allMenuItems
            .map((item) => _buildNavItem(item, currentItem))
            .toList(),
      ),
    );
  }

  Widget _buildNavItem(String title, String currentItem) {
    final isActive = currentItem == title;

    return _HoverButton(
      onTap: () => _navigateToItem(title),
      builder: (isHovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.ease,
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive
                ? const Color(0xFF2563EB)
                : isHovered
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF64748B),
            fontFamily: 'Sora',
          ),
        ),
      ),
    );
  }

  String _getCurrentItem(String location) {
    switch (location) {
      case '/recherche':
        return 'Recherche';
      case '/profil':
        return 'Profil';
      case '/paiement':
        return 'Paiement';
      case '/reservation':
        return 'Réservation';
      case '/espace-client':
        return 'Espace Client';
      case '/prestataire':
        return 'Prestataire';
      default:
        return 'Accueil';
    }
  }

  void _navigateToItem(String title) {
    switch (title) {
      case 'Accueil':
        context.go('/');
        break;
      case 'Recherche':
        context.go('/recherche');
        break;
      case 'Profil':
        context.go('/profil');
        break;
      case 'Réservation':
        context.go('/reservation');
        break;
      case 'Paiement':
        context.go('/paiement');
        break;
      case 'Espace Client':
        context.go('/espace-client');
        break;
      case 'Prestataire':
        context.go('/prestataire');
        break;
      case 'Mobile':
        break;
    }
  }

  Widget _buildButtons() {
    return Row(
      children: [
        _buildConnexionButton(),
        const SizedBox(width: 8),
        _buildInscriptionButton(),
      ],
    );
  }

  Widget _buildConnexionButton() {
    return _HoverButton(
      onTap: () => context.go('/login'),
      builder: (isHovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.ease,
        height: 29,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isHovered ? const Color(0xFF2563EB) : const Color(0xFFE8ECF2),
            width: 1,
          ),
        ),
        child: Text(
          'Connexion',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color:
                isHovered ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            fontFamily: 'Sora',
          ),
        ),
      ),
    );
  }

  Widget _buildInscriptionButton() {
    return _HoverButton(
      onTap: () => context.go('/register'),
      builder: (isHovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.ease,
        height: 27,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isHovered ? const Color(0xFF1D4ED8) : const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          "S'inscrire",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontFamily: 'Sora',
          ),
        ),
      ),
    );
  }

  Widget _buildMobileMenu(String currentItem) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => _buildMobileDrawer(currentItem),
        );
      },
      icon: const Icon(Icons.menu, color: Color(0xFF1E293B)),
    );
  }

  Widget _buildMobileDrawer(String currentItem) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...allMenuItems.map(
            (item) => ListTile(
              title: Text(
                item,
                style: TextStyle(
                  color: currentItem == item
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF1E293B),
                  fontWeight:
                      currentItem == item ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToItem(item);
              },
            ),
          ),
          const SizedBox(height: 16),
          if (!isLoggedIn)
            Row(
              children: [
                Expanded(child: _buildConnexionButton()),
                const SizedBox(width: 8),
                Expanded(child: _buildInscriptionButton()),
              ],
            ),
        ],
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
