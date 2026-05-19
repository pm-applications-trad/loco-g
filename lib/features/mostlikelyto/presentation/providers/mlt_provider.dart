import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locogames/features/mostlikelyto/domain/entities/mlt_game.dart';
import 'package:locogames/features/mostlikelyto/domain/entities/player.dart';
import 'package:locogames/features/mostlikelyto/domain/entities/game_settings.dart';
import 'package:locogames/features/mostlikelyto/domain/usecases/mlt_usecases.dart';
import 'package:locogames/features/mostlikelyto/data/repositories/prompt_repository_impl.dart';

final mltPromptRepoProvider = Provider<MLTPromptRepositoryImpl>((ref) {
  return MLTPromptRepositoryImpl();
});

final mltCreateGameProvider = Provider<CreateMLTGame>((ref) {
  return CreateMLTGame();
});

final mltAdvanceRoundProvider = Provider<AdvanceMLTRound>((ref) {
  return AdvanceMLTRound();
});

class MLTGameNotifier extends Notifier<MLTGame?> {
  @override
  MLTGame? build() => null;

  void startGame({
    required int playerCount,
    required int totalRounds,
    required List<String> playerNames,
  }) {
    final settings = MLTGameSettings(
      playerCount: playerCount,
      totalRounds: totalRounds,
    );

    final prompts = ref.read(mltPromptRepoProvider).getPrompts(totalRounds);

    final players = List.generate(
      playerCount,
      (i) => MLTPlayer.create(name: playerNames.length > i ? playerNames[i] : 'Player ${i + 1}'),
    );

    final game = ref.read(mltCreateGameProvider).call(
          settings: settings,
          players: players,
          prompts: prompts,
        );

    state = game;
  }

  void castVote(String votedPlayerId) {
    final game = state;
    if (game == null || game.phase != MLTPhase.voting) return;

    final voter = game.currentVoter;
    if (game.playersWhoHaveVoted.contains(voter.id)) return;

    final newVotes = Map<String, int>.from(game.currentVotes);
    newVotes[votedPlayerId] = (newVotes[votedPlayerId] ?? 0) + 1;

    final newVoted = Set<String>.from(game.playersWhoHaveVoted)..add(voter.id);

    final nextVoterIndex = game.currentVoterIndex + 1;

    final newPhase = newVoted.length == game.players.length ? MLTPhase.results : MLTPhase.voting;

    state = game.copyWith(
      currentVotes: newVotes,
      playersWhoHaveVoted: newVoted,
      currentVoterIndex: nextVoterIndex,
      phase: newPhase,
    );
  }

  void nextRound() {
    final game = state;
    if (game == null || game.phase != MLTPhase.results) return;

    final winnerId = game.winnerId;
    if (winnerId != null) {
      final winner = game.players.where((p) => p.id == winnerId).firstOrNull;
      if (winner != null) {
        final updatedWinner = winner.copyWith(drinkCount: winner.drinkCount + 1);
        state = game.updatePlayer(updatedWinner);
      }
    }

    final updated = ref.read(mltAdvanceRoundProvider).call(state!);
    state = updated;
  }

  void resetGame() {
    state = null;
  }
}

final mltGameProvider = NotifierProvider<MLTGameNotifier, MLTGame?>(
  MLTGameNotifier.new,
);
