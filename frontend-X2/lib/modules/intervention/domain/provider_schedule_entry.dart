import '../../../core/utils/date_parser.dart';
import 'intervention.dart';

/// Entree "publique" du planning d'un prestataire (date + heures occupees +
/// statut), sans donnee client, utilisee pour griser les creneaux deja pris
/// quand un client consulte le calendrier de ce prestataire.
class ProviderScheduleEntry {
  final DateTime date;
  final List<int> heures;
  final InterventionStatus statut;

  const ProviderScheduleEntry({required this.date, required this.heures, required this.statut});

  factory ProviderScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ProviderScheduleEntry(
      date: parseFlexibleDate(json['date']) ?? DateTime.now(),
      heures: (json['heures'] as List?)?.map((e) => e as int).toList() ?? [],
      statut: interventionStatusFromJson(json['statut']),
    );
  }
}
