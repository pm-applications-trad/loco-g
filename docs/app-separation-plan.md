# LocoGames — 3-App Build Separation Plan

> **Strategy**: Use Flutter flavors (`--flavor`) + conditional compilation to produce 3 standalone apps from a single codebase.

---

## 1. The Three Products

| # | Product Name | Content | Target Audience | Monetization |
|---|-------------|---------|-----------------|---------------|
| **A** | **LocoGames** | Party/parlor games (Impostor, Guessing, Who Am I?, future additions) — "Gesellschaftsspiele" | General adults 18+, party hosts | Ad-supported + Premium subscription |
| **B** | **LocoDrinks** | Drinking games only (Kings Cup, Ride the Bus, Power Hour, Never Have I Ever, Ring of Fire, Most Likely To, Paranoia, etc.) | Party crowds, pre-game, university | Ad-supported + Premium subscription |
| **C** | **LocoBundle** | All games from A + B combined | Power users wanting everything | Higher-priced single purchase or subscription |

---

## 2. Flutter Flavor Configuration

### 2.1 Flavor Names

```
locogames     → LocoGames (Party Games)
locodrinks    → LocoDrinks (Drinking Games)
locobundle    → LocoBundle (Combined)
```

### 2.2 Entry Points

```
lib/main_locogames.dart    → Party Games entry
lib/main_locodrinks.dart   → Drinking Games entry
lib/main_locobundle.dart   → Combined entry
```

Each entry point configures which features are registered in GetIt and which routes are available in the router.

### 2.3 Build Commands

```bash
# LocoGames (Party Games)
flutter build apk --flavor locogames -t lib/main_locogames.dart
flutter build ios --flavor locogames -t lib/main_locogames.dart

# LocoDrinks (Drinking Games)
flutter build apk --flavor locodrinks -t lib/main_locodrinks.dart
flutter build ios --flavor locodrinks -t lib/main_locodrinks.dart

# LocoBundle (Combined)
flutter build apk --flavor locobundle -t lib/main_locobundle.dart
flutter build ios --flavor locobundle -t lib/main_locobundle.dart
```

### 2.4 Android Flavor Config (`android/app/build.gradle`)

```groovy
android {
    flavorDimensions "app"
    productFlavors {
        locogames {
            dimension "app"
            applicationIdSuffix ""
            applicationId "com.pmapplications.locogames"
            versionNameSuffix ""
            resValue "string", "app_name", "LocoGames"
        }
        locodrinks {
            dimension "app"
            applicationIdSuffix ".drinks"
            applicationId "com.pmapplications.locodrinks"
            versionNameSuffix "-drinks"
            resValue "string", "app_name", "LocoDrinks"
        }
        locobundle {
            dimension "app"
            applicationIdSuffix ".bundle"
            applicationId "com.pmapplications.locobundle"
            versionNameSuffix "-bundle"
            resValue "string", "app_name", "LocoBundle"
        }
    }
}
```

### 2.5 iOS Schemes

Three Xcode schemes + three `Info.plist` configurations with different bundle identifiers:
- `com.pmapplications.locogames`
- `com.pmapplications.locodrinks`
- `com.pmapplications.locobundle`

---

## 3. Feature Flag System

### 3.1 Configuration

```dart
// lib/core/constants/app_flavor.dart
import 'package:flutter/foundation.dart';

enum AppFlavor { locogames, locodrinks, locobundle }

class FlavorConfig {
  final AppFlavor flavor;
  final String appName;
  final String appIdSuffix;
  final String adMobAppId;
  final String revenueCatApiKey;
  final Set<GameFeature> enabledGames;
  final bool showPremiumBanner;
  final String appStoreUrl;

  const FlavorConfig({
    required this.flavor,
    required this.appName,
    required this.appIdSuffix,
    required this.adMobAppId,
    required this.revenueCatApiKey,
    required this.enabledGames,
    required this.showPremiumBanner,
    required this.appStoreUrl,
  });

  bool isGameEnabled(GameFeature game) => enabledGames.contains(game);
}

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
```

### 3.2 Flavor Configuration Map

```dart
const flavorConfigs = {
  AppFlavor.locogames: FlavorConfig(
    flavor: AppFlavor.locogames,
    appName: 'LocoGames',
    appIdSuffix: '',
    adMobAppId: AppConstants.adMobAppIdAndroid,
    revenueCatApiKey: AppConstants.revenueCatApiKeyAndroid,
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
    adMobAppId: 'YOUR_DRINKS_ADMOB_ID',
    revenueCatApiKey: 'YOUR_DRINKS_RC_KEY',
    enabledGames: {
      GameFeature.kingsCup,
      GameFeature.rideTheBus,
      GameFeature.powerHour,
      GameFeature.neverHaveIEver,
      GameFeature.ringOfFire,
      GameFeature.mostLikelyTo,
      GameFeature.paranoia,
    },
    showPremiumBanner: true,
    appStoreUrl: 'https://apps.apple.com/app/locodrinks/idXXXXXXXX',
  ),
  AppFlavor.locobundle: FlavorConfig(
    flavor: AppFlavor.locobundle,
    appName: 'LocoBundle',
    appIdSuffix: '.bundle',
    adMobAppId: 'YOUR_BUNDLE_ADMOB_ID',
    revenueCatApiKey: 'YOUR_BUNDLE_RC_KEY',
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
    showPremiumBanner: false, // Bundle may be paid upfront
    appStoreUrl: 'https://apps.apple.com/app/locobundle/idXXXXXXXX',
  ),
};
```

### 3.3 Usage in Widgets

```dart
// Home screen: only show enabled games
SliverList(
  delegate: SliverChildListDelegate([
    if (flavorConfig.isGameEnabled(GameFeature.impostor))
      GameCard(title: 'Impostor', ...),
    if (flavorConfig.isGameEnabled(GameFeature.guessing))
      GameCard(title: 'Guess Battle', ...),
    if (flavorConfig.isGameEnabled(GameFeature.whoAmI))
      GameCard(title: 'Who Am I?', ...),
    if (flavorConfig.isGameEnabled(GameFeature.kingsCup))
      GameCard(title: 'Kings Cup', ...),
    // ...
  ]),
),
```

---

## 4. Drinking Games (LocoDrinks) — Game Concepts

| Game | Players | Description | Key Mechanics |
|------|---------|-------------|---------------|
| **Kings Cup** | 2-12 | Classic card-drawing game. Each card value = a rule. Virtual deck + animated card flips. | Card draw, rule display, king's cup accumulation |
| **Ride the Bus** | 2-8 | Card guessing game: Red/Black → Higher/Lower → Inside/Outside → Suit. Pyramid card layout. | Card deck, prediction buttons, pyramid UI |
| **Power Hour** | 1-20 | 60 minutes, 60 sips. Timer with minute-by-minute prompts and mini-challenges. | Timer, random challenge generator |
| **Never Have I Ever** | 3-20 | Statement-based. Vote who has done it. Score tracking. Categories: mild, spicy, extreme. | Statement card, vote tally, themed decks |
| **Ring of Fire** | 2-12 | Cards placed around a cup. Pull a card, do the rule. If ring breaks → penalty. | Circular card layout, snap detection |
| **Most Likely To** | 3-20 | "Who's most likely to..." questions. Players vote. Most-voted drinks. | Question card, player vote, results reveal |
| **Paranoia** | 3-12 | Whisper a question about another player to your neighbor. They answer by pointing. You guess who. | Question whisper (private text), point mechanic |

---

## 5. Cross-Promotion Between Apps

- Each app shows a banner/tile for the sibling app ("Want drinking games? Get LocoDrinks!")
- Deep linking between apps (if both installed)
- Bundle version includes all content from both standalone apps
- Shared backend (same VPS, same WebSocket server) serves all apps

---

## 6. Shared Code Structure

```
lib/
├── main_locogames.dart          # Entry: party games flavor
├── main_locodrinks.dart         # Entry: drinking games flavor
├── main_locobundle.dart         # Entry: combined flavor
├── core/                        # Shared across ALL flavors
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── app_flavor.dart      # FlavorConfig + GameFeature enum
│   ├── di/
│   │   └── injection.dart       # Conditional registration per flavor
│   ├── router/
│   │   ├── app_router.dart      # Conditional routes per flavor
│   │   └── routes.dart
│   ├── services/                # Shared: haptics, audio, ads, premium
│   ├── theme/                   # Shared: theming (flavor-specific brand colors)
│   └── widgets/                 # Shared: buttons, cards, dialogs
├── features/
│   ├── party_games/             # LocoGames core
│   │   ├── impostor/
│   │   ├── guessing/
│   │   └── who_am_i/
│   ├── drinking_games/          # LocoDrinks core
│   │   ├── kings_cup/
│   │   ├── ride_the_bus/
│   │   ├── power_hour/
│   │   ├── never_have_i_ever/
│   │   ├── ring_of_fire/
│   │   ├── most_likely_to/
│   │   └── paranoia/
│   └── shared/                  # Used by both
│       ├── home/
│       ├── onboarding/
│       ├── settings/
│       ├── monetization/
│       └── multiplayer/         # Lobby, WebSocket, room management
└── l10n/                        # All strings for all games in all 4 languages
```

---

## 7. Implementation Order

| Priority | Item | Notes |
|----------|------|-------|
| 1 | `app_flavor.dart` + flavor configuration | Foundation for everything else |
| 2 | Add `GameFeature` enum and conditional to main.dart | Must work before any game screen |
| 3 | Refactor `app_router.dart` to use conditional routes | Routes depend on flavor |
| 4 | Create `party_games/` and `drinking_games/` feature folders | Separate concerns |
| 5 | Implement party games (Impostor, Guessing) | Existing legacy logic |
| 6 | Implement Who Am I? | New multiplayer game |
| 7 | Implement drinking games one by one | New games |
| 8 | Cross-promotion widgets | "Get LocoDrinks" banner etc. |
| 9 | App Store listings × 3 | Separate metadata, screenshots |
