import 'dart:math';

import 'package:uuid/uuid.dart';

import 'package:locogames/features/kingscup/domain/entities/card_model.dart';
import 'package:locogames/features/kingscup/domain/entities/player.dart';
import 'package:locogames/features/kingscup/domain/entities/game_settings.dart';

enum KingsCupPhase { setup, playing, gameOver }

class DrawnCard {
  final CardModel card;
  final int drawnByPlayerIndex;

  const DrawnCard({required this.card, required this.drawnByPlayerIndex});
}

class KingsCupGame {
  final String id;
  final KingsCupGameSettings settings;
  final List<KingsCupPlayer> players;
  final List<CardModel> remainingCards;
  final List<DrawnCard> drawnCards;
  final int currentPlayerIndex;
  final int kingsDrawn;
  final KingsCupPhase phase;
  final int centerCupDrinkerIndex;

  const KingsCupGame({
    required this.id,
    required this.settings,
    required this.players,
    this.remainingCards = const [],
    this.drawnCards = const [],
    this.currentPlayerIndex = 0,
    this.kingsDrawn = 0,
    this.phase = KingsCupPhase.setup,
    this.centerCupDrinkerIndex = -1,
  });

  factory KingsCupGame.create({required KingsCupGameSettings settings}) {
    final deck = _buildShuffledDeck();
    final players = List.generate(
      settings.playerCount,
      (i) => KingsCupPlayer.create(name: 'Player ${i + 1}'),
    );

    return KingsCupGame(
      id: const Uuid().v4(),
      settings: settings,
      players: players,
      remainingCards: deck,
    );
  }

  static List<CardModel> _buildShuffledDeck() {
    final deck = <CardModel>[];
    for (final suit in CardSuit.values) {
      for (final value in CardValue.values) {
        deck.add(CardModel(suit: suit, value: value));
      }
    }
    deck.shuffle(Random());
    return deck;
  }

  KingsCupPlayer get currentPlayer => players[currentPlayerIndex];

  List<KingsCupPlayer> get sortedByDrinks {
    final sorted = List<KingsCupPlayer>.from(players);
    sorted.sort((a, b) => b.drinksAssigned.compareTo(a.drinksAssigned));
    return sorted;
  }

  KingsCupPlayer? get centerCupDrinker =>
      centerCupDrinkerIndex >= 0 && centerCupDrinkerIndex < players.length
          ? players[centerCupDrinkerIndex]
          : null;

  int get totalCardsDrawn => drawnCards.length;

  KingsCupGame copyWith({
    String? id,
    KingsCupGameSettings? settings,
    List<KingsCupPlayer>? players,
    List<CardModel>? remainingCards,
    List<DrawnCard>? drawnCards,
    int? currentPlayerIndex,
    int? kingsDrawn,
    KingsCupPhase? phase,
    int? centerCupDrinkerIndex,
  }) {
    return KingsCupGame(
      id: id ?? this.id,
      settings: settings ?? this.settings,
      players: players ?? this.players,
      remainingCards: remainingCards ?? this.remainingCards,
      drawnCards: drawnCards ?? this.drawnCards,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      kingsDrawn: kingsDrawn ?? this.kingsDrawn,
      phase: phase ?? this.phase,
      centerCupDrinkerIndex: centerCupDrinkerIndex ?? this.centerCupDrinkerIndex,
    );
  }

  KingsCupGame updatePlayer(KingsCupPlayer updatedPlayer) {
    final updatedPlayers = players.map((p) {
      return p.id == updatedPlayer.id ? updatedPlayer : p;
    }).toList();
    return copyWith(players: updatedPlayers);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KingsCupGame &&
          id == other.id &&
          settings == other.settings &&
          _listEquals(players, other.players) &&
          _listEquals(remainingCards, other.remainingCards) &&
          _listEquals(drawnCards, other.drawnCards) &&
          currentPlayerIndex == other.currentPlayerIndex &&
          kingsDrawn == other.kingsDrawn &&
          phase == other.phase &&
          centerCupDrinkerIndex == other.centerCupDrinkerIndex;

  @override
  int get hashCode => id.hashCode;

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'KingsCupGame(id: $id, phase: $phase, kings: $kingsDrawn, players: ${players.length})';
}
