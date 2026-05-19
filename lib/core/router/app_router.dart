// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locogames/features/home/presentation/screens/home_screen.dart';
import 'package:locogames/features/settings/presentation/screens/settings_screen.dart';
import 'package:locogames/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:locogames/features/impostor/presentation/screens/impostor_setup_screen.dart';
import 'package:locogames/features/impostor/presentation/screens/impostor_game_screen.dart';
import 'package:locogames/features/guessing/presentation/screens/guessing_setup_screen.dart';
import 'package:locogames/features/guessing/presentation/screens/guessing_game_screen.dart';
import 'package:locogames/features/monetization/presentation/screens/premium_screen.dart';
import 'package:locogames/features/multiplayer/presentation/screens/lobby_screen.dart';
import 'package:locogames/features/multiplayer/presentation/screens/multiplayer_game_screen.dart';
import 'package:locogames/features/whoami/presentation/screens/who_am_i_setup_screen.dart';
import 'package:locogames/features/whoami/presentation/screens/who_am_i_game_screen.dart';
import 'package:locogames/features/kingscup/presentation/screens/kings_cup_setup_screen.dart';
import 'package:locogames/features/kingscup/presentation/screens/kings_cup_game_screen.dart';
import 'package:locogames/features/neverhaveiever/presentation/screens/nhie_setup_screen.dart';
import 'package:locogames/features/neverhaveiever/presentation/screens/nhie_game_screen.dart';
import 'package:locogames/features/mostlikelyto/presentation/screens/mlt_setup_screen.dart';
import 'package:locogames/features/mostlikelyto/presentation/screens/mlt_game_screen.dart';
import 'package:locogames/features/powerhour/presentation/screens/power_hour_setup_screen.dart';
import 'package:locogames/features/powerhour/presentation/screens/power_hour_game_screen.dart';
import 'package:locogames/features/ridethebus/presentation/screens/ride_the_bus_setup_screen.dart';
import 'package:locogames/features/ridethebus/presentation/screens/ride_the_bus_game_screen.dart';

part 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: appRoutes,
  );
});
