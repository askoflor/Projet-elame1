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
import '../modules/historique/presentation/pages/historique_page.dart';
class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: AppConstants.homeRoute,
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
          builder: (context, state) => const RegisterScreen(),
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
            return SearchPage(initialCategory: extra is String ? extra : null);
          },
        ),
        GoRoute(
          path: AppConstants.bookingRoute,
          builder: (context, state) {
            final extra = state.extra;
            if (extra is int) {
              return BookingPage(initialServiceIndex: extra);
            }
            return BookingPage(provider: extra is ProviderModel ? extra : null);
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
          path: AppConstants.historiqueRoute,
          builder: (context, state) => const HistoriquePage(),
        ),
      ],
    );
  }
}
