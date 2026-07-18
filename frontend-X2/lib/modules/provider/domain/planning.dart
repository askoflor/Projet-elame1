import 'package:flutter/material.dart';

class PlanningSlot {
  final String id;
  final DateTime date;
  final TimeOfDay heureDebut;
  final TimeOfDay heureFin;
  final String missionId;
  final String? missionTitre;
  final String? clientNom;
  final String? adresse;
  final PlanningSlotType type;

  PlanningSlot({
    required this.id,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    this.missionId = '',
    this.missionTitre,
    this.clientNom,
    this.adresse,
    this.type = PlanningSlotType.mission,
  });
}

enum PlanningSlotType { mission, disponible, indisponible, pause }

class PlanningSemaine {
  final DateTime debutSemaine;
  final List<PlanningJour> jours;

  PlanningSemaine({required this.debutSemaine, required this.jours});
}

class PlanningJour {
  final DateTime date;
  final bool estAujourdhui;
  final List<PlanningSlot> slots;

  PlanningJour({required this.date, required this.estAujourdhui, required this.slots});
}

class DisponibiliteSemaine {
  final int jourSemaine;
  final TimeOfDay debut;
  final TimeOfDay fin;
  final bool actif;

  DisponibiliteSemaine({
    required this.jourSemaine,
    required this.debut,
    required this.fin,
    this.actif = true,
  });

  String get jourNom {
    const jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return jourSemaine >= 0 && jourSemaine < 7 ? jours[jourSemaine] : '';
  }
}
