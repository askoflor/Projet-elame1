class Certification {
  final String titre;
  final String organisme;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final bool enAttenteVerification;

  const Certification({
    required this.titre,
    required this.organisme,
    this.dateDebut,
    this.dateFin,
    this.enAttenteVerification = false,
  });

  Certification copyWith({
    String? titre,
    String? organisme,
    DateTime? dateDebut,
    DateTime? dateFin,
    bool? enAttenteVerification,
  }) {
    return Certification(
      titre: titre ?? this.titre,
      organisme: organisme ?? this.organisme,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      enAttenteVerification: enAttenteVerification ?? this.enAttenteVerification,
    );
  }
}
