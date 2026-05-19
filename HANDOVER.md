# LocoGames — Handover Summary

## 1. Session Date & Duration
**2026-05-19** — Single session, ~90 minutes

## 2. Files Created/Modified

### Task 1: i18n Completion (Phase 0.5)

- **`assets/l10n/en.json`** — Added 20 Ride the Bus i18n keys + `card` key (21 new keys total)
- **`assets/l10n/de.json`** — Added 21 German translations for new keys
- **`assets/l10n/es.json`** — Added 21 Spanish translations for new keys
- **`assets/l10n/fr.json`** — Added 21 French translations for new keys

All 4 language files now have 177 keys each, fully synced.

### Task 2: Ride the Bus Game Implementation (formerly `onTap: null`)

- **`lib/features/ridethebus/domain/entities/card_model.dart`** — NEW. `PlayingCard` model with `CardSuit`/`CardValue` enums, numeric comparison support.
- **`lib/features/ridethebus/domain/entities/player.dart`** — NEW. `RTBPlayer` entity with penalty tracking and bus-rider flag.
- **`lib/features/ridethebus/domain/entities/ride_the_bus_game.dart`** — NEW. Core game state object with `PyramidSlot`, `RTBRound`, `RTBPhase` enums. Pyramid layout: 4-3-2-1 card structure. Player ordering, penalty sorting, card-above lookups.
- **`lib/features/ridethebus/domain/usecases/ride_the_bus_usecases.dart`** — NEW. `CreateRideTheBusGame`, `ProcessGuess` (validates Red/Black, Higher/Lower, Inside/Outside, Suit guesses against actual cards), `AdvanceRideTheBusGame` (handles step/round/player transitions, fresh pyramid per player), `ResetRideTheBusGame`.
- **`lib/features/ridethebus/presentation/providers/ride_the_bus_provider.dart`** — NEW. Riverpod `Notifier` with `RideTheBusViewState` (setup/playing/gameOver), `startGame`, `setGuessing`, `submitGuess`, `advance`, `resetGame`.
- **`lib/features/ridethebus/presentation/screens/ride_the_bus_setup_screen.dart`** — NEW. Setup screen with 2-8 player selection, name fields, in-game rules display. Follows kings_cup pattern with `_rebuildNameControllers` (preserves names on count change) and empty name fallback to "Player N".
- **`lib/features/ridethebus/presentation/screens/ride_the_bus_game_screen.dart`** — NEW. Full game screen with 4 phases:
  - `_RoundIntroPhase` — Shows current round name, pyramid preview with highlighted row, player header with penalty counts
  - `_GuessingPhase` — Shows face-down card, guess buttons (contextual per round: Red/Black, Higher/Lower, Inside/Outside, 4 suits), reference card indicators for Higher/Lower and Inside/Outside rounds, pyramid status with revealed cards
  - `_ResultPhase` — Animated correct/wrong reveal, shows flipped card, penalty amount (1/2/3/4 drinks based on round)
  - `_GameOverPhase` — Leaderboard with medals, bus rider highlight, play-again / main-menu buttons

### Router & Navigation Updates

- **`lib/core/router/app_router.dart`** — Added imports for `RideTheBusSetupScreen` and `RideTheBusGameScreen`
- **`lib/core/router/routes.dart`** — Added `/ridebus` route with nested `/ridebus/play` route
- **`lib/features/home/presentation/screens/home_screen.dart`** — Changed Ride the Bus card from `onTap: null` to `onTap: () => context.go('/ridebus')`

### Build Infrastructure

- **`build_apk.ps1`** — NEW. PowerShell build script supporting:
  - All 3 flavors (locogames, locodrinks, locobundle)
  - Debug + Release APK builds
  - Auto-finds Flutter SDK (common paths + `-FlutterPath` param)
  - Copies APKs to `build/output/` with timestamped names
  - Prints emulator/device install instructions on completion

## 3. Current Project State

| Phase | Description | Status |
|-------|-------------|--------|
| 0 | Foundation & Architecture Setup | **DONE** |
| 0.1 | Flutter project scaffolding | Done |
| 0.2 | Clean Architecture skeleton | Done |
| 0.3 | Riverpod + GetIt setup | Done |
| 0.4 | go_router routing & navigation | Done |
| 0.5 | i18n infrastructure (JSON files) | **DONE** (this session) |
| 0.6 | Theming engine | Done |
| 1 | Extension plan v1.0 | Done |
| 2 | Core shared modules | Pending |
| 3 | Legacy game migration | Done |
| 4 | New games implementation | **7 of 10 games implemented** |
| 5 | Polish & UX enhancement | Pending |
| 6 | Testing & QA | Pending |
| 7 | App Store preparation & release | Pending |

### Game Feature Status Summary

| Game | Implementation | Status |
|------|---------------|--------|
| Impostor | Complete (9 files) | Done |
| Guessing | Complete (10 files) | Done |
| Never Have I Ever | Complete (10 files) | Done |
| Most Likely To | Complete (10 files) | Done |
| Who Am I | Complete (10 files) | Done |
| Kings Cup | Complete (8 files) | Done |
| **Ride the Bus** | **Complete (7 files)** | **DONE (this session)** |
| Power Hour | Complete (4 files) | Done |
| Multiplayer | STUB (2 placeholder screens) | Pending |
| Ring of Fire | `onTap: null` | Pending |
| Paranoia | `onTap: null` | Pending |

### Remaining `onTap: null` cards on Home Screen
- Ring of Fire
- Paranoia

## 4. Pending Tasks

- [ ] Implement Ring of Fire game
- [ ] Implement Paranoia game
- [ ] **Phase 2**: Core shared modules (ContentManager, Hive caching layer per extension plan v1.0 Section 3.3)
- [ ] Implement Multiplayer backend (WebSocket server + REST API on Ubuntu VPS)
- [ ] Build and test APKs on a machine with Flutter SDK
- [ ] Write unit/widget tests for all games (currently zero coverage)
- [ ] Flutter SDK not available for `Administrator` user — needs install or access to `pm-dev` installation

## 5. Blockers & Decisions

- **Flutter SDK**: Still not accessible. The build script (`build_apk.ps1`) auto-searches common paths including `C:\Users\pm-dev\flutter_sdk\flutter`. Run on pm-dev's machine or install Flutter for Administrator.
- **Ride the Bus design decision**: Each player gets a fresh shuffled pyramid (not the same pyramid across players). This is simpler and more fair.
- **Card model duplication**: `PlayingCard` in `ridethebus/` is a separate copy from `CardModel` in `kingscup/`. Future refactor: extract a shared `lib/core/models/card_model.dart` used by both features.
- **Remaining `onTap: null` games**: Ring of Fire and Paranoia are the last two. Ring of Fire is similar to Kings Cup (card-drawing). Paranoia is a social/whispering game — will need different UI patterns.

## 6. Next Steps

### First Action for Next Session
Implement **Ring of Fire** game (card-based drinking game, similar pattern to Kings Cup). Then **Paranoia** game (social whispering game with pointing/guessing mechanic).

### APK Build Verification
On a machine with Flutter SDK:
```powershell
.\build_apk.ps1 -Mode all -Flavor all
```
Or for quick single-flavor test:
```powershell
flutter build apk --debug --flavor locodrinks --target lib/main_locodrinks.dart
```
Then install on emulator:
```powershell
adb install build\output\locogames_locodrinks_debug_*.apk
```
