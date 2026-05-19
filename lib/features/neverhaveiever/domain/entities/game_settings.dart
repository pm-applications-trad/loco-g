import 'package:equatable/equatable.dart';

import 'statement.dart';

class NHIEGameSettings extends Equatable {
  final int playerCount;
  final int totalRounds;
  final NHIECategory category;

  const NHIEGameSettings({
    required this.playerCount,
    required this.totalRounds,
    this.category = NHIECategory.mixed,
  });

  NHIEGameSettings copyWith({int? playerCount, int? totalRounds, NHIECategory? category}) {
    return NHIEGameSettings(
      playerCount: playerCount ?? this.playerCount,
      totalRounds: totalRounds ?? this.totalRounds,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [playerCount, totalRounds, category];
}
