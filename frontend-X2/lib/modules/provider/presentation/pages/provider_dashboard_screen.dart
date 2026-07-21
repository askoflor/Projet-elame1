import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../home/presentation/widgets/header/nav_bar.dart';
import '../../../intervention/state/intervention_provider.dart';
import '../../state/provider_dashboard_state.dart';
import '../widgets/dashboard/dashboard_content.dart';
import '../widgets/planning/planning_content.dart';
import '../widgets/missions/missions_content.dart';
import '../widgets/revenus/revenus_content.dart';
import '../widgets/statistiques/statistiques_content.dart';
import '../widgets/disponibilites/disponibilites_content.dart';
import '../widgets/notifications/notifications_content.dart';
import '../widgets/parametres/parametres_content.dart';

class _ProviderMenuItem {
  final IconData icon;
  final String labelKey;
  const _ProviderMenuItem(this.icon, this.labelKey);
}

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  static const _menuItems = [
    _ProviderMenuItem(Icons.dashboard_rounded, 'provider.menuDashboard'),
    _ProviderMenuItem(Icons.calendar_month_rounded, 'provider.menuPlanning'),
    _ProviderMenuItem(Icons.work_rounded, 'provider.menuMissions'),
    _ProviderMenuItem(Icons.monetization_on_rounded, 'provider.menuRevenus'),
    _ProviderMenuItem(Icons.bar_chart_rounded, 'provider.menuStatistiques'),
    _ProviderMenuItem(Icons.toggle_on_rounded, 'provider.menuDisponibilites'),
    _ProviderMenuItem(Icons.notifications_rounded, 'provider.menuNotifications'),
    _ProviderMenuItem(Icons.settings_rounded, 'provider.menuParametres'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderDashboardProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const NavBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTabBar(context, provider)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                child: _buildCurrentContent(provider.selectedIndex),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, ProviderDashboardProvider provider) {
    final aChiffrer = context.watch<InterventionProvider>().enAttente.length;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = provider.selectedIndex == index;
          final badge = index == 2 && aChiffrer > 0
              ? '$aChiffrer'
              : (index == 6 && provider.notificationsNonLues > 0 ? '${provider.notificationsNonLues}' : null);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => provider.setSelectedIndex(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE8ECF2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      context.tr(item.labelKey),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(10)),
                        child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentContent(int index) {
    switch (index) {
      case 0: return const DashboardContent();
      case 1: return const PlanningContent();
      case 2: return const MissionsContent();
      case 3: return const RevenusContent();
      case 4: return const StatistiquesContent();
      case 5: return const DisponibilitesContent();
      case 6: return const NotificationsContent();
      case 7: return const ParametresContent();
      default: return const DashboardContent();
    }
  }
}
