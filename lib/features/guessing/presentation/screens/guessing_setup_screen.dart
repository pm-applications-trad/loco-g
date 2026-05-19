import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/core/constants/app_constants.dart';
import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/features/guessing/presentation/providers/guessing_game_provider.dart';

class GuessingSetupScreen extends ConsumerStatefulWidget {
  const GuessingSetupScreen({super.key});

  @override
  ConsumerState<GuessingSetupScreen> createState() => _GuessingSetupScreenState();
}

class _GuessingSetupScreenState extends ConsumerState<GuessingSetupScreen> {
  int _playerCount = 4;
  int _totalRounds = 5;
  final List<TextEditingController> _nameControllers = [];

  @override
  void initState() {
    super.initState();
    _updateNameControllers();
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _updateNameControllers() {
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

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('guessing_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, l10n.translate('player_count')),
            Row(
              children: [
                IconButton(
                  onPressed: _playerCount > AppConstants.minPlayersGuessing
                      ? () => setState(() {
                            _playerCount--;
                            _updateNameControllers();
                          })
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_playerCount',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _playerCount < AppConstants.maxPlayersGuessing
                      ? () => setState(() {
                            _playerCount++;
                            _updateNameControllers();
                          })
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            _buildSectionTitle(context, l10n.translate('round')),
            Slider(
              value: _totalRounds.toDouble(),
              min: 3,
              max: 10,
              divisions: 7,
              label: '$_totalRounds',
              onChanged: (value) => setState(() => _totalRounds = value.round()),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            _buildSectionTitle(context, l10n.translate('players')),
            const SizedBox(height: AppTheme.spacingS),
            ...List.generate(_playerCount, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                child: TextField(
                  controller: _nameControllers[index],
                  decoration: InputDecoration(
                    hintText: 'Player ${index + 1}',
                    prefixIcon: Icon(
                      index == 0 ? Icons.star : Icons.person_outline,
                      size: 20,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: AppTheme.spacingXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final names = _nameControllers
                      .asMap()
                      .entries
                      .map((e) => e.value.text.isEmpty ? 'Player ${e.key + 1}' : e.value.text)
                      .toList();
                  ref.read(guessingGameProvider.notifier).startGame(
                        playerCount: _playerCount,
                        totalRounds: _totalRounds,
                        playerNames: names,
                      );
                  context.go('/guessing/play');
                },
                child: Text(l10n.translate('start_game')),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
