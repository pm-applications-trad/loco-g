import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/core/providers/shared_providers.dart';
import 'package:locogames/core/constants/app_constants.dart';
import 'package:locogames/l10n/l10n.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);
    final hapticsEnabled = ref.watch(hapticsEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          _buildSectionTitle(context, l10n.translate('select_language')),
          const SizedBox(height: AppTheme.spacingS),
          ...['en', 'de', 'es', 'fr'].map((code) {
            final langKey = 'language_$code';
            return RadioListTile<String>(
              title: Text(l10n.translate(langKey)),
              value: code,
              groupValue: locale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).state = Locale(value);
                  ref.read(sharedPrefsProvider).setString(AppConstants.keySelectedLanguage, value);
                }
              },
            );
          }),
          const Divider(height: AppTheme.spacingXL),
          _buildSectionTitle(context, l10n.translate('dark_mode')),
          SwitchListTile(
            title: Text(l10n.translate('dark_mode')),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              final mode = value ? ThemeMode.dark : ThemeMode.light;
              ref.read(themeModeProvider.notifier).state = mode;
              ref.read(sharedPrefsProvider).setString(
                    AppConstants.keyThemeMode,
                    value ? 'dark' : 'light',
                  );
            },
          ),
          const Divider(height: AppTheme.spacingXL),
          SwitchListTile(
            title: Text(l10n.translate('sound_effects')),
            value: soundEnabled,
            onChanged: (value) {
              ref.read(soundEnabledProvider.notifier).state = value;
              ref.read(sharedPrefsProvider).setBool(AppConstants.keySoundEnabled, value);
            },
          ),
          SwitchListTile(
            title: Text(l10n.translate('haptic_feedback')),
            value: hapticsEnabled,
            onChanged: (value) {
              ref.read(hapticsEnabledProvider.notifier).state = value;
              ref.read(sharedPrefsProvider).setBool(AppConstants.keyHapticsEnabled, value);
            },
          ),
          const Divider(height: AppTheme.spacingXL),
          ListTile(
            title: Text(l10n.translate('terms_of_service')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLegalDialog(context, l10n.translate('terms_of_service')),
          ),
          ListTile(
            title: Text(l10n.translate('privacy_policy')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLegalDialog(context, l10n.translate('privacy_policy')),
          ),
          ListTile(
            title: Text(l10n.translate('legal_notice')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLegalDialog(context, l10n.translate('legal_notice')),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppTheme.spacingM, top: AppTheme.spacingS),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

void _showLegalDialog(BuildContext context, String title) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(L10n.of(ctx).translate('coming_soon')),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(L10n.of(ctx).translate('confirm')),
        ),
      ],
    ),
  );
}
