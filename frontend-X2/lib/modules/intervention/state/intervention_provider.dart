import 'package:flutter/material.dart';
import '../data/intervention_repository.dart';
import '../domain/intervention.dart';
import '../domain/provider_schedule_entry.dart';

/// Etat partage du cycle de vie des interventions, adosse a l'API backend
/// (`/api/v1/interventions`).
///
/// Un utilisateur peut etre a la fois prestataire ET client (un prestataire
/// peut commander un service aupres d'un autre prestataire), donc les deux
/// "vues" sont chargees et mises en cache separement :
/// - [mesReservations] : ce que l'utilisateur a lui-meme commande (cote client) ;
/// - [mesMissions] : ce qui lui est assigne en tant que prestataire.
///
/// Le planning d'un prestataire specifique (utilise pour griser les
/// creneaux deja pris sur son calendrier public) est charge a la demande
/// via [chargerPlanning].
class InterventionProvider extends ChangeNotifier {
  final InterventionRepository _repository;

  InterventionProvider({InterventionRepository? repository})
      : _repository = repository ?? InterventionRepository();

  List<Intervention> _mesReservations = [];
  List<Intervention> _mesMissions = [];
  bool _loading = false;
  String? lastCreatedReference;
  final Map<String, List<ProviderScheduleEntry>> _scheduleCache = {};

  /// Reservations faites par l'utilisateur en tant que client.
  List<Intervention> get mesReservations => List.unmodifiable(_mesReservations);

  /// Missions assignees a l'utilisateur en tant que prestataire.
  List<Intervention> get mesMissions => List.unmodifiable(_mesMissions);

  bool get isLoading => _loading;

  List<Intervention> get missionsEnAttente =>
      _mesMissions.where((i) => i.statut == InterventionStatus.attente).toList();
  List<Intervention> get missionsEnCours =>
      _mesMissions.where((i) => i.statut == InterventionStatus.encours).toList();
  List<Intervention> get missionsTerminees =>
      _mesMissions.where((i) => i.statut == InterventionStatus.terminee).toList();

  double get montantCeMoisMissions => _montantCeMois(_mesMissions);
  double get montantCeMoisReservations => _montantCeMois(_mesReservations);

  double _montantCeMois(List<Intervention> source) {
    final now = DateTime.now();
    return source
        .where((i) =>
            i.montant != null &&
            i.statut != InterventionStatus.annulee &&
            i.date.year == now.year &&
            i.date.month == now.month)
        .fold<double>(0, (sum, i) => sum + i.montant!);
  }

  Future<void> chargerMesReservations() async {
    _loading = true;
    notifyListeners();
    _mesReservations = await _repository.mesReservationsClient();
    _loading = false;
    notifyListeners();
  }

  Future<void> chargerMesMissions() async {
    _loading = true;
    notifyListeners();
    _mesMissions = await _repository.mesMissionsPrestataire();
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
      _mesReservations = [created, ..._mesReservations];
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
    _replaceMission(updated);
    return true;
  }

  Future<bool> terminerAvecRapport(
    String reference, {
    required String description,
    required List<String> photos,
  }) async {
    final updated = await _repository.terminer(reference, description: description, photos: photos);
    if (updated == null) return false;
    _replaceMission(updated);
    return true;
  }

  Future<bool> annuler(String reference) async {
    final updated = await _repository.annuler(reference);
    if (updated == null) return false;
    _replaceMission(updated);
    return true;
  }

  void _replaceMission(Intervention updated) {
    final index = _mesMissions.indexWhere((i) => i.reference == updated.reference);
    if (index == -1) {
      _mesMissions = [updated, ..._mesMissions];
    } else {
      final next = List.of(_mesMissions);
      next[index] = updated;
      _mesMissions = next;
    }
    notifyListeners();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
