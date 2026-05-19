import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String text;
  final double answer;
  final String unit;
  final String funFact;

  const Question({
    required this.text,
    required this.answer,
    required this.unit,
    required this.funFact,
  });

  @override
  List<Object> get props => [text, answer, unit, funFact];
}
