import 'package:flutter/material.dart';

class _Realisation {
  final String imageUrl;
  final String caption;
  const _Realisation(this.imageUrl, this.caption);
}

const List<_Realisation> _realisations = [
  _Realisation(
    'https://images.unsplash.com/photo-1676210134188-4c05dd172f89?auto=format&fit=crop&w=900&q=75',
    'Réfection de plomberie murale',
  ),
  _Realisation(
    'https://images.unsplash.com/photo-1676210133055-eab6ef033ce3?auto=format&fit=crop&w=900&q=75',
    'Installation sous évier',
  ),
  _Realisation(
    'https://images.unsplash.com/photo-1676630656246-3047520adfdf?auto=format&fit=crop&w=900&q=75',
    'Travaux électriques muraux',
  ),
  _Realisation(
    'https://images.unsplash.com/photo-1748442001865-5583ec02ae22?auto=format&fit=crop&w=900&q=75',
    'Inspection et maintenance',
  ),
];

/// Carrousel illustrant les réalisations passées d'un prestataire, affiché
/// sur son profil. Images d'illustration (le projet n'a pas encore de
/// systeme d'upload de photos par les prestataires).
class RealisationsCarousel extends StatefulWidget {
  const RealisationsCarousel({super.key});

  @override
  State<RealisationsCarousel> createState() => _RealisationsCarouselState();
}

class _RealisationsCarouselState extends State<RealisationsCarousel> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.86);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              Text(
                'Réalisations',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            child: PageView.builder(
              controller: _controller,
              itemCount: _realisations.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final item = _realisations[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(color: const Color(0xFFF1F5F9));
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFF1F5F9),
                            child: const Center(
                              child: Icon(Icons.image_not_supported_outlined, color: Color(0xFFCBD5E1)),
                            ),
                          ),
                        ),
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
                              item.caption,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_realisations.length, (i) {
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
      ),
    );
  }
}
