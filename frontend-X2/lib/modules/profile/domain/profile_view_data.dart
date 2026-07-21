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

  factory ProfileViewData.fromProviderProfile(ProviderProfile p) {
    return ProfileViewData(
      initials: p.initiales,
      name: p.nomComplet,
      specialty: p.specialite,
      ville: p.ville,
      isAvailable: p.disponible,
      isCertified: p.certifications.isNotEmpty,
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
    );
  }
}
