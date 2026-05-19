import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'package:locogames/features/guessing/domain/entities/player.dart';
import 'package:locogames/features/guessing/domain/entities/game_settings.dart';
import 'package:locogames/features/guessing/domain/entities/question.dart';

enum GuessingGamePhase { setup, answering, results, gameOver }

class GuessingGame extends Equatable {
  final String id;
  final GuessingGameSettings settings;
  final List<GuessingPlayer> players;
  final Question? currentQuestion;
  final GuessingGamePhase phase;
  final int currentRound;

  /// All players tied for the closest guess this round. Empty until the round
  /// is resolved. More than one entry means the round was a tie and every
  /// listed player was awarded a point.
  final List<String> roundWinnerIds;

  const GuessingGame({
    required this.id,
    required this.settings,
    required this.players,
    this.currentQuestion,
    required this.phase,
    required this.currentRound,
    this.roundWinnerIds = const [],
  });

  factory GuessingGame.create({required GuessingGameSettings settings}) {
    return GuessingGame(
      id: const Uuid().v4(),
      settings: settings,
      players: List.generate(
        settings.playerCount,
        (i) => GuessingPlayer.create(name: 'Player ${i + 1}'),
      ),
      phase: GuessingGamePhase.setup,
      currentRound: 1,
    );
  }

  List<GuessingPlayer> get sortedByScore =>
      List<GuessingPlayer>.from(players)..sort((a, b) => b.score.compareTo(a.score));

  bool get allGuessesIn => players.every((p) => p.currentGuess != null);
  bool get isLastRound => currentRound >= settings.totalRounds;

  GuessingGame copyWith({
    String? id,
    GuessingGameSettings? settings,
    List<GuessingPlayer>? players,
    Question? currentQuestion,
    GuessingGamePhase? phase,
    int? currentRound,
    List<String>? roundWinnerIds,
    bool clearQuestion = false,
    bool clearRoundWinner = false,
  }) {
    return GuessingGame(
      id: id ?? this.id,
      settings: settings ?? this.settings,
      players: players ?? this.players,
      currentQuestion: clearQuestion ? null : (currentQuestion ?? this.currentQuestion),
      phase: phase ?? this.phase,
      currentRound: currentRound ?? this.currentRound,
      roundWinnerIds:
          clearRoundWinner ? const [] : (roundWinnerIds ?? this.roundWinnerIds),
    );
  }

  GuessingGame updatePlayer(GuessingPlayer updated) {
    final newPlayers = players.map((p) => p.id == updated.id ? updated : p).toList();
    return copyWith(players: newPlayers);
  }

  @override
  List<Object?> get props => [
        id,
        settings,
        players,
        currentQuestion,
        phase,
        currentRound,
        roundWinnerIds,
      ];
}
