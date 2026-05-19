import 'dart:math';

import 'package:locogames/features/guessing/domain/entities/question.dart';
import 'package:locogames/features/guessing/domain/repositories/question_repository.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final _random = Random();

  final List<Question> _questions = const [
    Question(
      text: 'How many bones are in the adult human body?',
      answer: 206,
      unit: 'bones',
      funFact: 'Babies are born with about 300 bones that fuse together as they grow.',
    ),
    Question(
      text: 'How many countries are there in the world?',
      answer: 195,
      unit: 'countries',
      funFact: 'This includes 193 UN member states and 2 observer states.',
    ),
    Question(
      text: 'What is the speed of light in km/s?',
      answer: 299792,
      unit: 'km/s',
      funFact: 'Light travels around the Earth 7.5 times in one second.',
    ),
    Question(
      text: 'How many teeth does an adult human have?',
      answer: 32,
      unit: 'teeth',
      funFact: 'Wisdom teeth are the last to appear, usually between ages 17-25.',
    ),
    Question(
      text: 'How many languages are spoken worldwide?',
      answer: 7151,
      unit: 'languages',
      funFact: 'About 40% of languages are endangered with fewer than 1,000 speakers.',
    ),
    Question(
      text: 'What is the population of India?',
      answer: 1440000000,
      unit: 'people',
      funFact: 'India surpassed China as the world\'s most populous country in 2023.',
    ),
    Question(
      text: 'How many hours does the average person sleep per year?',
      answer: 2920,
      unit: 'hours',
      funFact: 'That\'s about one-third of your entire life spent sleeping.',
    ),
    Question(
      text: 'How many neurons are in the human brain?',
      answer: 86000000000,
      unit: 'neurons',
      funFact: 'Each neuron can connect to up to 10,000 other neurons.',
    ),
    Question(
      text: 'What is the circumference of Earth at the equator in km?',
      answer: 40075,
      unit: 'km',
      funFact: 'Earth is not a perfect sphere — it bulges at the equator.',
    ),
    Question(
      text: 'How many species of edible fruits exist worldwide?',
      answer: 2000,
      unit: 'species',
      funFact: 'Only about 200 are commonly eaten in the Western world.',
    ),
    Question(
      text: 'How many heart beats does the average human have per day?',
      answer: 100000,
      unit: 'beats',
      funFact: 'Your heart beats about 35 million times per year.',
    ),
    Question(
      text: 'What is the total length of all blood vessels in the human body in km?',
      answer: 100000,
      unit: 'km',
      funFact: 'That\'s enough to circle the Earth 2.5 times.',
    ),
    Question(
      text: 'How many steps does the average person take per day?',
      answer: 5000,
      unit: 'steps',
      funFact: 'The commonly recommended 10,000 steps originated from a Japanese marketing campaign.',
    ),
    Question(
      text: 'What is the volume of the Pacific Ocean in million cubic km?',
      answer: 660,
      unit: 'million km³',
      funFact: 'The Pacific Ocean is larger than all of Earth\'s landmass combined.',
    ),
    Question(
      text: 'How many wings does a bee flap per second?',
      answer: 200,
      unit: 'times',
      funFact: 'A bee\'s buzz comes from the rapid vibration of its flight muscles.',
    ),
    Question(
      text: 'What is the height of Mount Everest in meters?',
      answer: 8849,
      unit: 'meters',
      funFact: 'Everest grows about 4mm taller each year due to tectonic plate movement.',
    ),
    Question(
      text: 'How many taste buds does the average human tongue have?',
      answer: 10000,
      unit: 'taste buds',
      funFact: 'Taste buds regenerate every 1-2 weeks.',
    ),
    Question(
      text: 'How many muscles does a cat have in each ear?',
      answer: 32,
      unit: 'muscles',
      funFact: 'Cats can rotate their ears 180 degrees independently.',
    ),
    Question(
      text: 'What is the gestation period of an elephant in days?',
      answer: 645,
      unit: 'days',
      funFact: 'Elephants have the longest pregnancy of any land animal — nearly 22 months.',
    ),
    Question(
      text: 'How many stars are in the Milky Way galaxy?',
      answer: 200000000000,
      unit: 'stars',
      funFact: 'There are more stars in the universe than grains of sand on all Earth\'s beaches.',
    ),
    Question(
      text: 'How many frames per second can the human eye perceive?',
      answer: 60,
      unit: 'fps',
      funFact: 'Fighter pilots can identify aircraft in images shown for just 1/220th of a second.',
    ),
    Question(
      text: 'What is the average lifespan of a red blood cell in days?',
      answer: 120,
      unit: 'days',
      funFact: 'Your body produces about 2 million new red blood cells every second.',
    ),
    Question(
      text: 'How many muscles does it take to smile?',
      answer: 17,
      unit: 'muscles',
      funFact: 'It takes 43 muscles to frown — smiling is actually more efficient.',
    ),
    Question(
      text: 'How many liters of blood does the human heart pump per day?',
      answer: 7570,
      unit: 'liters',
      funFact: 'That\'s enough to fill about 40 bathtubs.',
    ),
    Question(
      text: 'How many times does the average person blink per day?',
      answer: 28800,
      unit: 'times',
      funFact: 'You blink about 15-20 times per minute while awake.',
    ),
    Question(
      text: 'What is the length of the Great Wall of China in km?',
      answer: 21196,
      unit: 'km',
      funFact: 'Contrary to popular belief, the Great Wall cannot be seen from space with the naked eye.',
    ),
    Question(
      text: 'How many hours does it take to digest a meal?',
      answer: 72,
      unit: 'hours',
      funFact: 'Food takes 6-8 hours to pass through the stomach and small intestine, then 36+ hours through the colon.',
    ),
    Question(
      text: 'How many hairs does the average human head have?',
      answer: 100000,
      unit: 'hairs',
      funFact: 'Blondes average 150,000 hairs, while redheads average only 90,000.',
    ),
    Question(
      text: 'How many unique visitors does Google get per day?',
      answer: 8500000000,
      unit: 'visitors',
      funFact: 'Google processes over 8.5 billion searches every single day.',
    ),
    Question(
      text: 'What is the depth of the Mariana Trench in meters?',
      answer: 11034,
      unit: 'meters',
      funFact: 'Only three people have ever reached the bottom of the Mariana Trench.',
    ),
  ];

  @override
  Question getRandomQuestion() {
    return _questions[_random.nextInt(_questions.length)];
  }

  @override
  List<Question> getQuestions() {
    return List.unmodifiable(_questions);
  }
}
