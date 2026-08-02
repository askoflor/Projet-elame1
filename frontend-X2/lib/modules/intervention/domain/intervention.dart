import '../../../core/utils/date_parser.dart';

enum InterventionStatus { attente, encours, terminee, annulee }

InterventionStatus interventionStatusFromJson(dynamic value) {
  final name = (value as String? ?? 'ATTENTE').toLowerCase();
  return InterventionStatus.values.firstWhere(
    (s) => s.name == name,
    orElse: () => InterventionStatus.attente,
  );
}

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

  factory Intervention.fromJson(Map<String, dynamic> json) {
    return Intervention(
      reference: json['reference'] as String,
      clientNom: json['clientNom'] as String? ?? '',
      clientPhone: json['clientPhone'] as String? ?? '',
      providerName: json['providerName'] as String? ?? '',
      service: json['service'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: parseFlexibleDate(json['date']) ?? DateTime.now(),
      heures: (json['heures'] as List?)?.map((e) => e as int).toList() ?? [],
      urgence: json['urgence'] as String? ?? '',
      adresse: json['adresse'] as String? ?? '',
      montant: (json['montant'] as num?)?.toDouble(),
      notePrestataire: json['notePrestataire'] as String?,
      statut: interventionStatusFromJson(json['statut']),
      creeLe: parseFlexibleDate(json['creeLe']) ?? DateTime.now(),
      completionDescription: json['completionDescription'] as String?,
      completionPhotos: (json['completionPhotos'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }
}
