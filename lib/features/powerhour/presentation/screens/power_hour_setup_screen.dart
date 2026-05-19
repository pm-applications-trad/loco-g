import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/l10n/l10n.dart';
import 'package:locogames/features/powerhour/presentation/providers/power_hour_provider.dart';

class PowerHourSetupScreen extends ConsumerWidget {
  const PowerHourSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final minutes = ref.watch(_selectedMinutesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('power_hour_title'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.translate('power_hour_minutes')}: $minutes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Slider(
                value: minutes.toDouble(),
                min: 10, max: 120, divisions: 22,
                label: '$minutes',
                onChanged: (v) => ref.read(_selectedMinutesProvider.notifier).state = v.toInt(),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              Text(
                l10n.translate('power_hour_subtitle'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(powerHourGameProvider.notifier).startGame(
                          totalMinutes: minutes,
                        );
                    context.go('/powerhour/play');
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.translate('start_game')),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppTheme.pageTransition);
  }
}

final _selectedMinutesProvider = StateProvider<int>((ref) => 60);
