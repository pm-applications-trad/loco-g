import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:locogames/core/flavor/app_flavor.dart';
import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/features/home/presentation/widgets/game_card.dart';
import 'package:locogames/features/home/presentation/widgets/gamified_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final flavor = currentFlavor;
    final gameCards = _buildGameCards(context, l10n, flavor);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const GamifiedHeader(),
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              sliver: SliverToBoxAdapter(
                child: Text(
                  l10n.translate('games_title'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppTheme.spacingM,
                  crossAxisSpacing: AppTheme.spacingM,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate(gameCards),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(bottom: AppTheme.spacingXXL),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/home/settings'),
        icon: const Icon(Icons.settings),
        label: Text(l10n.translate('settings')),
      ),
    );
  }

  List<Widget> _buildGameCards(BuildContext context, L10n l10n, FlavorConfig flavor) {
    final cards = <Widget>[];

    if (flavor.isGameEnabled(GameFeature.impostor)) {
      cards.add(
        GameCard(
          title: l10n.translate('impostor_title'),
          subtitle: l10n.translate('impostor_subtitle'),
          icon: Icons.people_outline,
          gradient: const [Color(0xFF6C3CE1), Color(0xFF8B5CF6)],
          onTap: () => context.go('/impostor'),
        ),
      );
    }

    if (flavor.isGameEnabled(GameFeature.guessing)) {
      cards.add(
        GameCard(
          title: l10n.translate('guessing_title'),
          subtitle: l10n.translate('guessing_subtitle'),
          icon: Icons.quiz_outlined,
          gradient: const [Color(0xFFFF3B6E), Color(0xFFFF6B8A)],
          onTap: () => context.go('/guessing'),
        ),
      );
    }

    if (flavor.isGameEnabled(GameFeature.multiplayer)) {
      cards.add(
        GameCard(
          title: l10n.translate('multiplayer_title'),
          subtitle: l10n.translate('multiplayer_subtitle'),
          icon: Icons.wifi,
          gradient: const [Color(0xFF00D4AA), Color(0xFF00E5C0)],
          onTap: () => context.go('/multiplayer'),
        ),
      );
    }

    if (flavor.isGameEnabled(GameFeature.whoAmI)) {
      cards.add(
        GameCard(
          title: l10n.translate('who_am_i_title'),
          subtitle: l10n.translate('who_am_i_subtitle'),
          icon: Icons.chat_bubble_outline,
          gradient: const [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
          onTap: () => context.go('/whoami'),
        ),
      );
    }

    if (flavor.isGameEnabled(GameFeature.kingsCup)) {
      cards.add(
        GameCard(
          title: l10n.translate('kings_cup_title'),
          subtitle: l10n.translate('kings_cup_subtitle'),
          icon: Icons.style_outlined,
          gradient: const [Color(0xFFE53935), Color(0xFFFF5252)],
          onTap: () => context.go('/kingscup'),
        ),
      );
    }

    if (flavor.isGameEnabled(GameFeature.rideTheBus)) {
      cards.add(
        GameCard(
          title: l10n.translate('ride_the_bus_title'),
          subtitle: l10n.translate('ride_the_bus_subtitle'),
          icon: Icons.directions_bus,
          gradient: const [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
          onTap: () => context.go('/ridebus'),
        ),
      );
    }

    if (flavor.isGameEnabled(GameFeature.powerHour)) {
      cards.add(
        GameCard(
          title: l10n.translate('power_hour_title'),
          subtitle: l10n.translate('power_hour_subtitle'),
          icon: Icons.timer,
          gradient: const [Color(0xFF283593), Color(0xFF5C6BC0)],
          onTap: () => context.go('/powerhour'),
        ),
      );
    }

    if (flavor.isGameEnabled(GameFeature.neverHaveIEver)) {
      cards.add(
        GameCard(
          title: l10n.translate('never_have_i_ever_title'),
          subtitle: l10n.translate('never_have_i_ever_subtitle'),
          icon: Icons.favorite,
          gradient: const [Color(0xFFC62828), Color(0xFFEF5350)],
          onTap: () => context.go('/nhie'),
        ),
      );
    }

    if (flavor.isGameEnabled(GameFeature.ringOfFire)) {
      cards.add(
        GameCard(
          title: l10n.translate('ring_of_fire_title'),
          subtitle: l10n.translate('ring_of_fire_subtitle'),
          icon: Icons.whatshot,
          gradient: const [Color(0xFFFF6F00), Color(0xFFFFA726)],
          onTap: null,
        ),
      );
    }

    if (flavor.isGameEnabled(GameFeature.mostLikelyTo)) {
      cards.add(
        GameCard(
          title: l10n.translate('most_likely_to_title'),
          subtitle: l10n.translate('most_likely_to_subtitle'),
          icon: Icons.how_to_vote,
          gradient: const [Color(0xFF00838F), Color(0xFF26C6DA)],
          onTap: () => context.go('/mlt'),
        ),
      );
    }

    if (flavor.isGameEnabled(GameFeature.paranoia)) {
      cards.add(
        GameCard(
          title: l10n.translate('paranoia_title'),
          subtitle: l10n.translate('paranoia_subtitle'),
          icon: Icons.remove_red_eye,
          gradient: const [Color(0xFF2E7D32), Color(0xFF66BB6A)],
          onTap: null,
        ),
      );
    }

    if (cards.isEmpty) {
      cards.add(
        GameCard(
          title: l10n.translate('coming_soon'),
          subtitle: l10n.translate('new_games_soon'),
          icon: Icons.more_horiz,
          gradient: [Colors.grey.shade700, Colors.grey.shade600],
          onTap: null,
          locked: true,
        ),
      );
    }

    return cards;
  }
}
