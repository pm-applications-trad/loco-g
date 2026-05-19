enum SubscriptionTier { free, premium }

class PremiumService {
  bool _initialized = false;
  SubscriptionTier _currentTier = SubscriptionTier.free;
  bool _subscriptionActive = false;

  bool get isInitialized => _initialized;
  SubscriptionTier get currentTier => _currentTier;
  bool get isPremium => _currentTier == SubscriptionTier.premium;
  bool get hasActiveSubscription => _subscriptionActive;

  Future<void> initialize() async {
    _initialized = true;
  }

  Future<bool> purchasePremium() async {
    _currentTier = SubscriptionTier.premium;
    _subscriptionActive = true;
    return true;
  }

  Future<bool> restorePurchases() async {
    return true;
  }

  Future<void> cancelSubscription() async {
    _currentTier = SubscriptionTier.free;
    _subscriptionActive = false;
  }

  void dispose() {}
}
