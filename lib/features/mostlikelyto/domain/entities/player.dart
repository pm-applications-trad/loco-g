import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class MLTPlayer extends Equatable {
  final String id;
  final String name;
  final int drinkCount;

  const MLTPlayer({
    required this.id,
    required this.name,
    this.drinkCount = 0,
  });

  factory MLTPlayer.create({required String name}) {
    return MLTPlayer(id: const Uuid().v4(), name: name);
  }

  MLTPlayer copyWith({String? name, int? drinkCount}) {
    return MLTPlayer(
      id: id,
      name: name ?? this.name,
      drinkCount: drinkCount ?? this.drinkCount,
    );
  }

  @override
  List<Object?> get props => [id, name, drinkCount];
}
