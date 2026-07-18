import 'package:flutter/material.dart';
import '../../domain/reservation.dart';

class MockReservations {
  static List<Reservation> get all {
    final now = DateTime.now();
    return [
      Reservation(
        id: 'R001',
        reference: 'SC-20260701-12345',
        serviceKey: 'electricite',
        serviceName: 'Électricité',
        providerName: 'Kofi Mensah',
        providerInitials: 'KM',
        montant: 25000,
        dateReservation: now.subtract(const Duration(days: 5)),
        dateIntervention: now.subtract(const Duration(days: 3)),
        heureSlot: '10:00 - 12:00',
        adresse: '15 Rue des Jardins, Cocody',
        description: 'Installation complète du tableau électrique',
        statut: ReservationStatus.completed,
        paymentMethod: 'Orange Money',
      ),
      Reservation(
        id: 'R002',
        reference: 'SC-20260703-67890',
        serviceKey: 'plomberie',
        serviceName: 'Plomberie',
        providerName: 'Amara Koné',
        providerInitials: 'AK',
        montant: 18000,
        dateReservation: now.subtract(const Duration(days: 2)),
        dateIntervention: now.add(const Duration(days: 1)),
        heureSlot: '14:00 - 16:00',
        adresse: '45 Avenue Kennedy, Plateau',
        description: 'Réparation fuite d\'eau salle de bain',
        statut: ReservationStatus.confirmed,
        paymentMethod: 'MTN MoMo',
      ),
      Reservation(
        id: 'R003',
        reference: 'SC-20260704-34567',
        serviceKey: 'climatisation',
        serviceName: 'Climatisation',
        providerName: 'Sandra Ngo',
        providerInitials: 'SN',
        montant: 35000,
        dateReservation: now.subtract(const Duration(days: 1)),
        dateIntervention: null,
        heureSlot: '09:00 - 11:00',
        adresse: '8 Boulevard de la Paix, Marcory',
        description: 'Installation climatiseur 9000 BTU',
        statut: ReservationStatus.pending,
        paymentMethod: 'Wave',
        annulable: true,
      ),
      Reservation(
        id: 'R004',
        reference: 'SC-20260628-90123',
        serviceKey: 'maintenance',
        serviceName: 'Maintenance',
        providerName: 'Paul Biya',
        providerInitials: 'PB',
        montant: 12000,
        dateReservation: now.subtract(const Duration(days: 10)),
        dateIntervention: now.subtract(const Duration(days: 8)),
        heureSlot: '15:00 - 17:00',
        adresse: '12 Rue de la Paix, Yopougon',
        description: 'Maintenance préventive climatisation',
        statut: ReservationStatus.completed,
        paymentMethod: 'Orange Money',
      ),
      Reservation(
        id: 'R005',
        reference: 'SC-20260625-45678',
        serviceKey: 'peinture',
        serviceName: 'Peinture',
        providerName: 'Marie Claire',
        providerInitials: 'MC',
        montant: 45000,
        dateReservation: now.subtract(const Duration(days: 14)),
        dateIntervention: now.subtract(const Duration(days: 12)),
        heureSlot: '08:00 - 17:00',
        adresse: '22 Rue des Fleurs, Treichville',
        description: 'Peinture complète salon + 2 chambres',
        statut: ReservationStatus.completed,
        paymentMethod: 'Cash',
      ),
      Reservation(
        id: 'R006',
        reference: 'SC-20260705-78901',
        serviceKey: 'electricite',
        serviceName: 'Électricité',
        providerName: 'Kofi Mensah',
        providerInitials: 'KM',
        montant: 42000,
        dateReservation: now,
        dateIntervention: now.add(const Duration(days: 5)),
        heureSlot: '08:00 - 12:00',
        adresse: '3 Rue des Entreprises, Zone 4',
        description: 'Mise aux normes électriques complète',
        statut: ReservationStatus.pending,
        paymentMethod: 'MTN MoMo',
        annulable: true,
      ),
      Reservation(
        id: 'R007',
        reference: 'SC-20260620-23456',
        serviceKey: 'jardinage',
        serviceName: 'Jardinage',
        providerName: 'Yves Landry',
        providerInitials: 'YL',
        montant: 20000,
        dateReservation: now.subtract(const Duration(days: 20)),
        dateIntervention: now.subtract(const Duration(days: 18)),
        heureSlot: '07:00 - 11:00',
        adresse: '5 Avenue de la Liberté, Angré',
        description: 'Tonte pelouse + taille haies',
        statut: ReservationStatus.cancelled,
        paymentMethod: 'Wave',
      ),
    ];
  }

  static List<Reservation> get actives =>
      all.where((r) => r.statut == ReservationStatus.confirmed || r.statut == ReservationStatus.pending).toList();

  static List<Reservation> get terminees =>
      all.where((r) => r.statut == ReservationStatus.completed).toList();

  static List<Reservation> get annulees =>
      all.where((r) => r.statut == ReservationStatus.cancelled).toList();

  static int get countActives => actives.length;
  static int get countTerminees => terminees.length;
  static int get countAnnulees => annulees.length;
  static double get totalDepense => all.where((r) => r.statut != ReservationStatus.cancelled).fold(0, (sum, r) => sum + r.montant);
}
