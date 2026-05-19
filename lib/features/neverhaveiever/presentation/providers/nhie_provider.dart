import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locogames/features/neverhaveiever/domain/entities/nhie_game.dart';
import 'package:locogames/features/neverhaveiever/domain/entities/player.dart';
import 'package:locogames/features/neverhaveiever/domain/entities/game_settings.dart';
import 'package:locogames/features/neverhaveiever/domain/entities/statement.dart';
import 'package:locogames/features/neverhaveiever/domain/usecases/nhie_usecases.dart';
import 'package:locogames/features/neverhaveiever/data/repositories/statement_repository_impl.dart';

final nhieStatementRepoProvider = Provider<NHIEStatementRepositoryImpl>((ref) {
  return NHIEStatementRepositoryImpl();
});

final nhieCreateGameProvider = Provider<CreateNHIEGame>((ref) {
  return CreateNHIEGame();
});

final nhieAdvanceStatementProvider = Provider<AdvanceNHIEStatement>((ref) {
  return AdvanceNHIEStatement();
});

enum NHIEViewState { setup, playing, results, gameOver }

final nhieViewStateProvider = StateProvider<NHIEViewState>((ref) => NHIEViewState.setup);

class NHIEGameNotifier extends Notifier<NHIEGame?> {
  @override
  NHIEGame? build() => null;

  void startGame({
    required int playerCount,
    required int totalRounds,
    required NHIECategory category,
    required List<String> playerNames,
  }) {
    final settings = NHIEGameSettings(
      playerCount: playerCount,
      totalRounds: totalRounds,
      category: category,
    );

    final statements = ref.read(nhieStatementRepoProvider).getStatements(category);

    final players = List.generate(
      playerCount,
      (i) => NHIEPlayer.create(name: playerNames.length > i ? playerNames[i] : 'Player ${i + 1}'),
    );

    final game = ref.read(nhieCreateGameProvider).call(
          settings: settings,
          players: players,
          statements: statements,
        );

    if (statements.isEmpty) return;
    state = game.copyWith(
      phase: NHIEPhase.playing,
      currentStatement: statements.first,
    );
    ref.read(nhieViewStateProvider.notifier).state = NHIEViewState.playing;
  }

  void markPlayerDidIt(String playerId) {
    final game = state;
    if (game == null) return;

    final player = game.players.where((p) => p.id == playerId).firstOrNull;
    if (player == null) return;
    final updatedPlayer = player.copyWith(drinkCount: player.drinkCount + 1);
    final updatedGame = game.updatePlayer(updatedPlayer).copyWith(
          playersWhoDidIt: {...game.playersWhoDidIt, playerId},
        );

    state = updatedGame;
  }

  void nextStatement() {
    final game = state;
    if (game == null || game.currentStatement == null) return;

    final updated = ref.read(nhieAdvanceStatementProvider).call(game);
    state = updated;

    if (updated.phase == NHIEPhase.gameOver) {
      ref.read(nhieViewStateProvider.notifier).state = NHIEViewState.gameOver;
    }
  }

  void resetGame() {
    state = null;
    ref.read(nhieViewStateProvider.notifier).state = NHIEViewState.setup;
  }
}

final nhieGameProvider = NotifierProvider<NHIEGameNotifier, NHIEGame?>(
  NHIEGameNotifier.new,
);
