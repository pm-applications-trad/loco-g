import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class GuessingPlayer extends Equatable {
  final String id;
  final String name;
  final int score;
  final double? currentGuess;

  const GuessingPlayer({
    required this.id,
    required this.name,
    required this.score,
    this.currentGuess,
  });

  factory GuessingPlayer.create({required String name}) {
    return GuessingPlayer(
      id: const Uuid().v4(),
      name: name,
      score: 0,
    );
  }

  GuessingPlayer copyWith({
    String? id,
    String? name,
    int? score,
    double? currentGuess,
    bool clearGuess = false,
  }) {
    return GuessingPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      currentGuess: clearGuess ? null : (currentGuess ?? this.currentGuess),
    );
  }

  @override
  List<Object?> get props => [id, name, score, currentGuess];
}
