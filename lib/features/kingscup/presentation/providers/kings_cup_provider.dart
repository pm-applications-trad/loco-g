import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locogames/features/kingscup/domain/entities/kings_cup_game.dart';
import 'package:locogames/features/kingscup/domain/entities/game_settings.dart';
import 'package:locogames/features/kingscup/domain/usecases/kings_cup_usecases.dart';

final createKingsCupGameProvider = Provider<CreateKingsCupGame>((ref) {
  return CreateKingsCupGame();
});

final drawCardProvider = Provider<DrawCard>((ref) {
  return DrawCard();
});

final resetKingsCupGameProvider = Provider<ResetKingsCupGame>((ref) {
  return ResetKingsCupGame();
});

enum KingsCupViewState { setup, playing, gameOver }

class KingsCupGameNotifier extends Notifier<KingsCupGame?> {
  @override
  KingsCupGame? build() {
    return null;
  }

  KingsCupViewState get viewState {
    final game = state;
    if (game == null) return KingsCupViewState.setup;

    switch (game.phase) {
      case KingsCupPhase.setup:
        return KingsCupViewState.setup;
      case KingsCupPhase.playing:
        return KingsCupViewState.playing;
      case KingsCupPhase.gameOver:
        return KingsCupViewState.gameOver;
    }
  }

  void startGame({
    required int playerCount,
    required List<String> playerNames,
  }) {
    final settings = KingsCupGameSettings(playerCount: playerCount);
    var game = ref.read(createKingsCupGameProvider).call(settings);

    if (playerNames.length == playerCount) {
      game = game.copyWith(
        players: List.generate(playerCount, (i) {
          return game.players[i].copyWith(name: playerNames[i]);
        }),
      );
    }

    game = game.copyWith(phase: KingsCupPhase.playing);
    state = game;
  }

  void drawCard() {
    final game = state;
    if (game == null || game.phase != KingsCupPhase.playing) return;

    final updated = ref.read(drawCardProvider).call(game);
    state = updated;
  }

  void resetGame() {
    state = null;
  }
}

final kingsCupGameProvider = NotifierProvider<KingsCupGameNotifier, KingsCupGame?>(
  KingsCupGameNotifier.new,
);
