import 'package:locogames/features/guessing/domain/entities/guessing_game.dart';
import 'package:locogames/features/guessing/domain/entities/game_settings.dart';
import 'package:locogames/features/guessing/domain/repositories/question_repository.dart';

class CreateGuessingGame {
  GuessingGame call(GuessingGameSettings settings) {
    return GuessingGame.create(settings: settings);
  }
}

class GetQuestion {
  final QuestionRepository _repository;

  GetQuestion(this._repository);

  GuessingGame call(GuessingGame game) {
    final question = _repository.getRandomQuestion();
    return game.copyWith(
      currentQuestion: question,
      phase: GuessingGamePhase.answering,
    );
  }
}

class SubmitGuess {
  GuessingGame call(GuessingGame game, String playerId, double guess) {
    if (game.phase != GuessingGamePhase.answering) return game;

    final player = game.players.firstWhere((p) => p.id == playerId);
    final updated = player.copyWith(currentGuess: guess);
    var updatedGame = game.updatePlayer(updated);

    if (updatedGame.allGuessesIn) {
      updatedGame = _resolveRound(updatedGame);
    }

    return updatedGame;
  }

  GuessingGame _resolveRound(GuessingGame game) {
    final question = game.currentQuestion;
    if (question == null) return game;

    double? closestDiff;
    for (final player in game.players) {
      if (player.currentGuess == null) continue;
      final diff = (player.currentGuess! - question.answer).abs();
      if (closestDiff == null || diff < closestDiff) {
        closestDiff = diff;
      }
    }

    if (closestDiff == null) {
      return game.copyWith(
        phase: GuessingGamePhase.results,
        clearRoundWinner: true,
      );
    }

    // Every player whose guess matches the closest distance shares the win,
    // so ties award a point to all tied players instead of silently favouring
    // whoever appears first in the list.
    const epsilon = 1e-9;
    final winnerIds = <String>[];
    var updatedGame = game;
    for (final player in game.players) {
      if (player.currentGuess == null) continue;
      final diff = (player.currentGuess! - question.answer).abs();
      if ((diff - closestDiff).abs() < epsilon) {
        winnerIds.add(player.id);
        updatedGame = updatedGame.updatePlayer(
          player.copyWith(score: player.score + 1),
        );
      }
    }

    return updatedGame.copyWith(
      phase: GuessingGamePhase.results,
      roundWinnerIds: winnerIds,
    );
  }
}

class AdvanceGuessingRound {
  final QuestionRepository _repository;

  AdvanceGuessingRound(this._repository);

  GuessingGame call(GuessingGame game) {
    final resetPlayers = game.players.map((p) => p.copyWith(clearGuess: true)).toList();
    var updated = game.copyWith(
      players: resetPlayers,
      clearQuestion: true,
      clearRoundWinner: true,
    );

    final nextRound = game.currentRound + 1;
    if (nextRound > game.settings.totalRounds) {
      return updated.copyWith(
        phase: GuessingGamePhase.gameOver,
        currentRound: game.currentRound,
      );
    }

    final question = _repository.getRandomQuestion();
    return updated.copyWith(
      currentQuestion: question,
      phase: GuessingGamePhase.answering,
      currentRound: nextRound,
    );
  }
}
