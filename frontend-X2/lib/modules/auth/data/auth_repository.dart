import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/storage_service.dart';
import '../domain/auth_model.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance;

  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _dio.post(
        AppConfig.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'] as String;
      final user = UserModel.fromJson(response.data['user']);

      await StorageService.saveToken(token);
      if (response.data['refreshToken'] != null) {
        await StorageService.saveRefreshToken(response.data['refreshToken'] as String);
      }

      return AuthResult(success: true, token: token, user: user);
    } on DioException catch (e) {
      final message = _handleDioError(e);
      return AuthResult(success: false, errorMessage: message);
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'Reponse du serveur inattendue ($e)');
    }
  }

  Future<AuthResult> register(
    String nom,
    String prenom,
    String email,
    String password,
    String role,
    String telephone, {
    String? specialite,
    DateTime? dateNaissance,
  }) async {
    try {
      final data = <String, dynamic>{
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'password': password,
        'role': role,
        'telephone': telephone,
      };
      if (specialite != null) data['specialite'] = specialite;
      if (dateNaissance != null) {
        data['dateNaissance'] =
            '${dateNaissance.year.toString().padLeft(4, '0')}-${dateNaissance.month.toString().padLeft(2, '0')}-${dateNaissance.day.toString().padLeft(2, '0')}';
      }
      final response = await _dio.post(
        AppConfig.registerEndpoint,
        data: data,
      );

      final token = response.data['token'] as String;
      final user = UserModel.fromJson(response.data['user']);
      await StorageService.saveToken(token);
      if (response.data['refreshToken'] != null) {
        await StorageService.saveRefreshToken(response.data['refreshToken'] as String);
      }

      return AuthResult(success: true, token: token, user: user);
    } on DioException catch (e) {
      final message = _handleDioError(e);
      return AuthResult(success: false, errorMessage: message);
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'Reponse du serveur inattendue ($e)');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(AppConfig.logoutEndpoint);
    } catch (_) {}
    await StorageService.clearAll();
  }

  Future<String?> forgotPassword(String email) async {
    try {
      await _dio.post(
        AppConfig.forgotPasswordEndpoint,
        data: {'email': email},
      );
      return null;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _dio.get(AppConfig.meEndpoint);
      return UserModel.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel?> updateProfile({String? nom, String? prenom, String? telephone}) async {
    try {
      final response = await _dio.put(
        AppConfig.meEndpoint,
        data: {
          if (nom != null) 'nom': nom,
          if (prenom != null) 'prenom': prenom,
          if (telephone != null) 'telephone': telephone,
        },
      );
      return UserModel.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai de connexion dépassé';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return 'Email ou mot de passe incorrect';
        }
        return 'Erreur serveur (${e.response?.statusCode})';
      case DioExceptionType.connectionError:
        return 'Impossible de joindre le serveur';
      default:
        return 'Une erreur est survenue';
    }
  }
}