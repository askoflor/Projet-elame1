import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/localization/translation_provider.dart';
import '../../../../../core/widgets/micro_interactions.dart';
import '../../../state/provider_dashboard_state.dart';
import '../../../domain/mission.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderDashboardProvider>();
    final tr = context.tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, provider, tr),
        const SizedBox(height: 20),
        _buildMetricsGrid(context, provider, tr),
        const SizedBox(height: 24),
        _buildMissionsSection(context, provider, tr),
        const SizedBox(height: 20),
        _buildBottomRow(context, provider, tr),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ProviderDashboardProvider provider, String Function(String) tr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('provider.greeting'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                fontFamily: 'Sora',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr('provider.greetingSub'),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildQuickAction(context, Icons.calendar_today_rounded, tr('provider.planningComplet'), () {}),
            const SizedBox(width: 8),
            _buildQuickAction(context, Icons.add_rounded, tr('provider.nouvelleMission'), () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return PointerCursor(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, ProviderDashboardProvider provider, String Function(String) tr) {
    final p = provider.profile;
    final metrics = [
      _MetricData(tr('provider.metricMissions'), '${provider.missionsDuJourCount}', tr('provider.changeMissions'), Icons.rocket_launch_rounded, const Color(0xFF2563EB)),
      _MetricData(tr('provider.metricRevenus'), '${p.revenuMensuel.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA', tr('provider.changeRevenus'), Icons.trending_up_rounded, const Color(0xFF16A34A)),
      _MetricData(tr('provider.metricRealisees'), '${p.missionsRealisees}', tr('provider.changeRealisees'), Icons.task_alt_rounded, const Color(0xFFF59E0B)),
      _MetricData(tr('provider.metricSatisfaction'), '${p.tauxSatisfaction.toStringAsFixed(0)}%', '${p.note}/5', Icons.emoji_emotions_rounded, const Color(0xFF8B5CF6)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) => _buildMetricCard(metrics[index]),
        );
      },
    );
  }

  Widget _buildMetricCard(_MetricData data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontFamily: 'DM Sans',
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, size: 16, color: data.color),
              ),
            ],
          ),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              fontFamily: 'Sora',
            ),
          ),
          Text(
            data.change,
            style: TextStyle(
              fontSize: 11,
              color: data.color,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsSection(BuildContext context, ProviderDashboardProvider provider, String Function(String) tr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('provider.missionsJour'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                  fontFamily: 'Sora',
                ),
              ),
              TextButton(
                onPressed: () => context.read<ProviderDashboardProvider>().setSelectedIndex(2),
                child: Text(
                  tr('provider.voirTout'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2563EB),
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (provider.missionsDuJour.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  tr('provider.aucuneMission'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: provider.missionsDuJour
                        .map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildMobileMissionCard(m, context, provider),
                            ))
                        .toList(),
                  );
                }
                return Column(
                  children: [
                    _buildTableHeader(tr),
                    const Divider(color: Color(0xFFE8ECF2)),
                    ...provider.missionsDuJour.map((m) => _buildTableRow(m, context, provider)),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String Function(String) tr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _tableCell(tr('provider.colClient'), 0.2, isHeader: true),
          _tableCell(tr('provider.colService'), 0.2, isHeader: true),
          _tableCell(tr('provider.colHeure'), 0.15, isHeader: true),
          _tableCell(tr('provider.colMontant'), 0.15, isHeader: true),
          _tableCell(tr('provider.colStatut'), 0.15, isHeader: true),
          _tableCell('', 0.15),
        ],
      ),
    );
  }

  Widget _buildTableRow(Mission mission, BuildContext context, ProviderDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          _tableCell(mission.clientNomComplet, 0.2),
          _tableCell(mission.service, 0.2),
          _tableCell('${mission.heureDebut.hour.toString().padLeft(2, '0')}:${mission.heureDebut.minute.toString().padLeft(2, '0')}', 0.15),
          _tableCell('${mission.montant.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA', 0.15),
          _tableCell('', 0.15, child: _buildStatusBadge(mission.statut)),
          _tableCell('', 0.15, child: _buildRowActions(mission, context, provider)),
        ],
      ),
    );
  }

  Widget _tableCell(String text, double flex, {bool isHeader = false, Widget? child}) {
    return Expanded(
      flex: (flex * 100).round(),
      child: child ??
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
              color: isHeader ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              fontFamily: 'DM Sans',
            ),
          ),
    );
  }

  Widget _buildMobileMissionCard(Mission mission, BuildContext context, ProviderDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mission.clientNomComplet,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                  fontFamily: 'Sora',
                ),
              ),
              _buildStatusBadge(mission.statut),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.work_outline, size: 13, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(mission.service, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'DM Sans')),
              const Spacer(),
              const Icon(Icons.access_time, size: 13, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text('${mission.heureDebut.hour.toString().padLeft(2, '0')}:${mission.heureDebut.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'DM Sans')),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${mission.montant.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF16A34A), fontFamily: 'Sora')),
              _buildRowActions(mission, context, provider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(MissionStatus status) {
    final data = switch (status) {
      MissionStatus.confirmed => ('Confirmé', const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
      MissionStatus.pending => ('En attente', const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
      MissionStatus.completed => ('Terminé', const Color(0xFF64748B), const Color(0xFFF1F5F9)),
      MissionStatus.cancelled => ('Annulé', const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: data.$3,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        data.$1,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: data.$2,
          fontFamily: 'DM Sans',
        ),
      ),
    );
  }

  Widget _buildRowActions(Mission mission, BuildContext context, ProviderDashboardProvider provider) {
    if (mission.statut == MissionStatus.pending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _actionButton(Icons.check_circle_outline, const Color(0xFF16A34A), () {
            provider.accepterMission(mission.id);
          }),
          const SizedBox(width: 4),
          _actionButton(Icons.cancel_outlined, const Color(0xFFEF4444), () {
            provider.annulerMission(mission.id);
          }),
        ],
      );
    }
    if (mission.statut == MissionStatus.confirmed) {
      return _actionButton(Icons.task_alt_rounded, const Color(0xFF2563EB), () {
        provider.completerMission(mission.id);
      });
    }
    return const SizedBox.shrink();
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return PointerCursor(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }

  Widget _buildBottomRow(BuildContext context, ProviderDashboardProvider provider, String Function(String) tr) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              _buildAvailabilityCard(provider, tr),
              const SizedBox(height: 12),
              _buildRequestsCard(context, provider, tr),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: _buildAvailabilityCard(provider, tr)),
            const SizedBox(width: 12),
            Expanded(child: _buildRequestsCard(context, provider, tr)),
          ],
        );
      },
    );
  }

  Widget _buildAvailabilityCard(ProviderDashboardProvider provider, String Function(String) tr) {
    final p = provider.profile;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('provider.disponibilite'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontFamily: 'Sora',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('provider.statutActuel'),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontFamily: 'DM Sans',
                ),
              ),
              Switch(
                value: p.disponible,
                onChanged: (_) => provider.toggleDisponibilite(),
                activeColor: const Color(0xFF16A34A),
                inactiveThumbColor: const Color(0xFFEF4444),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                p.disponible ? Icons.check_circle : Icons.cancel,
                size: 14,
                color: p.disponible ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
              ),
              const SizedBox(width: 6),
              Text(
                p.disponible ? tr('provider.vousEtesDisponible') : tr('provider.vousEtesIndisponible'),
                style: TextStyle(
                  fontSize: 12,
                  color: p.disponible ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsCard(BuildContext context, ProviderDashboardProvider provider, String Function(String) tr) {
    final demandes = provider.missionsEnAttente;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('provider.nouvellesDemandes'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontFamily: 'Sora',
            ),
          ),
          const SizedBox(height: 12),
          if (demandes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                tr('provider.aucuneDemande'),
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontFamily: 'DM Sans'),
              ),
            )
          else
            ...demandes.map((m) => _buildRequestItem(m, context, provider)),
        ],
      ),
    );
  }

  Widget _buildRequestItem(Mission mission, BuildContext context, ProviderDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFEFF6FF),
            child: Text(
              mission.clientInitiales,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
                fontFamily: 'Sora',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.service,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontFamily: 'DM Sans',
                  ),
                ),
                Text(
                  '${mission.clientNomComplet} · ${mission.montant.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
          _actionButton(Icons.check_circle_outline, const Color(0xFF16A34A), () {
            provider.accepterMission(mission.id);
          }),
        ],
      ),
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final String change;
  final IconData icon;
  final Color color;

  const _MetricData(this.label, this.value, this.change, this.icon, this.color);
}
