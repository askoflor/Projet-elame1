import 'package:flutter/material.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../domain/reservation.dart';

const Color _primary = Color(0xFF2563EB);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const Color _textMuted = Color(0xFF94A3B8);
const Color _border = Color(0xFFE8ECF2);
const Color _success = Color(0xFF16A34A);
const Color _warning = Color(0xFFF59E0B);
const Color _error = Color(0xFFEF4444);

class ReservationDetailSheet extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onCancel;

  const ReservationDetailSheet({
    super.key,
    required this.reservation,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final r = reservation;
    final statusData = _statusData(r.statut);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _primary.withOpacity(0.1),
                  child: Text(
                    r.providerInitials,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      fontFamily: 'Sora',
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.providerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                          fontFamily: 'Sora',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Réf: ${r.reference}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _textMuted,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(statusData),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: _border),
            const SizedBox(height: 16),
            _detailRow(tr('historique.service'), r.serviceName, Icons.build_rounded),
            const Divider(height: 20, color: _border),
            _detailRow(tr('historique.date'), r.formattedDate, Icons.calendar_today_rounded),
            if (r.heureSlot.isNotEmpty) ...[
              const Divider(height: 20, color: _border),
              _detailRow(tr('historique.heure'), r.heureSlot, Icons.access_time_rounded),
            ],
            if (r.adresse.isNotEmpty) ...[
              const Divider(height: 20, color: _border),
              _detailRow(tr('historique.adresse'), r.adresse, Icons.location_on_outlined),
            ],
            if (r.description.isNotEmpty) ...[
              const Divider(height: 20, color: _border),
              _detailRow(tr('historique.description'), r.description, Icons.description_outlined),
            ],
            if (r.paymentMethod.isNotEmpty) ...[
              const Divider(height: 20, color: _border),
              _detailRow(tr('historique.paiement'), r.paymentMethod, Icons.payment_rounded),
            ],
            const Divider(height: 20, color: _border),
            _detailRow(
              tr('historique.montant'),
              '${r.montant.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA',
              Icons.monetization_on_rounded,
              valueColor: _success,
              bold: true,
            ),
            const SizedBox(height: 24),
            if (onCancel != null)
              SizedBox(
                width: double.infinity,
                child: PointerCursor(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _error.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cancel_outlined, size: 18, color: _error),
                            const SizedBox(width: 8),
                            Text(
                              tr('historique.annulerReservation'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _error,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: _textMuted, fontFamily: 'DM Sans'),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                  color: valueColor ?? _textPrimary,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge((String, Color, Color) data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: data.$3, borderRadius: BorderRadius.circular(8)),
      child: Text(
        data.$1,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: data.$2, fontFamily: 'DM Sans'),
      ),
    );
  }

  (String, Color, Color) _statusData(ReservationStatus status) {
    return switch (status) {
      ReservationStatus.pending => ('En attente', _warning, const Color(0xFFFEF3C7)),
      ReservationStatus.confirmed => ('Confirmée', _primary, const Color(0xFFEFF6FF)),
      ReservationStatus.completed => ('Terminée', _success, const Color(0xFFDCFCE7)),
      ReservationStatus.cancelled => ('Annulée', _error, const Color(0xFFFEE2E2)),
    };
  }
}
