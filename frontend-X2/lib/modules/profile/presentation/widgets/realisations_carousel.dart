import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/data_uri.dart';
import '../../../auth/data/auth_repository.dart';

/// Carrousel des photos de realisations (portfolio) rattachees au compte
/// connecte. En mode `editable`, permet d'ajouter/supprimer des photos ;
/// sinon affichage seul (visite du profil par un tiers).
class RealisationsCarousel extends StatefulWidget {
  final bool editable;

  const RealisationsCarousel({super.key, this.editable = false});

  @override
  State<RealisationsCarousel> createState() => _RealisationsCarouselState();
}

class _RealisationsCarouselState extends State<RealisationsCarousel> {
  final _repository = AuthRepository();
  late final PageController _controller;
  int _index = 0;
  List<Map<String, dynamic>> _photos = [];
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.86);
    _loadPhotos();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    final photos = await _repository.getRealisations();
    if (!mounted) return;
    setState(() {
      _photos = photos;
      _loading = false;
    });
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
        _toast('Image trop volumineuse (max ~1,5 Mo). Choisissez une photo plus légère.');
        return;
      }
      setState(() => _uploading = true);
      final ext = picked.name.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
      final dataUri = 'data:image/$ext;base64,${base64Encode(bytes)}';
      final created = await _repository.addRealisation(dataUri);
      if (!mounted) return;
      setState(() {
        _uploading = false;
        if (created != null) _photos = [created, ..._photos];
      });
      if (created == null) _toast('Échec de l\'envoi de la photo, réessayez');
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploading = false);
      _toast('Impossible de charger cette image');
    }
  }

  Future<void> _deletePhoto(Map<String, dynamic> photo) async {
    final id = photo['id']?.toString();
    if (id == null) return;
    final ok = await _repository.deleteRealisation(id);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _photos = _photos.where((p) => p['id']?.toString() != id).toList();
        if (_index >= _photos.length && _index > 0) _index = _photos.length - 1;
      });
    } else {
      _toast('Impossible de supprimer cette photo');
    }
  }

  void _goTo(int target) {
    if (target < 0 || target >= _photos.length) return;
    _controller.animateToPage(target, duration: const Duration(milliseconds: 250), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_outlined, size: 18, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              const Text(
                'Réalisations',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
              const Spacer(),
              if (widget.editable)
                _uploading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : OutlinedButton.icon(
                        onPressed: _addPhoto,
                        icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                        label: const Text('Ajouter'),
                      ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const SizedBox(height: 190, child: Center(child: CircularProgressIndicator()))
          else if (_photos.isEmpty)
            Container(
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
              child: Text(
                widget.editable ? 'Aucune photo pour le moment — ajoutez-en une' : 'Aucune réalisation publiée',
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
            )
          else
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 190,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _photos.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) {
                      final photo = _photos[i];
                      final bytes = decodeDataUri(photo['imageData'] as String?);
                      final caption = photo['caption'] as String?;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              bytes != null
                                  ? Image.memory(bytes, fit: BoxFit.cover)
                                  : Container(
                                      color: const Color(0xFFF1F5F9),
                                      child: const Center(
                                        child: Icon(Icons.image_not_supported_outlined, color: Color(0xFFCBD5E1)),
                                      ),
                                    ),
                              if (caption != null && caption.isNotEmpty)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [Colors.black.withOpacity(0.65), Colors.black.withOpacity(0)],
                                      ),
                                    ),
                                    child: Text(
                                      caption,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                                  ),
                                ),
                              if (widget.editable)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => _deletePhoto(photo),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), shape: BoxShape.circle),
                                      child: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_photos.length > 1) ...[
                  Positioned(
                    left: 0,
                    child: _NavArrow(icon: Icons.chevron_left_rounded, onTap: _index > 0 ? () => _goTo(_index - 1) : null),
                  ),
                  Positioned(
                    right: 0,
                    child: _NavArrow(
                      icon: Icons.chevron_right_rounded,
                      onTap: _index < _photos.length - 1 ? () => _goTo(_index + 1) : null,
                    ),
                  ),
                ],
              ],
            ),
          if (_photos.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_photos.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(onTap != null ? 0.95 : 0.5),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)],
          ),
          child: Icon(icon, size: 20, color: onTap != null ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
        ),
      ),
    );
  }
}
