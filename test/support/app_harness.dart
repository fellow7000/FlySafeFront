import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Core/Vars/globals.dart';
import 'package:fs_front/Core/Vars/providers.dart';
import 'package:fs_front/Core/Vars/routes.dart';
import 'package:fs_front/Helpers/app_helper.dart';
import 'package:fs_front/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _translations = <String, Map<String, dynamic>>{};

Future<void> loadAppTranslations() async {
  for (final language in ['en', 'de', 'ru']) {
    _translations[language] = jsonDecode(
      await rootBundle.loadString('$langPath/$language.json'),
    ) as Map<String, dynamic>;
  }
}

Future<ProviderContainer> pumpFlySafe(
  WidgetTester tester, {
  required EndDevice platform,
  Size size = const Size(520, 900),
}) async {
  SharedPreferences.setMockInitialValues({'isShowStartDialog': false});
  await EasyLocalization.ensureInitialized();
  final container = createAppContainer(
    overrides: [
      dateTimeTickerProvider.overrideWith((ref) => const Stream<int>.empty()),
    ],
  );
  await AppHelper.initApp(container);
  // Exercise each presentation variant without native plugins or backend writes.
  appPlatform = platform;
  isMobileDevice = platform == EndDevice.android || platform == EndDevice.ios;
  clickToRetry = platform == EndDevice.web ? 'ClickToRetry' : 'TapToRetry';
  requestStartUpSignIn = false;
  accessToken = '';
  appRouter.go('/');
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    requestStartUpSignIn = false;
  });
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: EasyLocalization(
        supportedLocales: [localeEN, localeDE, localeRU],
        path: langPath,
        startLocale: localeEN,
        fallbackLocale: localeEN,
        useOnlyLangCode: true,
        assetLoader: _BundledTranslations(_translations),
        child: const FlySafeApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

class _BundledTranslations extends AssetLoader {
  const _BundledTranslations(this.translations);
  final Map<String, Map<String, dynamic>> translations;
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return translations[locale.languageCode]!;
  }
}
