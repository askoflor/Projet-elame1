import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/localization/translation_provider.dart';
import '../../../state/provider_dashboard_state.dart';
import '../../../../intervention/domain/intervention.dart';
import '../../../../intervention/state/intervention_provider.dart';

const Color _primary = Color(0xFF2563EB);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const Color _textMuted = Color(0xFF94A3B8);
const Color _border = Color(0xFFE8ECF2);
const Color _success = Color(0xFF16A34A);
const Color _warning = Color(0xFFF59E0B);
const Color _purple = Color(0xFF8B5CF6);

class StatistiquesContent extends StatelessWidget {
  const StatistiquesContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderDashboardProvider>();
    final interventions = context.watch<InterventionProvider>();
    final tr = context.tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(tr),
        const SizedBox(height: 20),
        _buildPerfCards(provider, interventions, tr),
        const SizedBox(height: 24),
        _buildStatsGrid(provider, interventions, tr),
      ],
    );
  }

  Widget _buildHeader(String Function(String) tr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('provider.statistiques'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary, fontFamily: 'Sora'),
        ),
        const SizedBox(height: 4),
        Text(
          tr('provider.statistiquesSub'),
          style: const TextStyle(fontSize: 13, color: _textSecondary, fontFamily: 'DM Sans'),
        ),
      ],
    );
  }

  Widget _buildPerfCards(ProviderDashboardProvider provider, InterventionProvider interventions, String Function(String) tr) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          children: [
            _perfCard(tr('provider.tauxSucces'), '${((provider.profile.missionsRealisees / math.max(provider.profile.missionsTotal, 1)) * 100).toStringAsFixed(1)}%', Icons.verified_rounded, _success, 0.91),
            _perfCard(tr('provider.tauxCompletion'), '${((interventions.missionsEnCours.length / math.max(interventions.mesMissions.length, 1)) * 100).toStringAsFixed(1)}%', Icons.task_alt_rounded, _primary, 0.78),
            _perfCard(tr('provider.satisfaction'), '${provider.profile.tauxSatisfaction.toStringAsFixed(0)}%', Icons.emoji_emotions_rounded, _warning, 0.97),
            _perfCard(tr('provider.noteMoyenne'), provider.profile.note.toStringAsFixed(1), Icons.star_rounded, _purple, 0.96),
          ],
        );
      },
    );
  }

  Widget _perfCard(String label, String value, IconData icon, Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: _textSecondary, fontFamily: 'DM Sans')),
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: color)),
            ],
          ),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color, fontFamily: 'Sora')),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ProviderDashboardProvider provider, InterventionProvider interventions, String Function(String) tr) {
    final p = provider.profile;
    final annulees = interventions.mesMissions.where((i) => i.statut == InterventionStatus.annulee).length;
    final stats = [
      _StatItem(tr('provider.totalMissions'), '${p.missionsTotal}', Icons.work_history_rounded, _primary),
      _StatItem(tr('provider.missionsRealisees'), '${interventions.missionsTerminees.length}', Icons.task_alt_rounded, _success),
      _StatItem(tr('provider.missionsEnAttente'), '${interventions.missionsEnAttente.length}', Icons.pending_actions_rounded, _warning),
      _StatItem(tr('provider.missionsAnnulees'), '$annulees', Icons.cancel_outlined, const Color(0xFFEF4444)),
      _StatItem(tr('provider.nombreClients'), '24', Icons.people_rounded, const Color(0xFF06B6D4)),
      _StatItem(tr('provider.tauxFidelite'), '92%', Icons.favorite_rounded, const Color(0xFFEC4899)),
      _StatItem(tr('provider.tempsMoyen'), '2.5 h', Icons.access_time_rounded, _purple),
      _StatItem(tr('provider.revenuMoyen'), '${p.revenuMensuel ~/ math.max(p.missionsTotal, 1)} FCFA', Icons.monetization_on_rounded, const Color(0xFFF97316)),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('provider.statistiquesDetail'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary, fontFamily: 'Sora')),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
              return GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                children: stats.map((s) => _singleStat(s)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _singleStat(_StatItem item) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: item.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(item.icon, size: 18, color: item.color)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: item.color, fontFamily: 'Sora')),
              Text(item.label, style: const TextStyle(fontSize: 11, color: _textMuted, fontFamily: 'DM Sans')),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}
