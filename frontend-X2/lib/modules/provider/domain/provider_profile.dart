import 'certification.dart';

class ProviderProfile {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String phone;
  final String photoUrl;
  final String specialite;
  final double note;
  final int missionsRealisees;
  final int missionsTotal;
  final double tauxSatisfaction;
  final double revenuMensuel;
  final double revenuTotal;
  final String adresse;
  final String ville;
  final String pays;
  final List<String> competences;
  final String description;
  final List<Certification> certifications;
  final DateTime dateInscription;
  final bool disponible;

  ProviderProfile({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.phone,
    this.photoUrl = '',
    required this.specialite,
    this.note = 0,
    this.missionsRealisees = 0,
    this.missionsTotal = 0,
    this.tauxSatisfaction = 0,
    this.revenuMensuel = 0,
    this.revenuTotal = 0,
    this.adresse = '',
    this.ville = '',
    this.pays = '',
    this.competences = const [],
    this.description = '',
    this.certifications = const [],
    DateTime? dateInscription,
    this.disponible = true,
  }) : dateInscription = dateInscription ?? DateTime.now();

  String get nomComplet => '$prenom $nom';
  String get initiales => '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}';

  ProviderProfile copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    String? phone,
    String? photoUrl,
    String? specialite,
    double? note,
    int? missionsRealisees,
    int? missionsTotal,
    double? tauxSatisfaction,
    double? revenuMensuel,
    double? revenuTotal,
    String? adresse,
    String? ville,
    String? pays,
    List<String>? competences,
    String? description,
    List<Certification>? certifications,
    DateTime? dateInscription,
    bool? disponible,
  }) {
    return ProviderProfile(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      specialite: specialite ?? this.specialite,
      note: note ?? this.note,
      missionsRealisees: missionsRealisees ?? this.missionsRealisees,
      missionsTotal: missionsTotal ?? this.missionsTotal,
      tauxSatisfaction: tauxSatisfaction ?? this.tauxSatisfaction,
      revenuMensuel: revenuMensuel ?? this.revenuMensuel,
      revenuTotal: revenuTotal ?? this.revenuTotal,
      adresse: adresse ?? this.adresse,
      ville: ville ?? this.ville,
      pays: pays ?? this.pays,
      competences: competences ?? this.competences,
      description: description ?? this.description,
      certifications: certifications ?? this.certifications,
      dateInscription: dateInscription ?? this.dateInscription,
      disponible: disponible ?? this.disponible,
    );
  }
}
