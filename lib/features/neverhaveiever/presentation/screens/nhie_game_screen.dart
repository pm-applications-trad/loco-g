import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/features/neverhaveiever/domain/entities/nhie_game.dart';
import 'package:locogames/features/neverhaveiever/presentation/providers/nhie_provider.dart';
import 'package:locogames/core/providers/shared_providers.dart';

class NHIEGameScreen extends ConsumerWidget {
  const NHIEGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(nhieGameProvider);
    final l10n = L10n.of(context);
    final audio = ref.read(audioServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    ref.listen(nhieGameProvider, (prev, next) {
      if (next == null || prev == null) return;
      if (prev.phase != NHIEPhase.gameOver && next.phase == NHIEPhase.gameOver) {
        haptic.reveal();
        audio.playReveal();
      }
    });

    if (game == null) {
      return Scaffold(body: Center(child: Text(l10n.translate('no_active_game'))));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.translate('never_have_i_ever_title')} — ${l10n.translate('round')} ${game.currentRound}/${game.settings.totalRounds}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            ref.read(nhieGameProvider.notifier).resetGame();
            context.go('/home');
          },
        ),
      ),
      body: SafeArea(
        child: game.phase == NHIEPhase.gameOver
            ? _buildGameOver(context, ref, l10n, game)
            : _PlayingPhase(game: game, l10n: l10n, ref: ref),
      ),
    );
  }

  Widget _buildGameOver(BuildContext context, WidgetRef ref, L10n l10n, NHIEGame game) {
    final sorted = game.sortedByDrinks;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('\u{1F389}', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              l10n.translate('game_over'),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (sorted.isNotEmpty)
              Text(
                '${l10n.translate('winner')}: ${sorted.first.name}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: AppTheme.spacingL),
            Expanded(
              child: ListView.builder(
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final player = sorted[index];
                  final rank = index + 1;
                  final medals = [Icons.emoji_events, Icons.workspace_premium, Icons.military_tech];
                  return ListTile(
                    leading: Icon(
                      rank <= 3 ? medals[rank - 1] : Icons.person,
                      color: rank == 1
                          ? const Color(0xFFFFD700)
                          : rank == 2
                              ? const Color(0xFFC0C0C0)
                              : rank == 3
                                  ? const Color(0xFFCD7F32)
                                  : null,
                    ),
                    title: Text(player.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_drink, color: Color(0xFFFF3B6E), size: 18),
                        const SizedBox(width: 4),
                        Text('${player.drinkCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(nhieGameProvider.notifier).resetGame();
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
                  ref.read(nhieGameProvider.notifier).resetGame();
                  context.go('/nhie');
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

class _PlayingPhase extends StatelessWidget {
  final NHIEGame game;
  final L10n l10n;
  final WidgetRef ref;

  const _PlayingPhase({required this.game, required this.l10n, required this.ref});

  @override
  Widget build(BuildContext context) {
    final statement = game.currentStatement;
    if (statement == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            '${game.currentPlayer.name}${l10n.translate('nhie_player_turn')}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              gradient: const LinearGradient(
                colors: [Color(0xFF6C3CE1), Color(0xFFFF3B6E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: AppTheme.neonGlow,
            ),
            child: Column(
              children: [
                Text(
                  statement.text,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                  ),
                  child: Text(
                    l10n.translate('nhie_category_${statement.category.name}').toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 2,
                        ),
                  ),
                ),
              ],
            ),
          ).animate().scale(
                begin: const Offset(0.9, 0.9),
                duration: AppTheme.normalAnimation,
                curve: Curves.easeOutBack,
              ),
          const Spacer(flex: 2),
          Text(
            l10n.translate('nhie_who_has_done'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Expanded(
            flex: 4,
            child: ListView.builder(
              itemCount: game.players.length,
              itemBuilder: (context, index) {
                final player = game.players[index];
                final didIt = game.playersWhoDidIt.contains(player.id);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: didIt
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                      : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    title: Text(player.name),
                    trailing: didIt
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_drink, color: Color(0xFFFF3B6E), size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${player.drinkCount}',
                                style: const TextStyle(color: Color(0xFFFF3B6E), fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : null,
                    onTap: didIt
                        ? null
                        : () {
                            ref.read(nhieGameProvider.notifier).markPlayerDidIt(player.id);
                            ref.read(hapticServiceProvider).selectionClick();
                            ref.read(audioServiceProvider).playTap();
                          },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(nhieGameProvider.notifier).nextStatement();
                ref.read(audioServiceProvider).playSuccess();
              },
              child: Text(l10n.translate('next')),
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
        ],
      ),
    );
  }
}
