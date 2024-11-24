import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/UI/Themes/app_themes.dart';

import 'Core/Vars/globals.dart';
import 'Core/Vars/providers.dart';
import 'Core/Vars/routes.dart';
import 'Helpers/app_helper.dart';
import 'Helpers/http_overrider.dart';

void main() async {
  if (kDebugMode) {
    HttpOverrides.global = HttpOverrider();
  }

  WidgetsFlutterBinding.ensureInitialized();

  // something to keep them entertained during initialization
  //runApp(const Center(child: CircularProgressIndicator()));
  await EasyLocalization.ensureInitialized();
  final container = ProviderContainer();
  await AppHelper.initApp(container);

  // var startLocale;
  //
  // if (kIsWeb) {
  //   if (container.read(appLocaleProvider.notifier).state.localeName != autoLanguage) {
  //     startLocale = container.read(appLocaleProvider.notifier).state;
  //   }
  // }

  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    UncontrolledProviderScope(
      container: container,
      child: EasyLocalization(
          supportedLocales: [localeEN, localeDE, localeRU],
          path: langPath,
          //startLocale: startLocale,
          fallbackLocale: localeEN,
          useOnlyLangCode: true,
          saveLocale: true,
          child: const FlySafeApp()),
    ),
  );
}

class FlySafeApp extends ConsumerWidget {
  const FlySafeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppHelper.initFonts(context, ref.watch(deltaFontSizeProvider));

    return MaterialApp.router(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: appRouter,
    );
  }
}
