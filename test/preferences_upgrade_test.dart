import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Core/Vars/globals.dart';
import 'package:fs_front/Core/Vars/providers.dart';
import 'package:fs_front/Helpers/app_helper.dart';
import 'package:fs_front/Helpers/preferences_helper.dart';
import 'package:fs_front/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('existing preferences and saved mobile mode are preserved', () async {
    SharedPreferences.setMockInitialValues({
      PreferencesHelper.appModePref: 'flight',
      PreferencesHelper.appLanguagePref: germanLanguage,
      PreferencesHelper.themeModePref: 'dark',
      PreferencesHelper.dateTimeOrderPref: 'dateTime',
      PreferencesHelper.deltaFontSizePref: 2.0,
      PreferencesHelper.isShowStartDialogPref: false,
    });
    final container = createAppContainer();
    addTearDown(container.dispose);
    await AppHelper.initApp(container);
    expect(container.read(appModeProvider), AppMode.flight);
    expect(container.read(appLocaleProvider).locale.languageCode, 'de');
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(container.read(dateTimeOrderProvider), DateTimeOrder.dateTime);
    expect(container.read(deltaFontSizeProvider), 2.0);
    expect(container.read(isStartConfirmedProvider), isTrue);
    await PreferencesHelper.setBoolPref(
      prefName: PreferencesHelper.isKeepDisplayOnPref,
      prefValue: false,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(PreferencesHelper.isKeepDisplayOnPref), isFalse);
    expect(prefs.getString(PreferencesHelper.appModePref), 'flight');
  });

  test('invalid stored preferences fall back to defaults', () async {
    SharedPreferences.setMockInitialValues({
      PreferencesHelper.appLanguagePref: 'unknownLanguage',
      PreferencesHelper.appModePref: 'unknownMode',
      PreferencesHelper.dateTimeOrderPref: 'unknownOrder',
      PreferencesHelper.loggedAsPref: 'unknownLogAs',
      PreferencesHelper.dateFormatPref: ['unknown'],
    });
    final container = createAppContainer();
    addTearDown(container.dispose);
    await AppHelper.initApp(container);
    expect(container.read(appLocaleProvider).localeName, autoLanguage);
    expect(container.read(appModeProvider), AppMode.online);
    expect(container.read(dateTimeOrderProvider), DateTimeOrder.timeDate);
    expect(container.read(authStateProvider), LogAs.none);
    expect(container.read(dateFormatProvider), dateISO);
  });

  test('stored date format is restored by value', () async {
    SharedPreferences.setMockInitialValues({
      PreferencesHelper.dateFormatPref: List<String>.of(dateEU),
    });
    final container = createAppContainer();
    addTearDown(container.dispose);
    await AppHelper.initApp(container);
    expect(container.read(dateFormatProvider), dateEU);
  });
}
