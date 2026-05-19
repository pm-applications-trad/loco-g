class AdService {
  bool _initialized = false;
  bool _adsEnabled = true;

  bool get isInitialized => _initialized;
  bool get areAdsEnabled => _adsEnabled;

  Future<void> initialize() async {
    _initialized = true;
  }

  void disableAds() {
    _adsEnabled = false;
  }

  void enableAds() {
    _adsEnabled = true;
  }

  Future<void> showInterstitial() async {
    if (!_adsEnabled) return;
  }

  Future<void> showRewardedAd() async {
    if (!_adsEnabled) return;
  }

  Future<void> loadBannerAd() async {
    if (!_adsEnabled) return;
  }

  void dispose() {}
}
