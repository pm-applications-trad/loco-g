import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locogames/core/di/injection.dart';
import 'package:locogames/core/flavor/app_flavor.dart';
import 'package:locogames/core/providers/shared_providers.dart';
import 'package:locogames/core/router/app_router.dart';
import 'package:locogames/core/theme/app_theme.dart';
import 'package:locogames/l10n/l10n.dart';

void main() {
  runLocoApp(AppFlavor.locogames);
}

void runLocoApp(AppFlavor flavor) {
  initializeFlavor(flavor);
  WidgetsFlutterBinding.ensureInitialized();
  initializeDependencies().then((_) {
    runApp(
      const ProviderScope(
        child: LocoGamesApp(),
      ),
    );
  }).catchError((Object error) {
    runApp(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Init error: $error'),
            ),
          ),
        ),
      ),
    );
  });
}

class LocoGamesApp extends ConsumerWidget {
  const LocoGamesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: currentFlavor.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: L10n.localizationsDelegates,
      routerConfig: router,
    );
  }
}
