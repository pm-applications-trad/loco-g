import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locogames/features/whoami/domain/entities/who_am_i_game.dart';
import 'package:locogames/features/whoami/domain/entities/player.dart';
import 'package:locogames/features/whoami/domain/entities/game_settings.dart';
import 'package:locogames/features/whoami/domain/usecases/who_am_i_usecases.dart';
import 'package:locogames/features/whoami/data/repositories/identity_repository_impl.dart';

final identityRepositoryProvider = Provider<IdentityRepositoryImpl>((ref) {
  return IdentityRepositoryImpl();
});

final createWhoAmIGameProvider = Provider<CreateWhoAmIGame>((ref) {
  return CreateWhoAmIGame();
});

final assignIdentityProvider = Provider<AssignIdentity>((ref) {
  return AssignIdentity(ref.read(identityRepositoryProvider));
});

final submitQuestionProvider = Provider<SubmitQuestion>((ref) {
  return SubmitQuestion();
});

final submitAnswerProvider = Provider<SubmitAnswer>((ref) {
  return SubmitAnswer();
});

final submitWhoAmIGuessProvider = Provider<SubmitWhoAmIGuess>((ref) {
  return SubmitWhoAmIGuess();
});

final advanceWhoAmIRoundProvider = Provider<AdvanceWhoAmIRound>((ref) {
  return AdvanceWhoAmIRound(ref.read(identityRepositoryProvider));
});

final whoAmIViewStateProvider = StateProvider<WhoAmIViewState>((ref) {
  return WhoAmIViewState.setup;
});

enum WhoAmIViewState { setup, subjectReveal, questioning, answering, guessing, results, gameOver }

class WhoAmIGameNotifier extends Notifier<WhoAmIGame?> {
  @override
  WhoAmIGame? build() {
    return null;
  }

  WhoAmIViewState get viewState {
    final game = state;
    if (game == null) return WhoAmIViewState.setup;

    switch (game.phase) {
      case WhoAmIPhase.setup:
        return WhoAmIViewState.setup;
      case WhoAmIPhase.questioning:
        return WhoAmIViewState.questioning;
      case WhoAmIPhase.results:
        return WhoAmIViewState.results;
      case WhoAmIPhase.gameOver:
        return WhoAmIViewState.gameOver;
    }
  }

  void startGame({
    required int playerCount,
    required int totalRounds,
    required List<String> playerNames,
  }) {
    final settings = WhoAmIGameSettings(
      playerCount: playerCount,
      totalRounds: totalRounds,
    );

    var game = ref.read(createWhoAmIGameProvider).call(settings);

    if (playerNames.length == playerCount) {
      game = game.copyWith(
        players: List.generate(
          playerCount,
          (i) => WhoAmIPlayer.create(name: playerNames[i]),
        ),
      );
    }

    game = ref.read(assignIdentityProvider).call(game);
    state = game;
    ref.read(whoAmIViewStateProvider.notifier).state = WhoAmIViewState.subjectReveal;
  }

  void advanceFromSubjectReveal() {
    ref.read(whoAmIViewStateProvider.notifier).state = WhoAmIViewState.questioning;
  }

  void askQuestion(String question) {
    final game = state;
    if (game == null || game.phase != WhoAmIPhase.questioning) return;

    final nonSubjects = game.nonSubjectPlayers;
    final questionerIndex = game.questionerIndex;

    if (questionerIndex >= nonSubjects.length) return;

    final player = nonSubjects[questionerIndex];
    final updated = ref.read(submitQuestionProvider).call(game, player.id, question);

    if (updated.allQuestionsAsked) {
      ref.read(whoAmIViewStateProvider.notifier).state = WhoAmIViewState.answering;
    }

    state = updated;
  }

  void answerQuestions(bool answer) {
    final game = state;
    if (game == null || game.phase != WhoAmIPhase.questioning) return;

    final updated = ref.read(submitAnswerProvider).call(game, answer);
    state = updated;
    ref.read(whoAmIViewStateProvider.notifier).state = WhoAmIViewState.guessing;
  }

  void answerQuestion(String playerId, bool answer) {
    final game = state;
    if (game == null) return;
    final player = game.players.firstWhere((p) => p.id == playerId);
    final updated = game.updatePlayer(player.copyWith(subjectAnswer: answer));
    state = updated;
  }

  void submitGuess(String guess) {
    final game = state;
    if (game == null || game.phase != WhoAmIPhase.questioning) return;

    final nextGuesserIndex = _nextGuessIndex(game);
    if (nextGuesserIndex >= game.nonSubjectPlayers.length) return;

    final player = game.nonSubjectPlayers[nextGuesserIndex];
    final updated = ref.read(submitWhoAmIGuessProvider).call(game, player.id, guess);

    if (updated.phase == WhoAmIPhase.results) {
      ref.read(whoAmIViewStateProvider.notifier).state = WhoAmIViewState.results;
    }

    state = updated;
  }

  int _nextGuessIndex(WhoAmIGame game) {
    final nonSubjects = game.nonSubjectPlayers;
    for (int i = 0; i < nonSubjects.length; i++) {
      if (nonSubjects[i].currentGuess == null) return i;
    }
    return nonSubjects.length;
  }

  void nextRound() {
    final game = state;
    if (game == null) return;

    final updated = ref.read(advanceWhoAmIRoundProvider).call(game);
    state = updated;
    ref.read(whoAmIViewStateProvider.notifier).state = WhoAmIViewState.subjectReveal;
  }

  void resetGame() {
    state = null;
    ref.read(whoAmIViewStateProvider.notifier).state = WhoAmIViewState.setup;
  }
}

final whoAmIGameProvider = NotifierProvider<WhoAmIGameNotifier, WhoAmIGame?>(
  WhoAmIGameNotifier.new,
);
