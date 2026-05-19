import 'dart:math';

import 'package:locogames/features/impostor/domain/entities/impostor_game.dart';
import 'package:locogames/features/impostor/domain/entities/player.dart';
import 'package:locogames/features/impostor/domain/entities/game_settings.dart';
import 'package:locogames/features/impostor/domain/repositories/location_repository.dart';

class CreateGame {
  ImpostorGame call(GameSettings settings) {
    final game = ImpostorGame.create(settings: settings);
    return game;
  }
}

class AssignRoles {
  ImpostorGame call(ImpostorGame game) {
    final random = Random();
    final playerIndices = List.generate(game.settings.playerCount, (i) => i)..shuffle(random);
    final spyIndices = playerIndices.take(game.settings.spyCount).toSet();

    final updatedPlayers = game.players.asMap().entries.map((entry) {
      final isSpy = spyIndices.contains(entry.key);
      return entry.value.copyWith(
        role: isSpy ? PlayerRole.impostor : PlayerRole.citizen,
      );
    }).toList();

    return game.copyWith(players: updatedPlayers);
  }
}

class DistributeWords {
  final LocationRepository _locationRepository;

  DistributeWords(this._locationRepository);

  ImpostorGame call(ImpostorGame game) {
    final location = _locationRepository.getRandomLocation();
    return game.copyWith(
      location: location,
      phase: GamePhase.discussion,
    );
  }
}

class SubmitVote {
  ImpostorGame call(ImpostorGame game, String voterId, String targetId) {
    final voter = game.players.firstWhere((p) => p.id == voterId);
    final updatedVoter = voter.copyWith(votedForId: targetId);
    final updatedGame = game.updatePlayer(updatedVoter);

    if (updatedGame.allVotesIn) {
      return updatedGame.copyWith(phase: GamePhase.results);
    }

    return updatedGame;
  }
}

class ResolveVoting {
  ImpostorGame call(ImpostorGame game) {
    final aliveIds = game.alivePlayers.map((p) => p.id).toSet();
    final votes = <String, int>{};

    for (final player in game.alivePlayers) {
      if (player.votedForId != null && aliveIds.contains(player.votedForId)) {
        votes[player.votedForId!] = (votes[player.votedForId!] ?? 0) + 1;
      }
    }

    if (votes.isEmpty) {
      return _advanceRound(game, impostorCaught: false);
    }

    final maxVotes = votes.values.reduce(max);
    final eliminated = votes.entries
        .where((e) => e.value == maxVotes)
        .map((e) => e.key)
        .toList();

    final eliminatedId = eliminated.length == 1 ? eliminated.first : null;

    final eliminatedPlayer = eliminatedId != null
        ? game.players.firstWhere((p) => p.id == eliminatedId)
        : null;

    final impostorCaught = eliminatedPlayer?.role == PlayerRole.impostor;

    return _advanceRound(game, impostorCaught: impostorCaught);
  }

  ImpostorGame _advanceRound(ImpostorGame game, {required bool impostorCaught}) {
    final nextRound = game.currentRound + 1;
    final isGameOver = impostorCaught || nextRound > game.settings.totalRounds;

    return game.copyWith(
      phase: isGameOver ? GamePhase.gameOver : GamePhase.setup,
      currentRound: isGameOver ? game.currentRound : nextRound,
      impostorCaught: impostorCaught,
    );
  }
}

class ResetVotes {
  ImpostorGame call(ImpostorGame game) {
    final resetPlayers = game.players.map((p) => p.copyWith(clearVote: true)).toList();
    return game.copyWith(players: resetPlayers);
  }
}
