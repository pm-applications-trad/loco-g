import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:locogames/core/services/haptic_service.dart';
import 'package:locogames/core/services/audio_service.dart';
import 'package:locogames/core/services/ad_service.dart';
import 'package:locogames/core/services/premium_service.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerLazySingleton<HapticService>(() => HapticService());
  getIt.registerLazySingleton<AudioService>(() => AudioService());
  getIt.registerLazySingleton<AdService>(() => AdService());
  getIt.registerLazySingleton<PremiumService>(() => PremiumService());
}
