class AppConstants {
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'current_user';

  // Routes
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String dashboardRoute = '/dashboard';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String clientLoginRoute = '/client-login';
  static const String providerLoginRoute = '/provider-login';
  static const String clientDashboardRoute = '/client-dashboard';
  static const String providerDashboardRoute = '/provider-dashboard';
  static const String searchRoute = '/recherche';
  static const String bookingRoute = '/reservation';
  static const String paymentRoute = '/paiement';
  static const String profileRoute = '/profil';
  static const String clientDashboardRouteFull = '/espace-client';
  static const String providerDashboardRouteFull = '/prestataire';

  // Messages
  static const String loginError = 'Email ou mot de passe incorrect';
  static const String networkError = 'Erreur réseau, vérifiez votre connexion';
  static const String serverError = 'Erreur serveur, réessayez plus tard';
}
