import 'package:flutter/material.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/utils/hour_range_formatter.dart';
import '../../../intervention/domain/intervention.dart';
import '../../../provider/presentation/widgets/dashboard/dashboard_content.dart' show buildInterventionStatusBadge;

const Color _primary = Color(0xFF2563EB);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF94A3B8);
const Color _border = Color(0xFFE8ECF2);
const Color _success = Color(0xFF16A34A);

class ReservationDetailSheet extends StatelessWidget {
  final Intervention intervention;
  final VoidCallback? onPay;
  final VoidCallback? onRate;

  const ReservationDetailSheet({
    super.key,
    required this.intervention,
    this.onPay,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final i = intervention;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _primary.withOpacity(0.1),
                  child: Text(
                    i.providerName.isNotEmpty ? i.providerName[0] : '?',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _primary, fontFamily: 'Sora'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(i.providerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary, fontFamily: 'Sora')),
                      const SizedBox(height: 4),
                      Text('Réf: ${i.reference}', style: const TextStyle(fontSize: 12, color: _textMuted, fontFamily: 'DM Sans')),
                    ],
                  ),
                ),
                buildInterventionStatusBadge(i.statut),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: _border),
            const SizedBox(height: 16),
            _detailRow('Service', i.service, Icons.build_rounded),
            const Divider(height: 20, color: _border),
            _detailRow('Date', '${i.date.day}/${i.date.month}/${i.date.year}', Icons.calendar_today_rounded),
            const Divider(height: 20, color: _border),
            _detailRow('Créneaux', formatHourRanges(i.heures), Icons.access_time_rounded),
            if (i.adresse.isNotEmpty) ...[
              const Divider(height: 20, color: _border),
              _detailRow('Adresse', i.adresse, Icons.location_on_outlined),
            ],
            if (i.description.isNotEmpty) ...[
              const Divider(height: 20, color: _border),
              _detailRow('Description', i.description, Icons.description_outlined),
            ],
            const Divider(height: 20, color: _border),
            _detailRow('Urgence', i.urgence, Icons.priority_high_rounded),
            const Divider(height: 20, color: _border),
            _detailRow(
              'Montant',
              i.montant == null ? 'À définir par le prestataire' : '${i.montant!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA',
              Icons.monetization_on_rounded,
              valueColor: i.montant == null ? _textMuted : _success,
              bold: i.montant != null,
            ),
            const SizedBox(height: 24),
            if (i.statut == InterventionStatus.encours && onPay != null) _buildActionButton(context, 'Payer', const Color(0xFFF97316), Icons.payments_outlined, onPay!),
            if (i.statut == InterventionStatus.terminee && onRate != null) _buildActionButton(context, 'Noter cette intervention', _primary, Icons.star_outline, onRate!),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, Color color, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: PointerCursor(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'DM Sans')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon, {Color? valueColor, bool bold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: _textMuted, fontFamily: 'DM Sans')),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w600 : FontWeight.w400, color: valueColor ?? _textPrimary, fontFamily: 'DM Sans')),
            ],
          ),
        ),
      ],
    );
  }
}
