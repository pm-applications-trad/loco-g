import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'package:locogames/features/whoami/domain/entities/player.dart';
import 'package:locogames/features/whoami/domain/entities/game_settings.dart';
import 'package:locogames/features/whoami/domain/entities/identity.dart';

enum WhoAmIPhase { setup, questioning, results, gameOver }

class WhoAmIGame extends Equatable {
  final String id;
  final WhoAmIGameSettings settings;
  final List<WhoAmIPlayer> players;
  final Identity? currentIdentity;
  final WhoAmIPhase phase;
  final int currentRound;
  final int questionerIndex;
  final List<String> roundWinnerIds;

  const WhoAmIGame({
    required this.id,
    required this.settings,
    required this.players,
    this.currentIdentity,
    required this.phase,
    required this.currentRound,
    required this.questionerIndex,
    this.roundWinnerIds = const [],
  });

  factory WhoAmIGame.create({required WhoAmIGameSettings settings}) {
    return WhoAmIGame(
      id: const Uuid().v4(),
      settings: settings,
      players: List.generate(
        settings.playerCount,
        (i) => WhoAmIPlayer.create(name: 'Player ${i + 1}'),
      ),
      phase: WhoAmIPhase.setup,
      currentRound: 1,
      questionerIndex: 0,
    );
  }

  List<WhoAmIPlayer> get sortedByScore =>
      List<WhoAmIPlayer>.from(players)..sort((a, b) => b.score.compareTo(a.score));

  bool get isLastRound => currentRound >= settings.totalRounds;

  bool get allQuestionsAsked =>
      players.where((p) => !p.isSubject).every((p) => p.currentQuestion != null);

  bool get allAnswersGiven =>
      players
          .where((p) => !p.isSubject)
          .every((p) => p.subjectAnswer != null && p.currentQuestion != null);

  bool get allGuessesIn =>
      players.where((p) => !p.isSubject).every((p) => p.currentGuess != null);

  int get subjectIndex => players.indexWhere((p) => p.isSubject);

  List<WhoAmIPlayer> get nonSubjectPlayers =>
      players.where((p) => !p.isSubject).toList();

  WhoAmIGame copyWith({
    String? id,
    WhoAmIGameSettings? settings,
    List<WhoAmIPlayer>? players,
    Identity? currentIdentity,
    WhoAmIPhase? phase,
    int? currentRound,
    int? questionerIndex,
    List<String>? roundWinnerIds,
    bool clearIdentity = false,
    bool clearRoundWinner = false,
  }) {
    return WhoAmIGame(
      id: id ?? this.id,
      settings: settings ?? this.settings,
      players: players ?? this.players,
      currentIdentity: clearIdentity ? null : (currentIdentity ?? this.currentIdentity),
      phase: phase ?? this.phase,
      currentRound: currentRound ?? this.currentRound,
      questionerIndex: questionerIndex ?? this.questionerIndex,
      roundWinnerIds: clearRoundWinner ? const [] : (roundWinnerIds ?? this.roundWinnerIds),
    );
  }

  WhoAmIGame updatePlayer(WhoAmIPlayer updated) {
    final newPlayers = players.map((p) => p.id == updated.id ? updated : p).toList();
    return copyWith(players: newPlayers);
  }

  @override
  List<Object?> get props => [
        id,
        settings,
        players,
        currentIdentity,
        phase,
        currentRound,
        questionerIndex,
        roundWinnerIds,
      ];
}
