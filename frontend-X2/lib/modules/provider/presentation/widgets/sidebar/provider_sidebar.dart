import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/localization/translation_provider.dart';
import '../../../state/provider_dashboard_state.dart';

class MenuItem {
  final IconData icon;
  final String labelKey;
  final String? badge;

  const MenuItem(this.icon, this.labelKey, {this.badge});
}

class ProviderSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  static const menuItems = [
    MenuItem(Icons.dashboard_rounded, 'provider.menuDashboard'),
    MenuItem(Icons.calendar_month_rounded, 'provider.menuPlanning'),
    MenuItem(Icons.work_rounded, 'provider.menuMissions'),
    MenuItem(Icons.monetization_on_rounded, 'provider.menuRevenus'),
    MenuItem(Icons.bar_chart_rounded, 'provider.menuStatistiques'),
    MenuItem(Icons.toggle_on_rounded, 'provider.menuDisponibilites'),
    MenuItem(Icons.notifications_rounded, 'provider.menuNotifications'),
    MenuItem(Icons.settings_rounded, 'provider.menuParametres'),
  ];

  const ProviderSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderDashboardProvider>();
    final tp = context.watch<TranslationProvider>();
    final currentLocale = tp.locale.languageCode;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileHeader(context, provider),
          const Divider(height: 1, color: Color(0xFFE8ECF2)),
          _buildMenuItems(context, provider, currentLocale),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProviderDashboardProvider provider) {
    final p = provider.profile;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFF2563EB),
            child: Text(
              p.initiales,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Sora',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            p.nomComplet,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontFamily: 'Sora',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            p.specialite,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 12),
          _buildRatingRow(p.note),
          const SizedBox(height: 10),
          _buildDisponibiliteBadge(p.disponible),
        ],
      ),
    );
  }

  Widget _buildRatingRow(double note) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          return Icon(
            i < note.floor() ? Icons.star_rounded : Icons.star_border_rounded,
            size: 16,
            color: const Color(0xFFF59E0B),
          );
        }),
        const SizedBox(width: 6),
        Text(
          note.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontFamily: 'Sora',
          ),
        ),
      ],
    );
  }

  Widget _buildDisponibiliteBadge(bool disponible) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: disponible
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: disponible
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            disponible ? 'Disponible' : 'Indisponible',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: disponible
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, ProviderDashboardProvider provider, String locale) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final isSelected = selectedIndex == index;
          final badge = item.badge ?? (index == 6 && provider.notificationsNonLues > 0
              ? provider.notificationsNonLues.toString()
              : null);

          return _MenuItemTile(
            icon: item.icon,
            label: item.labelKey,
            isSelected: isSelected,
            badge: badge,
            onTap: () => onItemSelected(index),
          );
        },
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  const _MenuItemTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? const Border(
                      left: BorderSide(
                        color: Color(0xFF2563EB),
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tr(label),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF475569),
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
