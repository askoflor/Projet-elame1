import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../data/auth_repository.dart';
import 'auth_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unauthenticated;
  UserModel? _user;
  String? _errorMessage;
  bool _isConnectionError = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isConnectionError => _isConnectionError;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    _checkAuthStatus();
  }

  void enableDemoMode({String? email, String? nom, String? prenom, String? role, String? specialite, DateTime? dateNaissance}) {
    _user = UserModel(
      id: 'demo-001',
      email: email ?? 'demo@serviceconnect.com',
      nom: nom ?? 'Doe',
      prenom: prenom ?? 'John',
      role: role ?? 'CLIENT',
      specialite: specialite,
      dateNaissance: dateNaissance,
    );
    _status = AuthStatus.authenticated;
    _errorMessage = null;
    _isConnectionError = false;
    notifyListeners();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final hasToken = await StorageService.hasToken();
      if (hasToken) {
        _user = await _repository.getCurrentUser();
        _status = _user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _isConnectionError = false;
    notifyListeners();

    try {
      final result = await _repository.login(email, password);

      if (result.success) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.errorMessage;
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (_) {
      _errorMessage = 'Impossible de joindre le serveur';
      _isConnectionError = true;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String nom,
    String prenom,
    String email,
    String password,
    String role,
    String telephone, {
    String? specialite,
    DateTime? dateNaissance,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _isConnectionError = false;
    notifyListeners();

    try {
      final result = await _repository.register(
        nom,
        prenom,
        email,
        password,
        role,
        telephone,
        specialite: specialite,
        dateNaissance: dateNaissance,
      );

      if (result.success) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.errorMessage;
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (_) {
      _errorMessage = 'Impossible de joindre le serveur';
      _isConnectionError = true;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({String? nom, String? prenom, String? telephone}) async {
    final updated = await _repository.updateProfile(nom: nom, prenom: prenom, telephone: telephone);
    if (updated != null) {
      _user = updated;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<String?> forgotPassword(String email) async {
    _errorMessage = null;
    _isConnectionError = false;
    notifyListeners();

    try {
      return await _repository.forgotPassword(email);
    } catch (_) {
      return 'Impossible de joindre le serveur';
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {}
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        _user = user;
        notifyListeners();
      }
    } catch (_) {}
  }
}
