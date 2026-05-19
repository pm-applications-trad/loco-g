import 'package:equatable/equatable.dart';

enum PowerHourPhase { idle, running, paused, finished }

class PowerHourGame extends Equatable {
  final PowerHourPhase phase;
  final int totalMinutes;
  final int elapsedSeconds;

  const PowerHourGame({
    required this.phase,
    required this.totalMinutes,
    this.elapsedSeconds = 0,
  });

  int get elapsedMinutes => elapsedSeconds ~/ 60;
  int get remainingSeconds => (totalMinutes * 60) - elapsedSeconds;
  int get remainingMinutes => remainingSeconds ~/ 60;
  int get remainingSecondsInMinute => remainingSeconds % 60;
  int get secondsInCurrentMinute => elapsedSeconds % 60;

  bool get isMinuteElapsed => elapsedSeconds > 0 && elapsedSeconds % 60 == 0;

  PowerHourGame copyWith({
    PowerHourPhase? phase,
    int? totalMinutes,
    int? elapsedSeconds,
  }) {
    return PowerHourGame(
      phase: phase ?? this.phase,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  @override
  List<Object?> get props => [phase, totalMinutes, elapsedSeconds];
}
