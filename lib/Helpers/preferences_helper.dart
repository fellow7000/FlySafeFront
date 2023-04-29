import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Helpers/app_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Core/DTO/Identity/authentification_requrest.dart';
import '../Core/DTO/Identity/authentification_response.dart';
import '../Core/Vars/enums.dart';
import '../Core/Vars/globals.dart';
import '../Core/Vars/providers.dart';

class PreferencesHelper {

  static const String appLanguagePref = "appLanguage";
  static const String appModePref = "appMode";
  static const String isShowStartDialogPref = "isShowStartDialog";
  static const String isKeepDisplayOnPref = "isKeepDisplayOn";
  static const String isConfirmationOnExitPref = "isConfirmationOnExit";
  static const String themeModePref = "themeMode";
  static const String dateTimeOrderPref = "dateTimeOrder";
  static const String dateFormatPref = "dateFormat";
  static const String userOrClubNamePref = "userOrClubName";
  static const String userOrClubHashPref = "userOrClubHash";
  static const String loggedAsPref = "loggedAs";
  static const String deltaFontSizePref = "deltaFontSize";

  static setBoolPref({required String prefName, required prefValue}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefName, prefValue);
  }

  static setIntPref({required String prefName, required prefValue}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefName, prefValue);
  }

  static setDoublePref({required String prefName, required prefValue}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(prefName, prefValue);
  }

  static setStringPref({required String prefName, required prefValue}) async {
    final prefs = await SharedPreferences.getInstance();
    var res = await prefs.setString(prefName, prefValue);
    if (kDebugMode) {
      log("Preference $prefName with new value $prefValue write result: $res");
    }
  }

  static readAllPrefs(ProviderContainer container) async {
    final prefs = await SharedPreferences.getInstance();

    //check app locale
    var appLanguage = prefs.getString(appLanguagePref)??autoLanguage;
    if (!appLocales.contains(appLocales.firstWhere((appLocale) => appLocale.localeName == appLanguage))) {
      appLanguage = autoLanguage;
    }
    container.read(appLocaleProvider.notifier).state = appLocales.firstWhere((appLocale) => appLocale.localeName == appLanguage);

    container.read(appModeProvider.notifier).state = AppMode.values.byName(prefs.getString(appModePref)??AppMode.online.name);
    container.read(isShowStartDialogProvider.notifier).state = prefs.getBool(isShowStartDialogPref)??true;
    container.read(isStartConfirmedProvider.notifier).state = (((container.read(isShowStartDialogProvider.notifier).state = container.read(isShowStartDialogProvider.notifier).state)== false) | kIsWeb | kDebugMode);
    container.read(isKeepDisplayOnProvider.notifier).state = prefs.getBool(isKeepDisplayOnPref)??true;
    container.read(isConfirmationOnExitProvider.notifier).state = prefs.getBool(isConfirmationOnExitPref)??true;
    container.read(themeModeProvider.notifier).state = (prefs.getString(themeModePref)??"light").contains("light")?ThemeMode.light:((prefs.getString(themeModePref)??"").contains("dark")?ThemeMode.dark:ThemeMode.system);
    container.read(dateTimeOrderProvider.notifier).state = DateTimeOrder.values.byName(prefs.getString(dateTimeOrderPref)??DateTimeOrder.timeDate.name);
    container.read(dateFormatProvider.notifier).state = dateFormats[dateFormats.indexOf(prefs.getStringList(dateFormatPref)??dateISO)];
    container.read(authStateProvider.notifier).state = LogAs.values.byName(prefs.getString(loggedAsPref)??LogAs.none.name);
    container.read(userOrClubNameProvider.notifier).state = prefs.getString(userOrClubNamePref)??"";
    container.read(userOrClubHashProvider.notifier).state =prefs.getString(userOrClubHashPref)??"";
    container.read(deltaFontSizeProvider.notifier).state = prefs.getDouble(deltaFontSizePref)??0.0;

    //prepare initial authentication
    if ((container.read(authStateProvider.notifier).state == LogAs.user || container.read(authStateProvider.notifier).state == LogAs.club)) {
    container.read(authentificationRequestProvider.notifier).state = AuthentificationRequest(
        userNameOrEmail: container
            .read(userOrClubNameProvider.notifier)
            .state,
        password: container
            .read(userOrClubHashProvider.notifier)
            .state,
        passwordType: PasswordType.hash,
        logAs: container
            .read(authStateProvider.notifier)
            .state,
        returnPasswordHash: false,
        endDevice: appPlatform,
        keepSignedIn: true);
    requestStartUpSignIn = true;
    }
    }
}