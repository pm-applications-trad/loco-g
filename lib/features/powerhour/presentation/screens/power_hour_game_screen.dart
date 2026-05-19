import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/features/powerhour/domain/entities/power_hour_game.dart';
import 'package:locogames/features/powerhour/presentation/providers/power_hour_provider.dart';
import 'package:locogames/core/providers/shared_providers.dart';

class PowerHourGameScreen extends ConsumerWidget {
  const PowerHourGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(powerHourGameProvider);
    final l10n = L10n.of(context);
    final audio = ref.read(audioServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    ref.listen(powerHourGameProvider, (prev, next) {
      if (next == null || prev == null) return;
      if (next.isMinuteElapsed && next.elapsedSeconds != prev.elapsedSeconds) {
        haptic.heavyImpact();
        audio.playSuccess();
      }
      if (prev.phase != PowerHourPhase.finished && next.phase == PowerHourPhase.finished) {
        haptic.reveal();
        audio.playReveal();
      }
    });

    if (game == null) {
      return Scaffold(body: Center(child: Text(l10n.translate('no_active_game'))));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('power_hour_title')),
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            ref.read(powerHourGameProvider.notifier).resetGame();
            context.go('/home');
          },
        ),
      ),
      body: SafeArea(
        child: game.phase == PowerHourPhase.finished
            ? _FinishedPhase(game: game, l10n: l10n, ref: ref)
            : _ActivePhase(game: game, l10n: l10n, ref: ref),
      ),
    );
  }
}

class _ActivePhase extends StatelessWidget {
  final PowerHourGame game;
  final L10n l10n;
  final WidgetRef ref;

  const _ActivePhase({required this.game, required this.l10n, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isPaused = game.phase == PowerHourPhase.paused;
    final showDrink = ref.watch(showDrinkNotificationProvider);

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          const Spacer(flex: 2),
          if (showDrink && !isPaused)
            Column(
              children: [
                const Icon(Icons.local_drink, size: 64, color: Color(0xFFFF3B6E)),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  l10n.translate('power_hour_take_drink'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFFFF3B6E),
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 300))
                .then()
                .fadeOut(duration: const Duration(milliseconds: 300), delay: const Duration(seconds: 2)),
          if (!showDrink || isPaused) ...[
            Text(
              _formatTime(game.remainingSeconds),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ).animate(onPlay: (controller) => controller.repeat())
                .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: const Duration(seconds: 2))
                .then().scale(end: const Offset(1.0, 1.0), duration: const Duration(seconds: 2)),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              l10n.translate('power_hour_remaining'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
          const Spacer(flex: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatCard(
                label: l10n.translate('power_hour_elapsed'),
                value: '${game.elapsedMinutes}',
                icon: Icons.timer,
              ),
              const SizedBox(width: AppTheme.spacingM),
              _StatCard(
                label: l10n.translate('power_hour_total'),
                value: '${game.totalMinutes}',
                icon: Icons.schedule,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          LinearProgressIndicator(
            value: game.elapsedSeconds / (game.totalMinutes * 60),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          const Spacer(flex: 1),
          SizedBox(
            width: double.infinity,
            child: isPaused
                ? ElevatedButton.icon(
                    onPressed: () => ref.read(powerHourGameProvider.notifier).resumeGame(),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l10n.translate('power_hour_resume')),
                  )
                : ElevatedButton.icon(
                    onPressed: () => ref.read(powerHourGameProvider.notifier).pauseGame(),
                    icon: const Icon(Icons.pause),
                    label: Text(l10n.translate('power_hour_pause')),
                  ),
          ),
          const SizedBox(height: AppTheme.spacingS),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL, vertical: AppTheme.spacingM),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: AppTheme.spacingS),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _FinishedPhase extends StatelessWidget {
  final PowerHourGame game;
  final L10n l10n;
  final WidgetRef ref;

  const _FinishedPhase({required this.game, required this.l10n, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('\u{1F37B}', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              l10n.translate('power_hour_complete'),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              '${game.elapsedMinutes} ${l10n.translate('power_hour_minutes')}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(powerHourGameProvider.notifier).resetGame();
                  context.go('/home');
                },
                child: Text(l10n.translate('main_menu')),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(powerHourGameProvider.notifier).resetGame();
                  context.go('/powerhour');
                },
                child: Text(l10n.translate('play_again')),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.slowAnimation);
  }
}
