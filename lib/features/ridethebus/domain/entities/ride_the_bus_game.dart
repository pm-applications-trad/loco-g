import 'dart:math';

import 'package:uuid/uuid.dart';

import 'package:locogames/features/ridethebus/domain/entities/card_model.dart';
import 'package:locogames/features/ridethebus/domain/entities/player.dart';

enum RTBRound {
  redOrBlack,
  higherOrLower,
  insideOrOutside,
  suitGuess,
}

enum RTBPhase {
  setup,
  roundIntro,
  guessing,
  result,
  playerTransition,
  gameOver,
}

class PyramidSlot {
  final PlayingCard? card;
  final bool revealed;

  const PyramidSlot({this.card, this.revealed = false});

  PyramidSlot copyWith({PlayingCard? card, bool? revealed}) {
    return PyramidSlot(
      card: card ?? this.card,
      revealed: revealed ?? this.revealed,
    );
  }
}

class RideTheBusGame {
  final String id;
  final List<RTBPlayer> players;
  final int currentPlayerIndex;
  final RTBRound currentRound;
  final int roundStep;
  final RTBPhase phase;
  final List<List<PyramidSlot>> pyramid;
  final PlayingCard? previousCard;
  final PlayingCard? currentCard;
  final String? lastGuess;
  final bool? lastGuessCorrect;
  final bool finished;

  static const pyramidRows = 4;

  const RideTheBusGame({
    required this.id,
    required this.players,
    this.currentPlayerIndex = 0,
    this.currentRound = RTBRound.redOrBlack,
    this.roundStep = 0,
    this.phase = RTBPhase.setup,
    this.pyramid = const [],
    this.previousCard,
    this.currentCard,
    this.lastGuess,
    this.lastGuessCorrect,
    this.finished = false,
  });

  factory RideTheBusGame.create({required int playerCount}) {
    final players = List.generate(
      playerCount,
      (i) => RTBPlayer.create(name: 'Player ${i + 1}'),
    );
    final pyramid = _buildInitialPyramid();

    return RideTheBusGame(
      id: const Uuid().v4(),
      players: players,
      phase: RTBPhase.setup,
      pyramid: pyramid,
    );
  }

  static List<List<PyramidSlot>> _buildInitialPyramid() {
    final deck = _buildShuffledDeck();
    var cardIndex = 0;
    final rows = <List<PyramidSlot>>[];

    final rowSizes = [4, 3, 2, 1];
    for (final size in rowSizes) {
      final row = <PyramidSlot>[];
      for (int i = 0; i < size; i++) {
        row.add(PyramidSlot(card: deck[cardIndex]));
        cardIndex++;
      }
      rows.add(row);
    }

    return rows;
  }

  static List<PlayingCard> _buildShuffledDeck() {
    final deck = <PlayingCard>[];
    for (final suit in CardSuit.values) {
      for (final value in CardValue.values) {
        deck.add(PlayingCard(suit: suit, value: value));
      }
    }
    deck.shuffle(Random());
    return deck;
  }

  RTBPlayer get currentPlayer => players[currentPlayerIndex];

  List<RTBPlayer> get sortedByPenalties {
    final sorted = List<RTBPlayer>.from(players);
    sorted.sort((a, b) => b.penaltyDrinks.compareTo(a.penaltyDrinks));
    return sorted;
  }

  RTBPlayer? get busRider {
    final maxPenalties = sortedByPenalties.first.penaltyDrinks;
    if (maxPenalties == 0) return null;
    return sortedByPenalties.first;
  }

  int cardsInCurrentRow() {
    if (currentRound == RTBRound.redOrBlack) return 4;
    if (currentRound == RTBRound.higherOrLower) return 3;
    if (currentRound == RTBRound.insideOrOutside) return 2;
    if (currentRound == RTBRound.suitGuess) return 1;
    return 0;
  }

  int currentRoundIndex() {
    if (currentRound == RTBRound.redOrBlack) return 0;
    if (currentRound == RTBRound.higherOrLower) return 1;
    if (currentRound == RTBRound.insideOrOutside) return 2;
    if (currentRound == RTBRound.suitGuess) return 3;
    return 0;
  }

  PlayingCard? getCardAbove(int rowIndex, int colIndex) {
    if (rowIndex <= 0 || rowIndex >= pyramid.length) return null;
    final rowAbove = pyramid[rowIndex - 1];
    if (colIndex >= rowAbove.length) return null;
    return rowAbove[colIndex].revealed ? rowAbove[colIndex].card : null;
  }

  PlayingCard? getSecondCardAbove(int rowIndex, int colIndex) {
    if (rowIndex <= 0 || rowIndex >= pyramid.length) return null;
    final rowAbove = pyramid[rowIndex - 1];
    final secondCol = colIndex + 1;
    if (secondCol >= rowAbove.length) return null;
    return rowAbove[secondCol].revealed ? rowAbove[secondCol].card : null;
  }

  RideTheBusGame copyWith({
    String? id,
    List<RTBPlayer>? players,
    int? currentPlayerIndex,
    RTBRound? currentRound,
    int? roundStep,
    RTBPhase? phase,
    List<List<PyramidSlot>>? pyramid,
    PlayingCard? previousCard,
    PlayingCard? currentCard,
    String? lastGuess,
    bool? lastGuessCorrect,
    bool? finished,
  }) {
    return RideTheBusGame(
      id: id ?? this.id,
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      currentRound: currentRound ?? this.currentRound,
      roundStep: roundStep ?? this.roundStep,
      phase: phase ?? this.phase,
      pyramid: pyramid ?? this.pyramid,
      previousCard: previousCard ?? this.previousCard,
      currentCard: currentCard ?? this.currentCard,
      lastGuess: lastGuess ?? this.lastGuess,
      lastGuessCorrect: lastGuessCorrect ?? this.lastGuessCorrect,
      finished: finished ?? this.finished,
    );
  }

  RideTheBusGame updatePlayer(RTBPlayer updatedPlayer) {
    final updatedPlayers = players.map((p) {
      return p.id == updatedPlayer.id ? updatedPlayer : p;
    }).toList();
    return copyWith(players: updatedPlayers);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideTheBusGame &&
          id == other.id &&
          _listEquals(players, other.players) &&
          currentPlayerIndex == other.currentPlayerIndex &&
          currentRound == other.currentRound &&
          roundStep == other.roundStep &&
          phase == other.phase &&
          finished == other.finished;

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
      'RideTheBusGame(id: $id, phase: $phase, round: $currentRound, player: $currentPlayerIndex)';
}
