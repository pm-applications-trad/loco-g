import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'package:locogames/features/impostor/domain/entities/player.dart';
import 'package:locogames/features/impostor/domain/entities/game_settings.dart';

enum GamePhase {
  setup,
  wordDistribution,
  discussion,
  voting,
  results,
  gameOver,
}

class ImpostorGame extends Equatable {
  final String id;
  final GameSettings settings;
  final List<Player> players;
  final String? location;
  final GamePhase phase;
  final int currentRound;
  final String? eliminatedPlayerId;
  final bool? impostorCaught;

  const ImpostorGame({
    required this.id,
    required this.settings,
    required this.players,
    this.location,
    required this.phase,
    required this.currentRound,
    this.eliminatedPlayerId,
    this.impostorCaught,
  });

  factory ImpostorGame.create({required GameSettings settings}) {
    return ImpostorGame(
      id: const Uuid().v4(),
      settings: settings,
      players: List.generate(
        settings.playerCount,
        (i) => Player.create(name: 'Player ${i + 1}'),
      ),
      phase: GamePhase.setup,
      currentRound: 1,
    );
  }

  Player get currentPlayer {
    final alive = players.where((p) => p.isAlive);
    return alive.isEmpty ? players.first : alive.first;
  }

  List<Player> get alivePlayers => players.where((p) => p.isAlive).toList();
  List<Player> get impostors => players.where((p) => p.role == PlayerRole.impostor).toList();
  List<Player> get citizens => players.where((p) => p.role == PlayerRole.citizen).toList();

  bool get allVotesIn => alivePlayers.every((p) => p.votedForId != null);
  bool get isLastRound => currentRound >= settings.totalRounds;

  ImpostorGame copyWith({
    String? id,
    GameSettings? settings,
    List<Player>? players,
    String? location,
    GamePhase? phase,
    int? currentRound,
    String? eliminatedPlayerId,
    bool? impostorCaught,
    bool clearLocation = false,
    bool clearEliminated = false,
    bool clearImpostorCaught = false,
  }) {
    return ImpostorGame(
      id: id ?? this.id,
      settings: settings ?? this.settings,
      players: players ?? this.players,
      location: clearLocation ? null : (location ?? this.location),
      phase: phase ?? this.phase,
      currentRound: currentRound ?? this.currentRound,
      eliminatedPlayerId: clearEliminated ? null : (eliminatedPlayerId ?? this.eliminatedPlayerId),
      impostorCaught: clearImpostorCaught ? null : (impostorCaught ?? this.impostorCaught),
    );
  }

  ImpostorGame updatePlayer(Player updated) {
    final newPlayers = players.map((p) => p.id == updated.id ? updated : p).toList();
    return copyWith(players: newPlayers);
  }

  @override
  List<Object?> get props => [
        id,
        settings,
        players,
        location,
        phase,
        currentRound,
        eliminatedPlayerId,
        impostorCaught,
      ];
}
