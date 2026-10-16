import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/settings/settings_cubit.dart';

void main() {
  test('restores persisted theme and language', () async {
    SharedPreferences.setMockInitialValues({
      'dark_mode': true,
      'language': 'hi',
    });
    final cubit = SettingsCubit(await SharedPreferences.getInstance())..load();

    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(cubit.state.locale, const Locale('hi'));
  });

  test('persists dark mode changes', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final cubit = SettingsCubit(preferences);

    await cubit.setDarkMode(true);

    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(preferences.getBool('dark_mode'), isTrue);
  });

  test('persists language changes', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final cubit = SettingsCubit(preferences);

    await cubit.setLanguage('hi');

    expect(cubit.state.locale, const Locale('hi'));
    expect(preferences.getString('language'), 'hi');
  });
}
