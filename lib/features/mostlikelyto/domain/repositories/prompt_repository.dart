import 'package:locogames/features/mostlikelyto/domain/entities/prompt.dart';

abstract class MLTPromptRepository {
  List<MLTPrompt> getPrompts(int count);
}
