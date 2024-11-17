import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Core/Vars/providers.dart';
import 'package:fs_front/Helpers/preferences_helper.dart';

import '../../../Core/Vars/globals.dart';
import '../../Themes/app_themes.dart';

class AppModeToggle extends ConsumerWidget {
  final String onLineModeLabel;
  final String flightModeLabel;

  const AppModeToggle({super.key, required this.onLineModeLabel, required this.flightModeLabel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextStyle textStyle = TextStyle(fontSize: 20 + ref.watch(deltaFontSizeProvider));
    Color iconColor = Theme.of(context).brightness == Brightness.light ? appBarIconColorLight : appBarIconColorDark;

    if (winWidth != WindowWidth.large) { //TODO: 27.12.2022 quick hack
      return IconButton(
          icon: Icon(ref.watch(appModeProvider) == AppMode.online ? Icons.cloud : Icons.airplanemode_active_rounded, color: iconColor),
          onPressed: () => _toggleAppMode(ref));
    } else {
      return ListTile(
        leading: Icon(ref.watch(appModeProvider) == AppMode.online ? Icons.cloud : Icons.airplanemode_active_rounded),
        title: Text(ref.watch(appModeProvider) == AppMode.online ? onLineModeLabel : flightModeLabel, style: textStyle),
        onTap: () => _toggleAppMode(ref)
      );
    }
  }

  void _toggleAppMode(WidgetRef ref) {
    if (ref.watch(appModeProvider) == AppMode.online) {
      ref.read(appModeProvider.notifier).state = AppMode.flight;
      requestStartUpSignIn = false;
    } else {
      if ((ref.watch(authStateProvider) == LogAs.user || ref.watch(authStateProvider) == LogAs.club) && accessToken.isEmpty) {
        requestStartUpSignIn = true;
      }
      ref.read(appModeProvider.notifier).state = AppMode.online;
    }
    debugPrint("Toggle app mode to ${ref.read(appModeProvider.notifier).state.name}");
    PreferencesHelper.setStringPref(prefName: PreferencesHelper.appModePref, prefValue: ref.read(appModeProvider.notifier).state.name);
  }
}
