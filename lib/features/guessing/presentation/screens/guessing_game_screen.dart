// ignore_for_file: require_trailing_commas
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/features/guessing/domain/entities/guessing_game.dart';
import 'package:locogames/features/guessing/presentation/providers/guessing_game_provider.dart';
import 'package:locogames/core/providers/shared_providers.dart';

class GuessingGameScreen extends ConsumerStatefulWidget {
  const GuessingGameScreen({super.key});

  @override
  ConsumerState<GuessingGameScreen> createState() => _GuessingGameScreenState();
}

class _GuessingGameScreenState extends ConsumerState<GuessingGameScreen> {
  final _guessController = TextEditingController();
  bool _questionRevealed = false;

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(guessingGameProvider);
    final l10n = L10n.of(context);
    final audio = ref.read(audioServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    ref.listen(guessingGameProvider, (prev, next) {
      if (next == null || prev == null) return;
      if (prev.phase != next.phase) {
        switch (next.phase) {
          case GuessingGamePhase.results:
            haptic.heavyImpact();
            audio.playSuccess();
            break;
          case GuessingGamePhase.gameOver:
            haptic.reveal();
            audio.playReveal();
            break;
          default:
            break;
        }
      }
    });

    if (game == null) {
      return Scaffold(
        body: Center(child: Text(l10n.translate('no_active_game'))),
      );
    }

    final viewState = ref.read(guessingGameProvider.notifier).viewState;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.translate('guessing_title')} — ${l10n.translate('round')} ${game.currentRound}/${game.settings.totalRounds}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            ref.read(guessingGameProvider.notifier).resetGame();
            context.go('/home');
          },
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppTheme.normalAnimation,
          child: _buildPhaseContent(context, l10n, game, viewState),
        ),
      ),
    );
  }

  Widget _buildPhaseContent(
    BuildContext context,
    L10n l10n,
    GuessingGame game,
    GuessingViewState viewState,
  ) {
    switch (viewState) {
      // GuessingViewState.setup is unreachable on this screen (startGame
      // advances to answering immediately) — kept for switch exhaustiveness.
      case GuessingViewState.setup:
      case GuessingViewState.answering:
        return _buildAnsweringPhase(context, l10n, game);
      case GuessingViewState.results:
        return _buildResultsPhase(context, l10n, game);
      case GuessingViewState.gameOver:
        return _buildGameOverPhase(context, l10n, game);
    }
  }

  Widget _buildAnsweringPhase(
    BuildContext context, L10n l10n, GuessingGame game,
  ) {
    final playerIndex = ref.watch(guessingPlayerIndexProvider);
    if (playerIndex >= game.players.length) return const SizedBox.shrink();
    final player = game.players[playerIndex];

    if (!_questionRevealed) {
      return Center(
        key: const ValueKey('question_hidden'),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${l10n.translate('pass_phone')}\n\n${player.name}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacingXXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _questionRevealed = true);
                    ref.read(hapticServiceProvider).reveal();
                    ref.read(audioServiceProvider).playReveal();
                  },
                  child: Text(l10n.translate('tap_to_reveal')),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: AppTheme.normalAnimation);
    }

    return Center(
      key: const ValueKey('question_revealed'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              player.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4AA), Color(0xFF00E5C0)],
                ),
              ),
              child: Text(
                game.currentQuestion?.text ?? '',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            Text(
              l10n.translate('your_answer'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextField(
              controller: _guessController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return newValue.text.isEmpty ||
                          RegExp(r'^\d*\.?\d*$').hasMatch(newValue.text)
                      ? newValue
                      : oldValue;
                }),
              ],
              decoration: InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final guess = double.tryParse(_guessController.text);
                  if (guess == null) return;
                  ref.read(guessingGameProvider.notifier).submitGuess(guess);
                  ref.read(hapticServiceProvider).selectionClick();
                  ref.read(audioServiceProvider).playTap();
                  _guessController.clear();
                  setState(() => _questionRevealed = false);
                },
                child: Text(l10n.translate('submit_guess')),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.normalAnimation);
  }

  Widget _buildResultsPhase(
    BuildContext context, L10n l10n, GuessingGame game,
  ) {
    final question = game.currentQuestion;
    final winners = game.players
        .where((p) => game.roundWinnerIds.contains(p.id))
        .toList();
    final winnerBanner = winners.isEmpty
        ? null
        : winners.length == 1
            ? '${winners.first.name} ${l10n.translate('wins_the_round')}'
            : l10n.translate('its_a_tie');

    return Center(
      key: const ValueKey('results'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF6C3CE1), Color(0xFF8B5CF6)],
                ),
              ),
              child: const Icon(Icons.emoji_events, color: Colors.white, size: 56),
            ),
            const SizedBox(height: AppTheme.spacingL),
            if (winnerBanner != null) ...[
              Text(
                winnerBanner,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                '${l10n.translate('closest_guess')}!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
            if (question != null) ...[
              const SizedBox(height: AppTheme.spacingM),
              Text(
                '${l10n.translate('correct_answer_was')}: ${_formatNumber(question.answer)} ${question.unit}',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                question.funFact,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppTheme.spacingL),
            ...game.sortedByScore.take(5).map((p) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      game.roundWinnerIds.contains(p.id)
                          ? Icons.emoji_events
                          : Icons.person,
                      color: game.roundWinnerIds.contains(p.id)
                          ? const Color(0xFFFFD700)
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 24,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Expanded(child: Text(p.name, style: Theme.of(context).textTheme.bodyLarge)),
                    Text(
                      '${p.score} pts',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppTheme.spacingXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(guessingGameProvider.notifier).nextRound();
                  setState(() => _questionRevealed = false);
                },
                child: Text(l10n.translate('next')),
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
          begin: const Offset(0.5, 0.5),
          duration: AppTheme.slowAnimation,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildGameOverPhase(
    BuildContext context, L10n l10n, GuessingGame game,
  ) {
    final topPlayers = game.sortedByScore;

    return Center(
      key: const ValueKey('game_over'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\u{1F389}',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              l10n.translate('game_over'),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (topPlayers.isNotEmpty) ...[
              Text(
                '${l10n.translate('winner')}: ${topPlayers.first.name}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                '${topPlayers.first.score} ${l10n.translate('score').toLowerCase()}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
            const SizedBox(height: AppTheme.spacingL),
            ...topPlayers.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final player = entry.value;
              final medals = [Icons.emoji_events, Icons.workspace_premium, Icons.military_tech];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      rank <= 3 ? medals[rank - 1] : Icons.person,
                      color: rank == 1
                          ? const Color(0xFFFFD700)
                          : rank == 2
                              ? const Color(0xFFC0C0C0)
                              : rank == 3
                                  ? const Color(0xFFCD7F32)
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 28,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Expanded(child: Text(player.name, style: Theme.of(context).textTheme.bodyLarge)),
                    Text(
                      '${player.score}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppTheme.spacingXXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(guessingGameProvider.notifier).resetGame();
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
                  ref.read(guessingGameProvider.notifier).resetGame();
                  context.go('/guessing');
                },
                child: Text(l10n.translate('play_again')),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.slowAnimation);
  }

  String _formatNumber(double value) {
    // The correct answer is shown verbatim next to a precise fun fact, so it
    // must never be lossily rounded (e.g. 299792 -> "300k"). Use thousands
    // grouping and keep up to two decimals only when the value is fractional.
    if (value == value.roundToDouble()) {
      return NumberFormat.decimalPattern().format(value.toInt());
    }
    return NumberFormat('#,##0.##').format(value);
  }
}
