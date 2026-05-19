import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum PlayerRole { citizen, impostor }

class Player extends Equatable {
  final String id;
  final String name;
  final PlayerRole role;
  final bool isAlive;
  final String? votedForId;

  const Player({
    required this.id,
    required this.name,
    required this.role,
    this.isAlive = true,
    this.votedForId,
  });

  factory Player.create({required String name, PlayerRole role = PlayerRole.citizen}) {
    return Player(
      id: const Uuid().v4(),
      name: name,
      role: role,
    );
  }

  Player copyWith({
    String? id,
    String? name,
    PlayerRole? role,
    bool? isAlive,
    String? votedForId,
    bool clearVote = false,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
      votedForId: clearVote ? null : (votedForId ?? this.votedForId),
    );
  }

  @override
  List<Object?> get props => [id, name, role, isAlive, votedForId];
}
