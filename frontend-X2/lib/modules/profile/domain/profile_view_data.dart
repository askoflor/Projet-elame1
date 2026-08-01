import '../../auth/domain/auth_model.dart';
import '../../provider/domain/provider_profile.dart';
import '../../search/domain/entities/provider_model.dart';

class CertificationDisplay {
  final String title;
  final String subtitle;
  final bool pending;

  const CertificationDisplay({required this.title, required this.subtitle, this.pending = false});
}

class ReviewDisplay {
  final String initials;
  final String name;
  final String date;
  final int rating;
  final String text;

  const ReviewDisplay({
    required this.initials,
    required this.name,
    required this.date,
    required this.rating,
    required this.text,
  });
}

/// Adaptateur d'affichage unifiant les deux sources de données du profil :
/// `ProviderModel` (lecture seule, résultats de recherche) et
/// `ProviderProfile` (édition, prestataire connecté sur son propre profil).
class ProfileViewData {
  final String initials;
  final String name;
  final String specialty;
  final String ville;
  final bool isAvailable;
  final bool isCertified;
  final String formattedInterventions;
  final String formattedRating;
  final String successRate;
  final List<String> skills;
  final List<CertificationDisplay> certifications;
  final String about;
  final int reviewCount;
  final List<ReviewDisplay> reviews;
  final String? photoUrl;

  const ProfileViewData({
    required this.initials,
    required this.name,
    required this.specialty,
    required this.ville,
    required this.isAvailable,
    required this.isCertified,
    required this.formattedInterventions,
    required this.formattedRating,
    required this.successRate,
    required this.skills,
    required this.certifications,
    required this.about,
    required this.reviewCount,
    required this.reviews,
    this.photoUrl,
  });

  factory ProfileViewData.fromProviderModel(ProviderModel p) {
    return ProfileViewData(
      initials: p.initials,
      name: p.name,
      specialty: p.specialty,
      ville: p.location,
      isAvailable: p.isAvailable,
      isCertified: p.isCertified,
      formattedInterventions: p.formattedInterventions,
      formattedRating: p.formattedRating,
      successRate: p.successRate,
      skills: p.skills,
      certifications: p.certifications
          .map((c) => CertificationDisplay(title: c['title'] ?? '', subtitle: c['date'] ?? ''))
          .toList(),
      about: p.about,
      reviewCount: p.reviewCount,
      reviews: p.reviews
          .map((r) => ReviewDisplay(initials: r.initials, name: r.name, date: r.date, rating: r.rating, text: r.text))
          .toList(),
    );
  }

  /// [realUser] et [certifie] proviennent du compte reellement inscrit
  /// (AuthProvider) : nom, metier et badge "Certifie" doivent refleter les
  /// informations d'inscription reelles plutot que le profil de demonstration
  /// (competences, calendrier, avis...) qui reste mocke.
  factory ProfileViewData.fromProviderProfile(ProviderProfile p, {UserModel? realUser, bool certifie = false}) {
    final realName = realUser != null ? '${realUser.prenom} ${realUser.nom}'.trim() : '';
    final realSpecialty = realUser?.specialite;
    return ProfileViewData(
      initials: realName.isNotEmpty ? _initialsFromName(realName) : p.initiales,
      name: realName.isNotEmpty ? realName : p.nomComplet,
      specialty: (realSpecialty != null && realSpecialty.isNotEmpty) ? realSpecialty : p.specialite,
      ville: p.ville,
      isAvailable: p.disponible,
      isCertified: certifie,
      formattedInterventions: '${p.missionsRealisees}',
      formattedRating: p.note.toStringAsFixed(1),
      successRate: '${p.tauxSatisfaction.toStringAsFixed(0)}%',
      skills: p.competences,
      certifications: p.certifications
          .map((c) => CertificationDisplay(
                title: c.titre,
                subtitle: c.organisme,
                pending: c.enAttenteVerification,
              ))
          .toList(),
      about: p.description,
      reviewCount: 0,
      reviews: const [],
      photoUrl: realUser?.photoUrl,
    );
  }

  static String _initialsFromName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
