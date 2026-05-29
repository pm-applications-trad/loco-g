# LocoGames Android releases

| Artifact | Description |
|----------|-------------|
| `locogames-debug.apk` | Debug build, **locogames** flavor (`lib/main_locogames.dart`). Built on VPS with Flutter 3.44. |

### `locogames-debug.apk` (latest)

- Built: 2026-05-29
- Size: ~160 MB
- SHA-256: `e427d8c50c9696c6a9d0cbc6a7f09c98efa9c72bbaa85cb53e515e87e6d37559`

Rebuild:

```bash
flutter build apk --debug --flavor locogames -t lib/main_locogames.dart
```

Requires JDK 17+, Android SDK, and Flutter >=3.27.
