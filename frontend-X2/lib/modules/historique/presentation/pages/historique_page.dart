import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../home/presentation/widgets/header/nav_bar.dart';
import '../../../intervention/domain/intervention.dart';
import '../../../intervention/state/intervention_provider.dart';
import '../widgets/reservation_card.dart';
import '../widgets/reservation_detail_sheet.dart';

const Color _primary = Color(0xFF2563EB);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const Color _textMuted = Color(0xFF94A3B8);
const Color _border = Color(0xFFE8ECF2);

class HistoriquePage extends StatefulWidget {
  const HistoriquePage({super.key});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  int _selectedFilter = 0;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final _filters = ['Toutes', 'En attente', 'En cours', 'Terminées'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Intervention> _filtered(InterventionProvider provider) {
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
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((i) => i.providerName.toLowerCase().contains(q) || i.service.toLowerCase().contains(q) || i.reference.toLowerCase().contains(q)).toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InterventionProvider>();
    final tr = context.tr;
    final interventions = _filtered(provider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const NavBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Align(alignment: Alignment.centerLeft, child: AppBackButton()),
                    const SizedBox(height: 12),
                    _buildHeader(tr, provider),
                    const SizedBox(height: 16),
                    _buildSearchBar(tr),
                    const SizedBox(height: 12),
                    _buildFilters(),
                    const SizedBox(height: 16),
                    Expanded(child: _buildList(interventions, tr)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String Function(String) tr, InterventionProvider provider) {
    final enAttente = provider.enAttente.length;
    final enCours = provider.enCours.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('historique.title'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary, fontFamily: 'Sora')),
            const SizedBox(height: 4),
            Text('${provider.all.length} ${tr('historique.total')}', style: const TextStyle(fontSize: 13, color: _textSecondary, fontFamily: 'DM Sans')),
          ],
        ),
        Row(
          children: [
            _statChip('$enAttente', 'en attente', const Color(0xFFF59E0B)),
            const SizedBox(width: 6),
            _statChip('$enCours', 'en cours', _primary),
          ],
        ),
      ],
    );
  }

  Widget _statChip(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color, fontFamily: 'Sora')),
          Text(label, style: TextStyle(fontSize: 9, color: color, fontFamily: 'DM Sans')),
        ],
      ),
    );
  }

  Widget _buildSearchBar(String Function(String) tr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: _textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: tr('historique.rechercher'),
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

  Widget _buildFilters() {
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
                    border: Border.all(color: isSelected ? _primary : _border),
                  ),
                  child: Text(filter, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : _textSecondary, fontFamily: 'DM Sans')),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList(List<Intervention> interventions, String Function(String) tr) {
    if (interventions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: _textMuted.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(tr('historique.aucune'), style: const TextStyle(fontSize: 15, color: _textSecondary, fontFamily: 'DM Sans')),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: interventions.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final i = interventions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ReservationCard(
            intervention: i,
            onTap: () => _showDetail(i),
            onPay: i.statut == InterventionStatus.encours ? () => context.push('/paiement', extra: i) : null,
            onRate: i.statut == InterventionStatus.terminee ? () => _toastNote() : null,
          ),
        );
      },
    );
  }

  void _toastNote() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notation de l\'intervention')));
  }

  void _showDetail(Intervention i) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReservationDetailSheet(
        intervention: i,
        onPay: i.statut == InterventionStatus.encours
            ? () {
                Navigator.pop(context);
                context.push('/paiement', extra: i);
              }
            : null,
        onRate: i.statut == InterventionStatus.terminee
            ? () {
                Navigator.pop(context);
                _toastNote();
              }
            : null,
      ),
    );
  }
}
