import 'package:flutter/material.dart';
import '../data/intervention_repository.dart';
import '../domain/intervention.dart';
import '../domain/provider_schedule_entry.dart';

/// Etat partage du cycle de vie des interventions, adosse a l'API backend
/// (`/api/v1/interventions`). `all` reflete les interventions du client
/// connecte (ses reservations) ou du prestataire connecte (ses missions)
/// selon le role, chargees via [chargerMesInterventions]. Le planning d'un
/// prestataire specifique (utilise pour griser les creneaux deja pris sur
/// son calendrier public) est charge a la demande via [chargerPlanning].
class InterventionProvider extends ChangeNotifier {
  final InterventionRepository _repository;

  InterventionProvider({InterventionRepository? repository})
      : _repository = repository ?? InterventionRepository();

  List<Intervention> _all = [];
  bool _loading = false;
  String? lastCreatedReference;
  final Map<String, List<ProviderScheduleEntry>> _scheduleCache = {};

  List<Intervention> get all => List.unmodifiable(_all);
  bool get isLoading => _loading;

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

  Future<void> chargerMesInterventions() async {
    _loading = true;
    notifyListeners();
    _all = await _repository.mesInterventions();
    _loading = false;
    notifyListeners();
  }

  /// Charge (ou rafraichit) le planning public d'un prestataire : necessaire
  /// avant d'utiliser [hoursBookedFor]/[isDateLocked] pour ce prestataire.
  Future<void> chargerPlanning(String providerName) async {
    final entries = await _repository.planningPrestataire(providerName);
    _scheduleCache[providerName] = entries;
    notifyListeners();
  }

  /// Heures deja occupees par une intervention non annulee d'un prestataire
  /// a une date donnee — sert a griser les creneaux "Complet". Necessite un
  /// appel prealable a [chargerPlanning] pour ce prestataire.
  Set<int> hoursBookedFor(String providerName, DateTime date) {
    final entries = _scheduleCache[providerName] ?? const [];
    return entries
        .where((e) => _sameDay(e.date, date))
        .expand((e) => e.heures)
        .toSet();
  }

  /// Un jour est verrouille (non basculable par le prestataire) s'il porte
  /// deja une intervention en attente ou en cours.
  bool isDateLocked(String providerName, DateTime date) {
    final entries = _scheduleCache[providerName] ?? const [];
    return entries.any((e) =>
        _sameDay(e.date, date) &&
        (e.statut == InterventionStatus.attente || e.statut == InterventionStatus.encours));
  }

  Future<Intervention?> creer({
    required String providerName,
    required String service,
    required String titre,
    String description = '',
    required DateTime date,
    required List<int> heures,
    required String urgence,
    required String adresse,
  }) async {
    final created = await _repository.creer(
      providerName: providerName,
      service: service,
      titre: titre,
      description: description,
      date: date,
      heures: heures,
      urgence: urgence,
      adresse: adresse,
    );
    if (created != null) {
      _all = [created, ..._all];
      lastCreatedReference = created.reference;
      notifyListeners();
    }
    return created;
  }

  Future<bool> chiffrer(
    String reference, {
    required double montant,
    DateTime? dateConfirmee,
    String? note,
  }) async {
    final updated = await _repository.chiffrer(reference, montant: montant, dateConfirmee: dateConfirmee, note: note);
    if (updated == null) return false;
    _replace(updated);
    return true;
  }

  Future<bool> terminerAvecRapport(
    String reference, {
    required String description,
    required List<String> photos,
  }) async {
    final updated = await _repository.terminer(reference, description: description, photos: photos);
    if (updated == null) return false;
    _replace(updated);
    return true;
  }

  Future<bool> annuler(String reference) async {
    final updated = await _repository.annuler(reference);
    if (updated == null) return false;
    _replace(updated);
    return true;
  }

  void _replace(Intervention updated) {
    final index = _all.indexWhere((i) => i.reference == updated.reference);
    if (index == -1) {
      _all = [updated, ..._all];
    } else {
      final next = List.of(_all);
      next[index] = updated;
      _all = next;
    }
    notifyListeners();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
