import 'package:flutter/material.dart';
import '../domain/provider_profile.dart';
import '../domain/certification.dart';
import '../domain/revenue.dart';
import '../domain/planning.dart';
import '../domain/notification_model.dart';
import '../data/models/mock_provider_data.dart';

class ProviderDashboardProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _isLoading = false;

  ProviderProfile _profile = MockProviderData.profile;
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
  RevenueSummary get revenueSummary => _revenueSummary;
  List<RevenueChartPoint> get chartData => _chartData;
  List<Revenue> get recentRevenus => _recentRevenus;
  PlanningSemaine get planningSemaine => _planningSemaine;
  List<DisponibiliteSemaine> get disponibilites => _disponibilites;
  List<ProviderNotification> get notifications => _notifications;
  int get notificationsNonLues => _notificationsNonLues;

  ProviderDashboardProvider() {
    _loadData();
  }

  void _loadData() {
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
    String? ville,
    String? description,
  }) {
    _profile = _profile.copyWith(
      nom: nom,
      prenom: prenom,
      email: email,
      phone: phone,
      specialite: specialite,
      ville: ville,
      description: description,
    );
    notifyListeners();
  }

  void updateCompetences(List<String> competences) {
    _profile = _profile.copyWith(competences: competences);
    notifyListeners();
  }

  void addCertification(Certification certification) {
    _profile = _profile.copyWith(
        certifications: [..._profile.certifications, certification]);
    notifyListeners();
  }

  void removeCertification(int index) {
    final next = List.of(_profile.certifications);
    if (index < 0 || index >= next.length) return;
    next.removeAt(index);
    _profile = _profile.copyWith(certifications: next);
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
}
