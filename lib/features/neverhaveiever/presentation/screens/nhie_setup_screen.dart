import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/features/neverhaveiever/domain/entities/statement.dart';
import 'package:locogames/features/neverhaveiever/presentation/providers/nhie_provider.dart';

class NHIESetupScreen extends ConsumerStatefulWidget {
  const NHIESetupScreen({super.key});

  @override
  ConsumerState<NHIESetupScreen> createState() => _NHIESetupScreenState();
}

class _NHIESetupScreenState extends ConsumerState<NHIESetupScreen> {
  int _playerCount = 4;
  int _totalRounds = 3;
  NHIECategory _category = NHIECategory.mixed;
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
      for (final c in _nameControllers) { c.dispose(); }
      _nameControllers = List.generate(count, (i) =>
          TextEditingController(text: i < oldNames.length ? oldNames[i] : 'Player ${i + 1}'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('never_have_i_ever_title'))),
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
                min: 1, max: 10, divisions: 9,
                label: '$_totalRounds',
                onChanged: (v) => setState(() => _totalRounds = v.toInt()),
              ),
              const SizedBox(height: AppTheme.spacingL),
              Text(l10n.translate('nhie_category'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppTheme.spacingS),
              SegmentedButton<NHIECategory>(
                segments: [
                  ButtonSegment(value: NHIECategory.mild, label: Text(l10n.translate('nhie_category_mild'))),
                  ButtonSegment(value: NHIECategory.spicy, label: Text(l10n.translate('nhie_category_spicy'))),
                  ButtonSegment(value: NHIECategory.extreme, label: Text(l10n.translate('nhie_category_extreme'))),
                  ButtonSegment(value: NHIECategory.mixed, label: Text(l10n.translate('nhie_category_mixed'))),
                ],
                selected: {_category},
                onSelectionChanged: (v) => setState(() => _category = v.first),
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
                    ref.read(nhieGameProvider.notifier).startGame(
                          playerCount: _playerCount,
                          totalRounds: _totalRounds,
                          category: _category,
                          playerNames: names,
                        );
                    context.go('/nhie/play');
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
