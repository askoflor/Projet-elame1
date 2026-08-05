import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../modules/auth/domain/auth_provider.dart';
import '../modules/auth/presentation/pages/login_screen.dart';
import '../modules/auth/presentation/pages/client_login_screen.dart';
import '../modules/auth/presentation/pages/register_screen.dart';
import '../modules/auth/presentation/pages/provider_login_screen.dart';
import '../modules/auth/presentation/pages/forgot_password_screen.dart';
import '../modules/dashboard/presentation/pages/dashboard_screen.dart';
import '../modules/home/presentation/pages/home_page.dart';
import '../modules/search/presentation/pages/search_page.dart';
import '../modules/booking/presentation/pages/booking_page.dart';
import '../modules/client/presentation/pages/client_dashboard_screen.dart';
import '../modules/provider/presentation/pages/provider_dashboard_screen.dart';
import '../modules/payment/presentation/pages/payment_page.dart';
import '../modules/profile/presentation/pages/profile_screen.dart';
import '../modules/search/domain/entities/provider_model.dart';
import '../modules/search/domain/entities/search_entry_args.dart';
import '../modules/booking/domain/booking_entry_args.dart';
import '../modules/static/presentation/pages/about_page.dart';
import '../modules/static/presentation/pages/faq_page.dart';
import '../modules/static/presentation/pages/privacy_policy_page.dart';

class AppRouter {
  /// Routes accessibles uniquement aux utilisateurs connectes ; toute
  /// tentative d'y acceder alors qu'on n'est pas authentifie renvoie vers
  /// la page de connexion.
  static const _protectedRoutes = [
    AppConstants.bookingRoute,
    AppConstants.paymentRoute,
  ];

  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: AppConstants.homeRoute,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isProtected = _protectedRoutes.any((r) => state.matchedLocation.startsWith(r));
        if (isProtected && !authProvider.isAuthenticated) {
          return AppConstants.loginRoute;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppConstants.homeRoute,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppConstants.loginRoute,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppConstants.clientLoginRoute,
          builder: (context, state) => const ClientLoginScreen(),
        ),
        GoRoute(
          path: AppConstants.providerLoginRoute,
          builder: (context, state) => const ProviderLoginScreen(),
        ),
        GoRoute(
          path: AppConstants.registerRoute,
          builder: (context, state) => RegisterScreen(
            initialRole: state.extra == 'PRESTATAIRE' ? UserRole.prestataire : null,
          ),
        ),
        GoRoute(
          path: AppConstants.forgotPasswordRoute,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: AppConstants.dashboardRoute,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppConstants.searchRoute,
          builder: (context, state) {
            final extra = state.extra;
            if (extra is SearchEntryArgs) {
              return SearchPage(initialCategory: extra.specialite, initialDate: extra.date);
            }
            return SearchPage(initialCategory: extra is String ? extra : null);
          },
        ),
        GoRoute(
          path: AppConstants.bookingRoute,
          builder: (context, state) {
            final extra = state.extra;
            if (extra is BookingEntryArgs) {
              return BookingPage(provider: extra.provider, initialDate: extra.date, initialHours: extra.hours);
            }
            // La réservation ne devrait être atteinte que depuis le calendrier
            // du profil (BookingEntryArgs) ; on retombe sur l'accueil sinon.
            return const HomePage();
          },
        ),
        GoRoute(
          path: AppConstants.profileRoute,
          builder: (context, state) => ProfileScreen(provider: state.extra is ProviderModel ? state.extra as ProviderModel : null),
        ),
        GoRoute(
          path: AppConstants.paymentRoute,
          builder: (context, state) => const PaymentPage(),
        ),
        GoRoute(
          path: AppConstants.clientDashboardRouteFull,
          builder: (context, state) => const ClientDashboardScreen(),
        ),
        GoRoute(
          path: AppConstants.providerDashboardRouteFull,
          builder: (context, state) => const ProviderDashboardScreen(),
        ),
        GoRoute(
          path: AppConstants.aProposRoute,
          builder: (context, state) => const AboutPage(),
        ),
        GoRoute(
          path: AppConstants.faqRoute,
          builder: (context, state) => const FaqPage(),
        ),
        GoRoute(
          path: AppConstants.confidentialiteRoute,
          builder: (context, state) => const PrivacyPolicyPage(),
        ),
      ],
    );
  }
}
