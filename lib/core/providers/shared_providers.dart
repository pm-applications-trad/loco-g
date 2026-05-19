import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:locogames/core/di/injection.dart';
import 'package:locogames/core/constants/app_constants.dart';
import 'package:locogames/core/services/haptic_service.dart';
import 'package:locogames/core/services/audio_service.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  return getIt<SharedPreferences>();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  return getIt<AudioService>();
});

final hapticServiceProvider = Provider<HapticService>((ref) {
  return getIt<HapticService>();
});

final localeProvider = StateProvider<Locale>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final languageCode = prefs.getString(AppConstants.keySelectedLanguage);
  if (languageCode != null) {
    return Locale(languageCode);
  }
  final systemLocale = PlatformDispatcher.instance.locale;
  final supportedCodes = ['en', 'de', 'es', 'fr'];
  if (supportedCodes.contains(systemLocale.languageCode)) {
    return systemLocale;
  }
  return const Locale('en');
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final themeString = prefs.getString(AppConstants.keyThemeMode);
  switch (themeString) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
});

final soundEnabledProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.getBool(AppConstants.keySoundEnabled) ?? true;
});

final hapticsEnabledProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.getBool(AppConstants.keyHapticsEnabled) ?? true;
});
