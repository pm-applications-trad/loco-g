import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/features/mostlikelyto/presentation/providers/mlt_provider.dart';

class MLTSetupScreen extends ConsumerStatefulWidget {
  const MLTSetupScreen({super.key});

  @override
  ConsumerState<MLTSetupScreen> createState() => _MLTSetupScreenState();
}

class _MLTSetupScreenState extends ConsumerState<MLTSetupScreen> {
  int _playerCount = 4;
  int _totalRounds = 5;
  late List<TextEditingController> _nameControllers;

  @override
  void initState() {
    super.initState();
    _nameControllers = List.generate(_playerCount, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _nameControllers) { c.dispose(); }
    super.dispose();
  }

  void _updatePlayerCount(int count) {
    setState(() {
      _playerCount = count;
      final oldNames = _nameControllers.map((c) => c.text).toList();
      for (final c in _nameControllers) {
        c.dispose();
      }
      _nameControllers = List.generate(
        count,
        (i) => TextEditingController(text: i < oldNames.length ? oldNames[i] : 'Player ${i + 1}'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('most_likely_to_title'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.translate('player_count')}: $_playerCount',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: _playerCount > 2 ? () => _updatePlayerCount(_playerCount - 1) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: AppTheme.spacingL),
                  Text('$_playerCount', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(width: AppTheme.spacingL),
                  IconButton.filled(
                    onPressed: _playerCount < 20 ? () => _updatePlayerCount(_playerCount + 1) : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),
              Text('${l10n.translate('round')}: $_totalRounds', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppTheme.spacingS),
              Slider(
                value: _totalRounds.toDouble(),
                min: 1, max: 20, divisions: 19,
                label: '$_totalRounds',
                onChanged: (v) => setState(() => _totalRounds = v.toInt()),
              ),
              const SizedBox(height: AppTheme.spacingL),
              ...List.generate(_playerCount, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                  child: TextField(
                    controller: _nameControllers[i],
                    decoration: InputDecoration(
                      labelText: '${l10n.translate('player')} ${i + 1}',
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppTheme.spacingL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final names = _nameControllers
                        .asMap()
                        .entries
                        .map((e) => e.value.text.isEmpty ? 'Player ${e.key + 1}' : e.value.text)
                        .toList();
                    ref.read(mltGameProvider.notifier).startGame(
                          playerCount: _playerCount,
                          totalRounds: _totalRounds,
                          playerNames: names,
                        );
                    context.go('/mlt/play');
                  },
                  child: Text(l10n.translate('start_game')),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.pageTransition);
  }
}
