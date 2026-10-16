import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
  });

  final ThemeMode themeMode;
  final Locale locale;

  @override
  List<Object?> get props => [themeMode, locale];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._preferences) : super(const SettingsState());

  static const _darkModeKey = 'dark_mode';
  static const _languageKey = 'language';
  final SharedPreferences _preferences;

  void load() {
    final darkMode = _preferences.getBool(_darkModeKey);
    final language = _preferences.getString(_languageKey) ?? 'en';
    emit(
      SettingsState(
        themeMode: darkMode == null
            ? ThemeMode.system
            : darkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        locale: Locale(language),
      ),
    );
  }

  Future<void> setDarkMode(bool enabled) async {
    await _preferences.setBool(_darkModeKey, enabled);
    emit(
      SettingsState(
        themeMode: enabled ? ThemeMode.dark : ThemeMode.light,
        locale: state.locale,
      ),
    );
  }

  Future<void> setLanguage(String languageCode) async {
    await _preferences.setString(_languageKey, languageCode);
    emit(
      SettingsState(themeMode: state.themeMode, locale: Locale(languageCode)),
    );
  }
}
