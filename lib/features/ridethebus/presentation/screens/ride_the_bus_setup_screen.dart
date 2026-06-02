import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/core/router/app_router.dart';
import 'package:locogames/features/ridethebus/presentation/providers/ride_the_bus_provider.dart';

class RideTheBusSetupScreen extends ConsumerStatefulWidget {
  const RideTheBusSetupScreen({super.key});

  @override
  ConsumerState<RideTheBusSetupScreen> createState() => _RideTheBusSetupScreenState();
}

class _RideTheBusSetupScreenState extends ConsumerState<RideTheBusSetupScreen> {
  int _playerCount = 2;
  final List<TextEditingController> _nameControllers = [];

  @override
  void initState() {
    super.initState();
    _rebuildNameControllers();
  }

  void _rebuildNameControllers() {
    final oldNames = _nameControllers.map((c) => c.text).toList();
    for (final c in _nameControllers) {
      c.dispose();
    }
    _nameControllers.clear();
    for (int i = 0; i < _playerCount; i++) {
      final name = i < oldNames.length && oldNames[i].isNotEmpty
          ? oldNames[i]
          : 'Player ${i + 1}';
      _nameControllers.add(TextEditingController(text: name));
    }
  }

  void _setPlayerCount(int count) {
    setState(() {
      _playerCount = count;
      _rebuildNameControllers();
    });
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.translate('ride_the_bus_title')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.directions_bus,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      l10n.translate('ride_the_bus_subtitle'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              Text(
                l10n.translate('rules'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              _buildRules(context, l10n),
              const SizedBox(height: AppTheme.spacingXL),
              Text(
                l10n.translate('player_count'),
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: _playerCount > 2 ? () => _setPlayerCount(_playerCount - 1) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: AppTheme.spacingL),
                  Text(
                    '$_playerCount',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingL),
                  IconButton.filled(
                    onPressed: _playerCount < 8 ? () => _setPlayerCount(_playerCount + 1) : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                l10n.translate('player_names'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacingS),
              for (int i = 0; i < _playerCount; i++) ...[
                TextField(
                  controller: _nameControllers[i],
                  decoration: InputDecoration(
                    labelText: '${l10n.translate('player')} ${i + 1}',
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
              ],
              const SizedBox(height: AppTheme.spacingL),
              FilledButton.icon(
                onPressed: () {
                  final router = ref.read(appRouterProvider);
                  final notifier = ref.read(rideTheBusGameProvider.notifier);
                  final names = _nameControllers
                      .asMap()
                      .entries
                      .map((e) {
                        final text = e.value.text.trim();
                        return text.isEmpty ? 'Player ${e.key + 1}' : text;
                      })
                      .toList();
                  notifier.startGame(
                    playerCount: _playerCount,
                    playerNames: names,
                  );
                  router.go('/ridebus/play');
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.translate('start_game')),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.normalAnimation);
  }

  Widget _buildRules(BuildContext context, L10n l10n) {
    final theme = Theme.of(context);
    final rules = [
      '${l10n.translate('rtb_red_or_black')}: ${l10n.translate('rtb_guess_red')} / ${l10n.translate('rtb_guess_black')} (4 cards)',
      '${l10n.translate('rtb_higher_or_lower')}: ${l10n.translate('rtb_guess_higher')} / ${l10n.translate('rtb_guess_lower')} (3 cards)',
      '${l10n.translate('rtb_inside_or_outside')}: ${l10n.translate('rtb_guess_inside')} / ${l10n.translate('rtb_guess_outside')} (2 cards)',
      '${l10n.translate('rtb_guess_the_suit')}: ♠ ♥ ♣ ♦ (1 card)',
    ];

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: rules.map((rule) {
          final index = rules.indexOf(rule);
          return Padding(
            padding: EdgeInsets.only(top: index > 0 ? AppTheme.spacingS : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.translate('round')} ${index + 1}: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    rule,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
