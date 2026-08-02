import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/localization/translation_provider.dart';
import '../../../../../core/widgets/micro_interactions.dart';
import '../../../../../core/utils/hour_range_formatter.dart';
import '../../../../intervention/domain/intervention.dart';
import '../../../../intervention/state/intervention_provider.dart';
import '../../../../intervention/presentation/widgets/chiffrage_modal.dart';
import '../../../../intervention/presentation/widgets/completion_modal.dart';
import '../../../../../core/widgets/pagination_bar.dart';
import '../dashboard/dashboard_content.dart' show buildInterventionStatusBadge;

const Color _primary = Color(0xFF2563EB);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const Color _textMuted = Color(0xFF94A3B8);
const Color _borderColor = Color(0xFFE8ECF2);
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
  static const _pageSize = 6;
  int _currentPage = 0;

  List<String> _filterLabels(BuildContext context) => [
        context.tr('intervention.filterToutes'),
        context.tr('intervention.filterEnAttente'),
        context.tr('intervention.filterEnCours'),
        context.tr('intervention.filterTerminees'),
        context.tr('intervention.filterAnnulees'),
      ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Intervention> _filteredInterventions(InterventionProvider provider) {
    var items = provider.all;
    switch (_selectedFilter) {
      case 1:
        items = items.where((i) => i.statut == InterventionStatus.attente).toList();
        break;
      case 2:
        items = items.where((i) => i.statut == InterventionStatus.encours).toList();
        break;
      case 3:
        items = items.where((i) => i.statut == InterventionStatus.terminee).toList();
        break;
      case 4:
        items = items.where((i) => i.statut == InterventionStatus.annulee).toList();
        break;
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items
          .where((i) => i.clientNom.toLowerCase().contains(q) || i.service.toLowerCase().contains(q))
          .toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InterventionProvider>();
    final tr = context.tr;
    final items = _filteredInterventions(provider);
    final totalPages = (items.length / _pageSize).ceil().clamp(1, 1 << 30);
    if (_currentPage >= totalPages) _currentPage = 0;
    final paged = items.skip(_currentPage * _pageSize).take(_pageSize).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(tr, provider),
        const SizedBox(height: 16),
        _buildFilters(),
        const SizedBox(height: 16),
        _buildSearchBar(tr),
        const SizedBox(height: 16),
        if (items.isEmpty)
          _buildEmptyState(tr)
        else ...[
          _buildInterventionsList(paged, context),
          PaginationBar(
            currentPage: _currentPage,
            totalPages: totalPages,
            onPageChanged: (p) => setState(() => _currentPage = p),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader(String Function(String) tr, InterventionProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('provider.mesMissions'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary, fontFamily: 'Sora'),
            ),
            const SizedBox(height: 4),
            Text(
              '${provider.all.length} ${tr('provider.missionsTotal')}',
              style: const TextStyle(fontSize: 13, color: _textSecondary, fontFamily: 'DM Sans'),
            ),
          ],
        ),
        Row(
          children: [
            _buildStatBadge(tr('intervention.statutAttente'), provider.enAttente.length, _warning),
            const SizedBox(width: 8),
            _buildStatBadge(tr('intervention.statutEnCours'), provider.enCours.length, _primary),
            const SizedBox(width: 8),
            _buildStatBadge(tr('provider.terminees'), provider.terminees.length, _textMuted),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text('$count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color, fontFamily: 'Sora')),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontFamily: 'DM Sans')),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = _filterLabels(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PointerCursor(
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedFilter = index;
                  _currentPage = 0;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _primary : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? _primary : _borderColor),
                  ),
                  child: Text(
                    filters[index],
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
        }),
      ),
    );
  }

  Widget _buildSearchBar(String Function(String) tr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: _borderColor)),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: _textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() {
                _searchQuery = v;
                _currentPage = 0;
              }),
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
                setState(() {
                  _searchQuery = '';
                  _currentPage = 0;
                });
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
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

  Widget _buildInterventionsList(List<Intervention> items, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: items
                .map((i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildMobileCard(i, context)))
                .toList(),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFFAFAFA)),
              columnSpacing: 24,
              columns: [
                DataColumn(label: _HeaderText(context.tr('intervention.colClient'))),
                DataColumn(label: _HeaderText(context.tr('intervention.colService'))),
                DataColumn(label: _HeaderText(context.tr('intervention.colDate'))),
                DataColumn(label: _HeaderText(context.tr('intervention.colCreneaux'))),
                DataColumn(label: _HeaderText(context.tr('intervention.colMontant'))),
                DataColumn(label: _HeaderText(context.tr('intervention.colStatut'))),
                const DataColumn(label: _HeaderText('')),
              ],
              rows: items
                  .map((i) => DataRow(cells: [
                        DataCell(_CellText('${i.clientNom}\n${i.reference}')),
                        DataCell(_CellText(i.service)),
                        DataCell(_CellText('${i.date.day}/${i.date.month}/${i.date.year}')),
                        DataCell(_CellText(formatHourRanges(i.heures))),
                        DataCell(_CellText(i.montant == null ? '—' : '${i.montant!.toStringAsFixed(0)} FCFA', bold: true)),
                        DataCell(buildInterventionStatusBadge(context, i.statut)),
                        DataCell(_buildRowActions(i, context)),
                      ]))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileCard(Intervention i, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(i.clientNom, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary, fontFamily: 'Sora')),
              buildInterventionStatusBadge(context, i.statut),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.work_outline, i.service),
          const SizedBox(height: 4),
          _infoRow(Icons.calendar_today, '${i.date.day}/${i.date.month}/${i.date.year}'),
          const SizedBox(height: 4),
          _infoRow(Icons.access_time, formatHourRanges(i.heures)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(i.montant == null ? '—' : '${i.montant!.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _success, fontFamily: 'Sora')),
              _buildRowActions(i, context),
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

  Widget _buildRowActions(Intervention i, BuildContext context) {
    if (i.statut == InterventionStatus.attente) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _actionButton(Icons.request_quote_outlined, _primary, () => ChiffrageModal.show(context, i)),
          const SizedBox(width: 4),
          _actionButton(Icons.cancel_outlined, _error, () => context.read<InterventionProvider>().annuler(i.reference)),
        ],
      );
    }
    if (i.statut == InterventionStatus.encours) {
      return _actionButton(Icons.task_alt_rounded, _primary, () => CompletionModal.show(context, i));
    }
    if (i.statut == InterventionStatus.terminee) {
      return Text(context.tr('intervention.cloturee'), style: const TextStyle(fontSize: 11, color: _textMuted, fontFamily: 'DM Sans'));
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

class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textMuted, fontFamily: 'DM Sans'));
}

class _CellText extends StatelessWidget {
  final String text;
  final bool bold;
  const _CellText(this.text, {this.bold = false});
  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w600 : FontWeight.w400, color: _textPrimary, fontFamily: 'DM Sans'));
}
