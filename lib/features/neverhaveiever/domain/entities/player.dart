import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class NHIEPlayer extends Equatable {
  final String id;
  final String name;
  final int drinkCount;

  const NHIEPlayer({
    required this.id,
    required this.name,
    this.drinkCount = 0,
  });

  factory NHIEPlayer.create({required String name}) {
    return NHIEPlayer(
      id: const Uuid().v4(),
      name: name,
    );
  }

  NHIEPlayer copyWith({String? id, String? name, int? drinkCount}) {
    return NHIEPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      drinkCount: drinkCount ?? this.drinkCount,
    );
  }

  @override
  List<Object?> get props => [id, name, drinkCount];
}
