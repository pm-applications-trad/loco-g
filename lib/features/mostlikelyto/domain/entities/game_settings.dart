import 'package:equatable/equatable.dart';

class MLTGameSettings extends Equatable {
  final int playerCount;
  final int totalRounds;

  const MLTGameSettings({
    required this.playerCount,
    required this.totalRounds,
  });

  @override
  List<Object?> get props => [playerCount, totalRounds];
}
