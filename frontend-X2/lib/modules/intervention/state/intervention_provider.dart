import 'package:flutter/material.dart';
import '../data/mock_interventions.dart';
import '../domain/intervention.dart';

/// État partagé du cycle de vie des interventions, consommé à la fois par
/// l'espace client et l'espace prestataire (une seule identité client et une
/// seule identité prestataire démo dans cette application, comme le reste
/// des données mock).
class InterventionProvider extends ChangeNotifier {
  List<Intervention> _all = List.of(mockInterventions);
  int _refCounter = 2419;
  String? lastCreatedReference;

  List<Intervention> get all => List.unmodifiable(_all);

  List<Intervention> get enAttente =>
      _all.where((i) => i.statut == InterventionStatus.attente).toList();
  List<Intervention> get enCours =>
      _all.where((i) => i.statut == InterventionStatus.encours).toList();
  List<Intervention> get terminees =>
      _all.where((i) => i.statut == InterventionStatus.terminee).toList();

  double get montantCeMois {
    final now = DateTime.now();
    return _all
        .where((i) =>
            i.montant != null &&
            i.statut != InterventionStatus.annulee &&
            i.date.year == now.year &&
            i.date.month == now.month)
        .fold<double>(0, (sum, i) => sum + i.montant!);
  }

  /// Heures déjà occupées par une intervention non annulée d'un prestataire
  /// à une date donnée — sert à griser les créneaux "Complet".
  Set<int> hoursBookedFor(String providerName, DateTime date) {
    return _all
        .where((i) =>
            i.providerName == providerName &&
            i.statut != InterventionStatus.annulee &&
            _sameDay(i.date, date))
        .expand((i) => i.heures)
        .toSet();
  }

  /// Un jour est verrouillé (non basculable par le prestataire) s'il porte
  /// déjà une intervention en attente ou en cours.
  bool isDateLocked(String providerName, DateTime date) {
    return _all.any((i) =>
        i.providerName == providerName &&
        _sameDay(i.date, date) &&
        (i.statut == InterventionStatus.attente || i.statut == InterventionStatus.encours));
  }

  Intervention creer({
    required String clientNom,
    required String clientPhone,
    required String providerName,
    required String service,
    required String titre,
    String description = '',
    required DateTime date,
    required List<int> heures,
    required String urgence,
    required String adresse,
  }) {
    final reference = 'INT-${_refCounter++}';
    final intervention = Intervention(
      reference: reference,
      clientNom: clientNom,
      clientPhone: clientPhone,
      providerName: providerName,
      service: service,
      titre: titre,
      description: description,
      date: date,
      heures: heures,
      urgence: urgence,
      adresse: adresse,
      statut: InterventionStatus.attente,
      creeLe: DateTime.now(),
    );
    _all = [intervention, ..._all];
    lastCreatedReference = reference;
    notifyListeners();
    return intervention;
  }

  void chiffrer(
    String reference, {
    required double montant,
    DateTime? dateConfirmee,
    String? note,
  }) {
    _updateByReference(reference, (i) => i.copyWith(
          montant: montant,
          date: dateConfirmee,
          notePrestataire: note,
          statut: InterventionStatus.encours,
        ));
  }

  void terminer(String reference) {
    _updateByReference(
        reference, (i) => i.copyWith(statut: InterventionStatus.terminee));
  }

  void annuler(String reference) {
    _updateByReference(
        reference, (i) => i.copyWith(statut: InterventionStatus.annulee));
  }

  void _updateByReference(
      String reference, Intervention Function(Intervention) update) {
    final index = _all.indexWhere((i) => i.reference == reference);
    if (index == -1) return;
    final next = List.of(_all);
    next[index] = update(next[index]);
    _all = next;
    notifyListeners();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
