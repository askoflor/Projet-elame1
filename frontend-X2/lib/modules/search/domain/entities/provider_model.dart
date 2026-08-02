import 'package:flutter/material.dart';

class ProviderModel {
  final String id;
  final String initials;
  final String name;
  final String specialty;
  final String location;
  final int interventions;
  final bool isAvailable;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final bool isCertified;
  final String price;
  final Color avatarColor;
  final Color avatarBgColor;
  final String about;
  final List<String> skills;
  final List<Map<String, String>> certifications;
  final List<ReviewModel> reviews;
  final String? photoUrl;

  const ProviderModel({
    this.id = '',
    required this.initials,
    required this.name,
    required this.specialty,
    required this.location,
    required this.interventions,
    required this.isAvailable,
    required this.tags,
    required this.rating,
    required this.reviewCount,
    required this.isCertified,
    required this.price,
    required this.avatarColor,
    required this.avatarBgColor,
    this.about = '',
    this.skills = const [],
    this.certifications = const [],
    this.reviews = const [],
    this.photoUrl,
  });

  String get successRate => '98%';
  String get formattedInterventions => '$interventions';
  String get formattedRating => rating.toStringAsFixed(1);

  /// Palette fixe utilisee pour deriver un avatar de couleur stable a partir
  /// de l'identifiant du prestataire, puisque le backend ne fournit pas de
  /// couleur (donnee purement presentation, pas une donnee metier).
  static const List<Color> _avatarColors = [
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFFD97706),
    Color(0xFF9333EA),
    Color(0xFFDB2777),
    Color(0xFF0D9488),
    Color(0xFFEA580C),
    Color(0xFF4F46E5),
  ];
  static const List<Color> _avatarBgColors = [
    Color(0xFFDBEAFE),
    Color(0xFFDCFCE7),
    Color(0xFFFEF3C7),
    Color(0xFFF3E8FF),
    Color(0xFFFCE7F3),
    Color(0xFFCCFBF1),
    Color(0xFFFFEDD5),
    Color(0xFFE0E7FF),
  ];

  /// Construit un [ProviderModel] a partir de la reponse JSON de
  /// `GET /api/v1/search/providers`. Les champs sans equivalent reel cote
  /// backend (avis/notes, competences, certifications detaillees, tarif
  /// fixe) restent volontairement vides/neutres tant qu'aucun systeme
  /// d'avis ou de tarification n'existe.
  factory ProviderModel.fromSearchJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final nom = json['nom'] as String? ?? '';
    final prenom = json['prenom'] as String? ?? '';
    final name = '$prenom $nom'.trim();
    final initials = ((prenom.isNotEmpty ? prenom[0] : '') + (nom.isNotEmpty ? nom[0] : '')).toUpperCase();
    final paletteIndex = id.hashCode.abs() % _avatarColors.length;
    return ProviderModel(
      id: id,
      initials: initials.isEmpty ? '?' : initials,
      name: name.isEmpty ? '—' : name,
      specialty: json['specialite'] as String? ?? '',
      location: (json['quartier'] as String?) ?? '',
      interventions: (json['missionsRealisees'] as num?)?.toInt() ?? 0,
      isAvailable: json['disponible'] as bool? ?? true,
      tags: const [],
      rating: 0,
      reviewCount: 0,
      isCertified: json['certifie'] as bool? ?? false,
      price: '',
      avatarColor: _avatarColors[paletteIndex],
      avatarBgColor: _avatarBgColors[paletteIndex],
      about: json['about'] as String? ?? '',
      skills: const [],
      certifications: const [],
      reviews: const [],
      photoUrl: json['photoUrl'] as String?,
    );
  }
}

class ReviewModel {
  final String initials;
  final String name;
  final String date;
  final int rating;
  final String text;

  const ReviewModel({
    required this.initials,
    required this.name,
    required this.date,
    required this.rating,
    required this.text,
  });
}
