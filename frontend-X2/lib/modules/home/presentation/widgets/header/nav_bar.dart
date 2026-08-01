import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../auth/domain/auth_provider.dart';
import '../../../../../core/localization/translation_provider.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  bool get isLoggedIn =>
      context.watch<AuthProvider>().isAuthenticated;

  List<String> get allMenuItems {
    final auth = context.watch<AuthProvider>();
    final items = ['Accueil', 'Recherche', 'Profil', 'Paiement', 'Confidentialité'];
    if (auth.isAuthenticated) {
      if (auth.user?.role == 'PRESTATAIRE') {
        items.add('Prestataire');
      } else if (auth.user?.role == 'CLIENT') {
        items.add('Espace Client');
      }
    }
    return items;
  }

  /// "Devenir prestataire" reste visible pour les visiteurs et les clients,
  /// et disparait uniquement une fois connecte en tant que prestataire.
  bool get _showDevenirPrestataire {
    final auth = context.watch<AuthProvider>();
    return !(auth.isAuthenticated && auth.user?.role == 'PRESTATAIRE');
  }

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
                    _buildLanguageToggle(),
                    const SizedBox(width: 8),
                    if (_showDevenirPrestataire) ...[
                      _buildDevenirPrestataireButton(),
                      const SizedBox(width: 8),
                    ],
                    if (!isLoggedIn) _buildButtons() else _buildUserMenu(),
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
                text: 'NZELA-',
                style: TextStyle(color: Color(0xFF2563EB)),
              ),
              TextSpan(
                text: 'SERVICE',
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
      case '/confidentialite':
        return 'Confidentialité';
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
      case 'Paiement':
        context.go('/paiement');
        break;
      case 'Confidentialité':
        context.go('/confidentialite');
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

  Widget _buildLanguageToggle() {
    final tp = context.watch<TranslationProvider>();
    final isFr = tp.locale.languageCode == 'fr';
    return _HoverButton(
      onTap: () => tp.setLocale(Locale(isFr ? 'en' : 'fr')),
      builder: (isHovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.ease,
        height: 29,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isHovered ? const Color(0xFF2563EB) : const Color(0xFFE8ECF2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language_rounded, size: 14, color: Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(
              isFr ? 'FR' : 'EN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isHovered ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                fontFamily: 'Sora',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevenirPrestataireButton() {
    return _HoverButton(
      onTap: () => context.go('/register', extra: 'PRESTATAIRE'),
      builder: (isHovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.ease,
        height: 29,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isHovered ? const Color(0xFFF97316) : const Color(0xFFE8ECF2),
            width: 1,
          ),
        ),
        child: Text(
          'Devenir prestataire',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isHovered ? const Color(0xFFF97316) : const Color(0xFF64748B),
            fontFamily: 'Sora',
          ),
        ),
      ),
    );
  }

  Widget _buildUserMenu() {
    final user = context.watch<AuthProvider>().user;
    final nom = user?.nom ?? '';
    final prenom = user?.prenom ?? '';
    final displayName = '$prenom $nom'.trim();
    final initiales = (prenom.isNotEmpty ? prenom[0] : '') + (nom.isNotEmpty ? nom[0] : '');

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 40),
      onSelected: (value) {
        if (value == 'profil') {
          context.go('/profil');
        } else if (value == 'logout') {
          context.read<AuthProvider>().logout();
          context.go('/');
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profil',
          child: Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF64748B)),
              const SizedBox(width: 10),
              const Text('Mon profil', style: TextStyle(fontSize: 13, fontFamily: 'Sora')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
              const SizedBox(width: 10),
              const Text('Déconnexion', style: TextStyle(fontSize: 13, fontFamily: 'Sora', color: Color(0xFFEF4444))),
            ],
          ),
        ),
      ],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF2563EB),
              child: Text(
                initiales.toUpperCase().isEmpty ? '?' : initiales.toUpperCase(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Sora'),
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                displayName.isEmpty ? 'Mon compte' : displayName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1E293B), fontFamily: 'Sora'),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
          ],
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
          Align(alignment: Alignment.centerRight, child: _buildLanguageToggle()),
          const SizedBox(height: 12),
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
          if (_showDevenirPrestataire) ...[
            SizedBox(width: double.infinity, child: _buildDevenirPrestataireButton()),
            const SizedBox(height: 8),
          ],
          if (!isLoggedIn)
            Row(
              children: [
                Expanded(child: _buildConnexionButton()),
                const SizedBox(width: 8),
                Expanded(child: _buildInscriptionButton()),
              ],
            )
          else
            _buildMobileUserRow(),
        ],
      ),
    );
  }

  Widget _buildMobileUserRow() {
    final user = context.watch<AuthProvider>().user;
    final displayName = '${user?.prenom ?? ''} ${user?.nom ?? ''}'.trim();
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.go('/profil');
            },
            icon: const Icon(Icons.person_outline_rounded, size: 16),
            label: Text(displayName.isEmpty ? 'Mon profil' : displayName, overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthProvider>().logout();
            context.go('/');
          },
          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
          child: const Icon(Icons.logout_rounded, size: 16),
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
