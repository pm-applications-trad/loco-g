import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locogames/features/impostor/domain/entities/impostor_game.dart';
import 'package:locogames/features/impostor/domain/entities/player.dart';
import 'package:locogames/features/impostor/domain/entities/game_settings.dart';
import 'package:locogames/features/impostor/domain/usecases/game_usecases.dart';
import 'package:locogames/features/impostor/data/repositories/location_repository_impl.dart';

final locationRepositoryProvider = Provider<LocationRepositoryImpl>((ref) {
  return LocationRepositoryImpl();
});

final createGameProvider = Provider<CreateGame>((ref) {
  return CreateGame();
});

final assignRolesProvider = Provider<AssignRoles>((ref) {
  return AssignRoles();
});

final distributeWordsProvider = Provider<DistributeWords>((ref) {
  return DistributeWords(ref.read(locationRepositoryProvider));
});

final submitVoteProvider = Provider<SubmitVote>((ref) {
  return SubmitVote();
});

final resolveVotingProvider = Provider<ResolveVoting>((ref) {
  return ResolveVoting();
});

final resetVotesProvider = Provider<ResetVotes>((ref) {
  return ResetVotes();
});

final currentPlayerIndexProvider = StateProvider<int>((ref) => 0);

enum ImpostorViewState { setup, roleReveal, wordReveal, discussion, voting, results, gameOver }

class ImpostorGameNotifier extends Notifier<ImpostorGame?> {
  @override
  ImpostorGame? build() {
    return null;
  }

  void startGame({
    required int playerCount,
    required int spyCount,
    required int totalRounds,
    required List<String> playerNames,
  }) {
    final settings = GameSettings(
      playerCount: playerCount,
      spyCount: spyCount,
      totalRounds: totalRounds,
    );

    var game = ref.read(createGameProvider).call(settings);

    if (playerNames.length == playerCount) {
      game = game.copyWith(
        players: List.generate(
          playerCount,
          (i) => Player.create(name: playerNames[i]),
        ),
      );
    }

    game = ref.read(assignRolesProvider).call(game);
    state = game;
    ref.read(currentPlayerIndexProvider.notifier).state = 0;
  }

  void revealLocation() {
    final game = state;
    if (game == null) return;

    final updated = ref.read(distributeWordsProvider).call(game);
    state = updated;
  }

  void startDiscussion() {
    final game = state;
    if (game == null) return;
    state = game.copyWith(phase: GamePhase.discussion);
  }

  void startVoting() {
    final game = state;
    if (game == null) return;
    final resetGame = ref.read(resetVotesProvider).call(game);
    state = resetGame.copyWith(phase: GamePhase.voting);
  }

  void submitVote(String targetId) {
    final game = state;
    if (game == null) return;

    final voterIndex = ref.read(currentPlayerIndexProvider);
    final alivePlayers = game.alivePlayers;
    if (voterIndex >= alivePlayers.length) return;

    final voter = alivePlayers[voterIndex];
    final updated = ref.read(submitVoteProvider).call(game, voter.id, targetId);
    state = updated;

    if (updated.allVotesIn) {
      final resolved = ref.read(resolveVotingProvider).call(updated);
      state = resolved;
    } else {
      ref.read(currentPlayerIndexProvider.notifier).state = voterIndex + 1;
    }
  }

  void nextRound() {
    final game = state;
    if (game == null) return;

    final reset = ref.read(resetVotesProvider).call(game);
    var updated = reset.copyWith(
      phase: GamePhase.setup,
      clearLocation: true,
      clearEliminated: true,
    );

    updated = ref.read(assignRolesProvider).call(updated);
    state = updated;
    ref.read(currentPlayerIndexProvider.notifier).state = 0;
  }

  void resetGame() {
    state = null;
    ref.read(currentPlayerIndexProvider.notifier).state = 0;
  }

  ImpostorViewState get viewState {
    final game = state;
    if (game == null) return ImpostorViewState.setup;

    switch (game.phase) {
      case GamePhase.setup:
        return ImpostorViewState.setup;
      case GamePhase.wordDistribution:
        if (game.location == null) return ImpostorViewState.roleReveal;
        return ImpostorViewState.wordReveal;
      case GamePhase.discussion:
        return ImpostorViewState.discussion;
      case GamePhase.voting:
        return ImpostorViewState.voting;
      case GamePhase.results:
        return ImpostorViewState.results;
      case GamePhase.gameOver:
        return ImpostorViewState.gameOver;
    }
  }
}

final impostorGameProvider = NotifierProvider<ImpostorGameNotifier, ImpostorGame?>(
  ImpostorGameNotifier.new,
);
