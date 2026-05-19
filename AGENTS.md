# LocoGames — Agent Instructions

> This file is read automatically by AI agents (KiloCode, etc.) when working in this project directory.

## Handover Protocol (MANDATORY)

**At the end of every session, the agent MUST produce a handover summary** containing:

1. **Session Date & Duration** — When the session occurred.
2. **Files Created/Modified** — List every file touched with a brief description of the change.
3. **Current Project State** — What phase/stage the project is in (referencing the Implementation Plan below).
4. **Pending Tasks** — Exactly what the next agent needs to pick up. Use checkbox format.
5. **Blockers & Decisions** — Any unresolved issues, decisions deferred, or context the next agent needs.
6. **Next Steps** — Specific, actionable first task for the next session.

Write the handover to the file `HANDOVER.md` in the project root. Overwrite it each session — it is a rolling document, not a log.

## Project Summary

- **Name**: LocoGames
- **Description**: Premium 18+ party game application
- **Framework**: Flutter (Dart) with Clean Architecture
- **Platforms**: iOS & Android
- **State Management**: Riverpod
- **DI**: GetIt
- **Routing**: go_router
- **i18n**: EN, DE, ES, FR (custom JSON-based L10n)
- **Monetization**: Ad-supported (Google Mobile Ads) + Subscription (RevenueCat) for ad-removal & premium features
- **Backend**: Ubuntu VPS — online multiplayer via WebSockets + REST API

## Tech Stack

```
flutter_riverpod ^2.6.1    | State management
go_router ^14.8.1           | Navigation
get_it ^8.0.3               | Dependency injection
dio ^5.7.0                  | HTTP client
web_socket_channel ^3.0.2   | WebSocket client
shared_preferences ^2.3.5   | Local key-value storage
hive ^2.2.3                 | Local NoSQL storage
flutter_animate ^4.5.2      | Declarative animations
lottie ^3.3.1               | Lottie animations
shimmer ^3.0.0              | Skeleton loading
cached_network_image ^3.4.1 | Image caching
confetti_widget ^0.4.0      | Celebration effects
vibration ^2.0.1            | Haptic feedback
audioplayers ^6.1.0         | Sound effects
google_mobile_ads ^5.2.0    | AdMob integration
revenuecat ^1.2.0           | Subscription management
freezed ^2.5.7              | Immutable data classes
json_serializable ^6.9.2    | JSON codegen
```

## Implementation Plan

| Phase | Description | Status |
|-------|-------------|--------|
| 0 | Foundation & Architecture Setup | IN PROGRESS |
| 0.1 | Flutter project scaffolding | Done |
| 0.2 | Clean Architecture skeleton | Done |
| 0.3 | Riverpod + GetIt setup in pubspec.yaml | Done |
| 0.4 | go_router routing & navigation | Done |
| 0.5 | i18n infrastructure (ARB/JSON files) | Pending |
| 0.6 | Theming engine | Done |
| 1 | Active Research & extension-plan-v1.0.md | Pending |
| 2 | Core shared modules | Pending |
| 3 | Legacy game migration (Impostor + Guessing) | Pending |
| 4 | New games implementation (up to 3) | Pending |
| 5 | Polish & UX enhancement | Pending |
| 6 | Testing & QA | Pending |
| 7 | App Store preparation & release | Pending |

## Project Structure

```
locogames/
├── lib/
│   ├── main.dart                    # Entry point with ProviderScope
│   ├── core/
│   │   ├── constants/               # AppConstants
│   │   ├── di/                      # GetIt injection setup
│   │   ├── extensions/              # Dart extensions
│   │   ├── router/                  # GoRouter config + routes
│   │   ├── services/                # HapticService, AudioService, AdService, PremiumService
│   │   ├── theme/                   # AppTheme (dark/light, tokens)
│   │   ├── utils/                   # Utility functions
│   │   └── widgets/                 # Shared widgets (animated containers, etc.)
│   ├── features/
│   │   ├── home/                    # Home screen with game grid
│   │   ├── onboarding/              # Age verification + intro carousel
│   │   ├── settings/                # Language, sound, haptics, legal
│   │   ├── impostor/                # "Impostor" game (ported from Kotlin)
│   │   ├── guessing/                # "Schätzduell" game (ported from Kotlin)
│   │   ├── monetization/            # Premium subscription + ad management
│   │   └── multiplayer/             # Online lobby + WebSocket game sessions
│   └── l10n/                        # Localization engine (custom L10n class)
├── assets/
│   ├── images/                      # Game assets, icons, backgrounds
│   ├── fonts/                       # Poppins + Righteous
│   ├── sounds/                      # SFX: tap, success, error, reveal, countdown, background
│   └── l10n/                        # JSON translation files (en.json, de.json, es.json, fr.json)
├── test/
│   ├── unit/                        # Unit tests for domain logic
│   ├── widget/                      # Widget tests for UI components
│   └── integration/                 # End-to-end game flow tests
├── pubspec.yaml                     # Dependencies & asset declarations
├── analysis_options.yaml            # Lint rules
└── AGENTS.md                        # This file
```

## Coding Conventions

- **State management**: Use Riverpod providers (`StateProvider`, `StateNotifierProvider`, `AsyncNotifierProvider`). Keep providers in the same feature folder.
- **Feature structure**: Each feature follows `data/`, `domain/`, `presentation/` layers. Domain models use `freezed`. Repositories are abstract in domain, implemented in data.
- **Widgets**: Prefer `const` constructors. Use `ConsumerWidget` / `ConsumerStatefulWidget` from Riverpod.
- **Theming**: Use `AppTheme` constants for spacing, durations, radii. Never hardcode values.
- **i18n**: All user-facing strings go through `L10n.of(context).translate('key')`. Never hardcode text.
- **Navigation**: Use `context.go()` or `ref.watch(appRouterProvider).go()` for navigation.
- **Package imports**: Use `package:locogames/...` for all internal imports.
- **Code generation**: Run `dart run build_runner build --delete-conflicting-outputs` after modifying freezed/json_serializable models.
- **No comments**: Do not add comments unless explicitly requested by the user.

## Running the Project

```bash
# Install dependencies
flutter pub get

# Run code generation (after modifying freezed/hive models)
dart run build_runner build --delete-conflicting-outputs

# Run on device
flutter run

# Run tests
flutter test

# Lint
flutter analyze
```
