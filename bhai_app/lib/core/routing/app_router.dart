import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/onboarding_screens.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/map/presentation/safe_route_screen.dart';
import '../../features/fake_call/presentation/fake_call_screen.dart';
import '../../features/travel/presentation/travel_mode_screen.dart';
import '../../features/helpline/presentation/helpline_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/volunteer/presentation/volunteer_dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreens(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/safe-route',
      builder: (context, state) => const SafeRouteScreen(),
    ),
    GoRoute(
      path: '/fake-call',
      builder: (context, state) => const FakeCallScreen(),
    ),
    GoRoute(
      path: '/travel-mode',
      builder: (context, state) => const TravelModeScreen(),
    ),
    GoRoute(
      path: '/helpline',
      builder: (context, state) => const HelplineScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/volunteer',
      builder: (context, state) => const VolunteerDashboardScreen(),
    ),
  ],
);
