import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/utils/data_uri.dart';
import '../../../../core/utils/hour_range_formatter.dart';
import '../../domain/intervention.dart';

/// Detail d'une intervention : recapitule la demande soumise par le client
/// et, une fois l'intervention terminee, affiche le compte-rendu et les
/// photos fournis par le prestataire.
class InterventionDetailDialog extends StatelessWidget {
  final Intervention intervention;

  const InterventionDetailDialog({super.key, required this.intervention});

  static Future<void> show(BuildContext context, Intervention intervention) {
    return showDialog(
      context: context,
      builder: (_) => InterventionDetailDialog(intervention: intervention),
    );
  }

  @override
  Widget build(BuildContext context) {
    final i = intervention;
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480, maxHeight: screenSize.height - 48),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(i.titre, style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, size: 20)),
                ],
              ),
              Text('${i.reference} · ${i.providerName}', style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF64748B))),
              const SizedBox(height: 16),
              _sectionTitle(context.tr('interventionDetail.demandeTitle')),
              const SizedBox(height: 8),
              _infoRow(Icons.build_outlined, context.tr('interventionDetail.service'), i.service),
              _infoRow(Icons.event_outlined, context.tr('interventionDetail.date'),
                  '${i.date.day}/${i.date.month}/${i.date.year} · ${formatHourRanges(i.heures)}'),
              _infoRow(Icons.location_on_outlined, context.tr('interventionDetail.adresse'), i.adresse),
              _infoRow(Icons.priority_high_rounded, context.tr('interventionDetail.urgence'), i.urgence),
              if (i.description.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(context.tr('interventionDetail.descriptionClient'),
                    style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
                const SizedBox(height: 4),
                Text(i.description, style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF334155), height: 1.5)),
              ],
              if (i.montant != null) ...[
                const SizedBox(height: 10),
                _infoRow(Icons.payments_outlined, context.tr('interventionDetail.montant'), '${i.montant!.toStringAsFixed(0)} FCFA'),
              ],
              if (i.statut == InterventionStatus.terminee) ...[
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFE8ECF2)),
                const SizedBox(height: 12),
                _sectionTitle(context.tr('interventionDetail.rapportTitle')),
                const SizedBox(height: 8),
                if ((i.completionDescription ?? '').trim().isEmpty && i.completionPhotos.isEmpty)
                  Text(context.tr('interventionDetail.rapportIndisponible'),
                      style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF94A3B8), fontStyle: FontStyle.italic))
                else ...[
                  if ((i.completionDescription ?? '').trim().isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
                      child: Text(i.completionDescription!, style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF166534), height: 1.5)),
                    ),
                  if (i.completionPhotos.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: i.completionPhotos.map((p) {
                        final bytes = decodeDataUri(p);
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: bytes != null
                              ? Image.memory(bytes, width: 88, height: 88, fit: BoxFit.cover)
                              : Container(
                                  width: 88,
                                  height: 88,
                                  color: const Color(0xFFF1F5F9),
                                  child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFFCBD5E1)),
                                ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(text, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)));

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF94A3B8))),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF1E293B))),
          ),
        ],
      ),
    );
  }
}
