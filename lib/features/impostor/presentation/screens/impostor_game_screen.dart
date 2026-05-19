// ignore_for_file: require_trailing_commas
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/features/impostor/domain/entities/impostor_game.dart';
import 'package:locogames/features/impostor/domain/entities/player.dart';
import 'package:locogames/features/impostor/presentation/providers/impostor_game_provider.dart';
import 'package:locogames/core/providers/shared_providers.dart';

class ImpostorGameScreen extends ConsumerStatefulWidget {
  const ImpostorGameScreen({super.key});

  @override
  ConsumerState<ImpostorGameScreen> createState() => _ImpostorGameScreenState();
}

class _ImpostorGameScreenState extends ConsumerState<ImpostorGameScreen> {
  bool _roleRevealed = false;
  bool _wordRevealed = false;
  int _currentDiscussionTime = 60;
  Timer? _discussionTimer;
  int _revealPlayerIndex = 0;

  @override
  void dispose() {
    _discussionTimer?.cancel();
    super.dispose();
  }

  void _startDiscussionTimer() {
    _currentDiscussionTime = 60;
    _discussionTimer?.cancel();
    _discussionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_currentDiscussionTime > 0) {
          _currentDiscussionTime--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(impostorGameProvider);
    if (game == null) {
      return const Scaffold(body: Center(child: Text('No active game')));
    }

    final viewState = ref.read(impostorGameProvider.notifier).viewState;
    final l10n = L10n.of(context);
    final audio = ref.read(audioServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    ref.listen(impostorGameProvider, (prev, next) {
      if (next == null || prev == null) return;
      if (prev.phase != next.phase) {
        switch (next.phase) {
          case GamePhase.discussion:
            audio.playCountdown();
            break;
          case GamePhase.voting:
            haptic.selectionClick();
            audio.playTap();
            break;
          case GamePhase.results:
            haptic.heavyImpact();
            audio.playSuccess();
            break;
          case GamePhase.gameOver:
            haptic.reveal();
            audio.playReveal();
            break;
          default:
            break;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.translate('impostor_title')} — ${l10n.translate('round')} ${game.currentRound}/${game.settings.totalRounds}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            _discussionTimer?.cancel();
            ref.read(impostorGameProvider.notifier).resetGame();
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
    ImpostorGame game,
    ImpostorViewState viewState,
  ) {
    switch (viewState) {
      case ImpostorViewState.setup:
      case ImpostorViewState.roleReveal:
        return _buildRoleRevealPhase(context, l10n, game);
      case ImpostorViewState.wordReveal:
        return _buildWordRevealPhase(context, l10n, game);
      case ImpostorViewState.discussion:
        return _buildDiscussionPhase(context, l10n, game);
      case ImpostorViewState.voting:
        return _buildVotingPhase(context, l10n, game);
      case ImpostorViewState.results:
        return _buildResultsPhase(context, l10n, game);
      case ImpostorViewState.gameOver:
        return _buildGameOverPhase(context, l10n, game);
    }
  }

  Widget _buildRoleRevealPhase(
      BuildContext context, L10n l10n, ImpostorGame game) {
    if (game.alivePlayers.isEmpty) return const SizedBox.shrink();
    final safeIndex = _revealPlayerIndex.clamp(0, game.alivePlayers.length - 1);
    final player = game.alivePlayers[safeIndex];

    if (!_roleRevealed) {
      return Center(
        key: const ValueKey('role_hidden'),
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
                    setState(() => _roleRevealed = true);
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

    final isImpostor = player.role == PlayerRole.impostor;

    return Center(
      key: const ValueKey('role_revealed'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isImpostor
                      ? const [Color(0xFFFF3B6E), Color(0xFFFF6B8A)]
                      : const [Color(0xFF00D4AA), Color(0xFF00E5C0)],
                ),
              ),
              child: Icon(
                isImpostor ? Icons.visibility_off : Icons.visibility,
                color: Colors.white,
                size: 56,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              isImpostor
                  ? l10n.translate('you_are_impostor')
                  : l10n.translate('you_are_citizen'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_revealPlayerIndex >= game.alivePlayers.length - 1) {
                    ref.read(impostorGameProvider.notifier).revealLocation();
                    setState(() {
                      _roleRevealed = false;
                      _revealPlayerIndex = 0;
                    });
                  } else {
                    setState(() {
                      _roleRevealed = false;
                      _revealPlayerIndex++;
                    });
                  }
                },
                child: Text(l10n.translate('confirm')),
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
          begin: const Offset(0.8, 0.8),
          duration: AppTheme.normalAnimation,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildWordRevealPhase(
      BuildContext context, L10n l10n, ImpostorGame game) {
    if (game.alivePlayers.isEmpty) return const SizedBox.shrink();
    final safeIndex = _revealPlayerIndex.clamp(0, game.alivePlayers.length - 1);
    final player = game.alivePlayers[safeIndex];
    final isImpostor = player.role == PlayerRole.impostor;

    if (!_wordRevealed) {
      return Center(
        key: const ValueKey('word_hidden'),
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
                    setState(() => _wordRevealed = true);
                    ref.read(hapticServiceProvider).lightImpact();
                    ref.read(audioServiceProvider).playTap();
                  },
                  child: Text(l10n.translate('tap_to_reveal')),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      key: const ValueKey('word_revealed'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isImpostor) ...[
              Text(
                l10n.translate('the_location_is'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C3CE1), Color(0xFF8B5CF6)],
                  ),
                ),
                child: Text(
                  game.location ?? '',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ] else ...[
              const Icon(Icons.help_outline, size: 80, color: Color(0xFFFF3B6E)),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                l10n.translate('impostor_doesnt_know'),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppTheme.spacingXXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_revealPlayerIndex >= game.alivePlayers.length - 1) {
                    ref.read(impostorGameProvider.notifier).startDiscussion();
                    _startDiscussionTimer();
                    setState(() {
                      _wordRevealed = false;
                      _revealPlayerIndex = 0;
                    });
                  } else {
                    setState(() {
                      _wordRevealed = false;
                      _revealPlayerIndex++;
                    });
                  }
                },
                child: Text(l10n.translate('confirm')),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.normalAnimation);
  }

  Widget _buildDiscussionPhase(
      BuildContext context, L10n l10n, ImpostorGame game) {
    return Center(
      key: const ValueKey('discussion'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.translate('discussion_phase'),
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              '${l10n.translate('the_location_is')}: ${game.location}',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            Text(
              '${_currentDiscussionTime}s',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: _currentDiscussionTime <= 10
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _discussionTimer?.cancel();
                  ref.read(impostorGameProvider.notifier).startVoting();
                },
                child: Text(l10n.translate('vote_impostor')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingPhase(
      BuildContext context, L10n l10n, ImpostorGame game) {
    final currentVoterIndex = ref.watch(currentPlayerIndexProvider);
    final alivePlayers = game.alivePlayers;
    final currentVoter = currentVoterIndex < alivePlayers.length
        ? alivePlayers[currentVoterIndex]
        : null;

    return Center(
      key: const ValueKey('voting'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.translate('voting_phase'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (currentVoter != null) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                '${currentVoter.name}\'s ${l10n.translate('vote_impostor').toLowerCase()}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
            const SizedBox(height: AppTheme.spacingM),
            Expanded(
              child: ListView.builder(
                itemCount: alivePlayers.length,
                itemBuilder: (context, index) {
                  final player = alivePlayers[index];
                  final canVote = currentVoter != null && player.id != currentVoter.id;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: player.role == PlayerRole.impostor
                            ? const Color(0xFFFF3B6E)
                            : const Color(0xFF6C3CE1),
                        child: Icon(
                          Icons.person,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      title: Text(player.name),
                      trailing: player.votedForId != null
                          ? const Icon(Icons.how_to_vote, color: Color(0xFF00D4AA))
                          : null,
                      enabled: canVote,
                      onTap: canVote
                          ? () {
                              ref
                                  .read(impostorGameProvider.notifier)
                                  .submitVote(player.id);
                              ref.read(hapticServiceProvider).selectionClick();
                              ref.read(audioServiceProvider).playTap();
                            }
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsPhase(
      BuildContext context, L10n l10n, ImpostorGame game) {
    final eliminated = game.eliminatedPlayerId != null
        ? game.players.firstWhere((p) => p.id == game.eliminatedPlayerId)
        : null;

    return Center(
      key: const ValueKey('results'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: game.impostorCaught == true
                      ? const [Color(0xFF00D4AA), Color(0xFF00E5C0)]
                      : const [Color(0xFFFF3B6E), Color(0xFFFF6B8A)],
                ),
              ),
              child: Icon(
                game.impostorCaught == true
                    ? Icons.check_circle
                    : Icons.cancel,
                color: Colors.white,
                size: 56,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              game.impostorCaught == true
                  ? l10n.translate('citizens_win')
                  : l10n.translate('impostor_wins'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            if (eliminated != null) ...[
              const SizedBox(height: AppTheme.spacingM),
              Text(
                '${eliminated.name} ${l10n.translate('eliminated')}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
            const SizedBox(height: AppTheme.spacingXXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(impostorGameProvider.notifier).nextRound();
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
      BuildContext context, L10n l10n, ImpostorGame game) {
    final impostors = game.impostors;
    final impostorWon = !(game.impostorCaught ?? false);

    return Center(
      key: const ValueKey('game_over'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🎉',
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
            Text(
              impostorWon
                  ? l10n.translate('impostor_wins')
                  : l10n.translate('citizens_win'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: impostorWon
                        ? const Color(0xFFFF3B6E)
                        : const Color(0xFF00D4AA),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              '${l10n.translate('location_was')}: ${game.location}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              '${l10n.translate('impostors_were')}: ${impostors.map((p) => p.name).join(', ')}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(impostorGameProvider.notifier).resetGame();
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
                  ref.read(impostorGameProvider.notifier).resetGame();
                  context.go('/impostor');
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
