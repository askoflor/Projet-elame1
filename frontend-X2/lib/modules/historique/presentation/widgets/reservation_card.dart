import 'package:flutter/material.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/utils/hour_range_formatter.dart';
import '../../../intervention/domain/intervention.dart';
import '../../../provider/presentation/widgets/dashboard/dashboard_content.dart' show buildInterventionStatusBadge;

const Color _primary = Color(0xFF2563EB);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const Color _textMuted = Color(0xFF94A3B8);
const Color _success = Color(0xFF16A34A);

class ReservationCard extends StatelessWidget {
  final Intervention intervention;
  final VoidCallback onTap;
  final VoidCallback? onPay;
  final VoidCallback? onRate;

  const ReservationCard({
    super.key,
    required this.intervention,
    required this.onTap,
    this.onPay,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final i = intervention;

    return PointerCursor(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8ECF2)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              _buildProviderAvatar(i),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(i.service, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary, fontFamily: 'Sora')),
                        ),
                        buildInterventionStatusBadge(i.statut),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(i.providerName, style: const TextStyle(fontSize: 12, color: _textSecondary, fontFamily: 'DM Sans')),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _infoChip(Icons.calendar_today_rounded, '${i.date.day}/${i.date.month}/${i.date.year}'),
                        const SizedBox(width: 8),
                        _infoChip(Icons.access_time_rounded, formatHourRanges(i.heures)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          i.montant == null ? '—' : '${i.montant!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _success, fontFamily: 'Sora'),
                        ),
                        _buildAction(context, i),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 18, color: _textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction(BuildContext context, Intervention i) {
    switch (i.statut) {
      case InterventionStatus.attente:
        return const Text('En attente de l\'appel', style: TextStyle(fontSize: 11, color: _textMuted, fontFamily: 'DM Sans'));
      case InterventionStatus.encours:
        return _actionButton('Payer', const Color(0xFFF97316), onPay);
      case InterventionStatus.terminee:
        return _actionButton('Noter', _primary, onRate);
      case InterventionStatus.annulee:
        return const SizedBox.shrink();
    }
  }

  Widget _actionButton(String label, Color color, VoidCallback? onTap) {
    return PointerCursor(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
          child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'DM Sans')),
        ),
      ),
    );
  }

  Widget _buildProviderAvatar(Intervention i) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: _primary.withOpacity(0.1),
      child: Text(
        i.providerName.isNotEmpty ? i.providerName[0] : '?',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _primary, fontFamily: 'Sora'),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: _textMuted),
        const SizedBox(width: 3),
        Text(text, style: const TextStyle(fontSize: 11, color: _textMuted, fontFamily: 'DM Sans')),
      ],
    );
  }
}
