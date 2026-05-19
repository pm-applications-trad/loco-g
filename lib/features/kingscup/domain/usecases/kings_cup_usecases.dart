import 'package:locogames/features/kingscup/domain/entities/kings_cup_game.dart';
import 'package:locogames/features/kingscup/domain/entities/game_settings.dart';
import 'package:locogames/features/kingscup/domain/entities/card_model.dart';

class CreateKingsCupGame {
  KingsCupGame call(KingsCupGameSettings settings) {
    return KingsCupGame.create(settings: settings);
  }
}

class DrawCard {
  KingsCupGame call(KingsCupGame game) {
    if (game.phase != KingsCupPhase.playing) return game;
    if (game.remainingCards.isEmpty) return game;

    final card = game.remainingCards.first;
    final newRemaining = List<CardModel>.from(game.remainingCards)..removeAt(0);
    final drawnCard = DrawnCard(card: card, drawnByPlayerIndex: game.currentPlayerIndex);
    final newHistory = List<DrawnCard>.from(game.drawnCards)..add(drawnCard);

    var updatedGame = game.copyWith(
      remainingCards: newRemaining,
      drawnCards: newHistory,
    );

    final isKing = card.value == CardValue.king;
    final isFourthKing = isKing && game.kingsDrawn == 3;

    if (isFourthKing) {
      updatedGame = updatedGame.copyWith(
        kingsDrawn: 4,
        centerCupDrinkerIndex: game.currentPlayerIndex,
        phase: KingsCupPhase.gameOver,
      );
      final drinker = game.players[game.currentPlayerIndex];
      updatedGame = updatedGame.updatePlayer(
        drinker.copyWith(drinksAssigned: drinker.drinksAssigned + 3, isCenterCupDrinker: true),
      );
    } else {
      int kingsUpdate = isKing ? game.kingsDrawn + 1 : game.kingsDrawn;

      final isAce = card.value == CardValue.ace;
      final isEight = card.value == CardValue.eight;
      final isKingNew = card.value == CardValue.king;
      final isQueen = card.value == CardValue.queen;

      if (isAce || isEight || isKingNew || isQueen) {
        final drinker = game.players[game.currentPlayerIndex];
        updatedGame = updatedGame.updatePlayer(
          drinker.copyWith(drinksAssigned: drinker.drinksAssigned + 1),
        );
      }

      final nextIndex = (game.currentPlayerIndex + 1) % game.players.length;
      updatedGame = updatedGame.copyWith(
        kingsDrawn: kingsUpdate,
        currentPlayerIndex: nextIndex,
      );
    }

    return updatedGame;
  }
}

class ResetKingsCupGame {
  KingsCupGame call() {
    return KingsCupGame.create(
      settings: const KingsCupGameSettings(playerCount: 4),
    );
  }
}
