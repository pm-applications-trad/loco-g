import 'package:equatable/equatable.dart';

import 'player.dart';
import 'prompt.dart';
import 'game_settings.dart';

enum MLTPhase { voting, results, gameOver }

class MLTGame extends Equatable {
  final MLTGameSettings settings;
  final List<MLTPlayer> players;
  final MLTPhase phase;
  final List<MLTPrompt> prompts;
  final int currentPromptIndex;
  final int currentRound;
  final int currentVoterIndex;
  final Map<String, int> currentVotes;
  final Set<String> playersWhoHaveVoted;

  const MLTGame({
    required this.settings,
    required this.players,
    required this.phase,
    required this.prompts,
    required this.currentPromptIndex,
    required this.currentRound,
    required this.currentVoterIndex,
    required this.currentVotes,
    required this.playersWhoHaveVoted,
  });

  MLTPrompt? get currentPrompt =>
      currentPromptIndex < prompts.length ? prompts[currentPromptIndex] : null;
  MLTPlayer get currentVoter => players[currentVoterIndex % players.length];
  bool get allVotesIn => playersWhoHaveVoted.length == players.length;

  String? get winnerId {
    if (!allVotesIn || currentVotes.isEmpty) return null;
    var maxVotes = 0;
    String? winner;
    for (final entry in currentVotes.entries) {
      if (entry.value > maxVotes) {
        maxVotes = entry.value;
        winner = entry.key;
      }
    }
    return maxVotes > 0 ? winner : null;
  }

  List<MLTPlayer> get sortedByDrinks {
    final sorted = List<MLTPlayer>.from(players);
    sorted.sort((a, b) => b.drinkCount.compareTo(a.drinkCount));
    return sorted;
  }

  MLTGame copyWith({
    MLTGameSettings? settings,
    List<MLTPlayer>? players,
    MLTPhase? phase,
    List<MLTPrompt>? prompts,
    int? currentPromptIndex,
    int? currentRound,
    int? currentVoterIndex,
    Map<String, int>? currentVotes,
    Set<String>? playersWhoHaveVoted,
  }) {
    return MLTGame(
      settings: settings ?? this.settings,
      players: players ?? this.players,
      phase: phase ?? this.phase,
      prompts: prompts ?? this.prompts,
      currentPromptIndex: currentPromptIndex ?? this.currentPromptIndex,
      currentRound: currentRound ?? this.currentRound,
      currentVoterIndex: currentVoterIndex ?? this.currentVoterIndex,
      currentVotes: currentVotes ?? this.currentVotes,
      playersWhoHaveVoted: playersWhoHaveVoted ?? this.playersWhoHaveVoted,
    );
  }

  MLTGame updatePlayer(MLTPlayer updated) {
    final newPlayers = players.map((p) => p.id == updated.id ? updated : p).toList();
    return copyWith(players: newPlayers);
  }

  @override
  List<Object?> get props => [
        settings,
        players,
        phase,
        prompts,
        currentPromptIndex,
        currentRound,
        currentVoterIndex,
        currentVotes,
        playersWhoHaveVoted,
      ];
}
