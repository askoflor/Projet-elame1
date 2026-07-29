import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Stockage local des jetons d'authentification.
///
/// Utilise shared_preferences plutot que flutter_secure_storage : sur le web,
/// flutter_secure_storage s'appuie sur l'API Web Crypto du navigateur, qui
/// n'est disponible que dans un contexte securise (HTTPS ou localhost). Tant
/// que l'app est servie en HTTP simple (IP sans certificat), cette API est
/// indisponible et fait echouer le stockage. shared_preferences (localStorage
/// sur le web) fonctionne quel que soit le contexte.
class StorageService {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }

  static Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.refreshTokenKey, token);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
  }
}
