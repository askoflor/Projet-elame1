import 'package:flutter/material.dart';
import '../domain/reservation.dart';
import '../data/models/mock_reservations.dart';

class ReservationHistoryProvider extends ChangeNotifier {
  List<Reservation> _allReservations = [];

  List<Reservation> get all => _allReservations;
  List<Reservation> get actives => _allReservations.where((r) => r.statut == ReservationStatus.pending || r.statut == ReservationStatus.confirmed).toList();
  List<Reservation> get terminees => _allReservations.where((r) => r.statut == ReservationStatus.completed).toList();
  List<Reservation> get annulees => _allReservations.where((r) => r.statut == ReservationStatus.cancelled).toList();

  int get countActives => actives.length;
  int get countTerminees => terminees.length;
  int get countAnnulees => annulees.length;
  double get totalDepense => _allReservations.where((r) => r.statut != ReservationStatus.cancelled).fold(0, (sum, r) => sum + r.montant);

  ReservationHistoryProvider() {
    _loadData();
  }

  void _loadData() {
    _allReservations = MockReservations.all;
    notifyListeners();
  }

  void ajouterReservation(Reservation reservation) {
    _allReservations.insert(0, reservation);
    notifyListeners();
  }

  void annulerReservation(String id) {
    final idx = _allReservations.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    _allReservations[idx] = _allReservations[idx].copyWith(
      statut: ReservationStatus.cancelled,
      annulable: false,
    );
    notifyListeners();
  }

  void confirmerReservation(String id) {
    final idx = _allReservations.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    _allReservations[idx] = _allReservations[idx].copyWith(statut: ReservationStatus.confirmed);
    notifyListeners();
  }

  Reservation? getById(String id) {
    try {
      return _allReservations.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Reservation> filtrer({String? query, ReservationStatus? statut}) {
    var result = _allReservations;
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((r) =>
          r.providerName.toLowerCase().contains(q) ||
          r.serviceName.toLowerCase().contains(q) ||
          r.reference.toLowerCase().contains(q)).toList();
    }
    if (statut != null) {
      result = result.where((r) => r.statut == statut).toList();
    }
    return result;
  }
}
