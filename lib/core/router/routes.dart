part of 'app_router.dart';

final List<RouteBase> appRoutes = [
  GoRoute(
    path: '/onboarding',
    builder: (context, state) => const OnboardingScreen(),
  ),
  GoRoute(
    path: '/home',
    builder: (context, state) => const HomeScreen(),
    routes: [
      GoRoute(
        path: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: 'premium',
        builder: (context, state) => const PremiumScreen(),
      ),
    ],
  ),
  GoRoute(
    path: '/impostor',
    builder: (context, state) => const ImpostorSetupScreen(),
    routes: [
      GoRoute(
        path: 'play',
        builder: (context, state) => const ImpostorGameScreen(),
      ),
    ],
  ),
  GoRoute(
    path: '/guessing',
    builder: (context, state) => const GuessingSetupScreen(),
    routes: [
      GoRoute(
        path: 'play',
        builder: (context, state) => const GuessingGameScreen(),
      ),
    ],
  ),
  GoRoute(
    path: '/multiplayer',
    builder: (context, state) => const LobbyScreen(),
    routes: [
      GoRoute(
        path: 'play/:roomId',
        builder: (context, state) => MultiplayerGameScreen(
          roomId: state.pathParameters['roomId']!,
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/whoami',
    builder: (context, state) => const WhoAmISetupScreen(),
    routes: [
      GoRoute(
        path: 'play',
        builder: (context, state) => const WhoAmIGameScreen(),
      ),
    ],
  ),
  GoRoute(
    path: '/kingscup',
    builder: (context, state) => const KingsCupSetupScreen(),
    routes: [
      GoRoute(
        path: 'play',
        builder: (context, state) => const KingsCupGameScreen(),
      ),
    ],
  ),
  GoRoute(
    path: '/nhie',
    builder: (context, state) => const NHIESetupScreen(),
    routes: [
      GoRoute(
        path: 'play',
        builder: (context, state) => const NHIEGameScreen(),
      ),
    ],
  ),
  GoRoute(
    path: '/mlt',
    builder: (context, state) => const MLTSetupScreen(),
    routes: [
      GoRoute(
        path: 'play',
        builder: (context, state) => const MLTGameScreen(),
      ),
    ],
  ),
  GoRoute(
    path: '/powerhour',
    builder: (context, state) => const PowerHourSetupScreen(),
    routes: [
      GoRoute(
        path: 'play',
        builder: (context, state) => const PowerHourGameScreen(),
      ),
    ],
  ),
  GoRoute(
    path: '/ridebus',
    builder: (context, state) => const RideTheBusSetupScreen(),
    routes: [
      GoRoute(
        path: 'play',
        builder: (context, state) => const RideTheBusGameScreen(),
      ),
    ],
  ),
];
