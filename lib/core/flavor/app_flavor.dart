import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locogames/core/constants/app_constants.dart';

enum AppFlavor { locogames, locodrinks, locobundle }

enum GameFeature {
  impostor,
  guessing,
  whoAmI,
  kingsCup,
  rideTheBus,
  powerHour,
  neverHaveIEver,
  ringOfFire,
  mostLikelyTo,
  paranoia,
  multiplayer,
  customCategories,
}

class FlavorConfig {
  final AppFlavor flavor;
  final String appName;
  final String appIdSuffix;
  final String adMobAppIdAndroid;
  final String adMobAppIdIos;
  final String revenueCatApiKeyAndroid;
  final String revenueCatApiKeyIos;
  final Set<GameFeature> enabledGames;
  final bool showPremiumBanner;
  final String appStoreUrl;

  const FlavorConfig({
    required this.flavor,
    required this.appName,
    required this.appIdSuffix,
    required this.adMobAppIdAndroid,
    required this.adMobAppIdIos,
    required this.revenueCatApiKeyAndroid,
    required this.revenueCatApiKeyIos,
    required this.enabledGames,
    required this.showPremiumBanner,
    required this.appStoreUrl,
  });

  bool isGameEnabled(GameFeature game) => enabledGames.contains(game);
  bool get isPartyGames => flavor == AppFlavor.locogames || flavor == AppFlavor.locobundle;
  bool get isDrinkingGames => flavor == AppFlavor.locodrinks || flavor == AppFlavor.locobundle;
}

const flavorConfigs = {
  AppFlavor.locogames: FlavorConfig(
    flavor: AppFlavor.locogames,
    appName: 'LocoGames',
    appIdSuffix: '',
    adMobAppIdAndroid: AppConstants.adMobAppIdAndroid,
    adMobAppIdIos: AppConstants.adMobAppIdIos,
    revenueCatApiKeyAndroid: AppConstants.revenueCatApiKeyAndroid,
    revenueCatApiKeyIos: AppConstants.revenueCatApiKeyIos,
    enabledGames: {
      GameFeature.impostor,
      GameFeature.guessing,
      GameFeature.whoAmI,
      GameFeature.multiplayer,
      GameFeature.customCategories,
    },
    showPremiumBanner: true,
    appStoreUrl: 'https://apps.apple.com/app/locogames/idXXXXXXXX',
  ),
  AppFlavor.locodrinks: FlavorConfig(
    flavor: AppFlavor.locodrinks,
    appName: 'LocoDrinks',
    appIdSuffix: '.drinks',
    adMobAppIdAndroid: AppConstants.adMobAppIdAndroid,
    adMobAppIdIos: AppConstants.adMobAppIdIos,
    revenueCatApiKeyAndroid: AppConstants.revenueCatApiKeyAndroid,
    revenueCatApiKeyIos: AppConstants.revenueCatApiKeyIos,
    enabledGames: {
      GameFeature.kingsCup,
      GameFeature.rideTheBus,
      GameFeature.powerHour,
      GameFeature.neverHaveIEver,
      GameFeature.ringOfFire,
      GameFeature.mostLikelyTo,
      GameFeature.paranoia,
      GameFeature.multiplayer,
    },
    showPremiumBanner: true,
    appStoreUrl: 'https://apps.apple.com/app/locodrinks/idXXXXXXXX',
  ),
  AppFlavor.locobundle: FlavorConfig(
    flavor: AppFlavor.locobundle,
    appName: 'LocoBundle',
    appIdSuffix: '.bundle',
    adMobAppIdAndroid: AppConstants.adMobAppIdAndroid,
    adMobAppIdIos: AppConstants.adMobAppIdIos,
    revenueCatApiKeyAndroid: AppConstants.revenueCatApiKeyAndroid,
    revenueCatApiKeyIos: AppConstants.revenueCatApiKeyIos,
    enabledGames: {
      GameFeature.impostor,
      GameFeature.guessing,
      GameFeature.whoAmI,
      GameFeature.kingsCup,
      GameFeature.rideTheBus,
      GameFeature.powerHour,
      GameFeature.neverHaveIEver,
      GameFeature.ringOfFire,
      GameFeature.mostLikelyTo,
      GameFeature.paranoia,
      GameFeature.multiplayer,
      GameFeature.customCategories,
    },
    showPremiumBanner: false,
    appStoreUrl: 'https://apps.apple.com/app/locobundle/idXXXXXXXX',
  ),
};

FlavorConfig? _currentFlavor;

FlavorConfig get currentFlavor {
  assert(_currentFlavor != null, 'Flavor not initialized. Call initializeFlavor() before accessing currentFlavor.');
  return _currentFlavor!;
}

void initializeFlavor(AppFlavor flavor) {
  _currentFlavor = flavorConfigs[flavor];
}

final currentFlavorProvider = Provider<FlavorConfig>((ref) => currentFlavor);
