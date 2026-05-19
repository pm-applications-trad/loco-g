import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'player.dart';
import 'statement.dart';
import 'game_settings.dart';

enum NHIEPhase { setup, playing, results, gameOver }

class NHIEGame extends Equatable {
  final String id;
  final NHIEGameSettings settings;
  final List<NHIEPlayer> players;
  final List<NHIEStatement> statements;
  final NHIEStatement? currentStatement;
  final NHIEPhase phase;
  final int currentRound;
  final int currentPlayerIndex;
  final Set<String> playersWhoDidIt;

  const NHIEGame({
    required this.id,
    required this.settings,
    required this.players,
    required this.statements,
    this.currentStatement,
    this.phase = NHIEPhase.setup,
    this.currentRound = 1,
    this.currentPlayerIndex = 0,
    this.playersWhoDidIt = const {},
  });

  factory NHIEGame.create({
    required NHIEGameSettings settings,
    required List<NHIEPlayer> players,
    required List<NHIEStatement> statements,
  }) {
    return NHIEGame(
      id: const Uuid().v4(),
      settings: settings,
      players: players,
      statements: statements,
    );
  }

  NHIEPlayer get currentPlayer => players[currentPlayerIndex % players.length];

  List<NHIEPlayer> get sortedByDrinks => List.from(players)
    ..sort((a, b) => b.drinkCount.compareTo(a.drinkCount));

  bool get isLastRound => currentRound >= settings.totalRounds;

  NHIEGame copyWith({
    String? id,
    NHIEGameSettings? settings,
    List<NHIEPlayer>? players,
    List<NHIEStatement>? statements,
    NHIEStatement? currentStatement,
    NHIEPhase? phase,
    int? currentRound,
    int? currentPlayerIndex,
    Set<String>? playersWhoDidIt,
    bool clearStatement = false,
    bool clearPlayersWhoDidIt = false,
  }) {
    return NHIEGame(
      id: id ?? this.id,
      settings: settings ?? this.settings,
      players: players ?? this.players,
      statements: statements ?? this.statements,
      currentStatement: clearStatement ? null : (currentStatement ?? this.currentStatement),
      phase: phase ?? this.phase,
      currentRound: currentRound ?? this.currentRound,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      playersWhoDidIt: clearPlayersWhoDidIt ? {} : (playersWhoDidIt ?? this.playersWhoDidIt),
    );
  }

  NHIEGame updatePlayer(NHIEPlayer updated) {
    final idx = players.indexWhere((p) => p.id == updated.id);
    if (idx == -1) return this;
    final newPlayers = List<NHIEPlayer>.from(players);
    newPlayers[idx] = updated;
    return copyWith(players: newPlayers);
  }

  @override
  List<Object?> get props => [
        id, settings, players, statements, currentStatement,
        phase, currentRound, currentPlayerIndex, playersWhoDidIt,
      ];
}
