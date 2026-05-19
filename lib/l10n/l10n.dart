import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class L10n {
  final Locale locale;

  L10n(this.locale);

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    _L10nDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  late final Map<String, String> _localizedStrings;

  Future<void> load() async {
    final jsonString = await rootBundle.loadString('assets/l10n/${locale.languageCode}.json');
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    _localizedStrings = map.map((key, value) => MapEntry(key, value.toString()));
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  bool isSupported(Locale locale) {
    return L10n.supportedLocales.contains(locale);
  }

  @override
  Future<L10n> load(Locale locale) async {
    final l10n = L10n(locale);
    await l10n.load();
    return l10n;
  }

  @override
  bool shouldReload(_L10nDelegate old) => false;
}
