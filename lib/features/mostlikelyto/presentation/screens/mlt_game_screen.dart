import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/features/mostlikelyto/domain/entities/mlt_game.dart';
import 'package:locogames/features/mostlikelyto/presentation/providers/mlt_provider.dart';
import 'package:locogames/core/providers/shared_providers.dart';

class MLTGameScreen extends ConsumerWidget {
  const MLTGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(mltGameProvider);
    final l10n = L10n.of(context);
    final audio = ref.read(audioServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    ref.listen(mltGameProvider, (prev, next) {
      if (next == null || prev == null) return;
      if (prev.phase != MLTPhase.results && next.phase == MLTPhase.results) {
        haptic.reveal();
        audio.playReveal();
      }
      if (prev.phase != MLTPhase.gameOver && next.phase == MLTPhase.gameOver) {
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
          '${l10n.translate('most_likely_to_title')} — ${l10n.translate('round')} ${game.currentRound}/${game.settings.totalRounds}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            ref.read(mltGameProvider.notifier).resetGame();
            context.go('/home');
          },
        ),
      ),
      body: SafeArea(
        child: game.phase == MLTPhase.gameOver
            ? _buildGameOver(context, ref, l10n, game)
            : game.phase == MLTPhase.results
                ? _ResultsPhase(game: game, l10n: l10n, ref: ref)
                : _VotingPhase(game: game, l10n: l10n, ref: ref),
      ),
    );
  }

  Widget _buildGameOver(BuildContext context, WidgetRef ref, L10n l10n, MLTGame game) {
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
                  ref.read(mltGameProvider.notifier).resetGame();
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
                  ref.read(mltGameProvider.notifier).resetGame();
                  context.go('/mlt');
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

class _VotingPhase extends StatelessWidget {
  final MLTGame game;
  final L10n l10n;
  final WidgetRef ref;

  const _VotingPhase({required this.game, required this.l10n, required this.ref});

  @override
  Widget build(BuildContext context) {
    final voter = game.currentVoter;
    final voted = game.playersWhoHaveVoted;

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          const Spacer(flex: 1),
          Text(
            '${voter.name}${l10n.translate('nhie_player_turn')}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            l10n.translate('most_likely_to_vote_for'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              gradient: const LinearGradient(
                colors: [Color(0xFF00838F), Color(0xFF26C6DA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: AppTheme.neonGlow,
            ),
            child: Text(
              game.currentPrompt?.text ?? '',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ).animate().scale(
                begin: const Offset(0.9, 0.9),
                duration: AppTheme.normalAnimation,
                curve: Curves.easeOutBack,
              ),
          const Spacer(flex: 1),
          Text(
            '${voted.length}/${game.players.length} ${l10n.translate('waiting_for_players')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: game.players.length,
              itemBuilder: (context, index) {
                final player = game.players[index];
                final voteCount = game.currentVotes[player.id] ?? 0;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    title: Text(player.name),
                    trailing: voteCount > 0
                        ? Text(
                            '$voteCount ${l10n.translate('most_likely_to_votes')}',
                            style: const TextStyle(color: Color(0xFF00838F), fontWeight: FontWeight.bold),
                          )
                        : null,
                    onTap: () {
                      ref.read(mltGameProvider.notifier).castVote(player.id);
                      ref.read(hapticServiceProvider).selectionClick();
                      ref.read(audioServiceProvider).playTap();
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
        ],
      ),
    );
  }
}

class _ResultsPhase extends StatelessWidget {
  final MLTGame game;
  final L10n l10n;
  final WidgetRef ref;

  const _ResultsPhase({required this.game, required this.l10n, required this.ref});

  @override
  Widget build(BuildContext context) {
    final winnerId = game.winnerId;
    final winner = winnerId != null
        ? game.players.where((p) => p.id == winnerId).firstOrNull
        : null;

    final sortedVotes = game.currentVotes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          const Spacer(flex: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              gradient: const LinearGradient(
                colors: [Color(0xFF00838F), Color(0xFF26C6DA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: AppTheme.neonGlow,
            ),
            child: Column(
              children: [
                Text(
                  game.currentPrompt?.text ?? '',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingL),
                if (winner != null) ...[
                  const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 48),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    winner.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    '${winner.name} ${l10n.translate('most_likely_to_drinks')}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                ] else
                  Text(
                    l10n.translate('its_a_tie'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
              ],
            ),
          ).animate().scale(
                begin: const Offset(0.9, 0.9),
                duration: AppTheme.normalAnimation,
                curve: Curves.easeOutBack,
              ),
          const Spacer(flex: 1),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: sortedVotes.length,
              itemBuilder: (context, index) {
                final entry = sortedVotes[index];
                final player = game.players.firstWhere((p) => p.id == entry.key);
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text(player.name),
                  trailing: Text(
                    '${entry.value} ${l10n.translate('most_likely_to_votes')}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                ref.read(mltGameProvider.notifier).nextRound();
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
