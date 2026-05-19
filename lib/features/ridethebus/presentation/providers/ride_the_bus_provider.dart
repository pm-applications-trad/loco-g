import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locogames/features/ridethebus/domain/entities/ride_the_bus_game.dart';
import 'package:locogames/features/ridethebus/domain/usecases/ride_the_bus_usecases.dart';

final createRideTheBusGameProvider = Provider<CreateRideTheBusGame>((ref) {
  return CreateRideTheBusGame();
});

final processGuessProvider = Provider<ProcessGuess>((ref) {
  return ProcessGuess();
});

final advanceRideTheBusGameProvider = Provider<AdvanceRideTheBusGame>((ref) {
  return AdvanceRideTheBusGame();
});

final resetRideTheBusGameProvider = Provider<ResetRideTheBusGame>((ref) {
  return ResetRideTheBusGame();
});

enum RideTheBusViewState { setup, playing, gameOver }

class RideTheBusGameNotifier extends Notifier<RideTheBusGame?> {
  @override
  RideTheBusGame? build() {
    return null;
  }

  RideTheBusViewState get viewState {
    final game = state;
    if (game == null) return RideTheBusViewState.setup;

    switch (game.phase) {
      case RTBPhase.setup:
        return RideTheBusViewState.setup;
      case RTBPhase.roundIntro:
      case RTBPhase.guessing:
      case RTBPhase.result:
      case RTBPhase.playerTransition:
        return RideTheBusViewState.playing;
      case RTBPhase.gameOver:
        return RideTheBusViewState.gameOver;
    }
  }

  void startGame({
    required int playerCount,
    required List<String> playerNames,
  }) {
    var game = ref.read(createRideTheBusGameProvider).call(playerCount);

    if (playerNames.length == playerCount) {
      game = game.copyWith(
        players: List.generate(playerCount, (i) {
          return game.players[i].copyWith(name: playerNames[i]);
        }),
      );
    }

    game = game.copyWith(phase: RTBPhase.roundIntro);
    state = game;
  }

  void setGuessing() {
    final game = state;
    if (game == null || game.phase != RTBPhase.roundIntro) return;
    state = game.copyWith(phase: RTBPhase.guessing);
  }

  void submitGuess(String guess) {
    final game = state;
    if (game == null || game.phase != RTBPhase.guessing) return;

    final updated = ref.read(processGuessProvider).call(game, guess);
    state = updated;
  }

  void advance() {
    final game = state;
    if (game == null) return;

    final updated = ref.read(advanceRideTheBusGameProvider).call(game);
    state = updated;
  }

  void resetGame() {
    state = null;
  }
}

final rideTheBusGameProvider = NotifierProvider<RideTheBusGameNotifier, RideTheBusGame?>(
  RideTheBusGameNotifier.new,
);
