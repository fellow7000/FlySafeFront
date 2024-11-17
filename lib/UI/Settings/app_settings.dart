import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Core/Vars/providers.dart';
import 'package:fs_front/Helpers/preferences_helper.dart';
import 'package:fs_front/UI/LocalDB/artefacts_manager.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../Core/Vars/globals.dart';
import '../../Helpers/app_helper.dart';
import '../Themes/app_themes.dart';
import 'Elements/dropdown_preference.dart';

class AppSettings extends ConsumerStatefulWidget {
  final String appBarLabel;
  final String generalSettingsLabel;
  final String languageLabel;

  const AppSettings({
    super.key,
    required this.appBarLabel,
    required this.generalSettingsLabel,
    required this.languageLabel,
  });

  @override
  ConsumerState<AppSettings> createState() => AppSettingsWidget();
}

class AppSettingsWidget extends ConsumerState<AppSettings> {
  static const double subsetSpacing = 20;
  static const double divIntent = 10;
  final double cardElevation = 3;

  @override
  Widget build(BuildContext context) {
    final deltaFontSize = ref.watch(deltaFontSizeProvider);
    final iconSize = appIconBasisSize + deltaFontSize;
    final textStyle = Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: deltaFontSize);
    final headlineSmallStyle =
        Theme.of(context).textTheme.headlineSmall?.apply(fontSizeDelta: deltaFontSize, color: Colors.blue[Theme.of(context).brightness == Brightness.light ? 900 : 500]);
    final Color appBarIconColor = Theme.of(context).brightness == Brightness.light ? appBarIconColorLight : appBarIconColorDark;

    List<Widget> fields = [];

    fields.add(Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(widget.generalSettingsLabel, textAlign: TextAlign.left, style: headlineSmallStyle), //TODO: replace with code label
      ),
    ));

    //General settings
    fields.add(Card(
      elevation: cardElevation,
      child: Column(
        children: [
          //APP Language
          DropdownPreference(
            prefKey: PreferencesHelper.appLanguagePref,
            title: widget.languageLabel,
            value: ref.watch(appLocaleProvider).localeName,
            values: appLocales.map((e) => e.localeName).toList(),
            deltaFontSize: ref.watch(deltaFontSizeProvider),
            displayValues: appLocales.map((e) => e.localeName.tr().toString()).toList(),
            onChange: (newVal) => _toggleAppLanguage(context, newVal),
          ),

          //Keep Display On
          if (isMobileDevice)
            const Divider(
              indent: divIntent,
              endIndent: divIntent,
            ),
          if (isMobileDevice)
            SwitchListTile(
                title: Text(
                  "KeepDisplayOn".tr(),
                  style: textStyle,
                ),
                value: ref.watch(isKeepDisplayOnProvider),
                onChanged: (val) => _toggleKeepDisplayOn(val)),

          //Show start warning dialog
          if (isMobileDevice)
            const Divider(
              indent: divIntent,
              endIndent: divIntent,
            ),
          if (isMobileDevice)
            SwitchListTile(
                title: Text(
                  "WarningAtStart".tr(),
                  style: textStyle,
                ),
                value: ref.watch(isShowStartDialogProvider),
                onChanged: (val) => _toggleConfirmationOnStart(val)),

          //Exist Confirmation
          if (isMobileDevice && (appPlatform == EndDevice.android || appPlatform == EndDevice.fuchsia))
            const Divider(
              indent: divIntent,
              endIndent: divIntent,
            ),
          if (isMobileDevice && (appPlatform == EndDevice.android || appPlatform == EndDevice.fuchsia))
            SwitchListTile(
                title: Text(
                  "ExitConfirmation".tr(),
                  style: textStyle,
                ),
                value: ref.watch(isConfirmationOnExitProvider),
                onChanged: (val) => _toggleConfirmationOnExit(val)),

          //App text size, excluding check list items
          const Divider(
            indent: divIntent,
            endIndent: divIntent,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Text(
                    "TextSize".tr(),
                    style: textStyle,
                  )),
              GestureDetector(
                onDoubleTap: () => _setDeltaFontSize(0),
                child: Slider(
                    min: -5,
                    max: 5,
                    divisions: 10,
                    label: ref.read(deltaFontSizeProvider.notifier).state.toStringAsFixed(0),
                    value: ref.watch(deltaFontSizeProvider),
                    onChanged: (val) => _setDeltaFontSize(val)),
              )
            ],
          )
        ],
      ),
    ));

    if (isMobileDevice) {
      fields.add(Padding(
        padding: const EdgeInsets.only(top: subsetSpacing),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text("LocalDB".tr(), textAlign: TextAlign.left, style: headlineSmallStyle), //TODO: replace with code label
          ),
        ),
      ));

      fields.add(Card(
          elevation: cardElevation,
          child: Column(children: [
            ListTile(
              title: Text(
                "ManageArtefacts".tr(),
                style: textStyle,
              ),
              trailing: Icon(
                chevronExpand,
                size: iconSize,
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArtefactsManager())),
            )
          ])));
    }

    return SafeArea(
        child: GestureDetector(
      onTap: () => AppHelper.dismissKeyboard(context),
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.appBarLabel),
            leading: IconButton(icon: const Icon(Icons.arrow_back), color: appBarIconColor, onPressed: () => Navigator.pop(context, false)),
          ),
          body: OrientationBuilder(builder: (context, orientation) {
            return Center(
                child: SingleChildScrollView(
                    child: SizedBox(
              width: winWidth == WindowWidth.small ? windowWidth : panelWidthLarge,
              child: Column(
                children: fields,
              ),
            )));
          })),
    ));
  }

  void _toggleAppLanguage(BuildContext context, newVal) {
    if (newVal != autoLanguage) {
      ref.read(appLocaleProvider.notifier).state = appLocales.firstWhere((locale) => locale.localeName == newVal);
      context.setLocale(ref.read(appLocaleProvider.notifier).state.locale);
    } else {
      ref.read(appLocaleProvider.notifier).state = appLocales.first;
      if (context.supportedLocales.contains(context.deviceLocale)) {
        context.resetLocale();
      } else {
        context.setLocale(context.fallbackLocale!);
      }
    }
  }

  void _toggleKeepDisplayOn(bool val) {
    ref.read(isKeepDisplayOnProvider.notifier).state = val;
    PreferencesHelper.setBoolPref(prefName: PreferencesHelper.isKeepDisplayOnPref, prefValue: val);
    WakelockPlus.toggle(enable: val);
  }

  void _toggleConfirmationOnStart(bool val) {
    ref.read(isShowStartDialogProvider.notifier).state = val;
    PreferencesHelper.setBoolPref(prefName: PreferencesHelper.isShowStartDialogPref, prefValue: val);
  }

  void _toggleConfirmationOnExit(bool val) {
    ref.read(isConfirmationOnExitProvider.notifier).state = val;
    PreferencesHelper.setBoolPref(prefName: PreferencesHelper.isConfirmationOnExitPref, prefValue: val);
  }

  void _setDeltaFontSize(double val) {
    ref.read(deltaFontSizeProvider.notifier).state = val;
    PreferencesHelper.setDoublePref(prefName: PreferencesHelper.deltaFontSizePref, prefValue: val);
    AppHelper.initFonts(context, val);
  }
}
