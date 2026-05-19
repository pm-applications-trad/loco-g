import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/core/router/app_router.dart';
import 'package:locogames/features/kingscup/domain/entities/kings_cup_game.dart';
import 'package:locogames/features/kingscup/domain/entities/card_model.dart';
import 'package:locogames/features/kingscup/domain/entities/player.dart';
import 'package:locogames/features/kingscup/presentation/providers/kings_cup_provider.dart';
import 'package:locogames/core/providers/shared_providers.dart';

class KingsCupGameScreen extends ConsumerWidget {
  const KingsCupGameScreen({super.key});

  static const List<Color> suitGradientColors = [
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
    Color(0xFF0F3460),
    Color(0xFF533483),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(kingsCupGameProvider);
    final audio = ref.read(audioServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    ref.listen(kingsCupGameProvider, (prev, next) {
      if (next == null || prev == null) return;
      if (prev.kingsDrawn != next.kingsDrawn) {
        haptic.reveal();
        audio.playReveal();
      }
      if (prev.phase != next.phase && next.phase == KingsCupPhase.gameOver) {
        haptic.reveal();
        audio.playReveal();
      }
    });

    if (game == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: suitGradientColors[0],
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: AppTheme.normalAnimation,
            child: game.phase == KingsCupPhase.playing
                ? _PlayingPhase(key: const ValueKey('playing'), game: game, ref: ref)
                : _GameOverPhase(key: const ValueKey('gameOver'), game: game, ref: ref),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppTheme.spacingS,
            left: AppTheme.spacingS,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () {
                ref.read(appRouterProvider).go('/home');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayingPhase extends StatelessWidget {
  final KingsCupGame game;
  final WidgetRef ref;

  const _PlayingPhase({super.key, required this.game, required this.ref});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final currentPlayer = game.currentPlayer;
    final lastCard = game.drawnCards.isNotEmpty ? game.drawnCards.last : null;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacingM),
          _buildKingsCounter(context),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            '${l10n.translate('cards_remaining')}: ${game.remainingCards.length}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                ),
          ).animate().fadeIn(duration: AppTheme.fastAnimation),
          const Spacer(),
          if (lastCard != null) ...[
            _buildLastCard(context, lastCard),
            const SizedBox(height: AppTheme.spacingL),
          ],
          _buildCurrentPlayerIndicator(context, currentPlayer),
          const SizedBox(height: AppTheme.spacingL),
          _buildDrawButton(context),
          const Spacer(),
          _buildPlayerList(context),
          const SizedBox(height: AppTheme.spacingM),
        ],
      ),
    ).animate().fadeIn(duration: AppTheme.normalAnimation);
  }

  Widget _buildKingsCounter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final isFilled = i < game.kingsDrawn;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXS),
          child: Icon(
            Icons.wine_bar,
            color: isFilled ? Colors.amber : Colors.white24,
            size: 28,
          ),
        ).animate().scale(duration: AppTheme.normalAnimation);
      }),
    );
  }

  Widget _buildLastCard(BuildContext context, DrawnCard lastCard) {
    final card = lastCard.card;
    final isRed = card.suit.isRed;
    final cardColor = isRed ? Colors.redAccent : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRed
              ? [const Color(0xFF8B0000), const Color(0xFFCC0000)]
              : [const Color(0xFF1A1A2E), const Color(0xFF2A2A4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: (isRed ? Colors.red : Colors.white).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            card.displayName,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: cardColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            L10n.of(context).translate('kings_cup_rule_${card.value.name}'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().scale(
          duration: AppTheme.normalAnimation,
          begin: const Offset(0.8, 0.8),
          curve: Curves.elasticOut,
        );
  }

  Widget _buildCurrentPlayerIndicator(BuildContext context, KingsCupPlayer player) {
    return Column(
      children: [
        Text(
          L10n.of(context).translate('kings_cup_your_turn'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
        ),
        Text(
          player.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildDrawButton(BuildContext context) {
    final l10n = L10n.of(context);

    return GestureDetector(
      onTap: () {
        ref.read(kingsCupGameProvider.notifier).drawCard();
        ref.read(hapticServiceProvider).selectionClick();
        ref.read(audioServiceProvider).playTap();
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: KingsCupGameScreen.suitGradientColors.skip(1).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF533483).withValues(alpha: 0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style_outlined,
              size: 44,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              l10n.translate('kings_cup_draw'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
          duration: AppTheme.slowAnimation,
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.0, 1.0),
        );
  }

  Widget _buildPlayerList(BuildContext context) {
    final l10n = L10n.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
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
                  color: isCurrent ? const Color(0xFF533483) : Colors.white.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.person,
                  color: isCurrent ? Colors.white : Colors.white54,
                  size: 20,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                player.name,
                style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.white54,
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                '${l10n.translate('drinks_short')}: ${player.drinksAssigned}',
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

class _GameOverPhase extends StatelessWidget {
  final KingsCupGame game;
  final WidgetRef ref;

  const _GameOverPhase({super.key, required this.game, required this.ref});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final drinker = game.centerCupDrinker;
    final sortedPlayers = game.sortedByDrinks;

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
                  const Icon(Icons.wine_bar, size: 64, color: Colors.white),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    l10n.translate('game_over'),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (drinker != null) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      l10n.translate('kings_cup_center_drinker'),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      drinker.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
              final medal = i == 0
                  ? '🥇'
                  : i == 1
                      ? '🥈'
                      : i == 2
                          ? '🥉'
                          : '${i + 1}';
              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: player.isCenterCupDrinker
                      ? Colors.amber.withValues(alpha: 0.15)
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
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Text(
                      '${player.drinksAssigned} ${l10n.translate('drinks_short')}',
                      style: TextStyle(color: Colors.amber.shade300, fontSize: 14),
                    ),
                    if (player.isCenterCupDrinker) ...[
                      const SizedBox(width: AppTheme.spacingS),
                      const Icon(Icons.wine_bar, color: Colors.redAccent, size: 18),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: AppTheme.spacingXL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(kingsCupGameProvider.notifier).resetGame();
                    ref.read(appRouterProvider).go('/kingscup');
                  },
                  icon: const Icon(Icons.replay),
                  label: Text(l10n.translate('play_again')),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(kingsCupGameProvider.notifier).resetGame();
                    ref.read(appRouterProvider).go('/home');
                  },
                  icon: const Icon(Icons.home),
                  label: Text(l10n.translate('main_menu')),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.slowAnimation);
  }
}
