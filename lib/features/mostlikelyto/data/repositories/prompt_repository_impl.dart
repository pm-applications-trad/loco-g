import 'dart:math';

import 'package:locogames/features/mostlikelyto/domain/entities/prompt.dart';
import 'package:locogames/features/mostlikelyto/domain/repositories/prompt_repository.dart';

class MLTPromptRepositoryImpl implements MLTPromptRepository {
  static const _allPrompts = [
    'Who is most likely to forget their own birthday?',
    'Who is most likely to become a millionaire first?',
    'Who is most likely to survive a zombie apocalypse?',
    'Who is most likely to cry at a wedding?',
    'Who is most likely to get lost in their own neighborhood?',
    'Who is most likely to talk their way out of a ticket?',
    'Who is most likely to become famous overnight?',
    'Who is most likely to sleep through an alarm?',
    'Who is most likely to win a dance battle?',
    'Who is most likely to order dessert before dinner?',
    'Who is most likely to adopt 10 stray animals?',
    'Who is most likely to become a secret agent?',
    'Who is most likely to laugh at the worst possible moment?',
    'Who is most likely to go viral on social media?',
    'Who is most likely to spend their last dollar on something ridiculous?',
    'Who is most likely to survive on a deserted island?',
    'Who is most likely to become a chef?',
    'Who is most likely to start a podcast?',
    'Who is most likely to break a world record?',
    'Who is most likely to forget their keys every day?',
    'Who is most likely to dance in the rain?',
    'Who is most likely to plan a surprise party?',
    'Who is most likely to win the lottery and lose the ticket?',
    'Who is most likely to become a stand-up comedian?',
    'Who is most likely to get a tattoo on impulse?',
    'Who is most likely to climb a mountain?',
    'Who is most likely to write a bestselling novel?',
    'Who is most likely to fall asleep during a movie?',
    'Who is most likely to invent something useful?',
    'Who is most likely to sing karaoke sober?',
    'Who is most likely to travel the world with a backpack?',
    'Who is most likely to become a politician?',
    'Who is most likely to befriend a stranger instantly?',
    'Who is most likely to lose a staring contest?',
    'Who is most likely to binge-watch an entire series in one day?',
    'Who is most likely to get caught sneaking snacks?',
    'Who is most likely to become a professional gamer?',
    'Who is most likely to run a marathon?',
    'Who is most likely to tell a dad joke right now?',
    'Who is most likely to start a cult?',
    'Who is most likely to forget someone else\'s name mid-conversation?',
    'Who is most likely to give the best hugs?',
    'Who is most likely to accidentally send a text to the wrong person?',
    'Who is most likely to win an eating contest?',
    'Who is most likely to speak a foreign language fluently?',
    'Who is most likely to survive in the wilderness?',
    'Who is most likely to become a superhero?',
    'Who is most likely to spill a drink at the worst moment?',
    'Who is most likely to have the messiest room?',
    'Who is most likely to charm their way out of trouble?',
  ];

  @override
  List<MLTPrompt> getPrompts(int count) {
    final rng = Random();
    final shuffled = List<MLTPrompt>.from(_allPrompts.map((t) => MLTPrompt(t)));
    shuffled.shuffle(rng);
    return shuffled.take(count).toList();
  }
}
