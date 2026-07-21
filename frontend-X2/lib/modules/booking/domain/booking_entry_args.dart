import '../../search/domain/entities/provider_model.dart';

/// Payload transmis à la route de réservation lorsqu'un client valide une
/// sélection de créneaux depuis le calendrier du profil d'un prestataire.
/// C'est la seule façon d'entrer dans le parcours de réservation.
class BookingEntryArgs {
  final ProviderModel provider;
  final DateTime date;
  final List<int> hours;

  const BookingEntryArgs({
    required this.provider,
    required this.date,
    required this.hours,
  });
}
