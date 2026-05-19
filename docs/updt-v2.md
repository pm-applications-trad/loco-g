# LocoGames — Update Plan v2.0

> Date: 2026-05-17
> Status: Research complete. Implementation begins after v1.0 APK validation + multiplayer migration.

---

## 0. Research Summary

### 0.1 Social Media Trends (May 2026)

| Platform | Top Trending Party Game Categories | Viral Potential |
|----------|-----------------------------------|-----------------|
| **TikTok** | Social deduction (Among Us clones), Truth or Dare extreme, "APT" Korean drinking game, Would You Rather speed rounds, Never Have I Ever reveal clips, "Guess the Gibberish" word distortion | Highest — short-form gameplay clips go viral daily |
| **Instagram Reels** | Aesthetic card draws (Kings Cup), "Who's Most Likely To" voting reels, Two Truths One Lie stories, Charades/Pictionary reaction clips | High — visually-driven, shareable results screens |
| **X / Twitter** | Word games (Wordle, Connections clones), Codenames meta-discussion, "Rate the party game" threads, Secret Hitler strategy | Medium — text-native discussion, not gameplay |
| **Reddit** (r/boardgames, r/partygames) | Blood on the Clocktower deep dives, Feed the Kraken praise, The Resistance legacy, Jackbox Party Pack recommendations, Decrypto/Codenames ranking | Medium — influences purchasing, slower trend adoption |
| **YouTube Shorts** | Among Us VR moments, Werewolf role reveal reactions, Drinking game compilations, "Try Not to Laugh" party game challenges | Medium-High — game clip compilations |
| **Current mega-trends** | "The Traitors" TV show (40+ country adaptations in 2025-2026) → massive social deduction demand; Wordle → word game renaissance; Jackbox → phone-as-controller normalization; APT → Korean drinking game crossover |

### 0.2 Competitor Landscape Confirmed

| Competitor | Installs | Our Differentiator |
|-----------|----------|-------------------|
| Evil Apples | 10M+ | We have multi-game variety, not just cards |
| Picolo | 10M+ | Our sub is value-add, not core-gating |
| Jackbox Party Pack | 5M+ (paid) | We're mobile-native, offline-capable, lower price |
| Heads Up! | 50M+ | We have depth (multiple games), multiplayer, and 18+ |

### 0.3 Game Categories Ranked by Implementation Difficulty (for our codebase)

| Difficulty | Category | Example Games | Why |
|-----------|----------|---------------|-----|
| **Trivial** (1-3h) | Statement-based | Never Have I Ever, Most Likely To, Would You Rather, Truth or Dare | Just text cycling + counters. No domain logic. |
| **Easy** (3-6h) | Card/category draws | Power Hour (timer), Categories (word chains), Ride the Bus (card guessing) | Simple rules, no multi-entity aggregates. |
| **Medium** (6-12h) | Word games, Guessing | Twenty Questions, Hangman, Chain Reaction, Charades lite | Needs word lists + some logic. |
| **Hard** (12-20h) | Social deduction, Hybrid | Mafia/Werewolf, Spyfall, Codenames, Paranoia, Murmur | Multiple roles, hidden info, voting, rounds. |
| **Complex** (20h+) | Real-time multiplayer | Among Us-style, Blood on the Clocktower, Feed the Kraken | WebSocket sync, multiple simultaneous states. |

---

## 1. Extensions to Existing Games

### 1.1 Impostor — Phase 2 Enhancements

| # | Extension | Effort | Value |
|---|-----------|--------|-------|
| E1 | **Custom location packs** — Let users create & share location lists | 4h | High — infinite replayability |
| E2 | **AI-generated locations** — Nano Banana generates fresh locations per session | 3h | High — already planned in ext-plan v1 |
| E3 | **Timed discussion round** — Configurable timer with escalating pressure (pulse animation) | 1h | Medium |
| E4 | **Spectator mode** — Eliminated players can watch but not vote | 2h | Medium |
| E5 | **Impostor streak tracking** — Stats: times caught vs escaped, locations survived | 2h | Low-Medium |
| E6 | **Double agent variant** — 2 impostors who know each other; must coordinate silently | 3h | High |
| E7 | **Wordless mode** — Citizens see the location word, impostors must guess from context alone (no question asking) | 2h | Medium |

### 1.2 Guessing (Guess Battle) — Phase 2 Enhancements

| # | Extension | Effort | Value |
|---|-----------|--------|-------|
| E1 | **Category filter** — Science, Sports, Pop Culture, History, Nature, Mixed | 2h | High |
| E2 | **AI-generated questions** — Nano Banana prompt already defined | 3h | High |
| E3 | **Betting mechanic** — Players wager confidence points before revealing answer (multiplier: 2x if correct, -1x if wrong) | 3h | High — adds bluffing |
| E4 | **Team mode** — 2+ teams discuss and submit consensus guess | 2h | Medium |
| E5 | **Progressive hints** — 3 hints revealed over 15s before answering (less points for late hints) | 3h | Medium |
| E6 | **Picture rounds** — Guess quantity in AI-generated image (e.g. "How many marbles in this jar?") | 5h | High — visual engagement |

### 1.3 Who Am I? — Phase 2 Enhancements

| # | Extension | Effort | Value |
|---|-----------|--------|-------|
| E1 | **AI-generated identities** — Nano Banana generates fresh identities + hints per session | 3h | High |
| E2 | **Individual subject answer** — Finish the incomplete answering flow (per-question Yes/No for subject) | 3h | Critical Bug fix |
| E3 | **Timer per question** — 30s to ask, 10s to answer per question | 1h | Medium |
| E4 | **Object mode** — Instead of people, guess objects/animals/places | 1h | Medium |
| E5 | **Blind mode** — Subject doesn't see their own identity (shown to all others); subject asks yes/no questions to discover themselves | 2h | High — twist on classic |
| E6 | **Emoji mode** — Identity shown only as 3 emoji clues; subject guesses from emoji hints | 2h | Medium |

### 1.4 Kings Cup — Phase 2 Enhancements

| # | Extension | Effort | Value |
|---|-----------|--------|-------|
| E1 | **Custom rule cards** — Users can edit/override any card's rule text | 2h | High |
| E2 | **Rule pack presets** — Classic / Extreme / Chill / Custom | 1h | Medium |
| E3 | **Card animation improvements** — Flip animation, particle effects on king drawn | 2h | Low-Medium |
| E4 | **Sip counter** — Track drinks per player, warn when exceeding safe limits | 2h | Medium (safety feature) |
| E5 | **Music integration** — Background playlist shuffle during game (optional) | 3h | Low |

---

## 2. Phase 3: 6 Drinking Game Placeholders → Real Games

These already exist as locked cards on the home screen with L10n keys. Build order prioritized by implementation ease.

### 2.1 Ride the Bus (Easy — Card Guessing Pyramid)
**Status:** Placeholder card exists. L10n keys ready.

**Mechanic:**
1. 4-round pyramid card guessing game
2. Round 1: Guess Red or Black (50/50) — wrong → drink
3. Round 2: Guess Higher or Lower than previous card — wrong → drink
4. Round 3: Guess Inside or Outside (between first 2 cards) — wrong → drink
5. Round 4: Guess the Suit — wrong → ride the bus (4 drinks)
6. Pyramid visual: stacks of 4-3-2-1 cards

**Implementation:** 3h. Simple card comparisons, no complex aggregates needed. Reuse `CardModel` from Kings Cup.

### 2.2 Power Hour (Easy — Timer + Minigames)
**Status:** Placeholder card exists. L10n keys ready.

**Mechanic:**
1. 60-minute timer. Every 60 seconds a new prompt appears.
2. Each minute: a mini-challenge (take a drink, do a dare, answer a question)
3. At 30 min: "Halfway!" celebration with bonus challenge
4. At 60 min: "You survived!" completion screen
5. Playlist of 60 prompts shuffled per game

**Implementation:** 2h. Timer + text list cycling. 60 pre-written prompts.

### 2.3 Never Have I Ever (Trivial — Statement + Voting)
**Status:** Placeholder card exists. L10n keys ready. Nano Banana prompt already defined.

**Mechanic:**
1. Each player takes turns reading "Never have I ever..." statements
2. All players who HAVE done it press a "I have" button
3. Counter shows how many have done it → those players drink
4. Statement decks: Mild / Spicy / Extreme / Mixed
5. 200 pre-loaded statements, AI-generated packs for premium

**Implementation:** 2h. Simple text display + counter. Follows same pattern as Kings Cup pass-and-play.

### 2.4 Most Likely To (Trivial — Voting)
**Status:** Placeholder card exists. L10n keys ready. Nano Banana prompt already defined.

**Mechanic:**
1. "Who is most likely to..." scenario shown to all players
2. Players vote by tapping a player's name/avatar
3. Majority vote winner drinks (or does the thing)
4. Scenario decks: Funny / Embarrassing / Wild / Mixed
5. 200 pre-loaded scenarios

**Implementation:** 2h. Voting UI + text display.

### 2.5 Ring of Fire (Medium — Card Circle)
**Status:** Placeholder card exists. L10n keys ready.

**Mechanic:**
1. Cards arranged in a circle around a center cup
2. Players take turns pulling a card from the circle
3. Each card has a rule (similar to Kings Cup but unique ring-specific rules)
4. If the ring of cards is broken (card pulls another card), penalty drink
5. Game ends when ring is empty or 4 kings drawn

**Implementation:** 4h. Card arrangement logic + rule system.

### 2.6 Paranoia (Medium — Whisper + Guess)
**Status:** Placeholder card exists. L10n keys ready.

**Mechanic:**
1. Player A whispers a question about Player C to Player B (e.g. "Who has the worst dance moves?")
2. Player B answers by tapping/pointing at another player (private — only they see)
3. Player C must guess WHO was asked about them and WHAT the question was
4. If C guesses correctly, B drinks. If wrong, C drinks.
5. Rotate roles each round.

**Implementation:** 5h. Private UI state per player, pass-phone mechanic, guess resolution.

---

## 3. New Party Game Concepts (Phase 4+)

### 3.1 INNOVATION — MURMUR (Hybrid: Telephone + Drawing + Social Deduction)

**Category:** Text + Image + Social Deduction Hybrid
**Players:** 4–12
**Complexity:** Medium-Hard (10-15h implementation)
**Platform fit:** Perfect for pass-and-play mobile. No real-time networking needed.

#### Core Mechanic

```
Chain: Player1 → Player2 → Player3 → Player4 → ... → PlayerN

┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ SHOW     │    │ WHISPER  │    │ DRAW     │    │ WRITE    │
│ (secret  │───►│ (repeat  │───►│ (draw    │───►│ (guess   │
│  phrase) │    │  phrase) │    │  what    │    │  drawing)│
└──────────┘    └──────────┘    │  heard)  │    └──────────┘
                                └──────────┘
Chain alternates: WHISPER → DRAW → WHISPER → DRAW → ...
Each step introduces natural distortion.
One player is THE MURMURER who secretly changes ONE word.
```

#### Game Flow

**Phase 1: Role Assignment**
- Each round, one player secretly assigned as The Murmurer
- The Murmurer must distort exactly ONE word at any point in the chain
- All other players are Transmitters trying to pass the message faithfully

**Phase 2: The Chain (Alternating Whisper/Draw)**

Seven stages per round:

| Step | Player Action | Screen Shows | Duration |
|------|--------------|-------------|----------|
| 1 | Player 1 reads secret phrase | AI-generated image + phrase text | 10s memorize |
| 2 | Player 1 whispers to Player 2 | Blank screen (privacy) | 15s |
| 3 | Player 2 draws interpretation | Drawing canvas + color palette | 30s |
| 4 | Player 3 views drawing, writes guess | Drawing displayed + text input | 20s |
| 5 | Player 3 whispers to Player 4 | Text shown to whisperer only | 15s |
| 6 | Player 4 draws interpretation | Drawing canvas | 30s |
| 7 | Player 5 views final drawing, writes final guess | Drawing + text input | 20s |
| End | All players see full evolution | Animated chain reveal | Auto |

**Phase 3: The Reveal (Animated)**
- Sequential animation: original image → whisper 1 → drawing 1 → guess 1 → whisper 2 → drawing 2 → final guess
- Color-coded: green = accurate transmission, yellow = slight drift, red = major distortion, purple = Murmurer intervention point
- Each step animates with a 1.5s delay for dramatic effect

**Phase 4: Accusation & Voting**
- All players see the full distorted chain
- Discussion: 60s timer (audio: suspense countdown)
- Each player votes for who they think is The Murmurer
- Scoring:
  - Correct Murmurer identification: +3 points per correct voter
  - Murmurer escapes detection: +5 points
  - Closest final guess to original: +2 points
  - Most creative/funny drawing: +1 point (audience vote)

**Phase 5: Drawing Gallery**
- All drawings saved to a per-session gallery
- Share individual drawings or full chain to social media
- "Funniest distortion" and "Best artist" badges awarded

#### Image Content Strategy

The game relies on AI-generated surreal images paired with evocative phrases. These serve as the "seed" for each round's chain.

**Image prompt template (for Gemini Nano Banana / ChatGPT):**

```
PROMPT: Create a surreal, slightly absurd illustration in a flat vector art style 
suitable for a party game. The image should combine 2-3 unexpected elements that 
suggest a specific phrase or concept.

Style: Flat vector, vibrant colors (#6C3CE1 purple, #FF3B6E pink, #00D4AA teal as 
dominant palette), clean outlines, 1:1 square format, no text on image, 
suitable for mobile screen display at 400x400px.

Concept: {CONCEPT}
Key elements to include: {ELEMENTS}
Mood: {MOOD}
Ambiguity level: {LEVEL} (how easy it is to misinterpret — higher = more chaos)

The image should clearly communicate the concept to someone who reads the phrase first, 
but be ambiguous enough that someone seeing ONLY the image might interpret it differently.
```

**Example image prompts (10 seed concepts):**

| # | Concept | Elements | Mood |
|---|---------|----------|------|
| 1 | "A cat running a bakery" | Cat in chef hat, croissant, flour explosion | Playful chaos |
| 2 | "The moon applying for a job" | Moon in a suit, holding resume, office desk | Absurd corporate |
| 3 | "Banana escaping from a fruit bowl" | Banana with tiny legs, overturned bowl, fleeing apple | Action comedy |
| 4 | "Ghost afraid of its own reflection" | Ghost looking in mirror, mirror shows scarier ghost, ghost sweating | Humorous fear |
| 5 | "Squirrel secret agent on mission" | Squirrel in tuxedo, tiny earpiece, acorn briefcase | Spy thriller |
| 6 | "Toaster having an existential crisis" | Toaster looking at bread, reflection shows stars/universe | Philosophical |
| 7 | "Cloud factory with weather dials" | Cloud assembly line, giant dials (rain/snow/sun), workers | Whimsical |
| 8 | "Penguin learning to fly" | Penguin with cardboard wings, flight school sign, crash pad | Determination |
| 9 | "Lighthouse sending text messages" | Lighthouse projecting SMS bubbles into ocean, "U UP?" | Lonely romance |
| 10 | "Chess pieces on a date" | King and Queen at tiny restaurant table, candle, waiter pawn | Romantic comedy |

**Model recommendation:** Gemini Nano Banana for images (better at surreal/fantastical compositions, faster generation, cost-effective at scale). ChatGPT/GPT-4o for phrase generation and game logic text.

#### UI Design Notes

- **Color overlay per phase:** Purple (whisper), Pink (draw), Teal (write), Gold (reveal), Red (accusation)
- **Chain reveal animation:** Cards slide in from right, connect with wavy lines (whisper = wavy, draw = brush stroke)
- **Drawing canvas:** 8-color palette + eraser, 3 brush sizes, undo button, 30s countdown ring
- **Voting screen:** Player avatars in a circle, tap to vote, checkmark confirms, glow on most-voted
- **Audio triggers:** Whisper sound on whisper phase, pencil scratch on draw, suspense on accusation, drumroll on reveal, celebration on correct Murmurer catch

#### Implementation Architecture

```
lib/features/murmur/
├── domain/
│   ├── entities/
│   │   ├── murmur_game.dart         # Aggregate: id, players, chainSteps, murmurerIndex, phase
│   │   ├── murmur_player.dart       # id, name, score, role (transmitter/murmurer)
│   │   ├── chain_step.dart          # stepIndex, type (whisper/draw/write), content, fromPlayer, toPlayer
│   │   ├── seed_card.dart           # imageUrl, secretPhrase, difficulty
│   │   └── game_settings.dart       # playerCount, rounds, chainLength
│   ├── repositories/
│   │   └── seed_card_repository.dart # abstract: getRandomSeed()
│   └── usecases/
│       ├── create_murmur_game.dart
│       ├── assign_murmurer.dart
│       ├── submit_whisper.dart
│       ├── submit_drawing.dart
│       ├── submit_guess.dart
│       ├── reveal_chain.dart
│       ├── submit_vote.dart
│       └── resolve_round.dart
├── data/
│   └── repositories/
│       └── seed_card_repository_impl.dart # 30+ bundled seed cards with image paths
├── presentation/
│   ├── providers/
│   │   └── murmur_game_provider.dart
│   └── screens/
│       ├── murmur_setup_screen.dart
│       ├── murmur_game_screen.dart        # Main game with phase switching
│       └── widgets/
│           ├── chain_reveal_widget.dart    # Animated evolution reveal
│           ├── drawing_canvas_widget.dart  # Simple drawing tool
│           └── voting_circle_widget.dart   # Player voting UI
```

### 3.2 Twenty Questions — AI Hosted (Easy-Medium)
**Category:** Guessing Game | **Players:** 2-20

**Mechanic:**
1. AI (or pre-selected deck) picks a secret noun
2. Players take turns asking yes/no questions
3. After each answer, players can guess or ask another question
4. Max 20 questions per round. Hints at questions 10 and 15.
5. Scoring: earlier correct guess = more points

**Implementation:** 5h. Reuse Who Am I? question-answer flow.

### 3.3 Two Truths One Lie — Digital (Easy)
**Category:** Social / Icebreaker | **Players:** 3-20

**Mechanic:**
1. Player enters 3 statements (2 true, 1 lie)
2. Other players read statements and vote on which is the lie
3. Animated reveal: lie statement glows red and shakes
4. Points: correct guessers +1, liar gets +1 per person fooled
5. Content packs: themed statement suggestions

**Implementation:** 4h.

### 3.4 Chain Reaction — Word Chain (Easy)
**Category:** Word Game | **Players:** 2-20

**Mechanic:**
1. First player says a word
2. Next player must say a word starting with the LAST letter of previous word
3. Timer decreases each round (starts at 10s, decreases by 0.5s each word)
4. Category mode: only animals, countries, movies, etc.
5. "Explode" at 0s → that player loses

**Implementation:** 3h. Simple word validation + timer.

### 3.5 Would You Rather — Debate Mode (Easy)
**Category:** Social / Conversation | **Players:** 2-20

**Mechanic:**
1. Two absurd scenarios shown ("Would you rather fight 100 duck-sized horses or 1 horse-sized duck?")
2. Players vote which they'd choose
3. Percentage reveal + debate phase: anyone can argue for their choice
4. Themed decks: Gross, Philosophical, Superhero, Survival, Dating

**Implementation:** 2h.

### 3.6 Secret Word — Codenames-Style (Medium)
**Category:** Word / Team | **Players:** 4-16 (2 teams)

**Mechanic:**
1. 25-word grid displayed to all
2. Spymaster sees color overlay (8 blue words, 8 red words, 1 assassin word, 8 neutral)
3. Spymaster gives one-word clue + number (e.g. "Fruit 3")
4. Teammates tap words to guess. Wrong tap = turn over or assassin = instant loss
5. First team to find all 8 words wins

**Implementation:** 8h. Grid UI, team split, word lists, color overlay system.

### 3.7 Spyfall — Location Deduction (Medium-Hard)
**Category:** Social Deduction | **Players:** 3-8

**Mechanic:**
1. All players see the same location card EXCEPT the spy
2. Players take turns asking each other questions about the location (without naming it)
3. The spy must bluff convincingly
4. After 8 minutes, players vote who is the spy
5. Spy can also guess the location to win instantly

**Implementation:** 8h. 30 locations with question-asking system.

### 3.8 Would You Rather — VR/Motion Variant (Future)
**Category:** Motion | **Players:** 2-8

**Mechanic:**
1. Two options shown on left/right sides of screen
2. Players tilt phone LEFT or RIGHT to vote physically
3. Gyroscope detects tilt angle → animated character walks left or right
4. Works as drinking game or icebreaker

**Implementation:** 6h. Requires sensor plugin integration.

---

## 4. Cross-Game Features (Phase 5)

### 4.1 Player Profile & Stats System
- Per-player stats across all games: games played, wins, favorite game
- "Player Vault" — name presets with avatars (emoji + color selection)
- Streak tracking: "3 wins in a row!" notifications
- Integration: shared Player model used by all game providers

### 4.2 Content Manager (AI-Generated Content)
Already designed in extension-plan-v1.0.md. Full implementation:
- `ContentManager` class (Dart) with Hive caching
- OpenAI API proxy on backend VPS
- Pre-fetch during app idle, cache with 24h TTL
- Fallback to bundled content when offline
- All 6 already-defined Nano Banana prompt templates

### 4.3 Social Sharing System
- Screenshot + overlay: game results with app watermark + QR code
- "Challenge a friend" deep links
- TikTok/Reels-optimized: pre-cropped 9:16 vertical format for "post your results" clips
- Drawing gallery (from Murmur) shareable as image carousel

### 4.4 Themed Party Packs
- Pre-configured game sequences: "Bachelorette Night" (Who Am I? → Never Have I Ever → Kings Cup), "Game Night" (Impostor → Murmur → Two Truths One Lie)
- Themed content for holidays (Halloween, Christmas, New Year's Eve)
- Premium: custom user-created pack builder

---

## 5. Multiplayer Migration (Critical Path)

### 5.1 Current State
- `WebSocketClient` in core/services is fully implemented but NOT wired to UI
- `LobbyScreen` and `MultiplayerGameScreen` are placeholder stubs
- No backend server code exists yet

### 5.2 Migration Plan

| Step | Task | Priority |
|------|------|----------|
| M1 | Write Node.js WebSocket server on Ubuntu VPS (Socket.io) | P0 |
| M2 | Room management: create/join by 6-char code, max 16 players | P0 |
| M3 | Wire `WebSocketClient` to `LobbyScreen` — real create/join flow | P0 |
| M4 | Impostor multiplayer: sync location, roles, voting across clients | P1 |
| M5 | Guessing multiplayer: sync question, guesses, results | P1 |
| M6 | Who Am I? multiplayer: sync identity, questions, guesses | P1 |
| M7 | Murmur multiplayer: sync chain steps, voting | P2 |
| M8 | REST API: player stats, leaderboards, content packs delivery | P2 |
| M9 | Auth system: device ID or optional email/password | P2 |

### 5.3 Backend Tech Stack
- **Server:** Node.js + Socket.io + Express
- **Database:** SQLite (lightweight, no separate DB process) or PostgreSQL
- **Deployment:** Docker on Ubuntu VPS, nginx reverse proxy, Let's Encrypt SSL
- **Monitoring:** pm2 process manager, basic health check endpoint

---

## 6. Full Implementation Sequence

```
v1.0 MVP (CURRENT — awaiting APK validation)
├── Impostor ✅
├── Guessing ✅
├── Who Am I? ✅
├── Kings Cup ✅
├── Core services (Audio, Haptic, Theme, L10n, Router) ✅
└── 3-flavor build system ✅

v1.0.1 — Polish & Fix (1-2 days after APK validation)
├── Fix Who Am I? incomplete answering flow (E2)
├── Add missing asset files (sounds, fonts)
├── Wire legal links in Settings
└── Smoke test all 4 games

v1.1 — Drinking Games Complete (3-4 days)
├── Never Have I Ever (2h)
├── Most Likely To (2h)
├── Power Hour (2h)
├── Ride the Bus (3h)
├── Ring of Fire (4h)
├── Paranoia (5h)
└── Update Home screen card enables + L10n

v1.2 — Game Extensions (2-3 days)
├── Impostor: custom locations, AI locations, timer
├── Guessing: betting, categories, AI questions
├── Who Am I?: AI identities, blind mode
├── Kings Cup: custom rules, pack presets
└── ContentManager + Hive caching (AI content pipeline)

v1.3 — New Games Wave 1 (4-5 days)
├── Two Truths One Lie (4h)
├── Would You Rather (2h)
├── Chain Reaction (3h)
├── Twenty Questions (5h)
└── Murmur FULL (12h) — flagship new game

v1.4 — New Games Wave 2 + Social (4-5 days)
├── Secret Word / Codenames (8h)
├── Spyfall (8h)
├── Categories (drinking game) (2h)
├── Social sharing system
└── Player profile & stats

v1.5 — Multiplayer (5-7 days)
├── Backend server on VPS
├── Room system in LobbyScreen
├── Impostor online
├── Guessing online
├── Who Am I? online
└── Murmur online

v2.0 — Premium + Release Polish (3-5 days)
├── RevenueCat integration (real)
├── AdMob integration (real)
├── Premium: AI host, unlimited content, custom packs
├── App Store screenshots & metadata
├── Privacy Policy, Terms, Legal
└── Release to Google Play / App Store
```

---

## 7. Key Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | Build drinking game placeholders FIRST (v1.1) | They're trivial/easy effort, unblock the full product offering, and the L10n keys already exist |
| 2 | Murmur is the flagship new game | Unique concept (no competitor has telephone+drawing+deduction hybrid), leverages AI images, high viral potential |
| 3 | Gemini Nano Banana for images, GPT-4o for text | Gemini better at surreal compositions; GPT better at structured game content generation |
| 4 | Multiplayer DEFERRED to v1.5 | Pass-and-play alone is a viable product. Multiplayer requires backend + more testing. Don't block v1.0 launch. |
| 5 | Premium = AI content + social sharing + ad removal | Follows the extension-plan-v1.0 strategy. AI cost justified by subscription. |
| 6 | All games work offline with bundled content | AI is enhancement, not requirement. 50-200 pre-seeded items per game. |
| 7 | Keep all games as flavored APKs | 3-app ecosystem (party/drinks/bundle) is unique competitive advantage |

---

## 8. Risks & Mitigations

| Risk | Prob | Impact | Mitigation |
|------|------|--------|------------|
| APK size too large with bundled images | High | Medium | Compress images to WebP, lazy-load from assets, download packs on-demand |
| AI image generation costs | Medium | Medium | Bundle 30+ static images per game, AI only for premium refresh |
| Murmur drawing canvas complexity | Medium | Medium | Simple 8-color palette + eraser, no layers/stamps. Keep it Minimal Viable Drawing. |
| Play Store 18+ policy rejection | Low | High | Clear age verification, no explicit content in screenshots, follow Google family policies |
| Multiplayer latency on VPS | Medium | Medium | Use Socket.io rooms, keep state updates minimal, reconnection logic |
| Competitor copies Murmur concept | Low | Low | First-mover advantage + embedded in multi-game ecosystem = hard to replicate stickiness |

---

## 9. Image Prompt Quick Reference (for Murmur Seed Cards)

```
Generate a surreal illustration for the party game "Murmur":
- Concept: {concept}
- Style: flat vector, vibrant palette (#6C3CE1 purple, #FF3B6E pink, #00D4AA teal, #FFB800 gold)
- Format: 1:1 square, 400x400px, PNG, no text on image
- Ambiguity target: {easy|medium|hard} to misinterpret
- Key elements: {comma-separated list of 3-5 visual elements}
- Mood: {playful|absurd|dramatic|mysterious|whimsical}
```

**10 bundled seed card concepts (shipped with v1.3):**
1. "A cat running a bakery" — easy
2. "The moon applying for a job" — medium
3. "Banana escaping from a fruit bowl" — easy
4. "Ghost afraid of its own reflection" — medium
5. "Squirrel secret agent on mission" — easy
6. "Toaster having an existential crisis" — hard
7. "Cloud factory with weather dials" — medium
8. "Penguin learning to fly" — easy
9. "Lighthouse sending text messages" — medium
10. "Chess pieces on a date" — easy

---

## 10. Appendix: L10n Key Forecast

Estimated new keys needed per game:

| Game | New L10n Keys |
|------|--------------|
| Ride the Bus | ~12 |
| Power Hour | ~10 |
| Never Have I Ever | ~8 |
| Most Likely To | ~8 |
| Ring of Fire | ~15 |
| Paranoia | ~14 |
| Murmur | ~35 |
| Twenty Questions | ~12 |
| Two Truths One Lie | ~8 |
| Would You Rather | ~8 |
| Chain Reaction | ~10 |
| Secret Word | ~18 |
| Spyfall | ~15 |
| Cross-game (stats, sharing, packs) | ~25 |
| **Total estimated new keys** | **~198** |

All 4 languages (EN/DE/ES/FR) — manageable within existing L10n pipeline.

---

## 11. Handover Context

This document (`updt-v2.md`) defines the full post-v1.0 roadmap. It is NOT prioritized — it sits at the end of the implementation sequence. The next agent should:

1. Complete v1.0 APK validation (user testing ongoing)
2. Execute v1.0.1 polish/fixes
3. Then follow the sequence: v1.1 → v1.2 → v1.3 → v1.4 → v1.5 → v2.0

The Murmur game is the centerpiece innovation. All other games follow established patterns from the codebase.
