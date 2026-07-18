import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TranslationProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr');
  Map<String, dynamic> _translations = {};

  Locale get locale => _locale;
  Map<String, dynamic> get translations => _translations;

  Future<void> loadTranslations(Locale locale) async {
    _locale = locale;
    final jsonString = await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    _translations = json.decode(jsonString) as Map<String, dynamic>;
    notifyListeners();
  }

  String translate(String key) {
    final keys = key.split('.');
    dynamic value = _translations;
    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key;
      }
    }
    return value is String ? value : key;
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != _locale.languageCode) {
      await loadTranslations(locale);
    }
  }
}

extension AppTranslate on BuildContext {
  String tr(String key) {
    return Provider.of<TranslationProvider>(this, listen: false).translate(key);
  }
}
