import 'package:equatable/equatable.dart';

class WhoAmIGameSettings extends Equatable {
  final int playerCount;
  final int totalRounds;

  const WhoAmIGameSettings({
    required this.playerCount,
    required this.totalRounds,
  });

  @override
  List<Object> get props => [playerCount, totalRounds];
}
