import 'package:locogames/features/guessing/domain/entities/question.dart';

abstract class QuestionRepository {
  Question getRandomQuestion();
  List<Question> getQuestions();
}
