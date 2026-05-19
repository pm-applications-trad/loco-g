import 'dart:math';

import 'package:locogames/features/whoami/domain/entities/identity.dart';
import 'package:locogames/features/whoami/domain/repositories/identity_repository.dart';

class IdentityRepositoryImpl implements IdentityRepository {
  final _random = Random();

  static const _identities = [
    Identity(name: 'Albert Einstein', category: 'Science', hint: 'Famous physicist with wild hair'),
    Identity(name: 'Cleopatra', category: 'History', hint: 'Last active ruler of Ptolemaic Egypt'),
    Identity(name: 'Batman', category: 'Fiction', hint: 'Dark Knight of Gotham City'),
    Identity(name: 'Taylor Swift', category: 'Music', hint: 'Pop star known for eras and storytelling'),
    Identity(name: 'Spider-Man', category: 'Fiction', hint: 'Your friendly neighborhood web-slinger'),
    Identity(name: 'Mona Lisa', category: 'Art', hint: 'Smiling lady in a famous painting'),
    Identity(name: 'Elon Musk', category: 'Business', hint: 'Tesla and SpaceX CEO'),
    Identity(name: 'Harry Potter', category: 'Fiction', hint: 'The boy who lived, wizard'),
    Identity(name: 'Marilyn Monroe', category: 'History', hint: 'Blonde Hollywood icon of the 1950s'),
    Identity(name: 'Darth Vader', category: 'Fiction', hint: 'Dark side of the Force, heavy breathing'),
    Identity(name: 'Beyoncé', category: 'Music', hint: 'Queen B, singer of Single Ladies'),
    Identity(name: 'Sherlock Holmes', category: 'Fiction', hint: 'Baker Street detective with a pipe'),
    Identity(name: 'Napoleon Bonaparte', category: 'History', hint: 'Short French emperor, Waterloo'),
    Identity(name: 'Mickey Mouse', category: 'Entertainment', hint: 'Disney mascot with big round ears'),
    Identity(name: 'Cristiano Ronaldo', category: 'Sports', hint: 'Portuguese football legend, number 7'),
    Identity(name: 'Wonder Woman', category: 'Fiction', hint: 'Amazonian princess with a lasso of truth'),
    Identity(name: 'Pablo Picasso', category: 'Art', hint: 'Cubist painter from Spain'),
    Identity(name: 'Ariana Grande', category: 'Music', hint: 'Petite pop star with a ponytail'),
    Identity(name: 'Julius Caesar', category: 'History', hint: 'Roman dictator, stabbed in the Senate'),
    Identity(name: 'SpongeBob SquarePants', category: 'Entertainment', hint: 'Lives in a pineapple under the sea'),
    Identity(name: 'Serena Williams', category: 'Sports', hint: 'Tennis champion with powerful serves'),
    Identity(name: 'Iron Man', category: 'Fiction', hint: 'Billionaire genius in a powered suit of armor'),
    Identity(name: 'Marie Curie', category: 'Science', hint: 'Discovered radium and polonium'),
    Identity(name: 'Michael Jackson', category: 'Music', hint: 'King of Pop, moonwalk'),
    Identity(name: 'Donald Trump', category: 'Politics', hint: 'You\'re fired — former US president'),
    Identity(name: 'Frida Kahlo', category: 'Art', hint: 'Mexican painter with unibrow'),
    Identity(name: 'Lionel Messi', category: 'Sports', hint: 'Argentine football magician, World Cup winner'),
    Identity(name: 'Princess Diana', category: 'History', hint: 'People\'s Princess, British royalty'),
    Identity(name: 'The Joker', category: 'Fiction', hint: 'Why so serious? Clown prince of crime'),
    Identity(name: 'Oprah Winfrey', category: 'Entertainment', hint: 'Talk show host, you get a car'),
  ];

  @override
  Identity getRandomIdentity() {
    return _identities[_random.nextInt(_identities.length)];
  }

  @override
  Identity getRandomIdentityExcluding(List<String> excludeNames) {
    final available = _identities.where((i) => !excludeNames.contains(i.name)).toList();
    if (available.isEmpty) {
      return _identities[_random.nextInt(_identities.length)];
    }
    return available[_random.nextInt(available.length)];
  }
}
