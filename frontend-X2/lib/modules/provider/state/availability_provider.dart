import 'package:flutter/material.dart';
import '../data/availability_repository.dart';

/// Disponibilite d'un prestataire, par date. En l'absence d'exception pour
/// une date, le prestataire est considere disponible par defaut.
class AvailabilityProvider extends ChangeNotifier {
  final AvailabilityRepository _repository;

  AvailabilityProvider({AvailabilityRepository? repository}) : _repository = repository ?? AvailabilityRepository();

  Map<String, bool> _mesOverrides = {};
  final Map<String, Map<String, bool>> _publicCache = {};
  bool _loading = false;

  bool get isLoading => _loading;

  String _key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool isAvailableOn(DateTime date) => _mesOverrides[_key(date)] ?? true;

  bool isProviderAvailableOn(String providerName, DateTime date) =>
      (_publicCache[providerName] ?? const {})[_key(date)] ?? true;

  Future<void> chargerMesDisponibilites() async {
    _loading = true;
    notifyListeners();
    _mesOverrides = await _repository.mesDisponibilites();
    _loading = false;
    notifyListeners();
  }

  Future<void> chargerDisponibilitesPrestataire(String providerName) async {
    _publicCache[providerName] = await _repository.disponibilitesPrestataire(providerName);
    notifyListeners();
  }

  Future<bool> basculerDate(DateTime date) async {
    final updated = await _repository.basculerDate(date);
    if (updated == null) return false;
    _mesOverrides = updated;
    notifyListeners();
    return true;
  }

  Future<bool> definirPeriode(DateTime debut, DateTime fin, bool disponible) async {
    final updated = await _repository.definirPeriode(debut, fin, disponible);
    if (updated == null) return false;
    _mesOverrides = updated;
    notifyListeners();
    return true;
  }
}
