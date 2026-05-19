class KingsCupGameSettings {
  final int playerCount;

  const KingsCupGameSettings({required this.playerCount});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KingsCupGameSettings && playerCount == other.playerCount;

  @override
  int get hashCode => playerCount.hashCode;

  @override
  String toString() => 'KingsCupGameSettings(playerCount: $playerCount)';
}
