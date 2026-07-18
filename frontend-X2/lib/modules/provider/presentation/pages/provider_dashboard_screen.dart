import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../home/presentation/widgets/header/nav_bar.dart';
import '../../state/provider_dashboard_state.dart';
import '../widgets/sidebar/provider_sidebar.dart';
import '../widgets/dashboard/dashboard_content.dart';
import '../widgets/planning/planning_content.dart';
import '../widgets/missions/missions_content.dart';
import '../widgets/revenus/revenus_content.dart';
import '../widgets/statistiques/statistiques_content.dart';
import '../widgets/disponibilites/disponibilites_content.dart';
import '../widgets/notifications/notifications_content.dart';
import '../widgets/parametres/parametres_content.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderDashboardProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const NavBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isStacked = constraints.maxWidth < 900;
                  if (isStacked) {
                    return _buildMobileLayout(context, provider);
                  }
                  return _buildDesktopLayout(context, provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ProviderDashboardProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 240,
            child: ProviderSidebar(
              selectedIndex: provider.selectedIndex,
              onItemSelected: (index) => provider.setSelectedIndex(index),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(),
                  ),
                  const SizedBox(height: 8),
                  _buildCurrentContent(provider.selectedIndex),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ProviderDashboardProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const AppBackButton(),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ProviderSidebar.menuItems.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final isSelected = provider.selectedIndex == idx;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => provider.setSelectedIndex(idx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE8ECF2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(item.icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF64748B)),
                                const SizedBox(width: 6),
                                Text(
                                  context.tr(item.labelKey),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.white : const Color(0xFF475569),
                                    fontFamily: 'DM Sans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildCurrentContent(provider.selectedIndex),
          ),
        ),
      ],
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
