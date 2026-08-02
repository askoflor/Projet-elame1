import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/localization/translation_provider.dart';
import '../../../../../core/widgets/micro_interactions.dart';
import '../../../../../core/utils/hour_range_formatter.dart';
import '../../../state/provider_dashboard_state.dart';
import '../../../../intervention/domain/intervention.dart';
import '../../../../intervention/state/intervention_provider.dart';
import '../../../../intervention/presentation/widgets/chiffrage_modal.dart';
import '../../../../intervention/presentation/widgets/completion_modal.dart';
import '../../../../../core/widgets/axis_line_chart.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  DateTimeRange? _selectedRange;
  static const _windowDays = 7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InterventionProvider>().chargerMesInterventions();
    });
  }

  DateTime _defaultDate(List<Intervention> all) {
    if (all.isEmpty) return DateTime.now();
    final dates = all.map((i) => DateTime(i.date.year, i.date.month, i.date.day)).toList()..sort();
    return dates.last;
  }

  DateTimeRange _defaultRange(List<Intervention> all) {
    final end = DateTime(_defaultDate(all).year, _defaultDate(all).month, _defaultDate(all).day);
    return DateTimeRange(start: end.subtract(const Duration(days: _windowDays - 1)), end: end);
  }

  Future<void> _pickRange(BuildContext context, List<Intervention> all) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _selectedRange ?? _defaultRange(all),
    );
    if (picked != null) setState(() => _selectedRange = picked);
  }

  List<DateTime> _daysIn(DateTimeRange range) {
    final days = <DateTime>[];
    var d = DateTime(range.start.year, range.start.month, range.start.day);
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    while (!d.isAfter(end)) {
      days.add(d);
      d = d.add(const Duration(days: 1));
    }
    if (days.isEmpty) days.add(end);
    return days;
  }

  List<MapEntry<DateTime, double>> _gainSeries(List<Intervention> all, DateTimeRange range) {
    return _daysIn(range).map((day) {
      final sum = all.where((i) {
        final d = DateTime(i.date.year, i.date.month, i.date.day);
        return !d.isAfter(day) && i.montant != null && i.statut != InterventionStatus.annulee;
      }).fold<double>(0, (s, i) => s + i.montant!);
      return MapEntry(day, sum);
    }).toList();
  }

  List<MapEntry<DateTime, double>> _missionsSeries(List<Intervention> all, DateTimeRange range) {
    return _daysIn(range).map((day) {
      final count = all.where((i) {
        final d = DateTime(i.date.year, i.date.month, i.date.day);
        return !d.isAfter(day) && i.statut == InterventionStatus.terminee;
      }).length;
      return MapEntry(day, count.toDouble());
    }).toList();
  }

  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderDashboardProvider>();
    final interventions = context.watch<InterventionProvider>();
    final tr = context.tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, provider, interventions, tr),
        const SizedBox(height: 20),
        _buildMetricsSection(context, interventions, tr),
        const SizedBox(height: 24),
        _buildInterventionsSection(context, interventions, tr),
        const SizedBox(height: 20),
        _buildBottomRow(context, provider, interventions, tr),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ProviderDashboardProvider provider,
      InterventionProvider interventions, String Function(String) tr) {
    final aChiffrer = interventions.enAttente.length;
    final headline = aChiffrer > 0
        ? tr('intervention.aChiffrer').replaceFirst('{0}', '$aChiffrer').replaceFirst('{1}', aChiffrer > 1 ? 's' : '')
        : tr('intervention.aucuneEnAttente');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('provider.dashboardTitle'),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            fontFamily: 'Sora',
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          headline,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontFamily: 'DM Sans',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsSection(BuildContext context, InterventionProvider interventions, String Function(String) tr) {
    final all = interventions.all;
    final range = _selectedRange ?? _defaultRange(all);
    final gainSeries = _gainSeries(all, range);
    final missionsSeries = _missionsSeries(all, range);
    final enCoursCount = interventions.enCours.length;
    final enCoursRatio = enCoursCount == 0 ? 0.05 : (enCoursCount / (enCoursCount + 3)).clamp(0.1, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              tr('intervention.apercu'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontFamily: 'Sora'),
            ),
            OutlinedButton.icon(
              onPressed: () => _pickRange(context, all),
              icon: const Icon(Icons.calendar_today_rounded, size: 14),
              label: Text('${_fmtDate(range.start)} — ${_fmtDate(range.end)}', style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final gainChart = _buildChartCard(tr('provider.metricRevenus'), gainSeries, const Color(0xFF16A34A), 10000, isCurrency: true);
            final missionsChart = _buildChartCard(tr('provider.metricRealisees'), missionsSeries, const Color(0xFF2563EB), 5);
            final enCoursCard = _buildProgressCard(tr('intervention.tachesEnCours'), '$enCoursCount', enCoursRatio.toDouble(), const Color(0xFFF97316));
            final cards = [gainChart, missionsChart, enCoursCard];
            if (constraints.maxWidth > 1100) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 16),
                      Expanded(child: cards[i]),
                    ],
                  ],
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  cards[i],
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildChartCard(String title, List<MapEntry<DateTime, double>> series, Color color, double step, {bool isCurrency = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontFamily: 'DM Sans')),
          const SizedBox(height: 8),
          AxisLineChart(
            points: series,
            color: color,
            yStep: step,
            height: 190,
            yLabelFormatter: isCurrency ? (v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : v.toStringAsFixed(0) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, String value, double ratio, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontFamily: 'DM Sans')),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF1E293B), fontFamily: 'Sora')),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(color: const Color(0xFFE8ECF2), borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterventionsSection(
      BuildContext context, InterventionProvider interventions, String Function(String) tr) {
    final mesMissions = interventions.all;

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
          Text(
            tr('provider.missionsJour'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontFamily: 'Sora',
            ),
          ),
          const SizedBox(height: 14),
          if (mesMissions.isEmpty)
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
                if (constraints.maxWidth < 700) {
                  return Column(
                    children: mesMissions
                        .map((i) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildMobileInterventionCard(i, context),
                            ))
                        .toList(),
                  );
                }
                return _buildMissionsDataTable(context, mesMissions, constraints.maxWidth);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMissionsDataTable(BuildContext context, List<Intervention> mesMissions, double maxWidth) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: maxWidth),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFFAFAFA)),
            columnSpacing: 20,
            columns: [
              DataColumn(label: Text(context.tr('intervention.colClient'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
              DataColumn(label: Text(context.tr('intervention.colService'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
              DataColumn(label: Text(context.tr('intervention.colDate'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
              DataColumn(label: Text(context.tr('intervention.colMontant'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
              DataColumn(label: Text(context.tr('intervention.colStatut'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
              const DataColumn(label: Text('')),
            ],
            rows: mesMissions.map((i) => DataRow(cells: [
                  DataCell(SizedBox(
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(i.clientNom, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontFamily: 'DM Sans')),
                        Text('${i.reference} · ${i.adresse}', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontFamily: 'DM Sans'), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  )),
                  DataCell(Text(i.service, style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), fontFamily: 'DM Sans'))),
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${i.date.day}/${i.date.month}/${i.date.year}', style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontFamily: 'DM Sans')),
                      Text(formatHourRanges(i.heures), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontFamily: 'DM Sans')),
                    ],
                  )),
                  DataCell(Text(i.montant == null ? '—' : '${i.montant!.toStringAsFixed(0)} FCFA', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontFamily: 'DM Sans'))),
                  DataCell(buildInterventionStatusBadge(context, i.statut)),
                  DataCell(_buildRowActions(i, context)),
                ])).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileInterventionCard(Intervention i, BuildContext context) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i.clientNom,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontFamily: 'Sora'),
                    ),
                    Text('${i.reference} · ${i.adresse}',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontFamily: 'DM Sans'),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              buildInterventionStatusBadge(context, i.statut),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.work_outline, size: 13, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(i.service, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'DM Sans')),
              const Spacer(),
              Text('${i.date.day}/${i.date.month}/${i.date.year} · ${formatHourRanges(i.heures)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'DM Sans')),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(i.montant == null ? '—' : '${i.montant!.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF16A34A), fontFamily: 'Sora')),
              _buildRowActions(i, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRowActions(Intervention i, BuildContext context) {
    if (i.statut == InterventionStatus.attente) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () => ChiffrageModal.show(context, i),
            icon: const Icon(Icons.phone_outlined, size: 14),
            label: Text(context.tr('intervention.chiffrerBtn'), style: const TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(0, 30),
            ),
          ),
          const SizedBox(width: 4),
          _actionButton(Icons.cancel_outlined, const Color(0xFFEF4444),
              () => context.read<InterventionProvider>().annuler(i.reference)),
        ],
      );
    }
    if (i.statut == InterventionStatus.encours) {
      return OutlinedButton(
        onPressed: () => CompletionModal.show(context, i),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(0, 30),
        ),
        child: Text(context.tr('intervention.terminerBtn'), style: const TextStyle(fontSize: 12)),
      );
    }
    if (i.statut == InterventionStatus.terminee) {
      return Text(context.tr('intervention.cloturee'), style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontFamily: 'DM Sans'));
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

  Widget _buildBottomRow(BuildContext context, ProviderDashboardProvider provider,
      InterventionProvider interventions, String Function(String) tr) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              _buildAvailabilityCard(provider, tr),
              const SizedBox(height: 12),
              _buildRequestsCard(context, interventions, tr),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: _buildAvailabilityCard(provider, tr)),
            const SizedBox(width: 12),
            Expanded(child: _buildRequestsCard(context, interventions, tr)),
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
                activeThumbColor: const Color(0xFF16A34A),
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

  Widget _buildRequestsCard(
      BuildContext context, InterventionProvider interventions, String Function(String) tr) {
    final demandes = interventions.enAttente;
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
            ...demandes.map((i) => _buildRequestItem(i, context)),
        ],
      ),
    );
  }

  Widget _buildRequestItem(Intervention i, BuildContext context) {
    final tr = context.tr;
    final isUrgent = i.urgence != 'Planifié';
    final montantLabel = i.montant != null ? '${i.montant!.toStringAsFixed(0)} FCFA' : tr('intervention.montantADefinir');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isUrgent ? const Color(0xFFFFF7ED) : const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUrgent ? Icons.warning_amber_rounded : Icons.work_outline_rounded,
              size: 16,
              color: isUrgent ? const Color(0xFFF97316) : const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUrgent ? '${tr('intervention.missionUrgente')} – ${i.clientNom}' : '${tr('intervention.nouvelleMission')} – ${i.clientNom}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontFamily: 'DM Sans',
                  ),
                ),
                Text(
                  '${i.service} · $montantLabel',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: () => ChiffrageModal.show(context, i),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(0, 30),
            ),
            child: Text(isUrgent ? tr('provider.accepter') : tr('provider.voir'), style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

/// Badge de statut réutilisé par les tableaux d'intervention (dashboard,
/// missions, historique).
Widget buildInterventionStatusBadge(BuildContext context, InterventionStatus status) {
  final data = switch (status) {
    InterventionStatus.attente => (context.tr('intervention.statutAttente'), const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
    InterventionStatus.encours => (context.tr('intervention.statutEnCours'), const Color(0xFF2563EB), const Color(0xFFDBEAFE)),
    InterventionStatus.terminee => (context.tr('intervention.statutTerminee'), const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
    InterventionStatus.annulee => (context.tr('intervention.statutAnnulee'), const Color(0xFF64748B), const Color(0xFFF1F5F9)),
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

