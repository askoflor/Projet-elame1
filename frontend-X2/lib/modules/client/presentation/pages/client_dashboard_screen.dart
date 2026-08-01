import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../home/presentation/widgets/header/nav_bar.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/hour_range_formatter.dart';
import '../../../auth/domain/auth_provider.dart';
import '../../../intervention/domain/intervention.dart';
import '../../../intervention/state/intervention_provider.dart';
import '../../../intervention/presentation/widgets/notation_dialog.dart';
import '../../../provider/presentation/widgets/dashboard/dashboard_content.dart' show buildInterventionStatusBadge;
import '../../../../core/widgets/axis_line_chart.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  DateTime? _selectedDate;
  static const _windowDays = 7;

  DateTime _defaultDate(List<Intervention> all) {
    if (all.isEmpty) return DateTime.now();
    final dates = all.map((i) => DateTime(i.date.year, i.date.month, i.date.day)).toList()..sort();
    return dates.last;
  }

  DateTimeRange _rangeForDate(DateTime date) {
    final end = DateTime(date.year, date.month, date.day);
    return DateTimeRange(start: end.subtract(const Duration(days: _windowDays - 1)), end: end);
  }

  Future<void> _pickDate(BuildContext context, List<Intervention> all) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDate: _selectedDate ?? _defaultDate(all),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const NavBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final horizontalPadding = constraints.maxWidth < 600 ? 14.0 : 24.0;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 28),
                          _buildTrendsSection(context),
                          const SizedBox(height: 28),
                          _buildInterventionsTableSection(context),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final prenom = context.watch<AuthProvider>().user?.prenom ?? 'Marie';
    return StaggeredFadeIn(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${context.tr('client.bonjourPrefix')} $prenom \u{1F44B}',
              style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr('client.subtitle'),
              style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendsSection(BuildContext context) {
    final all = context.watch<InterventionProvider>().all;
    final selected = _selectedDate ?? _defaultDate(all);
    final range = _rangeForDate(selected);
    final taskSeries = _taskSeries(all, range);
    final expenseSeries = _expenseSeries(all, range);
    final enCoursSeries = _enCoursSeries(all, range);

    return StaggeredFadeIn(
      staggerDelay: const Duration(milliseconds: 120),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(context.tr('client.evolution'), style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                OutlinedButton.icon(
                  onPressed: () => _pickDate(context, all),
                  icon: const Icon(Icons.calendar_today_rounded, size: 14),
                  label: Text(_fmtDate(selected), style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final tasksChart = _buildChartCard(context.tr('client.tachesAttribuees'), taskSeries, const Color(0xFF2563EB), 5);
                final expenseChart = _buildChartCard(context.tr('client.fcfaDepenses'), expenseSeries, const Color(0xFF059669), 10000, isCurrency: true);
                final enCoursChart = _buildChartCard(context.tr('client.enCours'), enCoursSeries, const Color(0xFFF97316), 5);
                final charts = [tasksChart, expenseChart, enCoursChart];
                if (constraints.maxWidth > 1100) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < charts.length; i++) ...[
                        if (i > 0) const SizedBox(width: 16),
                        Expanded(child: charts[i]),
                      ],
                    ],
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < charts.length; i++) ...[
                      if (i > 0) const SizedBox(height: 16),
                      charts[i],
                    ],
                  ],
                );
              },
            ),
          ],
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
          Text(title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
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

  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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

  List<MapEntry<DateTime, double>> _taskSeries(List<Intervention> all, DateTimeRange range) {
    return _daysIn(range).map((day) {
      final count = all.where((i) {
        final d = DateTime(i.date.year, i.date.month, i.date.day);
        return !d.isAfter(day);
      }).length;
      return MapEntry(day, count.toDouble());
    }).toList();
  }

  List<MapEntry<DateTime, double>> _expenseSeries(List<Intervention> all, DateTimeRange range) {
    return _daysIn(range).map((day) {
      final sum = all.where((i) {
        final d = DateTime(i.date.year, i.date.month, i.date.day);
        return !d.isAfter(day) && i.montant != null && i.statut != InterventionStatus.annulee;
      }).fold<double>(0, (s, i) => s + i.montant!);
      return MapEntry(day, sum);
    }).toList();
  }

  List<MapEntry<DateTime, double>> _enCoursSeries(List<Intervention> all, DateTimeRange range) {
    return _daysIn(range).map((day) {
      final count = all.where((i) {
        final d = DateTime(i.date.year, i.date.month, i.date.day);
        return !d.isAfter(day) && i.statut == InterventionStatus.encours;
      }).length;
      return MapEntry(day, count.toDouble());
    }).toList();
  }

  Widget _buildInterventionsTableSection(BuildContext context) {
    final interventions = context.watch<InterventionProvider>().all;

    return StaggeredFadeIn(
      staggerDelay: const Duration(milliseconds: 140),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('client.mesInterventions'),
              style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            if (interventions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(context.tr('client.aucuneIntervention'), style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF94A3B8))),
                ),
              )
            else
              _buildInterventionsTable(context, interventions),
          ],
        ),
      ],
    );
  }

  Widget _buildInterventionsTable(BuildContext context, List<Intervention> interventions) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            children: interventions.map((i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildMobileRow(context, i))).toList(),
          );
        }
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8ECF2)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFFAFAFA)),
                columnSpacing: 24,
                columns: [
                  DataColumn(label: Text(context.tr('client.prestataire'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                  DataColumn(label: Text(context.tr('client.service'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                  DataColumn(label: Text(context.tr('client.date'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                  DataColumn(label: Text(context.tr('client.montant'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                  DataColumn(label: Text(context.tr('client.statut'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                  const DataColumn(label: Text('')),
                ],
                rows: interventions.map((i) => DataRow(cells: [
                      DataCell(Text('${i.providerName}\n${i.reference}', style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)))),
                      DataCell(_serviceCell(i)),
                      DataCell(Text('${i.date.day}/${i.date.month}/${i.date.year}\n${formatHourRanges(i.heures)}', style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)))),
                      DataCell(Text(i.montant == null ? '—' : '${i.montant!.toStringAsFixed(0)} FCFA', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)))),
                      DataCell(buildInterventionStatusBadge(context, i.statut)),
                      DataCell(_buildAction(context, i)),
                    ])).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _serviceCell(Intervention i) {
    const urgencyColors = {'Urgent': Color(0xFFD97706), 'Très urgent': Color(0xFFEF4444)};
    final dotColor = urgencyColors[i.urgence] ?? const Color(0xFF94A3B8);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, margin: const EdgeInsets.only(right: 5), decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        Text(i.service, style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildAction(BuildContext context, Intervention i) {
    switch (i.statut) {
      case InterventionStatus.attente:
        return Text(context.tr('client.enAttenteAppel'), style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)));
      case InterventionStatus.encours:
        return ElevatedButton(
          onPressed: () => context.push('/paiement', extra: i),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white, minimumSize: const Size(0, 32)),
          child: Text(context.tr('client.payerBtn'), style: const TextStyle(fontSize: 12)),
        );
      case InterventionStatus.terminee:
        return OutlinedButton(
          onPressed: () async {
            final result = await NotationDialog.show(context, i.providerName);
            if (result != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('client.merciNote').replaceFirst('{0}', '${result.rating}'))),
              );
            }
          },
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 32)),
          child: Text(context.tr('client.noterBtn'), style: const TextStyle(fontSize: 12)),
        );
      case InterventionStatus.annulee:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMobileRow(BuildContext context, Intervention i) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8ECF2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(i.providerName, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              ),
              buildInterventionStatusBadge(context, i.statut),
            ],
          ),
          const SizedBox(height: 4),
          Text('${i.service} · ${i.date.day}/${i.date.month}/${i.date.year} · ${formatHourRanges(i.heures)}',
              style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF94A3B8))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(i.montant == null ? '—' : '${i.montant!.toStringAsFixed(0)} FCFA',
                  style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB))),
              _buildAction(context, i),
            ],
          ),
        ],
      ),
    );
  }
}
