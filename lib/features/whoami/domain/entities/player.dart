import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class WhoAmIPlayer extends Equatable {
  final String id;
  final String name;
  final int score;
  final String? currentQuestion;
  final bool? subjectAnswer;
  final String? currentGuess;
  final bool isSubject;

  const WhoAmIPlayer({
    required this.id,
    required this.name,
    required this.score,
    this.currentQuestion,
    this.subjectAnswer,
    this.currentGuess,
    required this.isSubject,
  });

  factory WhoAmIPlayer.create({required String name}) {
    return WhoAmIPlayer(
      id: const Uuid().v4(),
      name: name,
      score: 0,
      isSubject: false,
    );
  }

  WhoAmIPlayer copyWith({
    String? id,
    String? name,
    int? score,
    String? currentQuestion,
    bool? subjectAnswer,
    String? currentGuess,
    bool? isSubject,
    bool clearQuestion = false,
    bool clearAnswer = false,
    bool clearGuess = false,
  }) {
    return WhoAmIPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      currentQuestion: clearQuestion ? null : (currentQuestion ?? this.currentQuestion),
      subjectAnswer: clearAnswer ? null : (subjectAnswer ?? this.subjectAnswer),
      currentGuess: clearGuess ? null : (currentGuess ?? this.currentGuess),
      isSubject: isSubject ?? this.isSubject,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        score,
        currentQuestion,
        subjectAnswer,
        currentGuess,
        isSubject,
      ];
}
