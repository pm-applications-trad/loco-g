import 'package:locogames/features/mostlikelyto/domain/entities/mlt_game.dart';
import 'package:locogames/features/mostlikelyto/domain/entities/player.dart';
import 'package:locogames/features/mostlikelyto/domain/entities/prompt.dart';
import 'package:locogames/features/mostlikelyto/domain/entities/game_settings.dart';

class CreateMLTGame {
  MLTGame call({
    required MLTGameSettings settings,
    required List<MLTPlayer> players,
    required List<MLTPrompt> prompts,
  }) {
    return MLTGame(
      settings: settings,
      players: players,
      phase: MLTPhase.voting,
      prompts: prompts,
      currentPromptIndex: 0,
      currentRound: 1,
      currentVoterIndex: 0,
      currentVotes: const {},
      playersWhoHaveVoted: const {},
    );
  }
}

class AdvanceMLTRound {
  MLTGame call(MLTGame game) {
    final nextIndex = game.currentPromptIndex + 1;
    if (nextIndex >= game.prompts.length) {
      return game.copyWith(phase: MLTPhase.gameOver);
    }

    return game.copyWith(
      phase: MLTPhase.voting,
      currentPromptIndex: nextIndex,
      currentRound: game.currentRound + 1,
      currentVoterIndex: 0,
      currentVotes: const {},
      playersWhoHaveVoted: const {},
    );
  }
}
