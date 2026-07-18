class Revenue {
  final String id;
  final DateTime date;
  final String libelle;
  final String missionId;
  final String clientNom;
  final String clientPrenom;
  final double montant;
  final double commission;
  final double net;
  final RevenueStatus statut;

  Revenue({
    required this.id,
    required this.date,
    required this.libelle,
    required this.missionId,
    required this.clientNom,
    required this.clientPrenom,
    required this.montant,
    this.commission = 0,
    required this.net,
    this.statut = RevenueStatus.paid,
  });

  String get clientNomComplet => '$clientPrenom $clientNom';
}

enum RevenueStatus { paid, pending, cancelled }

class RevenueSummary {
  final double totalMois;
  final double totalAnnee;
  final double totalGlobal;
  final int missionsMois;
  final int missionsAnnee;
  final double progression;
  final double moyenneParMission;

  RevenueSummary({
    required this.totalMois,
    required this.totalAnnee,
    required this.totalGlobal,
    required this.missionsMois,
    required this.missionsAnnee,
    required this.progression,
    required this.moyenneParMission,
  });
}

class RevenueChartPoint {
  final String mois;
  final double montant;
  final int missions;

  RevenueChartPoint({required this.mois, required this.montant, required this.missions});
}
