class AppConstants {
  AppConstants._();

  static const String appName = 'LocoGames';
  static const String appTagline = 'Unleash the Party';
  static const String appVersion = '1.0.0';

  // AdMob
  static const String adMobAppIdAndroid = 'YOUR_ADMOB_APP_ID_ANDROID';
  static const String adMobAppIdIos = 'YOUR_ADMOB_APP_ID_IOS';
  static const String adMobBannerUnitIdAndroid = 'YOUR_BANNER_AD_UNIT_ID_ANDROID';
  static const String adMobBannerUnitIdIos = 'YOUR_BANNER_AD_UNIT_ID_IOS';
  static const String adMobInterstitialUnitIdAndroid = 'YOUR_INTERSTITIAL_AD_UNIT_ID_ANDROID';
  static const String adMobInterstitialUnitIdIos = 'YOUR_INTERSTITIAL_AD_UNIT_ID_IOS';
  static const String adMobRewardedUnitIdAndroid = 'YOUR_REWARDED_AD_UNIT_ID_ANDROID';
  static const String adMobRewardedUnitIdIos = 'YOUR_REWARDED_AD_UNIT_ID_IOS';

  // RevenueCat
  static const String revenueCatApiKeyAndroid = 'YOUR_RC_API_KEY_ANDROID';
  static const String revenueCatApiKeyIos = 'YOUR_RC_API_KEY_IOS';
  static const String premiumEntitlementId = 'premium';

  // Backend
  static const String apiBaseUrl = 'https://api.locogames.com';
  static const String wsBaseUrl = 'wss://api.locogames.com/ws';
  static const int apiTimeoutSeconds = 30;

  // Storage keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyThemeMode = 'theme_mode';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyHapticsEnabled = 'haptics_enabled';
  static const String keyAgreedToTerms = 'agreed_to_terms';
  static const String keyAgeVerified = 'age_verified';

  // Game limits
  static const int minPlayersImpostor = 3;
  static const int maxPlayersImpostor = 12;
  static const int maxSpiesImpostor = 3;
  static const int minPlayersGuessing = 2;
  static const int maxPlayersGuessing = 20;
  static const int defaultRoundCount = 5;

  // Multiplayer
  static const int maxLobbyPlayers = 16;
  static const int roomCodeLength = 6;
}
