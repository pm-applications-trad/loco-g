import 'package:uuid/uuid.dart';

class RTBPlayer {
  final String id;
  final String name;
  final int penaltyDrinks;
  final bool hasRiddenTheBus;

  const RTBPlayer({
    required this.id,
    required this.name,
    this.penaltyDrinks = 0,
    this.hasRiddenTheBus = false,
  });

  factory RTBPlayer.create({required String name}) {
    return RTBPlayer(
      id: const Uuid().v4(),
      name: name,
    );
  }

  RTBPlayer copyWith({
    String? id,
    String? name,
    int? penaltyDrinks,
    bool? hasRiddenTheBus,
  }) {
    return RTBPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      penaltyDrinks: penaltyDrinks ?? this.penaltyDrinks,
      hasRiddenTheBus: hasRiddenTheBus ?? this.hasRiddenTheBus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RTBPlayer &&
          id == other.id &&
          name == other.name &&
          penaltyDrinks == other.penaltyDrinks &&
          hasRiddenTheBus == other.hasRiddenTheBus;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ penaltyDrinks.hashCode ^ hasRiddenTheBus.hashCode;

  @override
  String toString() =>
      'RTBPlayer(id: $id, name: $name, penalties: $penaltyDrinks)';
}
