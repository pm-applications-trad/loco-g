import 'package:equatable/equatable.dart';

class GameSettings extends Equatable {
  final int playerCount;
  final int spyCount;
  final int totalRounds;

  const GameSettings({
    required this.playerCount,
    required this.spyCount,
    required this.totalRounds,
  });

  factory GameSettings.defaultParty() {
    return const GameSettings(
      playerCount: 4,
      spyCount: 1,
      totalRounds: 5,
    );
  }

  GameSettings copyWith({
    int? playerCount,
    int? spyCount,
    int? totalRounds,
  }) {
    return GameSettings(
      playerCount: playerCount ?? this.playerCount,
      spyCount: spyCount ?? this.spyCount,
      totalRounds: totalRounds ?? this.totalRounds,
    );
  }

  @override
  List<Object> get props => [playerCount, spyCount, totalRounds];
}
