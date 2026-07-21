import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../home/presentation/widgets/header/nav_bar.dart';
import '../../../../core/widgets/app_back_button.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/hour_range_formatter.dart';
import '../../../auth/domain/auth_provider.dart';
import '../../../intervention/domain/intervention.dart';
import '../../../intervention/state/intervention_provider.dart';
import '../../../provider/presentation/widgets/dashboard/dashboard_content.dart' show buildInterventionStatusBadge;

class ClientDashboardScreen extends StatelessWidget {
  const ClientDashboardScreen({super.key});

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
                          const Align(alignment: Alignment.centerLeft, child: AppBackButton()),
                          const SizedBox(height: 20),
                          _buildHeader(context),
                          const SizedBox(height: 28),
                          _buildStatsGrid(context),
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
              'Bonjour, $prenom \u{1F44B}',
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

  Widget _buildStatsGrid(BuildContext context) {
    final interventions = context.watch<InterventionProvider>().all;
    final total = interventions.length;
    final enCours = interventions.where((i) => i.statut == InterventionStatus.encours).length;
    final depense = interventions
        .where((i) => i.montant != null && i.statut != InterventionStatus.annulee)
        .fold<double>(0, (sum, i) => sum + i.montant!);
    final depenseFormatted = depense.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');

    return StaggeredFadeIn(
      staggerDelay: const Duration(milliseconds: 100),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _buildStatCard(
                context,
                icon: Icons.build_rounded,
                value: '$total',
                label: context.tr('client.interventionsTotales'),
                color: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF4FF),
                badge: context.tr('client.plusCeMois'),
                badgeUp: true,
                chartWidth: total == 0 ? 0.05 : (total / (total + 5)).clamp(0.1, 1.0),
              ),
              _buildStatCard(
                context,
                icon: Icons.access_time_rounded,
                value: '$enCours',
                label: context.tr('client.enCours'),
                color: const Color(0xFFF97316),
                bgColor: const Color(0xFFFFF7ED),
                badge: context.tr('client.activesBadge'),
                badgeUp: true,
                chartWidth: enCours == 0 ? 0.05 : (enCours / (enCours + 3)).clamp(0.1, 1.0),
              ),
              _buildStatCard(
                context,
                icon: Icons.payments_rounded,
                value: depenseFormatted,
                label: context.tr('client.fcfaDepenses'),
                color: const Color(0xFF059669),
                bgColor: const Color(0xFFECFDF5),
                badge: context.tr('client.ceMois'),
                badgeUp: true,
                chartWidth: depense == 0 ? 0.05 : 0.55,
              ),
              _buildStatCard(
                context,
                icon: Icons.star_rounded,
                value: '4.8',
                label: context.tr('client.noteMoyenne'),
                color: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFF3F0FF),
                chartWidth: 0.96,
              ),
            ];
            final crossAxisCount = constraints.maxWidth > 700 ? 4 : (constraints.maxWidth > 460 ? 2 : 1);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: crossAxisCount == 1 ? 2.2 : 1.35,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) => cards[index],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
    String? badge,
    bool badgeUp = false,
    double? chartWidth,
  }) {
    return SlideOnHover(
      offset: const Offset(0, -0.04),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8ECF2), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeUp ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: badgeUp ? const Color(0xFF059669) : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF64748B))),
            if (chartWidth != null) ...[
              const SizedBox(height: 12),
              Container(
                height: 6,
                decoration: BoxDecoration(color: const Color(0xFFE8ECF2), borderRadius: BorderRadius.circular(3)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: chartWidth.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInterventionsTableSection(BuildContext context) {
    final interventions = context.watch<InterventionProvider>().all;

    return StaggeredFadeIn(
      staggerDelay: const Duration(milliseconds: 140),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('client.mesInterventions'),
                  style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                ),
                HoverWrap(
                  scale: 1.05,
                  child: PointerCursor(
                    child: TextButton(
                      onPressed: () => context.push('/historique'),
                      child: Text(
                        context.tr('client.voirTout'),
                        style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)),
                      ),
                    ),
                  ),
                ),
              ],
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
                columns: const [
                  DataColumn(label: Text('Prestataire', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                  DataColumn(label: Text('Service', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                  DataColumn(label: Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                  DataColumn(label: Text('Montant', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                  DataColumn(label: Text('Statut', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
                  DataColumn(label: Text('')),
                ],
                rows: interventions.map((i) => DataRow(cells: [
                      DataCell(Text('${i.providerName}\n${i.reference}', style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)))),
                      DataCell(_serviceCell(i)),
                      DataCell(Text('${i.date.day}/${i.date.month}/${i.date.year}\n${formatHourRanges(i.heures)}', style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)))),
                      DataCell(Text(i.montant == null ? '—' : '${i.montant!.toStringAsFixed(0)} FCFA', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)))),
                      DataCell(buildInterventionStatusBadge(i.statut)),
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
        return const Text('En attente de l\'appel', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)));
      case InterventionStatus.encours:
        return ElevatedButton(
          onPressed: () => context.push('/paiement', extra: i),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white, minimumSize: const Size(0, 32)),
          child: const Text('Payer', style: TextStyle(fontSize: 12)),
        );
      case InterventionStatus.terminee:
        return OutlinedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notation de l\'intervention'))),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 32)),
          child: const Text('Noter', style: TextStyle(fontSize: 12)),
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
              buildInterventionStatusBadge(i.statut),
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
