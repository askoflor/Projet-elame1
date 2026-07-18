class AppConfig {
  // URL de ton API Gateway Spring Boot
  static const String baseUrl = 'http://localhost:8080';
  static const String apiVersion = '/api/v1';
  static const String apiUrl = '$baseUrl$apiVersion';

  // Toggle pour utiliser un backend mock local (utile pour le dev sans serveur)
  static const bool useMockBackend = true;

  // Endpoints Auth
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshEndpoint = '/auth/refresh';
  static const String meEndpoint = '/auth/me';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}