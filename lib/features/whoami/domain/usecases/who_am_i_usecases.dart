import 'package:locogames/features/whoami/domain/entities/who_am_i_game.dart';
import 'package:locogames/features/whoami/domain/entities/game_settings.dart';
import 'package:locogames/features/whoami/domain/repositories/identity_repository.dart';

class CreateWhoAmIGame {
  WhoAmIGame call(WhoAmIGameSettings settings) {
    return WhoAmIGame.create(settings: settings);
  }
}

class AssignIdentity {
  final IdentityRepository _repository;

  AssignIdentity(this._repository);

  WhoAmIGame call(WhoAmIGame game) {
    final identity = _repository.getRandomIdentity();
    final subjIndex = game.currentRound % game.players.length;
    final updatedPlayers = game.players.asMap().entries.map((entry) {
      final i = entry.key;
      final p = entry.value;
      return p.copyWith(
        isSubject: i == subjIndex,
        clearQuestion: true,
        clearAnswer: true,
        clearGuess: true,
      );
    }).toList();

    return game.copyWith(
      players: updatedPlayers,
      currentIdentity: identity,
      phase: WhoAmIPhase.questioning,
      questionerIndex: 0,
    );
  }
}

class SubmitQuestion {
  WhoAmIGame call(WhoAmIGame game, String playerId, String question) {
    final player = game.players.firstWhere((p) => p.id == playerId);
    final updated = player.copyWith(currentQuestion: question);
    var updatedGame = game.updatePlayer(updated);

    final nextIndex = game.questionerIndex + 1;
    updatedGame = updatedGame.copyWith(questionerIndex: nextIndex);

    return updatedGame;
  }
}

class SubmitAnswer {
  WhoAmIGame call(WhoAmIGame game, bool answer) {
    final nonSubjects = game.nonSubjectPlayers;
    if (nonSubjects.isEmpty) return game;

    var updatedGame = game;
    for (final player in nonSubjects) {
      if (player.currentQuestion != null && player.subjectAnswer == null) {
        updatedGame = updatedGame.updatePlayer(
          player.copyWith(subjectAnswer: answer),
        );
      }
    }

    return updatedGame;
  }
}

class SubmitWhoAmIGuess {
  WhoAmIGame call(WhoAmIGame game, String playerId, String guess) {
    if (game.phase != WhoAmIPhase.questioning) return game;

    final player = game.players.firstWhere((p) => p.id == playerId);
    final updated = player.copyWith(currentGuess: guess);
    var updatedGame = game.updatePlayer(updated);

    if (updatedGame.allGuessesIn) {
      updatedGame = _resolveRound(updatedGame);
    }

    return updatedGame;
  }

  WhoAmIGame _resolveRound(WhoAmIGame game) {
    final identity = game.currentIdentity;
    if (identity == null) return game;

    final winnerIds = <String>[];
    var updatedGame = game;
    final lowerName = identity.name.toLowerCase();
    for (final player in game.nonSubjectPlayers) {
      if (player.currentGuess == null) continue;
      if (player.currentGuess!.trim().toLowerCase() == lowerName) {
        winnerIds.add(player.id);
        updatedGame = updatedGame.updatePlayer(
          player.copyWith(score: player.score + 1),
        );
      }
    }

    return updatedGame.copyWith(
      phase: WhoAmIPhase.results,
      roundWinnerIds: winnerIds,
    );
  }
}

class AdvanceWhoAmIRound {
  final IdentityRepository _repository;

  AdvanceWhoAmIRound(this._repository);

  WhoAmIGame call(WhoAmIGame game) {
    final resetPlayers = game.players.map((p) => p.copyWith(
          clearQuestion: true,
          clearAnswer: true,
          clearGuess: true,
          isSubject: false,
        ),).toList();

    var updated = game.copyWith(
      players: resetPlayers,
      clearIdentity: true,
      clearRoundWinner: true,
    );

    final nextRound = game.currentRound + 1;
    if (nextRound > game.settings.totalRounds) {
      return updated.copyWith(
        phase: WhoAmIPhase.gameOver,
        currentRound: game.currentRound,
      );
    }

    final identity = _repository.getRandomIdentity();
    final subjIndex = nextRound % game.players.length;
    final playersWithSubject = updated.players.asMap().entries.map((entry) {
      final i = entry.key;
      final p = entry.value;
      return p.copyWith(isSubject: i == subjIndex);
    }).toList();

    return updated.copyWith(
      players: playersWithSubject,
      currentIdentity: identity,
      phase: WhoAmIPhase.questioning,
      currentRound: nextRound,
      questionerIndex: 0,
    );
  }
}
