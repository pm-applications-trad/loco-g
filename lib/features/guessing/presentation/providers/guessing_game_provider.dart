import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locogames/features/guessing/domain/entities/guessing_game.dart';
import 'package:locogames/features/guessing/domain/entities/player.dart';
import 'package:locogames/features/guessing/domain/entities/game_settings.dart';
import 'package:locogames/features/guessing/domain/usecases/game_usecases.dart';
import 'package:locogames/features/guessing/data/repositories/question_repository_impl.dart';

final questionRepositoryProvider = Provider<QuestionRepositoryImpl>((ref) {
  return QuestionRepositoryImpl();
});

final createGuessingGameProvider = Provider<CreateGuessingGame>((ref) {
  return CreateGuessingGame();
});

final getQuestionProvider = Provider<GetQuestion>((ref) {
  return GetQuestion(ref.read(questionRepositoryProvider));
});

final submitGuessProvider = Provider<SubmitGuess>((ref) {
  return SubmitGuess();
});

final advanceGuessingRoundProvider = Provider<AdvanceGuessingRound>((ref) {
  return AdvanceGuessingRound(ref.read(questionRepositoryProvider));
});

final guessingPlayerIndexProvider = StateProvider<int>((ref) => 0);

enum GuessingViewState { setup, answering, results, gameOver }

class GuessingGameNotifier extends Notifier<GuessingGame?> {
  @override
  GuessingGame? build() {
    return null;
  }

  GuessingViewState get viewState {
    final game = state;
    if (game == null) return GuessingViewState.setup;

    switch (game.phase) {
      case GuessingGamePhase.setup:
        return GuessingViewState.setup;
      case GuessingGamePhase.answering:
        return GuessingViewState.answering;
      case GuessingGamePhase.results:
        return GuessingViewState.results;
      case GuessingGamePhase.gameOver:
        return GuessingViewState.gameOver;
    }
  }

  void startGame({
    required int playerCount,
    required int totalRounds,
    required List<String> playerNames,
  }) {
    final settings = GuessingGameSettings(
      playerCount: playerCount,
      totalRounds: totalRounds,
    );

    var game = ref.read(createGuessingGameProvider).call(settings);

    if (playerNames.length == playerCount) {
      game = game.copyWith(
        players: List.generate(
          playerCount,
          (i) => GuessingPlayer.create(name: playerNames[i]),
        ),
      );
    }

    game = ref.read(getQuestionProvider).call(game);
    state = game;
    ref.read(guessingPlayerIndexProvider.notifier).state = 0;
  }

  void submitGuess(double guess) {
    final game = state;
    if (game == null) return;

    final playerIndex = ref.read(guessingPlayerIndexProvider);
    final player = game.players[playerIndex];

    final updated = ref.read(submitGuessProvider).call(game, player.id, guess);
    state = updated;

    if (updated.phase == GuessingGamePhase.results) {
      ref.read(guessingPlayerIndexProvider.notifier).state = 0;
    } else {
      ref.read(guessingPlayerIndexProvider.notifier).state = playerIndex + 1;
    }
  }

  void nextRound() {
    final game = state;
    if (game == null) return;

    final updated = ref.read(advanceGuessingRoundProvider).call(game);
    state = updated;
    ref.read(guessingPlayerIndexProvider.notifier).state = 0;
  }

  void resetGame() {
    state = null;
    ref.read(guessingPlayerIndexProvider.notifier).state = 0;
  }
}

final guessingGameProvider = NotifierProvider<GuessingGameNotifier, GuessingGame?>(
  GuessingGameNotifier.new,
);
