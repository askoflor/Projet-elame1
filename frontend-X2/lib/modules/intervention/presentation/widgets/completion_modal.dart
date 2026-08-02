import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/utils/data_uri.dart';
import '../../domain/intervention.dart';
import '../../state/intervention_provider.dart';

/// Modale de cloture : le prestataire doit fournir une description detaillee
/// de la resolution et au moins une photo du travail realise avant de
/// pouvoir faire passer l'intervention au statut "terminee".
class CompletionModal extends StatefulWidget {
  final Intervention intervention;

  const CompletionModal({super.key, required this.intervention});

  static Future<void> show(BuildContext context, Intervention intervention) {
    return showDialog(
      context: context,
      builder: (_) => CompletionModal(intervention: intervention),
    );
  }

  @override
  State<CompletionModal> createState() => _CompletionModalState();
}

class _CompletionModalState extends State<CompletionModal> {
  final _descriptionController = TextEditingController();
  final List<String> _photos = [];
  bool _uploading = false;
  bool _submitAttempted = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addPhoto() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (bytes.lengthInBytes > 1600 * 1024) {
        if (!mounted) return;
        _toast(context.tr('completion.imageTropVolumineuse'));
        return;
      }
      setState(() => _uploading = true);
      final ext = picked.name.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
      final dataUri = 'data:image/$ext;base64,${base64Encode(bytes)}';
      if (!mounted) return;
      setState(() {
        _photos.add(dataUri);
        _uploading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploading = false);
      _toast(context.tr('completion.impossibleChargerImage'));
    }
  }

  bool get _isValid => _descriptionController.text.trim().isNotEmpty && _photos.isNotEmpty;

  void _confirmer() {
    setState(() => _submitAttempted = true);
    if (!_isValid) {
      _toast(context.tr('completion.champsRequis'));
      return;
    }
    context.read<InterventionProvider>().terminerAvecRapport(
          widget.intervention.reference,
          description: _descriptionController.text.trim(),
          photos: _photos,
        );
    Navigator.of(context).pop();
    _toast(context.tr('completion.interventionTerminee'));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final descError = _submitAttempted && _descriptionController.text.trim().isEmpty;
    final photosError = _submitAttempted && _photos.isEmpty;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 460, maxHeight: screenSize.height - 48),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(context.tr('completion.title'), style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, size: 20)),
                ],
              ),
              Text(
                '${widget.intervention.reference} · ${widget.intervention.service} · ${widget.intervention.clientNom}',
                style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr('completion.instructions'),
                        style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF1E3A8A), height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(context.tr('completion.descriptionLabel'),
                  style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              const SizedBox(height: 6),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: context.tr('completion.descriptionHint'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: descError ? const Color(0xFFEF4444) : const Color(0xFFE8ECF2))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: descError ? const Color(0xFFEF4444) : const Color(0xFFE8ECF2))),
                ),
              ),
              if (descError) ...[
                const SizedBox(height: 4),
                Text(context.tr('completion.descriptionRequise'), style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
              ],
              const SizedBox(height: 16),
              Text(context.tr('completion.photosLabel'),
                  style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _photos.length; i++) _buildPhotoThumb(i),
                  _buildAddPhotoButton(),
                ],
              ),
              if (photosError) ...[
                const SizedBox(height: 4),
                Text(context.tr('completion.photoRequise'), style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.tr('completion.annulerBtn'))),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _confirmer,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(context.tr('completion.confirmerBtn')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoThumb(int index) {
    final bytes = decodeDataUri(_photos[index]);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: bytes != null
              ? Image.memory(bytes, width: 72, height: 72, fit: BoxFit.cover)
              : Container(width: 72, height: 72, color: const Color(0xFFF1F5F9)),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: () => setState(() => _photos.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _uploading ? null : _addPhoto,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE8ECF2), style: BorderStyle.solid),
          color: const Color(0xFFF8FAFC),
        ),
        child: _uploading
            ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
            : const Icon(Icons.add_a_photo_outlined, color: Color(0xFF94A3B8), size: 22),
      ),
    );
  }
}
