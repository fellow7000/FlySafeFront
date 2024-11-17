import "package:flutter/material.dart";

ThemeData appLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
);

ThemeData appDarkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color>(Colors.blueGrey)))
);

//Appbar Icons colors
const Color appBarIconColorLight = Colors.black;
const Color appBarIconColorDark = Colors.white;

//validation
const MaterialColor validColorLight = Colors.green;
const MaterialColor validColorDark = Colors.green;
const MaterialColor notValidColorLight = Colors.red;
const MaterialColor notValidColorDark = Colors.red;

//Colors
const Color drawerHeaderLightColor = Colors.blue;
final Color? drawerHeaderDarkColor = Colors.grey[800];

//Blue Labels
const Color textBlueColorLight = Colors.blue;
final Color? textBlueColorDark = Colors.blue[800];

//Primary default button
const Color primaryActionButtonDefEnabledColorLight = Colors.blue;
final Color? primaryActionButtonDefEnabledColorDark = Colors.blue[800];
final Color primaryActionButtonDefDisabledColor = Colors.blueGrey.shade300;

//Primary Ok button
const Color primaryActionButtonOkEnabledColorLight = Colors.green;
final Color primaryActionButtonOkDisabledColorLight = Colors.green.shade300;
final Color primaryActionButtonOkDisabledColorDark = Colors.blueGrey.shade300;

//Warning Button
const Color primaryWarningButtonEnabledColorLight = Colors.red;
final Color primaryWarningButtonDisabledColorLight = Colors.red.shade300;
final Color primaryWarningButtonEnabledColorDark = Colors.red.shade200;
final Color primaryWarningButtonDisabledColorDark = Colors.red.shade100;

//Tables
final Color evenRowColor = Colors.grey[200]!;

//default fontsTextStyle textStyleTitleLarge
late TextStyle textStyleTitleMedium;
late TextStyle textStyleTitleLarge;
late TextStyle textStyleHeadlineSmall;
late TextStyle textStyleHeadlineSmallButton;
late TextStyle textStyleBodyLarge;
late TextStyle textStyleBodyMedium;