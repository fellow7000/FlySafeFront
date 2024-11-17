import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/UI/Elements/Dialogs/about_dialog.dart';
import 'package:fs_front/UI/Elements/MainSidePanel/theme_mode_swith.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/identity_helper.dart';
import '../Elements/MainSidePanel/app_mode_toggle.dart';
import '../Elements/MainSidePanel/sign_in_tile.dart';
import '../Settings/app_settings.dart';
import '../Themes/app_themes.dart';

class SideMainMenu extends ConsumerWidget {
  const SideMainMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextStyle textStyle = Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider));
    TextStyle textStyleDrawerHeader = Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider) + 2, color: Colors.white);

    List<Widget> tiles = [
      if (isMobileDevice && winWidth == WindowWidth.large)
        AppModeToggle(
            onLineModeLabel: "Online".tr(),
            flightModeLabel: "FlightMode".tr()),
      if (winWidth == WindowWidth.large)
        SignInTile(
          signInLabel: "SignIn".tr(),
          userOrClubName: ref.watch(userOrClubNameProvider),
        ),

      ListTile(
          style: ListTileStyle.list,
          leading: const Icon(Icons.warehouse),
          title: Text(
            "ListedClubs".tr(),
            style: textStyle,
          ),
          //hoverColor: ref.read(hoverColorProvider.notifier).state,
          onTap: () => _toPublicClubsLogin(context, ref)),

      if (appPlatform != EndDevice.web)
        ListTile(
          leading: const Icon(Icons.web),
          title: Text(
            "GoWeb".tr(),
            style: textStyle,
          ),
          onTap: () => _gotoWeb(ref),
        ),

      ThemeModeSwitch(textStyle: textStyle, lightModeLabel: "LightTheme".tr(), darkModeLabel: "DarkTheme".tr(), systemModeLabel: "SystemTheme".tr()),

      ListTile(
        leading: const Icon(Icons.settings),
        title: Text("Settings".tr(), style: textStyle),
        onTap: () => _goToSettings(context),
      ),

      ListTile(
        leading: const Icon(Icons.info),
        title: Text(
          "About".tr(),
          style: textStyle,
        ),
        onTap: () => AppDialogs.aboutDialog(context: context, textStyle: Theme.of(context).textTheme.bodyMedium!),
      )
    ];

    //LOC / UTC Time
    Widget dateTimeWgt = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: (Column(
        children: [
          Text("UTC: ${ref.watch(dateTimeUTCProvider)}\n", style: winWidth != WindowWidth.large ? textStyleDrawerHeader : textStyle),
          Text("${"LOC".tr()}: ${ref.watch(dateTimeLocProvider)}", style: winWidth != WindowWidth.large ? textStyleDrawerHeader : textStyle),
        ],
      )),
    );

    if (winWidth != WindowWidth.large) {
      tiles.insert(
          0,
          DrawerHeader(
            padding: const EdgeInsets.only(left: 25 ,right: 25),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light ? drawerHeaderLightColor : drawerHeaderDarkColor,
              ),
              child: dateTimeWgt));
    } else {
      tiles.insert(0, Padding(padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10), child: dateTimeWgt));
      tiles.insert(
          1,
          const Divider(
            height: 1,
          ));
    }

    return SingleChildScrollView(padding: EdgeInsets.zero, child: IntrinsicWidth(child: Column(children: tiles)));
  }

  void _toPublicClubsLogin(BuildContext context, WidgetRef ref) {
    if (winWidth != WindowWidth.large) {
      Navigator.pop(context, false);
    }
    ref.read(selectedPublicClubProvider.notifier).state = null;
    IdentityHelper.toSignIn(context, ref, LogAs.club);
  }

  void _gotoWeb(WidgetRef ref) async {
    final launchUri = ref.read(webHostProvider.notifier).state;
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _goToSettings(BuildContext context) {
    if (winWidth != WindowWidth.large) {
      Navigator.pop(context, false);
    }
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => AppSettings(appBarLabel: "Settings".tr(), generalSettingsLabel: "GeneralSettings".tr(), languageLabel: "AppLanguage".tr(),)
    ));
  }
}
