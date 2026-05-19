import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/core/router/app_router.dart';
import 'package:locogames/features/kingscup/presentation/providers/kings_cup_provider.dart';

class KingsCupSetupScreen extends ConsumerStatefulWidget {
  const KingsCupSetupScreen({super.key});

  @override
  ConsumerState<KingsCupSetupScreen> createState() => _KingsCupSetupScreenState();
}

class _KingsCupSetupScreenState extends ConsumerState<KingsCupSetupScreen> {
  int _playerCount = 4;
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
        title: Text(l10n.translate('kings_cup_title')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.translate('kings_cup_subtitle'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
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
                    onPressed: _playerCount < 10 ? () => _setPlayerCount(_playerCount + 1) : null,
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
                  final notifier = ref.read(kingsCupGameProvider.notifier);
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
                  router.go('/kingscup/play');
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
}
