import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/hour_range_formatter.dart';
import '../../domain/intervention.dart';
import '../../state/intervention_provider.dart';

const _durees = ['1h', '2h', '3h', 'Demi-journée', 'Journée complète'];

/// Modale de chiffrage : le prestataire fixe le montant d'une intervention
/// "en attente", ce qui la fait passer au statut "en cours".
class ChiffrageModal extends StatefulWidget {
  final Intervention intervention;

  const ChiffrageModal({super.key, required this.intervention});

  static Future<void> show(BuildContext context, Intervention intervention) {
    return showDialog(
      context: context,
      builder: (_) => ChiffrageModal(intervention: intervention),
    );
  }

  @override
  State<ChiffrageModal> createState() => _ChiffrageModalState();
}

class _ChiffrageModalState extends State<ChiffrageModal> {
  final _montantController = TextEditingController();
  final _noteController = TextEditingController();
  late String _dureeSelectionnee;
  late DateTime _dateConfirmee;
  double _montant = 0;

  @override
  void initState() {
    super.initState();
    _dureeSelectionnee = dureeLabelFromHours(widget.intervention.dureeHeures);
    if (!_durees.contains(_dureeSelectionnee)) _dureeSelectionnee = _durees.first;
    _dateConfirmee = widget.intervention.date;
    _montantController.addListener(() {
      setState(() => _montant = double.tryParse(_montantController.text) ?? 0);
    });
  }

  @override
  void dispose() {
    _montantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateConfirmee,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dateConfirmee = picked);
  }

  void _confirmer() {
    if (_montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saisissez le montant convenu avec le client')),
      );
      return;
    }
    context.read<InterventionProvider>().chiffrer(
          widget.intervention.reference,
          montant: _montant,
          dateConfirmee: _dateConfirmee,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(
          '${widget.intervention.reference} validée · statut « En cours » · le client peut payer')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.intervention;
    final commission = _montant * 0.05;
    final net = _montant - commission;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Valider l\'intervention',
                      style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              Text(
                '${i.reference} · ${i.service} · ${i.date.day}/${i.date.month}/${i.date.year}, '
                '${formatHourRanges(i.heures)} · ${i.adresse}',
                style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  border: Border.all(color: const Color(0xFFBFCFFD)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_in_talk_outlined, color: Color(0xFF2563EB)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i.clientNom,
                              style: GoogleFonts.sora(
                                  fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E40AF))),
                          Text(i.clientPhone,
                              style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF2563EB))),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Appel du client en cours…'))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Appeler'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Appelez le client pour convenir des modalités, puis saisissez le montant convenu. '
                'L\'intervention passera alors au statut « En cours ».',
                style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 14),
              _label('Montant convenu (FCFA)'),
              TextField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Ex. 25000'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Durée estimée'),
                        DropdownButtonFormField<String>(
                          initialValue: _dureeSelectionnee,
                          items: _durees
                              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                              .toList(),
                          onChanged: (v) => setState(() => _dureeSelectionnee = v ?? _dureeSelectionnee),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Date confirmée'),
                        InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(),
                            child: Text(
                                '${_dateConfirmee.day}/${_dateConfirmee.month}/${_dateConfirmee.year}'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _label('Note pour le client (optionnel)'),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Ex. Prévoir l\'accès au tableau électrique...'),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _calcRow('Montant de la prestation', _montant),
                    _calcRow('Commission plateforme (5 %)', commission),
                    const Divider(color: Color(0xFFE8ECF2)),
                    _calcRow('Net prestataire', net, bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _confirmer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Valider et démarrer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: GoogleFonts.sora(
                fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
      );

  Widget _calcRow(String label, double value, {bool bold = false}) {
    final formatted =
        '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: bold ? 13 : 12,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: bold ? const Color(0xFF1E293B) : const Color(0xFF64748B))),
          Text(formatted,
              style: GoogleFonts.dmSans(
                  fontSize: bold ? 13 : 12,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: bold ? const Color(0xFF1E293B) : const Color(0xFF64748B))),
        ],
      ),
    );
  }
}
