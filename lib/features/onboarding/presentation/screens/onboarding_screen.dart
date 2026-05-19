import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/core/constants/app_constants.dart';
import 'package:locogames/core/providers/shared_providers.dart';
import 'package:locogames/l10n/l10n.dart';

final ageVerifiedProvider = StateProvider<bool>((ref) => false);
final onboardingPageProvider = StateProvider<int>((ref) => 0);

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final ageVerified = ref.watch(ageVerifiedProvider);
    final page = ref.watch(onboardingPageProvider);

    if (!ageVerified) {
      return _AgeVerificationPage(l10n: l10n, ref: ref);
    }

    return _IntroPage(l10n: l10n, page: page, ref: ref);
  }
}

class _AgeVerificationPage extends StatelessWidget {
  final L10n l10n;
  final WidgetRef ref;

  const _AgeVerificationPage({required this.l10n, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A1A), Color(0xFF1A1A2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C3CE1), Color(0xFFFF3B6E)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C3CE1).withValues(alpha: 0.3),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.sports_esports, color: Colors.white, size: 56),
                ),
                const SizedBox(height: AppTheme.spacingXL),
                Text(
                  l10n.translate('app_name'),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  l10n.translate('tagline'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD700), size: 32),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        l10n.translate('age_verification_title'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        l10n.translate('age_verification_text'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(ageVerifiedProvider.notifier).state = true;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D4AA),
                            foregroundColor: Colors.black,
                          ),
                          child: Text(l10n.translate('i_am_18_plus')),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      TextButton(
                        onPressed: () => SystemNavigator.pop(),
                        child: Text(
                          l10n.translate('no'),
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  final L10n l10n;
  final int page;
  final WidgetRef ref;

  const _IntroPage({required this.l10n, required this.page, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A1A), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const Icon(Icons.celebration, color: Color(0xFFFFD700), size: 80),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                'Ready to Party?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'Choose a game and start the fun!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingXL),
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(sharedPrefsProvider).setBool(AppConstants.keyOnboardingComplete, true);
                    if (context.mounted) context.go('/home');
                  },
                  child: Text(l10n.translate('continue')),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
            ],
          ),
        ),
      ),
    );
  }
}
