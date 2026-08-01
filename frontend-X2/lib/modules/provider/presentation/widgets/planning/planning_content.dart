import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/localization/translation_provider.dart';
import '../../../../../core/widgets/micro_interactions.dart';
import '../../../state/provider_dashboard_state.dart';
import '../../../domain/planning.dart';

const Color _primary = Color(0xFF2563EB);
const Color _bgLight = Color(0xFFF8FAFC);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const Color _textMuted = Color(0xFF94A3B8);
const Color _border = Color(0xFFE8ECF2);
const Color _success = Color(0xFF16A34A);
const Color _warning = Color(0xFFF59E0B);

class PlanningContent extends StatefulWidget {
  const PlanningContent({super.key});

  @override
  State<PlanningContent> createState() => _PlanningContentState();
}

class _PlanningContentState extends State<PlanningContent> {
  int _selectedJourIndex = -1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderDashboardProvider>();
    final tr = context.tr;
    final semaine = provider.planningSemaine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(tr),
        const SizedBox(height: 20),
        _buildSemaineGrid(semaine, tr),
        const SizedBox(height: 20),
        if (_selectedJourIndex >= 0 && _selectedJourIndex < semaine.jours.length)
          _buildJourDetail(semaine.jours[_selectedJourIndex], tr),
      ],
    );
  }

  Widget _buildHeader(String Function(String) tr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('provider.planning'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                fontFamily: 'Sora',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr('provider.planningSub'),
              style: const TextStyle(
                fontSize: 13,
                color: _textSecondary,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildNavButton(Icons.chevron_left_rounded, () {}),
            const SizedBox(width: 4),
            _buildNavButton(Icons.chevron_right_rounded, () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return PointerCursor(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
          ),
          child: Icon(icon, size: 18, color: _textPrimary),
        ),
      ),
    );
  }

  Widget _buildSemaineGrid(PlanningSemaine semaine, String Function(String) tr) {
    return Container(
      padding: const EdgeInsets.all(16),
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
'Semaine du ${semaine.debutSemaine.day}/${semaine.debutSemaine.month}/${semaine.debutSemaine.year}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = (constraints.maxWidth - 48) / 7;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: semaine.jours.map((jour) {
                    final idx = semaine.jours.indexOf(jour);
                    return _buildJourCell(jour, cellWidth, idx);
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJourCell(PlanningJour jour, double width, int index) {
    final isSelected = _selectedJourIndex == index;
    final joursNoms = [
      context.tr('provider.jourLun'),
      context.tr('provider.jourMar'),
      context.tr('provider.jourMer'),
      context.tr('provider.jourJeu'),
      context.tr('provider.jourVen'),
      context.tr('provider.jourSam'),
      context.tr('provider.jourDim'),
    ];
    final missionCount = jour.slots.where((s) => s.type == PlanningSlotType.mission).length;

    return PointerCursor(
      child: GestureDetector(
        onTap: () => setState(() => _selectedJourIndex = isSelected ? -1 : index),
        child: Container(
          width: width.clamp(80, 130),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: jour.estAujourdhui
                ? _primary.withOpacity(0.08)
                : (isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFFAFAFA)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? _primary
                  : (jour.estAujourdhui ? _primary.withOpacity(0.3) : _border),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                joursNoms[jour.date.weekday - 1],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: jour.estAujourdhui ? _primary : _textSecondary,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${jour.date.day}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: jour.estAujourdhui ? _primary : _textPrimary,
                  fontFamily: 'Sora',
                ),
              ),
              const SizedBox(height: 6),
              if (missionCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$missionCount',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                      fontFamily: 'Sora',
                    ),
                  ),
                )
              else
                const Text(
                  '-',
                  style: TextStyle(
                    fontSize: 10,
                    color: _textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJourDetail(PlanningJour jour, String Function(String) tr) {
    final missions = jour.slots.where((s) => s.type == PlanningSlotType.mission).toList();
    final dispos = jour.slots.where((s) => s.type == PlanningSlotType.disponible).toList();

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
                '${jour.date.day}/${jour.date.month}/${jour.date.year}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                  fontFamily: 'Sora',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: jour.estAujourdhui ? _primary.withOpacity(0.1) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  jour.estAujourdhui ? tr('provider.aujourdhui') : tr('provider.prevoir'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: jour.estAujourdhui ? _primary : _textSecondary,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (missions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_busy_rounded, size: 40, color: _textMuted.withOpacity(0.5)),
                    const SizedBox(height: 8),
                    Text(
                      tr('provider.aucuneMissionPlanning'),
                      style: const TextStyle(fontSize: 13, color: _textMuted, fontFamily: 'DM Sans'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...missions.map((m) => _buildSlotCard(m)),
          if (dispos.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: _border),
            const SizedBox(height: 12),
            Text(
              tr('provider.creneauxDisponibles'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textSecondary,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 8),
            ...dispos.map((d) => _buildDispoSlot(d)),
          ],
        ],
      ),
    );
  }

  Widget _buildSlotCard(PlanningSlot slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: _primary, width: 3)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${slot.heureDebut.hour.toString().padLeft(2, '0')}:${slot.heureDebut.minute.toString().padLeft(2, '0')} - '
                '${slot.heureFin.hour.toString().padLeft(2, '0')}:${slot.heureFin.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                  fontFamily: 'Sora',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                slot.missionTitre ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                  fontFamily: 'DM Sans',
                ),
              ),
              if (slot.clientNom != null)
                Text(
                  slot.clientNom!,
                  style: const TextStyle(fontSize: 11, color: _textSecondary, fontFamily: 'DM Sans'),
                ),
            ],
          ),
          const Spacer(),
          if (slot.adresse != null)
            Icon(Icons.location_on_outlined, size: 16, color: _textMuted),
        ],
      ),
    );
  }

  Widget _buildDispoSlot(PlanningSlot slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 14, color: _success),
          const SizedBox(width: 6),
          Text(
            '${slot.heureDebut.hour.toString().padLeft(2, '0')}:${slot.heureDebut.minute.toString().padLeft(2, '0')} - '
            '${slot.heureFin.hour.toString().padLeft(2, '0')}:${slot.heureFin.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 12,
              color: _success,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
