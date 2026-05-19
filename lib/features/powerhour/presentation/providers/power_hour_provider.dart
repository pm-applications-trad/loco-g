import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locogames/features/powerhour/domain/entities/power_hour_game.dart';

final showDrinkNotificationProvider = StateProvider<bool>((ref) => false);

class PowerHourNotifier extends Notifier<PowerHourGame?> {
  Timer? _timer;
  Timer? _drinkNotificationTimer;

  @override
  PowerHourGame? build() {
    ref.onDispose(() {
      _timer?.cancel();
      _drinkNotificationTimer?.cancel();
    });
    return null;
  }

  void startGame({required int totalMinutes}) {
    _timer?.cancel();
    state = PowerHourGame(
      phase: PowerHourPhase.running,
      totalMinutes: totalMinutes,
      elapsedSeconds: 0,
    );
    _startTimer();
  }

  void pauseGame() {
    if (state?.phase != PowerHourPhase.running) return;
    _timer?.cancel();
    state = state!.copyWith(phase: PowerHourPhase.paused);
  }

  void resumeGame() {
    if (state?.phase != PowerHourPhase.paused) return;
    state = state!.copyWith(phase: PowerHourPhase.running);
    _startTimer();
  }

  void resetGame() {
    _timer?.cancel();
    _drinkNotificationTimer?.cancel();
    ref.read(showDrinkNotificationProvider.notifier).state = false;
    state = null;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final game = state;
      if (game == null || game.phase != PowerHourPhase.running) {
        _timer?.cancel();
        return;
      }

      final newElapsed = game.elapsedSeconds + 1;
      final minuteJustElapsed = newElapsed > 0 && newElapsed % 60 == 0;

      if (newElapsed >= game.totalMinutes * 60) {
        state = game.copyWith(
          elapsedSeconds: newElapsed,
          phase: PowerHourPhase.finished,
        );
        _timer?.cancel();
      } else {
        state = game.copyWith(elapsedSeconds: newElapsed);
      }

      if (minuteJustElapsed) {
        ref.read(showDrinkNotificationProvider.notifier).state = true;
        _drinkNotificationTimer?.cancel();
        _drinkNotificationTimer = Timer(const Duration(seconds: 3), () {
          ref.read(showDrinkNotificationProvider.notifier).state = false;
        });
      }
    });
  }
}

final powerHourGameProvider = NotifierProvider<PowerHourNotifier, PowerHourGame?>(
  PowerHourNotifier.new,
);
