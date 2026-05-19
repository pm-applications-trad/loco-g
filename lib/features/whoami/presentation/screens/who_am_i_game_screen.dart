import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/features/whoami/domain/entities/who_am_i_game.dart';
import 'package:locogames/features/whoami/presentation/providers/who_am_i_provider.dart';
import 'package:locogames/core/providers/shared_providers.dart';

class WhoAmIGameScreen extends ConsumerStatefulWidget {
  const WhoAmIGameScreen({super.key});

  @override
  ConsumerState<WhoAmIGameScreen> createState() => _WhoAmIGameScreenState();
}

class _WhoAmIGameScreenState extends ConsumerState<WhoAmIGameScreen> {
  final _questionController = TextEditingController();
  final _guessController = TextEditingController();
  int _answerIndex = 0;
  int _guessIndex = 0;
  bool _subjectRevealed = false;
  String? _lastIdentityName;

  @override
  void dispose() {
    _questionController.dispose();
    _guessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(whoAmIGameProvider);
    final l10n = L10n.of(context);
    final audio = ref.read(audioServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    ref.listen(whoAmIGameProvider, (prev, next) {
      if (next == null || prev == null) return;
      if (prev.phase != next.phase) {
        switch (next.phase) {
          case WhoAmIPhase.results:
            haptic.heavyImpact();
            audio.playSuccess();
            break;
          case WhoAmIPhase.gameOver:
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

    final viewState = ref.watch(whoAmIViewStateProvider);

    if (game.currentIdentity?.name != _lastIdentityName) {
      _lastIdentityName = game.currentIdentity?.name;
      _subjectRevealed = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.translate('who_am_i_title')} — ${l10n.translate('round')} ${game.currentRound}/${game.settings.totalRounds}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            ref.read(whoAmIGameProvider.notifier).resetGame();
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
    WhoAmIGame game,
    WhoAmIViewState viewState,
  ) {
    switch (viewState) {
      case WhoAmIViewState.setup:
        return const SizedBox.shrink();
      case WhoAmIViewState.subjectReveal:
        return _buildSubjectReveal(context, l10n, game);
      case WhoAmIViewState.questioning:
        return _buildQuestioningPhase(context, l10n, game);
      case WhoAmIViewState.answering:
        return _buildAnsweringPhase(context, l10n, game);
      case WhoAmIViewState.guessing:
        return _buildGuessingPhase(context, l10n, game);
      case WhoAmIViewState.results:
        return _buildResultsPhase(context, l10n, game);
      case WhoAmIViewState.gameOver:
        return _buildGameOverPhase(context, l10n, game);
    }
  }

  Widget _buildSubjectReveal(
    BuildContext context, L10n l10n, WhoAmIGame game,
  ) {
    if (!_subjectRevealed) {
      final subject = game.players[game.subjectIndex];

      return Center(
        key: const ValueKey('subject_hidden'),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${l10n.translate('pass_phone')}\n\n${subject.name}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacingXXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _subjectRevealed = true);
                    ref.read(hapticServiceProvider).reveal();
                    ref.read(audioServiceProvider).playReveal();
                  },
                  child: Text(l10n.translate('tap_to_reveal')),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildSubjectRevealedContent(context, l10n, game);
  }

  Widget _buildSubjectRevealedContent(
    BuildContext context, L10n l10n, WhoAmIGame game,
  ) {
    final identity = game.currentIdentity;

    return Center(
      key: const ValueKey('subject_revealed'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
                ),
              ),
              child: const Icon(Icons.face, color: Colors.white, size: 40),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              l10n.translate('you_are'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              identity?.name ?? '',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF6B35),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingS),
            if (identity?.category != null)
              Text(
                '${identity!.category}: ${identity.hint}',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: AppTheme.spacingXXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(whoAmIGameProvider.notifier).advanceFromSubjectReveal();
                },
                child: Text(l10n.translate('continue')),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.normalAnimation);
  }

  Widget _buildQuestioningPhase(
    BuildContext context, L10n l10n, WhoAmIGame game,
  ) {
    final nonSubjects = game.nonSubjectPlayers;
    final questionIndex = game.questionerIndex;

    if (questionIndex < nonSubjects.length) {
      final player = nonSubjects[questionIndex];
      return Center(
        key: ValueKey('questioning_$questionIndex'),
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
              const SizedBox(height: AppTheme.spacingL),
              Text(
                l10n.translate('ask_question'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextField(
                controller: _questionController,
                textAlign: TextAlign.center,
                maxLength: 120,
                decoration: InputDecoration(
                  hintText: l10n.translate('question_hint'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_questionController.text.trim().isEmpty) return;
                    ref.read(whoAmIGameProvider.notifier).askQuestion(
                          _questionController.text.trim(),
                        );
                    _questionController.clear();
                  },
                  child: Text(l10n.translate('send')),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: AppTheme.normalAnimation);
    }

    return Center(
      key: const ValueKey('pass_to_subject'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${l10n.translate('pass_phone')}\n\n${game.players[game.subjectIndex].name}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              l10n.translate('answer_questions'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingXXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _answerIndex = 0;
                  ref.read(whoAmIViewStateProvider.notifier).state = WhoAmIViewState.answering;
                },
                child: Text(l10n.translate('answer_questions')),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.normalAnimation);
  }

  Widget _buildAnsweringPhase(
    BuildContext context, L10n l10n, WhoAmIGame game,
  ) {
    final nonSubjects = game.nonSubjectPlayers;
    if (_answerIndex >= nonSubjects.length) {
      return Center(
        key: const ValueKey('answer_done'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.translate('answered_all'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingXXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _guessIndex = 0);
                  ref.read(whoAmIViewStateProvider.notifier).state = WhoAmIViewState.guessing;
                },
                child: Text(l10n.translate('continue')),
              ),
            ),
          ],
        ),
      );
    }

    final player = nonSubjects[_answerIndex];
    return Center(
      key: ValueKey('answering_$_answerIndex'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
                ),
              ),
              child: Text(
                '${player.name}: ${player.currentQuestion ?? ''}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXXL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(whoAmIGameProvider.notifier).answerQuestion(player.id, true);
                      setState(() => _answerIndex++);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D4AA),
                    ),
                    child: Text(l10n.translate('yes')),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(whoAmIGameProvider.notifier).answerQuestion(player.id, false);
                      setState(() => _answerIndex++);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B6E),
                    ),
                    child: Text(l10n.translate('no')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.normalAnimation);
  }

  Widget _buildGuessingPhase(
    BuildContext context, L10n l10n, WhoAmIGame game,
  ) {
    final nonSubjects = game.nonSubjectPlayers;

    if (_guessIndex >= nonSubjects.length) {
      return Center(
        key: const ValueKey('waiting_results'),
        child: Text(
          l10n.translate('revealing'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ).animate().fadeIn(duration: AppTheme.normalAnimation);
    }

    final player = nonSubjects[_guessIndex];
    return Center(
      key: ValueKey('guessing_$_guessIndex'),
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
            Text(
              l10n.translate('who_am_i_guess'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextField(
              controller: _guessController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: l10n.translate('guess_hint'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    if (_guessController.text.trim().isEmpty) return;
                    ref.read(whoAmIGameProvider.notifier).submitGuess(
                          _guessController.text.trim(),
                        );
                    ref.read(hapticServiceProvider).selectionClick();
                    ref.read(audioServiceProvider).playTap();
                    _guessController.clear();
                    setState(() => _guessIndex++);
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
    BuildContext context, L10n l10n, WhoAmIGame game,
  ) {
    final identity = game.currentIdentity;
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
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
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
            ],
            if (winners.isEmpty)
              Text(
                l10n.translate('no_one_guessed'),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            if (identity != null) ...[
              const SizedBox(height: AppTheme.spacingM),
              Text(
                '${l10n.translate('identity_was')}: ${identity.name}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                '${identity.category}: ${identity.hint}',
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
                  _answerIndex = 0;
                  _guessIndex = 0;
                  ref.read(whoAmIGameProvider.notifier).nextRound();
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
    BuildContext context, L10n l10n, WhoAmIGame game,
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
                  ref.read(whoAmIGameProvider.notifier).resetGame();
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
                  ref.read(whoAmIGameProvider.notifier).resetGame();
                  context.go('/whoami');
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
