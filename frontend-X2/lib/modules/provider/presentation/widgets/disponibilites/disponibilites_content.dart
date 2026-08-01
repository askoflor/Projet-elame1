import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/localization/translation_provider.dart';
import '../../../../../core/widgets/micro_interactions.dart';
import '../../../state/provider_dashboard_state.dart';
import '../../../domain/planning.dart';

const Color _primary = Color(0xFF2563EB);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const Color _textMuted = Color(0xFF94A3B8);
const Color _border = Color(0xFFE8ECF2);
const Color _success = Color(0xFF16A34A);
const Color _error = Color(0xFFEF4444);

class DisponibilitesContent extends StatelessWidget {
  const DisponibilitesContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderDashboardProvider>();
    final tr = context.tr;
    final p = provider.profile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(tr),
        const SizedBox(height: 20),
        _buildStatusCard(context, provider, tr, p.disponible),
        const SizedBox(height: 20),
        _buildWeeklySchedule(context, provider, tr),
        const SizedBox(height: 20),
        _buildInfoCard(tr),
      ],
    );
  }

  Widget _buildHeader(String Function(String) tr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('provider.disponibilites'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary, fontFamily: 'Sora')),
        const SizedBox(height: 4),
        Text(tr('provider.disponibilitesSub'), style: const TextStyle(fontSize: 13, color: _textSecondary, fontFamily: 'DM Sans')),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, ProviderDashboardProvider provider, String Function(String) tr, bool disponible) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: disponible ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              disponible ? Icons.toggle_on_rounded : Icons.toggle_off_outlined,
              size: 32,
              color: disponible ? _success : _error,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(disponible ? 'provider.statutDisponible' : 'provider.statutIndisponible'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary, fontFamily: 'Sora'),
                ),
                const SizedBox(height: 4),
                Text(
                  tr(disponible ? 'provider.disponibleMessage' : 'provider.indisponibleMessage'),
                  style: const TextStyle(fontSize: 12, color: _textSecondary, fontFamily: 'DM Sans'),
                ),
              ],
            ),
          ),
          Switch(
            value: disponible,
            onChanged: (_) => provider.toggleDisponibilite(),
            activeColor: _success,
            inactiveThumbColor: _error,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySchedule(BuildContext context, ProviderDashboardProvider provider, String Function(String) tr) {
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
          Text(tr('provider.heuresTravail'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary, fontFamily: 'Sora')),
          const SizedBox(height: 16),
          ...provider.disponibilites.asMap().entries.map((entry) => _buildJourRow(context, entry.key, entry.value, provider, tr)),
        ],
      ),
    );
  }

  Widget _buildJourRow(BuildContext context, int index, DisponibiliteSemaine dispo, ProviderDashboardProvider provider, String Function(String) tr) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              dispo.jourNom,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textPrimary, fontFamily: 'DM Sans'),
            ),
          ),
          Switch(
            value: dispo.actif,
            onChanged: (v) => provider.updateDisponibiliteJour(index, v),
            activeColor: _success,
            inactiveThumbColor: _textMuted,
          ),
          const SizedBox(width: 8),
          if (dispo.actif)
            Expanded(
              child: PointerCursor(
                child: GestureDetector(
                  onTap: () => _showTimePicker(context, index, dispo, provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 14, color: _textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          '${dispo.debut.hour.toString().padLeft(2, '0')}:${dispo.debut.minute.toString().padLeft(2, '0')} - ${dispo.fin.hour.toString().padLeft(2, '0')}:${dispo.fin.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12, color: _textPrimary, fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            Text(tr('provider.nonTravaille'), style: const TextStyle(fontSize: 12, color: _textMuted, fontFamily: 'DM Sans')),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context, int index, DisponibiliteSemaine dispo, ProviderDashboardProvider provider) async {
    final debut = await showTimePicker(
      context: context,
      initialTime: dispo.debut,
      helpText: context.tr('provider.heureDebut'),
    );
    if (debut == null) return;
    final fin = await showTimePicker(
      context: context,
      initialTime: dispo.fin,
      helpText: context.tr('provider.heureFin'),
    );
    if (fin == null) return;
    provider.updateDisponibiliteHeure(index, debut, fin);
  }

  Widget _buildInfoCard(String Function(String) tr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: _primary, width: 3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 20, color: _primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tr('provider.disponibilitesInfo'),
              style: const TextStyle(fontSize: 12, color: _textSecondary, fontFamily: 'DM Sans', height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
