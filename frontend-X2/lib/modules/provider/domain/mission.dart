enum MissionStatus { confirmed, pending, completed, cancelled }

class Mission {
  final String id;
  final String clientNom;
  final String clientPrenom;
  final String service;
  final DateTime date;
  final DateTime heureDebut;
  final DateTime heureFin;
  final double montant;
  final String adresse;
  final String ville;
  final String description;
  final MissionStatus statut;
  final String clientPhoto;

  Mission({
    required this.id,
    required this.clientNom,
    required this.clientPrenom,
    required this.service,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.montant,
    this.adresse = '',
    this.ville = '',
    this.description = '',
    this.statut = MissionStatus.pending,
    this.clientPhoto = '',
  });

  String get clientNomComplet => '$clientPrenom $clientNom';
  String get clientInitiales => '${clientPrenom.isNotEmpty ? clientPrenom[0] : ''}${clientNom.isNotEmpty ? clientNom[0] : ''}';

  Mission copyWith({
    String? id,
    String? clientNom,
    String? clientPrenom,
    String? service,
    DateTime? date,
    DateTime? heureDebut,
    DateTime? heureFin,
    double? montant,
    String? adresse,
    String? ville,
    String? description,
    MissionStatus? statut,
    String? clientPhoto,
  }) {
    return Mission(
      id: id ?? this.id,
      clientNom: clientNom ?? this.clientNom,
      clientPrenom: clientPrenom ?? this.clientPrenom,
      service: service ?? this.service,
      date: date ?? this.date,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
      montant: montant ?? this.montant,
      adresse: adresse ?? this.adresse,
      ville: ville ?? this.ville,
      description: description ?? this.description,
      statut: statut ?? this.statut,
      clientPhoto: clientPhoto ?? this.clientPhoto,
    );
  }
}
