import 'package:locogames/features/ridethebus/domain/entities/ride_the_bus_game.dart';
import 'package:locogames/features/ridethebus/domain/entities/card_model.dart';

class CreateRideTheBusGame {
  RideTheBusGame call(int playerCount) {
    return RideTheBusGame.create(playerCount: playerCount);
  }
}

class ProcessGuess {
  RideTheBusGame call(RideTheBusGame game, String guess) {
    if (game.phase != RTBPhase.guessing) return game;

    final currentPyramidCard = game.pyramid[game.currentRoundIndex()][game.roundStep];
    final card = currentPyramidCard.card;
    if (card == null) return game;

    bool correct = false;

    switch (game.currentRound) {
      case RTBRound.redOrBlack:
        final guessedRed = guess == 'red';
        correct = card.suit.isRed == guessedRed;
        break;

      case RTBRound.higherOrLower:
        final cardAbove = game.getCardAbove(game.currentRoundIndex(), game.roundStep);
        if (cardAbove != null) {
          final guessedHigher = guess == 'higher';
          correct = card.value.numericValue > cardAbove.value.numericValue
              ? guessedHigher
              : card.value.numericValue < cardAbove.value.numericValue
                  ? !guessedHigher
                  : true;
        }
        break;

      case RTBRound.insideOrOutside:
        final firstCard = game.getCardAbove(game.currentRoundIndex(), game.roundStep);
        final secondCard = game.getSecondCardAbove(game.currentRoundIndex(), game.roundStep);
        if (firstCard != null && secondCard != null) {
          final minVal = firstCard.value.numericValue < secondCard.value.numericValue
              ? firstCard.value.numericValue
              : secondCard.value.numericValue;
          final maxVal = firstCard.value.numericValue > secondCard.value.numericValue
              ? firstCard.value.numericValue
              : secondCard.value.numericValue;
          final guessedInside = guess == 'inside';
          final isInside = card.value.numericValue > minVal && card.value.numericValue < maxVal;
          correct = guessedInside == isInside;
        } else {
          correct = true;
        }
        break;

      case RTBRound.suitGuess:
        final guessedSuit = guess.toLowerCase();
        correct = card.suit.name == guessedSuit;
        break;
    }

    final updatedPyramid = game.pyramid.map((row) {
      return row.map((slot) => slot).toList();
    }).toList();
    final slot = updatedPyramid[game.currentRoundIndex()][game.roundStep];
    updatedPyramid[game.currentRoundIndex()][game.roundStep] = slot.copyWith(revealed: true);

    final penalty = correct
        ? 0
        : game.currentRound == RTBRound.suitGuess
            ? 4
            : game.currentRoundIndex() + 1;

    var updatedGame = game.copyWith(
      pyramid: updatedPyramid,
      currentCard: card,
      lastGuess: guess,
      lastGuessCorrect: correct,
      phase: RTBPhase.result,
    );

    if (!correct && penalty > 0) {
      final player = game.currentPlayer;
      updatedGame = updatedGame.updatePlayer(
        player.copyWith(
          penaltyDrinks: player.penaltyDrinks + penalty,
          hasRiddenTheBus: game.currentRound == RTBRound.suitGuess || player.hasRiddenTheBus,
        ),
      );
    }

    return updatedGame;
  }
}

class AdvanceRideTheBusGame {
  RideTheBusGame call(RideTheBusGame game) {
    final nextStep = game.roundStep + 1;
    final cardsInRow = game.cardsInCurrentRow();

    if (nextStep < cardsInRow) {
      return game.copyWith(
        roundStep: nextStep,
        phase: RTBPhase.guessing,
        lastGuess: null,
        lastGuessCorrect: null,
        currentCard: null,
      );
    }

    final nextRound = _nextRound(game.currentRound);
    if (nextRound != null) {
      return game.copyWith(
        currentRound: nextRound,
        roundStep: 0,
        phase: RTBPhase.roundIntro,
        lastGuess: null,
        lastGuessCorrect: null,
        currentCard: null,
      );
    }

    final nextPlayer = game.currentPlayerIndex + 1;
    if (nextPlayer < game.players.length) {
      final newGame = RideTheBusGame.create(playerCount: game.players.length);
      return newGame.copyWith(
        players: game.players,
        currentPlayerIndex: nextPlayer,
        phase: RTBPhase.roundIntro,
        currentRound: RTBRound.redOrBlack,
        roundStep: 0,
      );
    }

    return game.copyWith(
      phase: RTBPhase.gameOver,
      finished: true,
    );
  }

  RTBRound? _nextRound(RTBRound current) {
    switch (current) {
      case RTBRound.redOrBlack:
        return RTBRound.higherOrLower;
      case RTBRound.higherOrLower:
        return RTBRound.insideOrOutside;
      case RTBRound.insideOrOutside:
        return RTBRound.suitGuess;
      case RTBRound.suitGuess:
        return null;
    }
  }
}

class ResetRideTheBusGame {
  RideTheBusGame call() {
    return RideTheBusGame.create(playerCount: 4);
  }
}
