import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Core/Vars/providers.dart';
import 'package:fs_front/UI/Identity/login.dart';
import 'package:fs_front/UI/Identity/request_password_reset.dart';
import 'package:fs_front/UI/Identity/sign_up.dart';
import 'package:fs_front/UI/MainScreen/main_screen.dart';
import 'package:fs_front/UI/Settings/app_settings.dart';

import 'support/app_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppTranslations);

  testWidgets('phone startup and existing mode toggle work', (tester) async {
    final container = await pumpFlySafe(tester, platform: EndDevice.android);
    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.byIcon(Icons.cloud), findsOneWidget);
    await tester.tap(find.byIcon(Icons.cloud));
    await tester.pump();
    expect(container.read(appModeProvider), AppMode.flight);
    expect(find.byIcon(Icons.airplanemode_active_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.airplanemode_active_rounded));
    await tester.pump();
    expect(container.read(appModeProvider), AppMode.online);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide web layout has a sidebar and no flight switch', (
    tester,
  ) async {
    await pumpFlySafe(
      tester,
      platform: EndDevice.web,
      size: const Size(1280, 900),
    );
    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);
    expect(find.byIcon(Icons.cloud), findsNothing);
    expect(find.byIcon(Icons.airplanemode_active_rounded), findsNothing);
    expect(find.text('Settings'.tr()), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login route, registration and password reset render', (
    tester,
  ) async {
    final container = await pumpFlySafe(tester, platform: EndDevice.ios);
    await tester.tap(find.byIcon(Icons.login));
    await tester.pumpAndSettle();
    expect(find.byType(LogIn), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    await tester.enterText(find.byType(TextFormField).first, 'test-pilot');
    await tester.pump();
    expect(find.text('test-pilot'), findsOneWidget);
    container.read(toSignAsProvider.notifier).state = LogAs.signUp;
    await tester.pumpAndSettle();
    expect(find.byType(SignUp), findsOneWidget);
    container.read(toSignAsProvider.notifier).state = LogAs.forgotPassword;
    await tester.pumpAndSettle();
    expect(find.byType(RequestPasswordReset), findsOneWidget);
    container.read(toSignAsProvider.notifier).state = LogAs.userOrClub;
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(LogIn), findsNothing);
    expect(find.byType(MainScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings, language and theme updates work after navigation', (
    tester,
  ) async {
    final container = await pumpFlySafe(
      tester,
      platform: EndDevice.web,
      size: const Size(1280, 900),
    );
    await tester.tap(find.text('Settings'.tr()));
    await tester.pumpAndSettle();
    expect(find.byType(AppSettings), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('German'.tr()).last);
    await tester.pumpAndSettle();
    expect(container.read(appLocaleProvider).locale.languageCode, 'de');
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
