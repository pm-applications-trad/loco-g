import 'dart:math';

import 'package:locogames/features/impostor/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final List<String> _locations = [
    'A crowded subway train at 8am',
    'Backstage at a fashion show',
    'A medieval castle dungeon',
    'The International Space Station',
    'A pirate ship in a storm',
    'A zombie apocalypse bunker',
    'A five-star hotel lobby',
    'An airport security checkpoint',
    'A circus tent during a performance',
    'A library at midnight',
    'A fast-food drive-thru at 2am',
    'A wedding reception gone wrong',
    'A space colony on Mars',
    'A submarine deep underwater',
    'A tropical beach resort',
    'A bank during a heist',
    'A rock concert backstage',
    'A haunted house at Halloween',
    'A ski lodge during a blizzard',
    'A courtroom during a dramatic trial',
    'A film set in Hollywood',
    'A jungle expedition camp',
    'A luxury cruise ship deck',
    'A maximum security prison yard',
    'A casino on the Vegas strip',
    'An ancient Egyptian tomb',
    'A tech startup office',
    'A crowded music festival',
    'A hospital emergency room',
    'A secret spy headquarters',
  ];

  final _random = Random();

  @override
  String getRandomLocation() {
    return _locations[_random.nextInt(_locations.length)];
  }

  @override
  List<String> getLocations() {
    return List.unmodifiable(_locations);
  }
}
