import 'package:flutter/material.dart';
import '../domain/provider_profile.dart';
import '../domain/mission.dart';
import '../domain/revenue.dart';
import '../domain/planning.dart';
import '../domain/notification_model.dart';
import '../data/models/mock_provider_data.dart';

class ProviderDashboardProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _isLoading = false;

  ProviderProfile _profile = MockProviderData.profile;
  List<Mission> _missionsDuJour = [];
  List<Mission> _toutesMissions = [];
  RevenueSummary _revenueSummary = MockProviderData.revenueSummary;
  List<RevenueChartPoint> _chartData = [];
  List<Revenue> _recentRevenus = [];
  PlanningSemaine _planningSemaine = MockProviderData.planningSemaine;
  List<DisponibiliteSemaine> _disponibilites = [];
  List<ProviderNotification> _notifications = [];
  int _notificationsNonLues = 0;

  int get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;

  ProviderProfile get profile => _profile;
  List<Mission> get missionsDuJour => _missionsDuJour;
  List<Mission> get toutesMissions => _toutesMissions;
  RevenueSummary get revenueSummary => _revenueSummary;
  List<RevenueChartPoint> get chartData => _chartData;
  List<Revenue> get recentRevenus => _recentRevenus;
  PlanningSemaine get planningSemaine => _planningSemaine;
  List<DisponibiliteSemaine> get disponibilites => _disponibilites;
  List<ProviderNotification> get notifications => _notifications;
  int get notificationsNonLues => _notificationsNonLues;

  List<Mission> get missionsEnAttente => _toutesMissions.where((m) => m.statut == MissionStatus.pending).toList();
  List<Mission> get missionsConfirmes => _toutesMissions.where((m) => m.statut == MissionStatus.confirmed).toList();
  List<Mission> get missionsTerminees => _toutesMissions.where((m) => m.statut == MissionStatus.completed).toList();
  List<Mission> get missionsAnnulees => _toutesMissions.where((m) => m.statut == MissionStatus.cancelled).toList();

  int get missionsCount => _toutesMissions.length;
  int get missionsDuJourCount => _missionsDuJour.length;

  ProviderDashboardProvider() {
    _loadData();
  }

  void _loadData() {
    _missionsDuJour = MockProviderData.missionsDuJour;
    _toutesMissions = MockProviderData.toutesMissions;
    _chartData = MockProviderData.chartData;
    _recentRevenus = MockProviderData.recentRevenus;
    _planningSemaine = MockProviderData.planningSemaine;
    _disponibilites = MockProviderData.disponibilites;
    _notifications = MockProviderData.notifications;
    _notificationsNonLues = MockProviderData.nombreNotificationsNonLues;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void updateProfile({
    String? nom,
    String? prenom,
    String? email,
    String? phone,
    String? specialite,
    String? description,
  }) {
    _profile = _profile.copyWith(
      nom: nom,
      prenom: prenom,
      email: email,
      phone: phone,
      specialite: specialite,
      description: description,
    );
    notifyListeners();
  }

  void toggleDisponibilite() {
    _profile = _profile.copyWith(disponible: !_profile.disponible);
    notifyListeners();
  }

  void updateDisponibiliteJour(int index, bool actif) {
    if (index < 0 || index >= _disponibilites.length) return;
    final old = _disponibilites[index];
    _disponibilites[index] = DisponibiliteSemaine(
      jourSemaine: old.jourSemaine,
      debut: old.debut,
      fin: old.fin,
      actif: actif,
    );
    notifyListeners();
  }

  void updateDisponibiliteHeure(int index, TimeOfDay debut, TimeOfDay fin) {
    if (index < 0 || index >= _disponibilites.length) return;
    _disponibilites[index] = DisponibiliteSemaine(
      jourSemaine: _disponibilites[index].jourSemaine,
      debut: debut,
      fin: fin,
      actif: _disponibilites[index].actif,
    );
    notifyListeners();
  }

  void marquerNotificationLue(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    if (!_notifications[idx].lu) {
      _notifications[idx] = _notifications[idx].copyWith(lu: true);
      _notificationsNonLues = _notifications.where((n) => !n.lu).length;
      notifyListeners();
    }
  }

  void marquerToutesNotificationsLues() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(lu: true);
    }
    _notificationsNonLues = 0;
    notifyListeners();
  }

  void accepterMission(String id) {
    final idx = _toutesMissions.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    _toutesMissions[idx] = _toutesMissions[idx].copyWith(statut: MissionStatus.confirmed);
    _missionsDuJour = _toutesMissions.where(
      (m) => m.date.year == DateTime.now().year &&
          m.date.month == DateTime.now().month &&
          m.date.day == DateTime.now().day
    ).toList();
    notifyListeners();
  }

  void completerMission(String id) {
    final idx = _toutesMissions.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    _toutesMissions[idx] = _toutesMissions[idx].copyWith(statut: MissionStatus.completed);
    _missionsDuJour = _toutesMissions.where(
      (m) => m.date.year == DateTime.now().year &&
          m.date.month == DateTime.now().month &&
          m.date.day == DateTime.now().day
    ).toList();
    _profile = _profile.copyWith(missionsRealisees: _profile.missionsRealisees + 1);
    notifyListeners();
  }

  void annulerMission(String id) {
    final idx = _toutesMissions.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    _toutesMissions[idx] = _toutesMissions[idx].copyWith(statut: MissionStatus.cancelled);
    _missionsDuJour = _toutesMissions.where(
      (m) => m.date.year == DateTime.now().year &&
          m.date.month == DateTime.now().month &&
          m.date.day == DateTime.now().day
    ).toList();
    notifyListeners();
  }
}
