import 'package:locogames/features/neverhaveiever/domain/entities/nhie_game.dart';
import 'package:locogames/features/neverhaveiever/domain/entities/game_settings.dart';
import 'package:locogames/features/neverhaveiever/domain/entities/player.dart';
import 'package:locogames/features/neverhaveiever/domain/entities/statement.dart';

class CreateNHIEGame {
  NHIEGame call({
    required NHIEGameSettings settings,
    required List<NHIEPlayer> players,
    required List<NHIEStatement> statements,
  }) {
    return NHIEGame.create(
      settings: settings,
      players: players,
      statements: statements,
    );
  }
}

class AdvanceNHIEStatement {
  NHIEGame call(NHIEGame game) {
    final nextIndex = (game.statements.indexOf(game.currentStatement!) + 1) % game.statements.length;

    if (nextIndex == 0 && game.currentPlayerIndex == game.players.length - 1) {
      if (game.isLastRound) {
        return game.copyWith(
          phase: NHIEPhase.gameOver,
          clearStatement: true,
          clearPlayersWhoDidIt: true,
        );
      }
      return game.copyWith(
        currentRound: game.currentRound + 1,
        currentPlayerIndex: 0,
        currentStatement: game.statements[0],
        clearPlayersWhoDidIt: true,
      );
    }

    if (nextIndex == 0) {
      return game.copyWith(
        currentPlayerIndex: game.currentPlayerIndex + 1,
        currentStatement: game.statements[0],
        clearPlayersWhoDidIt: true,
      );
    }

    return game.copyWith(
      currentStatement: game.statements[nextIndex],
      clearPlayersWhoDidIt: true,
    );
  }
}
