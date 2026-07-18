import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/localization/translation_provider.dart';
import '../../../../../core/widgets/micro_interactions.dart';
import '../../../state/provider_dashboard_state.dart';
import '../../../domain/mission.dart';

const Color _primary = Color(0xFF2563EB);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const Color _textMuted = Color(0xFF94A3B8);
const Color _border = Color(0xFFE8ECF2);
const Color _success = Color(0xFF16A34A);
const Color _warning = Color(0xFFF59E0B);
const Color _error = Color(0xFFEF4444);

class MissionsContent extends StatefulWidget {
  const MissionsContent({super.key});

  @override
  State<MissionsContent> createState() => _MissionsContentState();
}

class _MissionsContentState extends State<MissionsContent> {
  int _selectedFilter = 0;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final _filters = ['Toutes', 'Confirmées', 'En attente', 'Terminées', 'Annulées'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Mission> _filteredMissions(ProviderDashboardProvider provider) {
    var missions = provider.toutesMissions;
    switch (_selectedFilter) {
      case 1:
        missions = missions.where((m) => m.statut == MissionStatus.confirmed).toList();
        break;
      case 2:
        missions = missions.where((m) => m.statut == MissionStatus.pending).toList();
        break;
      case 3:
        missions = missions.where((m) => m.statut == MissionStatus.completed).toList();
        break;
      case 4:
        missions = missions.where((m) => m.statut == MissionStatus.cancelled).toList();
        break;
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      missions = missions.where((m) =>
          m.clientNomComplet.toLowerCase().contains(q) ||
          m.service.toLowerCase().contains(q)).toList();
    }
    return missions;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderDashboardProvider>();
    final tr = context.tr;
    final missions = _filteredMissions(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(tr, provider),
        const SizedBox(height: 16),
        _buildFilters(tr),
        const SizedBox(height: 16),
        _buildSearchBar(tr),
        const SizedBox(height: 16),
        if (missions.isEmpty)
          _buildEmptyState(tr)
        else
          _buildMissionsList(missions, context, provider, tr),
      ],
    );
  }

  Widget _buildHeader(String Function(String) tr, ProviderDashboardProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('provider.mesMissions'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                fontFamily: 'Sora',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${provider.missionsCount} ${tr('provider.missionsTotal')}',
              style: const TextStyle(fontSize: 13, color: _textSecondary, fontFamily: 'DM Sans'),
            ),
          ],
        ),
        Row(
          children: [
            _buildStatBadge(tr('provider.confirmees'), provider.missionsConfirmes.length, _success),
            const SizedBox(width: 8),
            _buildStatBadge(tr('provider.enAttente'), provider.missionsEnAttente.length, _warning),
            const SizedBox(width: 8),
            _buildStatBadge(tr('provider.terminees'), provider.missionsTerminees.length, _textMuted),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Sora',
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontFamily: 'DM Sans'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(String Function(String) tr) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final index = _filters.indexOf(filter);
          final isSelected = _selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PointerCursor(
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _primary : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? _primary : _border,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : _textSecondary,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar(String Function(String) tr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: _textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: tr('provider.rechercherMission'),
                hintStyle: const TextStyle(fontSize: 13, color: _textMuted, fontFamily: 'DM Sans'),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              style: const TextStyle(fontSize: 13, fontFamily: 'DM Sans', color: _textPrimary),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Icon(Icons.close_rounded, size: 16, color: _textMuted),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String Function(String) tr) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: _textMuted.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              tr('provider.aucuneMissionTrouvee'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _textSecondary, fontFamily: 'DM Sans'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionsList(List<Mission> missions, BuildContext context, ProviderDashboardProvider provider, String Function(String) tr) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: missions.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildMobileMissionCard(m, context, provider),
            )).toList(),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFFAFAFA)),
              columnSpacing: 24,
              columns: [
                DataColumn(label: _headerText(tr('provider.colClient'))),
                DataColumn(label: _headerText(tr('provider.colService'))),
                DataColumn(label: _headerText(tr('provider.colDate'))),
                DataColumn(label: _headerText(tr('provider.colHeure'))),
                DataColumn(label: _headerText(tr('provider.colMontant'))),
                DataColumn(label: _headerText(tr('provider.colStatut'))),
                DataColumn(label: _headerText('')),
              ],
              rows: missions.map((m) => DataRow(cells: [
                DataCell(_cellText(m.clientNomComplet)),
                DataCell(_cellText(m.service)),
                DataCell(_cellText('${m.date.day}/${m.date.month}/${m.date.year}')),
                DataCell(_cellText('${m.heureDebut.hour.toString().padLeft(2, '0')}:${m.heureDebut.minute.toString().padLeft(2, '0')}')),
                DataCell(_cellText('${m.montant.toStringAsFixed(0)} FCFA', bold: true)),
                DataCell(_buildStatusBadge(m.statut)),
                DataCell(_buildRowActions(m, context, provider)),
              ])).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileMissionCard(Mission mission, BuildContext context, ProviderDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(mission.clientNomComplet, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary, fontFamily: 'Sora')),
              _buildStatusBadge(mission.statut),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.work_outline, mission.service),
          const SizedBox(height: 4),
          _infoRow(Icons.calendar_today, '${mission.date.day}/${mission.date.month}/${mission.date.year}'),
          const SizedBox(height: 4),
          _infoRow(Icons.access_time, '${mission.heureDebut.hour.toString().padLeft(2, '0')}:${mission.heureDebut.minute.toString().padLeft(2, '0')}'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${mission.montant.toStringAsFixed(0)} FCFA', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _success, fontFamily: 'Sora')),
              _buildRowActions(mission, context, provider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _textMuted),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: _textSecondary, fontFamily: 'DM Sans')),
      ],
    );
  }

  Widget _headerText(String text) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textMuted, fontFamily: 'DM Sans'));
  }

  Widget _cellText(String text, {bool bold = false}) {
    return Text(text, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w600 : FontWeight.w400, color: _textPrimary, fontFamily: 'DM Sans'));
  }

  Widget _buildStatusBadge(MissionStatus status) {
    final data = switch (status) {
      MissionStatus.confirmed => ('Confirmée', _success, const Color(0xFFDCFCE7)),
      MissionStatus.pending => ('En attente', _warning, const Color(0xFFFEF3C7)),
      MissionStatus.completed => ('Terminée', _textMuted, const Color(0xFFF1F5F9)),
      MissionStatus.cancelled => ('Annulée', _error, const Color(0xFFFEE2E2)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: data.$3, borderRadius: BorderRadius.circular(6)),
      child: Text(data.$1, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: data.$2, fontFamily: 'DM Sans')),
    );
  }

  Widget _buildRowActions(Mission mission, BuildContext context, ProviderDashboardProvider provider) {
    if (mission.statut == MissionStatus.pending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _actionButton(Icons.check_circle_outline, _success, () => provider.accepterMission(mission.id)),
          const SizedBox(width: 4),
          _actionButton(Icons.cancel_outlined, _error, () => provider.annulerMission(mission.id)),
        ],
      );
    }
    if (mission.statut == MissionStatus.confirmed) {
      return _actionButton(Icons.task_alt_rounded, _primary, () => provider.completerMission(mission.id));
    }
    return const SizedBox.shrink();
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return PointerCursor(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
