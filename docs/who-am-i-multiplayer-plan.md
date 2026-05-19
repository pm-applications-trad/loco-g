# Who Am I? — Multiplayer Chat Game Design

> **Game Type**: Chat-based multiplayer parlor game
> **Platform**: Flutter (iOS + Android) with Ubuntu VPS backend
> **Target**: 2–16 players per room, real-time WebSocket communication

---

## 1. Game Overview

A digital version of the classic "Who Am I?" party game. Each player is secretly assigned a person, fictional character, or object. The assignment is visible to all *other* players but not to oneself. Through a chat interface, players take turns asking yes/no questions to deduce their own identity.

**Core Loop**:
1. Host creates a room → receives room code
2. Players join via room code
3. Host selects category and game settings
4. Each player receives a hidden identity (visible to others)
5. Players ask yes/no questions in chat
6. A player guesses their identity correctly → they "win" and can spectate or help
7. Last player remaining is the "loser" (drinking game penalty potential)

---

## 2. Category System

### 2.1 Built-in Categories

```dart
enum CategoryType { realPerson, fictionalCharacter, animal, object, custom }
```

| Category | Examples | Difficulty |
|----------|----------|------------|
| **Celebrities** | Tom Cruise, Beyoncé, Elon Musk | Easy |
| **Historical Figures** | Cleopatra, Einstein, Napoleon | Medium |
| **Athletes** | Messi, Serena Williams, Michael Jordan | Easy |
| **Politicians** | Angela Merkel, Barack Obama, Greta Thunberg | Medium |
| **Musicians** | Mozart, Freddie Mercury, Taylor Swift | Easy |
| **Movie Characters** | Harry Potter, James Bond, Elsa | Easy |
| **TV Characters** | Walter White, Homer Simpson, Daenerys | Medium |
| **Video Game Characters** | Mario, Lara Croft, Kratos | Medium |
| **Literary Characters** | Sherlock Holmes, Dracula, Katniss | Hard |
| **Animals** | Elephant, Dolphin, Penguin | Easy |
| **Objects** | Toaster, Submarine, Microwave | Medium |
| **Food & Drinks** | Pizza, Sushi, Champagne | Easy |
| **Professions** | Astronaut, Pirate, Surgeon | Medium |
| **Fictional Beings** | Unicorn, Zombie, Dragon | Easy |

### 2.2 Custom Categories (User-Created)

- Users can create private custom category lists
- Lists are stored in PostgreSQL on the VPS
- Lists can be **shared** publicly via a toggle
- Shared lists become discoverable in a "Community Categories" browser
- Each list has metadata: author nickname, creation date, play count, rating, language
- Lists are language-tagged (EN/DE/ES/FR) and filterable by language
- Users can import community categories into their game with one tap
- Moderation: report button on shared lists (flagged for review)

### 2.3 Toggle Settings (Per Game)

| Setting | Default | Description |
|---------|---------|-------------|
| `includeRealPersons` | ON | Include real people (celebrities, historical, etc.) |
| `includeFictional` | ON | Include fictional characters (movies, books, games) |
| `includeObjects` | OFF | Include objects, animals, food, professions |
| `allowCustomCategories` | ON | Let host mix in custom category lists |
| `difficultyFilter` | ALL | Easy / Medium / Hard / All |
| `languageFilter` | Host's language | Filter identities by language relevance |

---

## 3. Multiplayer Architecture

### 3.1 WebSocket Protocol

```
Server: wss://api.locogames.com/ws
```

#### Client → Server Messages

```json
{"type": "create_room", "data": {"nickname": "Max", "max_players": 8}}
{"type": "join_room", "data": {"room_code": "ABC123", "nickname": "Anna"}}
{"type": "leave_room", "data": {}}
{"type": "start_game", "data": {"settings": {...}}}
{"type": "ask_question", "data": {"question": "Am I a man?"}}
{"type": "answer_question", "data": {"question_id": "...", "answer": "yes"}}
{"type": "make_guess", "data": {"guess": "Elon Musk"}}
{"type": "chat_message", "data": {"text": "Hmm, I think you're..."}}
{"type": "heartbeat", "data": {}}
```

#### Server → Client Messages

```json
{"type": "room_created", "data": {"room_code": "ABC123"}}
{"type": "player_joined", "data": {"nickname": "Anna", "player_count": 3}}
{"type": "player_left", "data": {"nickname": "Tom"}}
{"type": "game_started", "data": {"your_identity": "Mona Lisa", "all_players": [...]}}
{"type": "identity_visible", "data": {"player_id": "p2", "identity": "Mona Lisa"}}
{"type": "question_asked", "data": {"player_id": "p1", "question": "Am I alive?"}}
{"type": "question_answered", "data": {"question_id": "...", "answer": "yes", "by": "p3"}}
{"type": "guess_result", "data": {"player_id": "p1", "guess": "...", "correct": false}}
{"type": "player_guessed", "data": {"player_id": "p1", "correct": true}}
{"type": "game_over", "data": {"winner": "p1", "loser": "p3", "all_revealed": {...}}}
{"type": "error", "data": {"code": "ROOM_FULL", "message": "Room is full"}}
```

### 3.2 Room Lifecycle

```
[CREATED] → [WAITING] → [IN_GAME] → [FINISHED] → [CLOSED]
                ↑                        |
                └── players leave ───────┘
```

- **CREATED**: Room exists, host is alone, waiting for joiners
- **WAITING**: 2+ players, host can start any time
- **IN_GAME**: Identities distributed, turns in progress
- **FINISHED**: Game ended, results shown, can rematch or close
- **CLOSED**: Room removed from memory

### 3.3 Turn System

1. Player 1's turn begins (30-second timer)
2. They ask a yes/no question via chat
3. All *other* players can answer (majority vote: yes/no/skip)
4. After answer or timeout, turn passes to next player
5. At any point, current player can submit a guess
   - Correct → they're out (win), identity revealed to all
   - Wrong → turn ends immediately, 30s penalty (skip next turn)

### 3.4 Improved Game Experience Functions

| Function | Description |
|----------|-------------|
| **Hints** | After 3 wrong guesses player gets a hint ("You're from Europe", "Your first name starts with M") |
| **Timer animations** | Countdown with haptic pulses at 10s, 5s, 3s |
| **Reactions** | Players can send emoji reactions (😂, 🤔, 👏, 🤯) during turns |
| **Spectator mode** | Correctly guessed players can watch and send reactions but not answer |
| **Duel mode** | 1v1 variant: both players try to guess first, fastest wins |
| **Team mode** | Teams of 2, partners can see each other's identities and help via private chat |
| **Hardcore mode** | No hint system, wrong guess = eliminated from round |
| **Score tracking** | History of who guessed which identity, fastest guess time, accuracy |
| **Replay** | After game ends, animated replay of all guesses and reveals |
| **Voice chat** | Optional WebRTC voice channel (future phase) |

---

## 4. Backend (Ubuntu VPS)

### 4.1 Technology Stack

| Component | Technology |
|-----------|------------|
| WebSocket server | Node.js + `ws` or Go with Gorilla WebSocket |
| REST API | Express.js / Fastify or Go with Gin |
| Database (game state) | Redis (in-memory, fast, TTL for rooms) |
| Database (users, categories) | PostgreSQL |
| Authentication | JWT (optional for casual, required for custom categories) |
| Reverse proxy | Nginx + SSL (Let's Encrypt) |

### 4.2 Database Schema (PostgreSQL)

```sql
-- Custom categories
CREATE TABLE custom_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    language VARCHAR(5) NOT NULL DEFAULT 'en',
    is_shared BOOLEAN DEFAULT FALSE,
    play_count INTEGER DEFAULT 0,
    rating_avg NUMERIC(3,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE custom_category_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES custom_categories(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    category_type VARCHAR(20) NOT NULL, -- realPerson, fictionalCharacter, object
    difficulty VARCHAR(10) DEFAULT 'medium',
    position INTEGER DEFAULT 0
);

-- Shared categories discovery
CREATE INDEX idx_categories_shared ON custom_categories(is_shared) WHERE is_shared = TRUE;
CREATE INDEX idx_categories_language ON custom_categories(language);
CREATE INDEX idx_categories_rating ON custom_categories(rating_avg DESC);
```

### 4.3 REST API Endpoints

```
POST   /api/rooms              Create a new room (returns room_code)
GET    /api/rooms/:code         Get room status
POST   /api/rooms/:code/join    Join a room

GET    /api/categories          List built-in + shared custom categories
POST   /api/categories          Create custom category
PUT    /api/categories/:id      Update custom category
DELETE /api/categories/:id      Delete custom category
POST   /api/categories/:id/share  Toggle share status
GET    /api/categories/:id/items  Get items in a category
POST   /api/categories/:id/items  Add item to category
DELETE /api/categories/:id/items/:item_id  Remove item

POST   /api/categories/:id/report  Report inappropriate content
GET    /api/leaderboard         Global fastest guess rankings
```

---

## 5. Flutter Client Architecture

### 5.1 Feature Structure

```
lib/features/who_am_i/
├── data/
│   ├── repositories/
│   │   ├── who_am_i_room_repository_impl.dart
│   │   └── who_am_i_category_repository_impl.dart
│   └── datasources/
│       ├── who_am_i_remote_datasource.dart
│       └── who_am_i_local_datasource.dart
├── domain/
│   ├── models/
│   │   ├── who_am_i_player.dart (freezed)
│   │   ├── who_am_i_room.dart (freezed)
│   │   ├── who_am_i_identity.dart (freezed)
│   │   ├── who_am_i_question.dart (freezed)
│   │   ├── who_am_i_category.dart (freezed)
│   │   └── who_am_i_game_settings.dart (freezed)
│   ├── repositories/
│   │   ├── who_am_i_room_repository.dart (abstract)
│   │   └── who_am_i_category_repository.dart (abstract)
│   └── enums/
│       ├── category_type.dart
│       ├── game_state.dart
│       └── room_state.dart
└── presentation/
    ├── screens/
    │   ├── who_am_i_lobby_screen.dart
    │   ├── who_am_i_game_screen.dart
    │   ├── who_am_i_results_screen.dart
    │   └── who_am_i_category_browser_screen.dart
    └── widgets/
        ├── who_am_i_chat_bubble.dart
        ├── who_am_i_player_grid.dart
        ├── who_am_i_question_input.dart
        ├── who_am_i_guess_dialog.dart
        ├── who_am_i_timer_widget.dart
        ├── who_am_i_identity_card.dart
        ├── who_am_i_category_picker.dart
        └── who_am_i_reaction_bar.dart
```

### 5.2 State Management (Riverpod)

```dart
// WebSocket connection provider
final wsProvider = Provider<WebSocketChannel>((ref) { ... });

// Current room state
final roomProvider = StateNotifierProvider<RoomNotifier, WhoAmIRoom>((ref) { ... });

// Current game state
final gameStateProvider = StateNotifierProvider<GameStateNotifier, WhoAmIGameState>((ref) { ... });

// Player's own identity (hidden from them in UI until guessed/revealed)
final myIdentityProvider = Provider<WhoAmIIdentity>((ref) { ... });

// Chat messages stream
final chatProvider = StreamProvider<List<WhoAmIChatMessage>>((ref) { ... });

// Category list (built-in + custom shared)
final categoriesProvider = FutureProvider<List<WhoAmICategory>>((ref) { ... });

// User's custom categories
final myCategoriesProvider = FutureProvider<List<WhoAmICategory>>((ref) { ... });
```

### 5.3 UI Flow

```
Home → Game Card "Who Am I?"
    → Lobby Screen (create/join room, category settings, player list)
        → Game Screen
            ├── Top: Your hidden identity (tap to peak if you give up)
            ├── Center: Chat area with questions/answers
            ├── My Question Input (during your turn)
            ├── Guess Button (always available)
            └── Bottom: Player avatars row (shows identities for others)
        → Results Screen (leaderboard, stats, replay, rematch)
```

---

## 6. Implementation Phases

### Phase A: Core Backend (Node.js/Go on VPS)
- WebSocket server with room management
- Identity assignment logic
- Turn system
- Question/Answer protocol
- Guess validation

### Phase B: Basic Client
- Room creation/joining
- Lobby with settings
- Chat interface
- Identity display (hidden for self, visible for others)
- Yes/No question flow
- Guessing mechanism

### Phase C: Enhanced Features
- Hints system (3 wrong guesses → hint)
- Timer with animations
- Emoji reactions
- Spectator mode
- Duel mode (1v1)
- Hardcore mode

### Phase D: Categories
- Built-in category data set (500+ identities across all types)
- Custom category CRUD
- Share/community browser
- Language filtering
- Rating system

### Phase E: Polish
- Animated reveals
- Score history
- Game replay
- Stats dashboard
