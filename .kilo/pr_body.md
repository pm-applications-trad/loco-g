## Summary

- **i18n Phase 0.5 completion** — Added 21 Ride the Bus translation keys across all 4 languages (en/de/es/fr), now 177 keys in sync
- **Ride the Bus game** — Full implementation replacing placeholder `onTap: null` card
  - 4-round pyramid card-guessing game (Red/Black → Higher/Lower → Inside/Outside → Suit)
  - 2-8 players with penalty tracking and bus rider mechanic
  - Fresh shuffled pyramid per player
  - Animated result reveals, pyramid visualization, leaderboard
- **APK build script** — `build_apk.ps1` for debug+release APK builds across all 3 flavors (locogames/locodrinks/locobundle)

### Files Changed

| Category | Files |
|----------|-------|
| i18n | `assets/l10n/en.json`, `de.json`, `es.json`, `fr.json` (+21 keys each) |
| Domain | `ridethebus/domain/entities/` (card_model, player, ride_the_bus_game) |
| Usecases | `ridethebus/domain/usecases/ride_the_bus_usecases.dart` |
| Provider | `ridethebus/presentation/providers/ride_the_bus_provider.dart` |
| Screens | `ridethebus/presentation/screens/` (setup + game, 1134-line game screen) |
| Router | `core/router/app_router.dart`, `core/router/routes.dart` (+`/ridebus` route) |
| Home | `features/home/presentation/screens/home_screen.dart` (wired onTap) |
| Build | `build_apk.ps1` (new) |
| Docs | `HANDOVER.md` (updated) |

### Remaining `onTap: null` cards
- Ring of Fire
- Paranoia
