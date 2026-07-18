import 'package:flutter/material.dart';
import '../../domain/provider_profile.dart';
import '../../domain/mission.dart';
import '../../domain/revenue.dart';
import '../../domain/planning.dart';
import '../../domain/notification_model.dart';

class MockProviderData {
  static final profile = ProviderProfile(
    id: '1',
    nom: 'Mensah',
    prenom: 'Kofi',
    email: 'kofi.mensah@email.com',
    phone: '+225 01 02 03 04 05',
    specialite: 'Électricien',
    note: 4.8,
    missionsRealisees: 142,
    missionsTotal: 156,
    tauxSatisfaction: 97,
    revenuMensuel: 1250000,
    revenuTotal: 18500000,
    adresse: '15 Rue des Artisans',
    ville: 'Abidjan',
    pays: 'Côte d\'Ivoire',
    competences: ['Installation électrique', 'Tableaux électriques', 'Dépannage urgent', 'Câblage réseau', 'Domotique'],
    description: 'Électricien professionnel avec plus de 8 ans d\'expérience. Spécialisé dans l\'installation électrique résidentielle et industrielle, la maintenance et le dépannage.',
    certifications: 'Certifié EDF – Norme NF C 15-100',
    dateInscription: DateTime(2023, 1, 15),
    disponible: true,
  );

  static List<Mission> get missionsDuJour {
    final today = DateTime.now();
    return [
      Mission(
        id: 'M001',
        clientNom: 'Kouamé',
        clientPrenom: 'Alima',
        service: 'Installation électrique',
        date: today,
        heureDebut: DateTime(today.year, today.month, today.day, 8, 0),
        heureFin: DateTime(today.year, today.month, today.day, 10, 0),
        montant: 25000,
        adresse: '15 Rue des Jardins, Cocody',
        description: 'Installation complète du tableau électrique et câblage des prises.',
        statut: MissionStatus.confirmed,
      ),
      Mission(
        id: 'M002',
        clientNom: 'Traoré',
        clientPrenom: 'Paul',
        service: 'Câblage réseau',
        date: today,
        heureDebut: DateTime(today.year, today.month, today.day, 11, 0),
        heureFin: DateTime(today.year, today.month, today.day, 13, 0),
        montant: 18000,
        adresse: '45 Avenue Kennedy, Plateau',
        description: 'Câblage réseau pour bureau 5 postes de travail.',
        statut: MissionStatus.confirmed,
      ),
      Mission(
        id: 'M003',
        clientNom: 'Diallo',
        clientPrenom: 'Fatou',
        service: 'Dépannage urgent',
        date: today,
        heureDebut: DateTime(today.year, today.month, today.day, 15, 0),
        heureFin: DateTime(today.year, today.month, today.day, 17, 0),
        montant: 35000,
        adresse: '8 Boulevard de la Paix, Marcory',
        description: 'Court-circuit général. Remplissage du disjoncteur et vérification réseau.',
        statut: MissionStatus.pending,
      ),
    ];
  }

  static List<Mission> get toutesMissions {
    final today = DateTime.now();
    return [
      ...missionsDuJour,
      Mission(
        id: 'M004',
        clientNom: 'Koné',
        clientPrenom: 'Moussa',
        service: 'Installation domotique',
        date: today.subtract(const Duration(days: 1)),
        heureDebut: DateTime(today.year, today.month, today.day - 1, 9, 0),
        heureFin: DateTime(today.year, today.month, today.day - 1, 12, 0),
        montant: 45000,
        adresse: '12 Rue de la Paix, Yopougon',
        statut: MissionStatus.completed,
      ),
      Mission(
        id: 'M005',
        clientNom: 'Soro',
        clientPrenom: 'Aminata',
        service: 'Réparation éclairage',
        date: today.subtract(const Duration(days: 2)),
        heureDebut: DateTime(today.year, today.month, today.day - 2, 14, 0),
        heureFin: DateTime(today.year, today.month, today.day - 2, 16, 0),
        montant: 12000,
        adresse: '5 Rue des Fleurs, Treichville',
        statut: MissionStatus.completed,
      ),
      Mission(
        id: 'M006',
        clientNom: 'Bamba',
        clientPrenom: 'Ibrahim',
        service: 'Mise aux normes',
        date: today.add(const Duration(days: 3)),
        heureDebut: DateTime(today.year, today.month, today.day + 3, 8, 0),
        heureFin: DateTime(today.year, today.month, today.day + 3, 17, 0),
        montant: 85000,
        adresse: '22 Rue des Entreprises, Zone 4',
        statut: MissionStatus.pending,
      ),
      Mission(
        id: 'M007',
        clientNom: 'Touré',
        clientPrenom: 'Mariam',
        service: 'Dépannage urgence',
        date: today.subtract(const Duration(days: 3)),
        heureDebut: DateTime(today.year, today.month, today.day - 3, 20, 0),
        heureFin: DateTime(today.year, today.month, today.day - 3, 22, 0),
        montant: 0,
        adresse: '3 Rue Secours, Adjamé',
        statut: MissionStatus.cancelled,
      ),
    ];
  }

  static RevenueSummary get revenueSummary {
    return RevenueSummary(
      totalMois: 1250000,
      totalAnnee: 8250000,
      totalGlobal: 18500000,
      missionsMois: 18,
      missionsAnnee: 96,
      progression: 12.5,
      moyenneParMission: 69444,
    );
  }

  static List<RevenueChartPoint> get chartData {
    return [
      RevenueChartPoint(mois: 'Jan', montant: 680000, missions: 10),
      RevenueChartPoint(mois: 'Fév', montant: 520000, missions: 8),
      RevenueChartPoint(mois: 'Mar', montant: 890000, missions: 14),
      RevenueChartPoint(mois: 'Avr', montant: 750000, missions: 11),
      RevenueChartPoint(mois: 'Mai', montant: 920000, missions: 15),
      RevenueChartPoint(mois: 'Juin', montant: 1100000, missions: 17),
      RevenueChartPoint(mois: 'Juil', montant: 1250000, missions: 18),
    ];
  }

  static List<Revenue> get recentRevenus {
    return [
      Revenue(id: 'R001', date: DateTime.now(), libelle: 'Installation électrique - Alima K.', missionId: 'M001', clientNom: 'Kouamé', clientPrenom: 'Alima', montant: 25000, commission: 2500, net: 22500, statut: RevenueStatus.paid),
      Revenue(id: 'R002', date: DateTime.now(), libelle: 'Câblage réseau - Paul T.', missionId: 'M002', clientNom: 'Traoré', clientPrenom: 'Paul', montant: 18000, commission: 1800, net: 16200, statut: RevenueStatus.pending),
      Revenue(id: 'R003', date: DateTime.now().subtract(const Duration(days: 1)), libelle: 'Installation domotique - Moussa K.', missionId: 'M004', clientNom: 'Koné', clientPrenom: 'Moussa', montant: 45000, commission: 4500, net: 40500, statut: RevenueStatus.paid),
      Revenue(id: 'R004', date: DateTime.now().subtract(const Duration(days: 2)), libelle: 'Réparation éclairage - Aminata S.', missionId: 'M005', clientNom: 'Soro', clientPrenom: 'Aminata', montant: 12000, commission: 1200, net: 10800, statut: RevenueStatus.paid),
      Revenue(id: 'R005', date: DateTime.now().subtract(const Duration(days: 3)), libelle: 'Dépannage urgence - Mariam T.', missionId: 'M007', clientNom: 'Touré', clientPrenom: 'Mariam', montant: 30000, commission: 3000, net: 27000, statut: RevenueStatus.cancelled),
    ];
  }

  static PlanningSemaine get planningSemaine {
    final today = DateTime.now();
    final debutSemaine = today.subtract(Duration(days: today.weekday - 1));
    final jours = <PlanningJour>[];

    for (int i = 0; i < 7; i++) {
      final date = debutSemaine.add(Duration(days: i));
      final slots = <PlanningSlot>[];

      if (i < 5) {
        slots.add(PlanningSlot(
          id: 'S${i}1',
          date: date,
          heureDebut: const TimeOfDay(hour: 8, minute: 0),
          heureFin: const TimeOfDay(hour: 12, minute: 0),
          missionId: '',
          type: PlanningSlotType.disponible,
        ));
        if (i < 3) {
          slots.add(PlanningSlot(
            id: 'S${i}2',
            date: date,
            heureDebut: const TimeOfDay(hour: 14, minute: 0),
            heureFin: const TimeOfDay(hour: 17, minute: 0),
            missionId: 'M00${i + 1}',
            missionTitre: ['Installation élec.', 'Câblage réseau', 'Dépannage'][i],
            clientNom: ['Alima K.', 'Paul T.', 'Fatou D.'][i],
            adresse: ['Cocody', 'Plateau', 'Marcory'][i],
            type: PlanningSlotType.mission,
          ));
        } else {
          slots.add(PlanningSlot(
            id: 'S${i}3',
            date: date,
            heureDebut: const TimeOfDay(hour: 14, minute: 0),
            heureFin: const TimeOfDay(hour: 18, minute: 0),
            missionId: '',
            type: PlanningSlotType.disponible,
          ));
        }
      } else {
        slots.add(PlanningSlot(
          id: 'S${i}1',
          date: date,
          heureDebut: const TimeOfDay(hour: 9, minute: 0),
          heureFin: const TimeOfDay(hour: 13, minute: 0),
          missionId: '',
          type: PlanningSlotType.disponible,
        ));
      }

      jours.add(PlanningJour(
        date: date,
        estAujourdhui: i == today.weekday - 1,
        slots: slots,
      ));
    }

    return PlanningSemaine(debutSemaine: debutSemaine, jours: jours);
  }

  static List<DisponibiliteSemaine> get disponibilites {
    return [
      DisponibiliteSemaine(jourSemaine: 0, debut: const TimeOfDay(hour: 8, minute: 0), fin: const TimeOfDay(hour: 17, minute: 0), actif: true),
      DisponibiliteSemaine(jourSemaine: 1, debut: const TimeOfDay(hour: 8, minute: 0), fin: const TimeOfDay(hour: 18, minute: 0), actif: true),
      DisponibiliteSemaine(jourSemaine: 2, debut: const TimeOfDay(hour: 8, minute: 0), fin: const TimeOfDay(hour: 18, minute: 0), actif: true),
      DisponibiliteSemaine(jourSemaine: 3, debut: const TimeOfDay(hour: 8, minute: 0), fin: const TimeOfDay(hour: 18, minute: 0), actif: true),
      DisponibiliteSemaine(jourSemaine: 4, debut: const TimeOfDay(hour: 8, minute: 0), fin: const TimeOfDay(hour: 17, minute: 0), actif: true),
      DisponibiliteSemaine(jourSemaine: 5, debut: const TimeOfDay(hour: 9, minute: 0), fin: const TimeOfDay(hour: 13, minute: 0), actif: true),
      DisponibiliteSemaine(jourSemaine: 6, debut: const TimeOfDay(hour: 0, minute: 0), fin: const TimeOfDay(hour: 0, minute: 0), actif: false),
    ];
  }

  static List<ProviderNotification> get notifications {
    final now = DateTime.now();
    return [
      ProviderNotification(
        id: 'N001',
        titre: 'Nouvelle mission',
        message: 'Alima K. a réservé une installation électrique pour demain à 8h.',
        date: now.subtract(const Duration(minutes: 30)),
        type: NotificationType.nouvelleMission,
        missionId: 'M001',
        emetteurNom: 'Alima K.',
      ),
      ProviderNotification(
        id: 'N002',
        titre: 'Paiement reçu',
        message: 'Paiement de 25 000 FCFA confirmé pour la mission M001.',
        date: now.subtract(const Duration(hours: 2)),
        type: NotificationType.paiementRecu,
        missionId: 'M001',
      ),
      ProviderNotification(
        id: 'N003',
        titre: 'Mission terminée',
        message: 'Moussa K. a confirmé la fin de la mission d\'installation domotique.',
        date: now.subtract(const Duration(hours: 5)),
        type: NotificationType.missionCompletee,
        missionId: 'M004',
        emetteurNom: 'Moussa K.',
      ),
      ProviderNotification(
        id: 'N004',
        titre: 'Évaluation reçue',
        message: 'Aminata S. vous a noté 5 étoiles ! "Excellent travail, professionnel et ponctuel."',
        date: now.subtract(const Duration(days: 1)),
        type: NotificationType.evaluationRecue,
        emetteurNom: 'Aminata S.',
      ),
      ProviderNotification(
        id: 'N005',
        titre: 'Mission annulée',
        message: 'Mariam T. a annulé la mission de dépannage d\'urgence prévue hier.',
        date: now.subtract(const Duration(days: 2)),
        type: NotificationType.missionAnnulee,
        missionId: 'M007',
        emetteurNom: 'Mariam T.',
        lu: true,
      ),
      ProviderNotification(
        id: 'N006',
        titre: 'Rappel',
        message: 'Vous avez une mission dans 1 heure : Tableau électrique chez Paul T.',
        date: now.subtract(const Duration(days: 3)),
        type: NotificationType.rappel,
        missionId: 'M002',
        emetteurNom: 'Paul T.',
        lu: true,
      ),
      ProviderNotification(
        id: 'N007',
        titre: 'Nouvelle mission',
        message: 'Fatou D. a réservé un dépannage urgent pour cet après-midi à 15h.',
        date: now.subtract(const Duration(days: 3)),
        type: NotificationType.nouvelleMission,
        missionId: 'M003',
        emetteurNom: 'Fatou D.',
        lu: true,
      ),
    ];
  }

  static List<ProviderNotification> get notificationsNonLues =>
      notifications.where((n) => !n.lu).toList();

  static int get nombreNotificationsNonLues => notificationsNonLues.length;
}
