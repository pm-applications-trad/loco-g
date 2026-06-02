# LocoGames — Handover Summary

## 1. Session Date & Duration
**2026-06-02** — Release signing setup + all-games (LocoBundle) release APK build.

## 2. Files Created/Modified

- **`android/key.properties.example`** — New committed template documenting how to create the git-ignored `key.properties` and generate a release keystore.
- **`.gitignore`** — Added `ios/Flutter/ephemeral/` so Flutter-generated iOS tooling is no longer tracked.
- **`HANDOVER.md`** — Rewritten for this session.
- Carried over from the previous session (build compatibility): `pubspec.yaml`, `android/gradle.properties`, `android/gradle/wrapper/gradle-wrapper.properties`, `android/settings.gradle`, `ios/Runner/GeneratedPluginRegistrant.m`, and analyzer cleanups in `lib/features/ridethebus/...`, `lib/features/settings/...`, `lib/features/mostlikelyto/...`, `lib/features/neverhaveiever/...`.

Local-only (git-ignored, NOT committed — secrets):
- **`android/app/locogames-release.jks`** — Release keystore (RSA 2048, validity 10000 days, alias `locogames`).
- **`android/key.properties`** — Points the Gradle release signing config at the keystore.

## 3. Current Project State

Release signing is wired end-to-end. The `release` build type in `android/app/build.gradle` consumes `signingConfigs.release`, which reads `android/key.properties`. A signed release APK was produced for the **LocoBundle** flavor, which is the flavor whose `enabledGames` set includes every built game.

All built games are present in the LocoBundle APK:
impostor, guessing, multiplayer, who am I, kings cup, ride the bus, power hour, never have i ever, most likely to. (`ring of fire` and `paranoia` remain disabled placeholder cards — no screens built yet.)

Verification completed:
- `flutter analyze` — No issues found
- `flutter test` — Passed (1 smoke test)
- `flutter build apk --release --flavor locobundle --target lib/main_locobundle.dart` — Passed
- `apksigner verify` — Signed by `CN=PM Applications` release cert (not debug)

## 4. Built Artifact

- **`build/app/outputs/flutter-apk/app-locobundle-release.apk`** (~63 MB) — signed LocoBundle release APK containing all games. `applicationId com.pmapplications.locobundle`.

## 5. Pending Tasks

- [ ] User to install and test the LocoBundle release APK on a device.
- [ ] Store the keystore + passwords in a secure secret manager (currently local only); losing them means losing the ability to update the published app.
- [ ] Optional: upgrade Kotlin to >= 2.2.20 and migrate to Flutter Built-in Kotlin (currently a deprecation warning, not an error).

## 6. Blockers & Decisions

- **Decision:** Delivered the **LocoBundle** flavor because it is the only flavor whose feature set bundles every game; `locogames` and `locodrinks` each expose a subset by design.
- **Decision:** Keystore and `key.properties` are git-ignored and excluded from the PR; only a `.example` template is committed.
- No outstanding blockers.
