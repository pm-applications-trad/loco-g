import 'package:equatable/equatable.dart';

class GuessingGameSettings extends Equatable {
  final int playerCount;
  final int totalRounds;

  const GuessingGameSettings({
    required this.playerCount,
    required this.totalRounds,
  });

  @override
  List<Object> get props => [playerCount, totalRounds];
}
