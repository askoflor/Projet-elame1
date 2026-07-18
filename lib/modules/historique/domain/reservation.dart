enum ReservationStatus { pending, confirmed, completed, cancelled }

class Reservation {
  final String id;
  final String reference;
  final String serviceKey;
  final String serviceName;
  final String providerName;
  final String providerInitials;
  final String providerPhoto;
  final double montant;
  final DateTime dateReservation;
  final DateTime? dateIntervention;
  final String heureSlot;
  final String adresse;
  final String description;
  final ReservationStatus statut;
  final String paymentMethod;
  final bool annulable;

  Reservation({
    required this.id,
    required this.reference,
    required this.serviceKey,
    required this.serviceName,
    required this.providerName,
    this.providerInitials = '',
    this.providerPhoto = '',
    required this.montant,
    required this.dateReservation,
    this.dateIntervention,
    this.heureSlot = '',
    this.adresse = '',
    this.description = '',
    this.statut = ReservationStatus.pending,
    this.paymentMethod = '',
    this.annulable = true,
  });

  String get formattedDate {
    const mois = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return '${dateIntervention?.day ?? dateReservation.day} ${mois[dateIntervention?.month ?? dateReservation.month - 1]} ${dateIntervention?.year ?? dateReservation.year}';
  }

  Reservation copyWith({ReservationStatus? statut, bool? annulable}) {
    return Reservation(
      id: id,
      reference: reference,
      serviceKey: serviceKey,
      serviceName: serviceName,
      providerName: providerName,
      providerInitials: providerInitials,
      providerPhoto: providerPhoto,
      montant: montant,
      dateReservation: dateReservation,
      dateIntervention: dateIntervention,
      heureSlot: heureSlot,
      adresse: adresse,
      description: description,
      statut: statut ?? this.statut,
      paymentMethod: paymentMethod,
      annulable: annulable ?? this.annulable,
    );
  }
}
