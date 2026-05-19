import 'dart:math';

import 'package:locogames/features/neverhaveiever/domain/entities/statement.dart';
import 'package:locogames/features/neverhaveiever/domain/repositories/statement_repository.dart';

class NHIEStatementRepositoryImpl implements NHIEStatementRepository {
  final _random = Random();

  static const _allStatements = <NHIEStatement>[
    NHIEStatement(text: 'Never have I ever lied about my age at a bar', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever sent a text to the wrong person', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever pretended to like a gift', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever fallen asleep at work or school', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever stalked an ex on social media', category: NHIECategory.spicy),
    NHIEStatement(text: 'Never have I ever had a crush on a friend\'s partner', category: NHIECategory.spicy),
    NHIEStatement(text: 'Never have I ever ghosted someone I was dating', category: NHIECategory.spicy),
    NHIEStatement(text: 'Never have I ever lied about my relationship status', category: NHIECategory.spicy),
    NHIEStatement(text: 'Never have I ever had a one-night stand', category: NHIECategory.extreme),
    NHIEStatement(text: 'Never have I ever skinny dipped', category: NHIECategory.extreme),
    NHIEStatement(text: 'Never have I ever been walked in on during an intimate moment', category: NHIECategory.extreme),
    NHIEStatement(text: 'Never have I ever drunk texted an ex', category: NHIECategory.mixed),
    NHIEStatement(text: 'Never have I ever been kicked out of a bar or club', category: NHIECategory.mixed),
    NHIEStatement(text: 'Never have I ever lied to get out of plans', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever re-gifted a present', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever sang karaoke in front of strangers', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever cried watching a movie alone', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever been on a blind date', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever faked a phone call to get out of something', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever eaten food that fell on the floor', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever had a secret relationship', category: NHIECategory.spicy),
    NHIEStatement(text: 'Never have I ever kissed someone on the first date', category: NHIECategory.spicy),
    NHIEStatement(text: 'Never have I ever had a dating app profile', category: NHIECategory.spicy),
    NHIEStatement(text: 'Never have I ever flirted my way into free drinks', category: NHIECategory.spicy),
    NHIEStatement(text: 'Never have I ever sent a spicy photo', category: NHIECategory.extreme),
    NHIEStatement(text: 'Never have I ever hooked up with a coworker', category: NHIECategory.extreme),
    NHIEStatement(text: 'Never have I ever had a threesome', category: NHIECategory.extreme),
    NHIEStatement(text: 'Never have I ever broken a bone doing something stupid', category: NHIECategory.mixed),
    NHIEStatement(text: 'Never have I ever been caught talking to myself', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever fallen for a scam or prank', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever fallen in love at first sight', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever danced on a table or bar', category: NHIECategory.spicy),
    NHIEStatement(text: 'Never have I ever had a public argument with a partner', category: NHIECategory.spicy),
    NHIEStatement(text: 'Never have I ever used someone just for their money', category: NHIECategory.spicy),
    NHIEStatement(text: 'Never have I ever had sex on the first date', category: NHIECategory.extreme),
    NHIEStatement(text: 'Never have I ever cheated on a test or exam', category: NHIECategory.mixed),
    NHIEStatement(text: 'Never have I ever drunk dialed someone', category: NHIECategory.mixed),
    NHIEStatement(text: 'Never have I ever forgotten someone\'s name while talking to them', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever eavesdropped on a private conversation', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever had an embarrassing autocorrect fail', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever been caught checking someone out', category: NHIECategory.spicy),
    NHIEStatement(text: 'Never have I ever made out with a stranger at a party', category: NHIECategory.spicy),
    NHIEStatement(text: 'Never have I ever had a crush on a teacher or boss', category: NHIECategory.spicy),
    NHIEStatement(text: 'Never have I ever snuck out of the house at night', category: NHIECategory.extreme),
    NHIEStatement(text: 'Never have I ever gone commando in public', category: NHIECategory.extreme),
    NHIEStatement(text: 'Never have I ever lied during a game of Never Have I Ever', category: NHIECategory.mixed),
    NHIEStatement(text: 'Never have I ever gotten a tattoo while drunk', category: NHIECategory.mixed),
    NHIEStatement(text: 'Never have I ever been on TV or in the news', category: NHIECategory.mild),
    NHIEStatement(text: 'Never have I ever had to be carried home from a party', category: NHIECategory.mixed),
    NHIEStatement(text: 'Never have I ever had a wardrobe malfunction in public', category: NHIECategory.mixed),
  ];

  @override
  List<NHIEStatement> getStatements(NHIECategory category) {
    final filtered = category == NHIECategory.mixed
        ? _allStatements
        : _allStatements.where((s) => s.category == category).toList();

    final shuffled = List<NHIEStatement>.from(filtered);
    shuffled.shuffle(_random);
    return shuffled;
  }
}
