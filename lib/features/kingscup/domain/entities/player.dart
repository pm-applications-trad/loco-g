import 'package:uuid/uuid.dart';

class KingsCupPlayer {
  final String id;
  final String name;
  final int drinksAssigned;
  final bool isCenterCupDrinker;

  const KingsCupPlayer({
    required this.id,
    required this.name,
    this.drinksAssigned = 0,
    this.isCenterCupDrinker = false,
  });

  factory KingsCupPlayer.create({required String name}) {
    return KingsCupPlayer(
      id: const Uuid().v4(),
      name: name,
    );
  }

  KingsCupPlayer copyWith({
    String? id,
    String? name,
    int? drinksAssigned,
    bool? isCenterCupDrinker,
  }) {
    return KingsCupPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      drinksAssigned: drinksAssigned ?? this.drinksAssigned,
      isCenterCupDrinker: isCenterCupDrinker ?? this.isCenterCupDrinker,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KingsCupPlayer &&
          id == other.id &&
          name == other.name &&
          drinksAssigned == other.drinksAssigned &&
          isCenterCupDrinker == other.isCenterCupDrinker;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ drinksAssigned.hashCode ^ isCenterCupDrinker.hashCode;

  @override
  String toString() => 'KingsCupPlayer(id: $id, name: $name, drinks: $drinksAssigned)';
}
