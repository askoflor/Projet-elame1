import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../domain/reservation.dart';

const Color _primary = Color(0xFF2563EB);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const Color _textMuted = Color(0xFF94A3B8);
const Color _success = Color(0xFF16A34A);
const Color _warning = Color(0xFFF59E0B);
const Color _error = Color(0xFFEF4444);

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onTap;
  final VoidCallback? onCancel;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final r = reservation;
    final statusData = _statusData(r.statut);

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
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildProviderAvatar(r),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            r.serviceName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                              fontFamily: 'Sora',
                            ),
                          ),
                        ),
                        _buildStatusBadge(statusData),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.providerName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textSecondary,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _infoChip(Icons.calendar_today_rounded, r.formattedDate),
                        const SizedBox(width: 8),
                        if (r.heureSlot.isNotEmpty)
                          _infoChip(Icons.access_time_rounded, r.heureSlot),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${r.montant.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _success,
                            fontFamily: 'Sora',
                          ),
                        ),
                        if (onCancel != null)
                          PointerCursor(
                            child: GestureDetector(
                              onTap: onCancel,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tr('historique.annuler'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _error,
                                    fontFamily: 'DM Sans',
                                  ),
                                ),
                              ),
                            ),
                          ),
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

  Widget _buildProviderAvatar(Reservation r) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: _primary.withOpacity(0.1),
      child: Text(
        r.providerInitials,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _primary,
          fontFamily: 'Sora',
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: _textMuted),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: _textMuted, fontFamily: 'DM Sans'),
        ),
      ],
    );
  }

  Widget _buildStatusBadge((String, Color, Color) data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: data.$3,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        data.$1,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: data.$2,
          fontFamily: 'DM Sans',
        ),
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
