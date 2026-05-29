import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/core/router/app_router.dart';
import 'package:locogames/features/ridethebus/domain/entities/ride_the_bus_game.dart';
import 'package:locogames/features/ridethebus/domain/entities/card_model.dart';
import 'package:locogames/features/ridethebus/presentation/providers/ride_the_bus_provider.dart';
import 'package:locogames/core/providers/shared_providers.dart';

class RideTheBusGameScreen extends ConsumerWidget {
  const RideTheBusGameScreen({super.key});

  static const List<Color> bgGradient = [
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
    Color(0xFF0F3460),
    Color(0xFF4A148C),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(rideTheBusGameProvider);
    final audio = ref.read(audioServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    ref.listen(rideTheBusGameProvider, (prev, next) {
      if (next == null || prev == null) return;
      if (prev.lastGuessCorrect != next.lastGuessCorrect) {
        if (next.lastGuessCorrect == true) {
          audio.playTap();
        } else if (next.lastGuessCorrect == false) {
          haptic.reveal();
          audio.playReveal();
        }
      }
    });

    if (game == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: bgGradient[0],
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: AppTheme.normalAnimation,
            child: _buildBody(context, ref, game),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppTheme.spacingS,
            left: AppTheme.spacingS,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () {
                ref.read(rideTheBusGameProvider.notifier).resetGame();
                ref.read(appRouterProvider).go('/home');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, RideTheBusGame game) {
    switch (game.phase) {
      case RTBPhase.roundIntro:
        return _RoundIntroPhase(key: const ValueKey('intro'), game: game, ref: ref);
      case RTBPhase.guessing:
        return _GuessingPhase(key: const ValueKey('guessing'), game: game, ref: ref);
      case RTBPhase.result:
        return _ResultPhase(key: const ValueKey('result'), game: game, ref: ref);
      case RTBPhase.playerTransition:
        return _PlayerTransitionPhase(key: const ValueKey('transition'), game: game, ref: ref);
      case RTBPhase.gameOver:
        return _GameOverPhase(key: const ValueKey('gameover'), game: game, ref: ref);
      case RTBPhase.setup:
        return const SizedBox.shrink();
    }
  }
}

class _RoundIntroPhase extends StatelessWidget {
  final RideTheBusGame game;
  final WidgetRef ref;

  const _RoundIntroPhase({super.key, required this.game, required this.ref});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final roundIndex = game.currentRoundIndex();
    final roundNames = [
      l10n.translate('rtb_red_or_black'),
      l10n.translate('rtb_higher_or_lower'),
      l10n.translate('rtb_inside_or_outside'),
      l10n.translate('rtb_guess_the_suit'),
    ];

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPlayerHeader(context, l10n),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingXL),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: RideTheBusGameScreen.bgGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFAB47BC).withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${l10n.translate('round')} ${roundIndex + 1} ${l10n.translate('of')} 4',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      roundNames[roundIndex],
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildPyramidPreview(context, game),
              const SizedBox(height: AppTheme.spacingXL),
              FilledButton.icon(
                onPressed: () {
                  ref.read(rideTheBusGameProvider.notifier).setGuessing();
                  ref.read(hapticServiceProvider).selectionClick();
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.translate('continue')),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL,
                    vertical: AppTheme.spacingM,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.normalAnimation);
  }

  Widget _buildPyramidPreview(BuildContext context, RideTheBusGame game) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: game.pyramid.asMap().entries.map((entry) {
        final rowIndex = entry.key;
        final row = entry.value;
        final isCurrentRow = rowIndex == game.currentRoundIndex();

        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.asMap().entries.map((slotEntry) {
              final slotIndex = slotEntry.key;
              final slot = slotEntry.value;
              final isCurrentSlot = isCurrentRow && slotIndex == game.roundStep && game.phase == RTBPhase.guessing;

              return Container(
                width: 48,
                height: 64,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isCurrentSlot
                      ? const Color(0xFF7B1FA2)
                      : isCurrentRow
                          ? const Color(0xFF4A148C).withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: isCurrentSlot
                      ? Border.all(color: const Color(0xFFAB47BC), width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '?',
                    style: TextStyle(
                      color: isCurrentRow ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerHeader(BuildContext context, L10n l10n) {
    if (game.players.length <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: game.players.map((player) {
          final isCurrent = player.id == game.currentPlayer.id;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? const Color(0xFF7B1FA2) : Colors.white.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.person,
                  color: isCurrent ? Colors.white : Colors.white54,
                  size: 18,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                player.name,
                style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.white54,
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                '${l10n.translate('drinks_short')}: ${player.penaltyDrinks}',
                style: TextStyle(
                  color: Colors.amber.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _GuessingPhase extends StatelessWidget {
  final RideTheBusGame game;
  final WidgetRef ref;

  const _GuessingPhase({super.key, required this.game, required this.ref});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          children: [
            const SizedBox(height: AppTheme.spacingL),
            _buildPlayerHeader(context, l10n),
            const Spacer(),
            _buildCurrentCardIndicator(context, game),
            const SizedBox(height: AppTheme.spacingL),
            _buildGuessButtons(context, l10n),
            const Spacer(),
            _buildPyramidStatus(context, game),
            const SizedBox(height: AppTheme.spacingM),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.normalAnimation);
  }

  Widget _buildCurrentCardIndicator(BuildContext context, RideTheBusGame game) {
    final l10n = L10n.of(context);

    return Column(
      children: [
        Text(
          '${l10n.translate('rtb_your_turn')}, ${game.currentPlayer.name}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFF7B1FA2).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: const Color(0xFFAB47BC).withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: const Center(
            child: Text(
              '?',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          '${l10n.translate('round')} ${game.currentRoundIndex() + 1} ${l10n.translate('of')} 4 — ${l10n.translate('card')} ${game.roundStep + 1} ${l10n.translate('of')} ${game.cardsInCurrentRow()}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
              ),
        ),
      ],
    );
  }

  Widget _buildGuessButtons(BuildContext context, L10n l10n) {
    final round = game.currentRound;
    final buttons = <Widget>[];

    switch (round) {
      case RTBRound.redOrBlack:
        buttons.addAll([
          _GuessButton(
            label: l10n.translate('rtb_guess_red'),
            icon: Icons.favorite,
            isRed: true,
            onTap: () => _submitGuess(ref, 'red'),
          ),
          _GuessButton(
            label: l10n.translate('rtb_guess_black'),
            icon: Icons.favorite_border,
            isRed: false,
            onTap: () => _submitGuess(ref, 'black'),
          ),
        ]);
        break;

      case RTBRound.higherOrLower:
        final aboveCard = game.getCardAbove(game.currentRoundIndex(), game.roundStep);
        if (aboveCard != null) {
          buttons.add(_AboveCardIndicator(card: aboveCard, l10n: l10n));
        }
        buttons.addAll([
          _GuessButton(
            label: l10n.translate('rtb_guess_higher'),
            icon: Icons.arrow_upward,
            onTap: () => _submitGuess(ref, 'higher'),
          ),
          _GuessButton(
            label: l10n.translate('rtb_guess_lower'),
            icon: Icons.arrow_downward,
            onTap: () => _submitGuess(ref, 'lower'),
          ),
        ]);
        break;

      case RTBRound.insideOrOutside:
        final firstCard = game.getCardAbove(game.currentRoundIndex(), game.roundStep);
        final secondCard = game.getSecondCardAbove(game.currentRoundIndex(), game.roundStep);
        if (firstCard != null && secondCard != null) {
          buttons.add(_InsideOutsideInfo(card1: firstCard, card2: secondCard, l10n: l10n));
        }
        buttons.addAll([
          _GuessButton(
            label: l10n.translate('rtb_guess_inside'),
            icon: Icons.arrow_right_alt,
            onTap: () => _submitGuess(ref, 'inside'),
          ),
          _GuessButton(
            label: l10n.translate('rtb_guess_outside'),
            icon: Icons.open_in_full,
            onTap: () => _submitGuess(ref, 'outside'),
          ),
        ]);
        break;

      case RTBRound.suitGuess:
        buttons.addAll([
          _GuessButton(
            label: '♥',
            icon: Icons.favorite,
            isHearts: true,
            onTap: () => _submitGuess(ref, 'hearts'),
          ),
          _GuessButton(
            label: '♦',
            icon: Icons.diamond,
            isDiamonds: true,
            onTap: () => _submitGuess(ref, 'diamonds'),
          ),
          _GuessButton(
            label: '♣',
            icon: Icons.park,
            onTap: () => _submitGuess(ref, 'clubs'),
          ),
          _GuessButton(
            label: '♠',
            icon: Icons.auto_awesome,
            onTap: () => _submitGuess(ref, 'spades'),
          ),
        ]);
        break;
    }

    return Wrap(
      spacing: AppTheme.spacingM,
      runSpacing: AppTheme.spacingM,
      alignment: WrapAlignment.center,
      children: buttons,
    );
  }

  void _submitGuess(WidgetRef ref, String guess) {
    ref.read(rideTheBusGameProvider.notifier).submitGuess(guess);
    ref.read(audioServiceProvider).playTap();
  }

  Widget _buildPyramidStatus(BuildContext context, RideTheBusGame game) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: game.pyramid.asMap().entries.map((entry) {
        final rowIndex = entry.key;
        final row = entry.value;
        final isCurrentRow = rowIndex == game.currentRoundIndex();
        final isPastRow = rowIndex < game.currentRoundIndex();

        return Opacity(
          opacity: isCurrentRow || isPastRow ? 1.0 : 0.3,
          child: Container(
            margin: const EdgeInsets.only(bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.asMap().entries.map((slotEntry) {
                final slotIndex = slotEntry.key;
                final slot = slotEntry.value;
                final isActiveSlot = isCurrentRow && slotIndex == game.roundStep;

                return Container(
                  width: 44,
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: isActiveSlot
                        ? const Color(0xFF7B1FA2)
                        : slot.revealed
                            ? const Color(0xFF1B5E20).withValues(alpha: 0.5)
                            : isCurrentRow
                                ? const Color(0xFF4A148C).withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: isActiveSlot
                        ? Border.all(color: const Color(0xFFAB47BC), width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      slot.revealed ? slot.card?.displayName ?? '?' : '?',
                      style: TextStyle(
                        color: isActiveSlot || slot.revealed ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerHeader(BuildContext context, L10n l10n) {
    if (game.players.length <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: game.players.map((player) {
          final isCurrent = player.id == game.currentPlayer.id;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? const Color(0xFF7B1FA2) : Colors.white.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.person,
                  color: isCurrent ? Colors.white : Colors.white54,
                  size: 18,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                player.name,
                style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.white54,
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                '${l10n.translate('drinks_short')}: ${player.penaltyDrinks}',
                style: TextStyle(
                  color: Colors.amber.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ResultPhase extends StatelessWidget {
  final RideTheBusGame game;
  final WidgetRef ref;

  const _ResultPhase({super.key, required this.game, required this.ref});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final correct = game.lastGuessCorrect ?? false;
    final card = game.currentCard;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPlayerHeader(context, l10n),
              const Spacer(),
              AnimatedContainer(
                duration: AppTheme.normalAnimation,
                padding: const EdgeInsets.all(AppTheme.spacingXL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: correct
                        ? [const Color(0xFF1B5E20), const Color(0xFF4CAF50)]
                        : [const Color(0xFFB71C1C), const Color(0xFFFF5252)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: (correct ? Colors.green : Colors.red).withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      correct ? Icons.check_circle : Icons.cancel,
                      size: 72,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      correct ? l10n.translate('rtb_correct') : l10n.translate('rtb_wrong'),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (card != null) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        card.displayName,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                    if (!correct) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        game.currentRound == RTBRound.suitGuess
                            ? l10n.translate('rtb_ride_the_bus_penalty')
                            : '${game.currentRoundIndex() + 1} ${l10n.translate('rtb_drink_penalty')}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              _buildPyramidStatus(context, game),
              const SizedBox(height: AppTheme.spacingXL),
              FilledButton.icon(
                onPressed: () {
                  ref.read(rideTheBusGameProvider.notifier).advance();
                  ref.read(hapticServiceProvider).selectionClick();
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.translate('continue')),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL,
                    vertical: AppTheme.spacingM,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    ).animate().scale(
          duration: AppTheme.normalAnimation,
          begin: const Offset(0.9, 0.9),
          curve: Curves.elasticOut,
        );
  }

  Widget _buildPyramidStatus(BuildContext context, RideTheBusGame game) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: game.pyramid.asMap().entries.map((entry) {
        final rowIndex = entry.key;
        final row = entry.value;
        final isCurrentRow = rowIndex == game.currentRoundIndex();
        final isPastRow = rowIndex < game.currentRoundIndex();

        return Opacity(
          opacity: isCurrentRow || isPastRow ? 1.0 : 0.3,
          child: Container(
            margin: const EdgeInsets.only(bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.asMap().entries.map((slotEntry) {
                final slot = slotEntry.value;

                return Container(
                  width: 44,
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: slot.revealed
                        ? const Color(0xFF1B5E20).withValues(alpha: 0.5)
                        : isCurrentRow
                            ? const Color(0xFF4A148C).withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Center(
                    child: Text(
                      slot.revealed ? slot.card?.displayName ?? '?' : '?',
                      style: TextStyle(
                        color: slot.revealed || isCurrentRow ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerHeader(BuildContext context, L10n l10n) {
    if (game.players.length <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: game.players.map((player) {
          final isCurrent = player.id == game.currentPlayer.id;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? const Color(0xFF7B1FA2) : Colors.white.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.person,
                  color: isCurrent ? Colors.white : Colors.white54,
                  size: 18,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                player.name,
                style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.white54,
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                '${l10n.translate('drinks_short')}: ${player.penaltyDrinks}',
                style: TextStyle(
                  color: Colors.amber.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _PlayerTransitionPhase extends StatelessWidget {
  final RideTheBusGame game;
  final WidgetRef ref;

  const _PlayerTransitionPhase({super.key, required this.game, required this.ref});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final nextPlayer = game.currentPlayerIndex < game.players.length ? game.players[game.currentPlayerIndex] : null;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_android, size: 64, color: Colors.white54),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                l10n.translate('rtb_pass_phone'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              ),
              if (nextPlayer != null) ...[
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  nextPlayer.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
              const SizedBox(height: AppTheme.spacingXL),
              FilledButton.icon(
                onPressed: () {
                  ref.read(rideTheBusGameProvider.notifier).setGuessing();
                  ref.read(hapticServiceProvider).selectionClick();
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.translate('continue')),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL,
                    vertical: AppTheme.spacingM,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.normalAnimation);
  }
}

class _GameOverPhase extends StatelessWidget {
  final RideTheBusGame game;
  final WidgetRef ref;

  const _GameOverPhase({super.key, required this.game, required this.ref});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final sortedPlayers = game.sortedByPenalties;
    final busRider = game.busRider;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          children: [
            const SizedBox(height: AppTheme.spacingXL),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events, size: 64, color: Colors.white),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    l10n.translate('game_over'),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (busRider != null) ...[
                    const SizedBox(height: AppTheme.spacingL),
                    const Icon(Icons.directions_bus, size: 48, color: Colors.white),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      busRider.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      l10n.translate('rtb_rides_the_bus'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                  if (busRider == null) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      l10n.translate('rtb_no_penalties'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            Text(
              l10n.translate('leaderboard'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            ...List.generate(sortedPlayers.length, (i) {
              final player = sortedPlayers[i];
              final medal = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '${i + 1}';
              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: player.hasRiddenTheBus
                      ? Colors.red.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    Text(medal, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: AppTheme.spacingS),
                    Expanded(
                      child: Text(
                        player.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Text(
                      '${l10n.translate('rtb_penalties')}: ${player.penaltyDrinks}',
                      style: TextStyle(
                        color: Colors.amber.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppTheme.spacingXL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(rideTheBusGameProvider.notifier).resetGame();
                    ref.read(appRouterProvider).go('/home');
                  },
                  icon: const Icon(Icons.home),
                  label: Text(l10n.translate('main_menu')),
                ),
                FilledButton.icon(
                  onPressed: () {
                    ref.read(rideTheBusGameProvider.notifier).resetGame();
                    ref.read(appRouterProvider).go('/ridebus');
                  },
                  icon: const Icon(Icons.replay),
                  label: Text(l10n.translate('play_again')),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.normalAnimation);
  }
}

class _GuessButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isRed;
  final bool isHearts;
  final bool isDiamonds;

  const _GuessButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isRed = false,
    this.isHearts = false,
    this.isDiamonds = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    if (isRed) {
      bgColor = const Color(0xFFB71C1C);
    } else if (isHearts) {
      bgColor = const Color(0xFFD32F2F);
    } else if (isDiamonds) {
      bgColor = const Color(0xFFE65100);
    } else {
      bgColor = const Color(0xFF4A148C);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingM,
          horizontal: AppTheme.spacingM,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor, bgColor.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
          duration: AppTheme.fastAnimation,
          begin: const Offset(0.95, 0.95),
          curve: Curves.easeOutBack,
        );
  }
}

class _AboveCardIndicator extends StatelessWidget {
  final PlayingCard card;
  final L10n l10n;

  const _AboveCardIndicator({super.key, required this.card, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.translate('rtb_current_card'),
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            card.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsideOutsideInfo extends StatelessWidget {
  final PlayingCard card1;
  final PlayingCard card2;
  final L10n l10n;

  const _InsideOutsideInfo({
    super.key,
    required this.card1,
    required this.card2,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.translate('rtb_current_card'),
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            '${card1.displayName}  ${card2.displayName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
