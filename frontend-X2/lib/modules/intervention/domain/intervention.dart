enum InterventionStatus { attente, encours, terminee, annulee }

class Intervention {
  final String reference;
  final String clientNom;
  final String clientPhone;
  final String providerName;
  final String service;
  final String titre;
  final String description;
  final DateTime date;
  final List<int> heures;
  final String urgence;
  final String adresse;
  final double? montant;
  final String? notePrestataire;
  final InterventionStatus statut;
  final DateTime creeLe;
  /// Compte-rendu redige par le prestataire a la cloture de l'intervention
  /// (obligatoire pour passer au statut "terminee").
  final String? completionDescription;
  /// Photos du travail realise, encodees en base64 (data URI), jointes au
  /// compte-rendu de cloture.
  final List<String> completionPhotos;

  const Intervention({
    required this.reference,
    required this.clientNom,
    required this.clientPhone,
    required this.providerName,
    required this.service,
    required this.titre,
    this.description = '',
    required this.date,
    required this.heures,
    required this.urgence,
    required this.adresse,
    this.montant,
    this.notePrestataire,
    this.statut = InterventionStatus.attente,
    required this.creeLe,
    this.completionDescription,
    this.completionPhotos = const [],
  });

  int get dureeHeures => heures.length;

  Intervention copyWith({
    double? montant,
    String? notePrestataire,
    InterventionStatus? statut,
    DateTime? date,
    String? completionDescription,
    List<String>? completionPhotos,
  }) {
    return Intervention(
      reference: reference,
      clientNom: clientNom,
      clientPhone: clientPhone,
      providerName: providerName,
      service: service,
      titre: titre,
      description: description,
      date: date ?? this.date,
      heures: heures,
      urgence: urgence,
      adresse: adresse,
      montant: montant ?? this.montant,
      notePrestataire: notePrestataire ?? this.notePrestataire,
      statut: statut ?? this.statut,
      creeLe: creeLe,
      completionDescription: completionDescription ?? this.completionDescription,
      completionPhotos: completionPhotos ?? this.completionPhotos,
    );
  }
}
