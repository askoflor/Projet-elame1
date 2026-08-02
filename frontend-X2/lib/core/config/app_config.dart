class AppConfig {
  // URL de l'API Gateway Spring Boot.
  // Surchargeable au build avec --dart-define=API_BASE_URL=https://mon-vps:8080
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
  static const String apiVersion = '/api/v1';
  static const String apiUrl = '$baseUrl$apiVersion';

  // Toggle pour utiliser un backend mock local (utile pour le dev sans serveur).
  // Surchargeable au build avec --dart-define=USE_MOCK_BACKEND=false
  static const bool useMockBackend = bool.fromEnvironment(
    'USE_MOCK_BACKEND',
    defaultValue: true,
  );

  // Endpoints Auth
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshEndpoint = '/auth/refresh';
  static const String meEndpoint = '/auth/me';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';

  // Endpoints Interventions
  static const String interventionsEndpoint = '/interventions';
  static const String myInterventionsEndpoint = '/interventions/mine';
  static const String interventionsPlanningEndpoint = '/interventions/planning';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}