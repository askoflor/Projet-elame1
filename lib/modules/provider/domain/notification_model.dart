class ProviderNotification {
  final String id;
  final String titre;
  final String message;
  final DateTime date;
  final bool lu;
  final NotificationType type;
  final String? missionId;
  final String? emetteurNom;

  ProviderNotification({
    required this.id,
    required this.titre,
    required this.message,
    required this.date,
    this.lu = false,
    this.type = NotificationType.info,
    this.missionId,
    this.emetteurNom,
  });

  ProviderNotification copyWith({bool? lu}) {
    return ProviderNotification(
      id: id,
      titre: titre,
      message: message,
      date: date,
      lu: lu ?? this.lu,
      type: type,
      missionId: missionId,
      emetteurNom: emetteurNom,
    );
  }
}

enum NotificationType {
  nouvelleMission,
  missionAnnulee,
  missionCompletee,
  paiementRecu,
  evaluationRecue,
  rappel,
  info,
}

class NotificationGroupe {
  final String titre;
  final List<ProviderNotification> notifications;

  NotificationGroupe({required this.titre, required this.notifications});
}
