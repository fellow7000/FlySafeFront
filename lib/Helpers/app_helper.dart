import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:date_format/date_format.dart' as dtf;
import '../Core/Vars/enums.dart';
import '../Core/Vars/globals.dart';
import '../Core/Vars/providers.dart';
import '../UI/Themes/app_themes.dart';
import 'preferences_helper.dart';

class AppHelper {
  static initApp(ProviderContainer container) async {
    if (kIsWeb) {
      appPlatform = EndDevice.web;
      isMobileDevice = false;
    } else if (Platform.isAndroid) {
      appPlatform = EndDevice.android;
      isMobileDevice = true;
    } else if (Platform.isIOS) {
      appPlatform = EndDevice.ios;
      isMobileDevice = true;
    } else if (Platform.isFuchsia) {
      appPlatform = EndDevice.fuchsia;
      isMobileDevice = true;
    } else if (Platform.isWindows) {
      appPlatform = EndDevice.windows;
      isMobileDevice = false;
    } else if (Platform.isLinux) {
      appPlatform = EndDevice.linux;
      isMobileDevice = false;
    } else if (Platform.isMacOS) {
      appPlatform = EndDevice.macos;
      isMobileDevice = false;
    } else {
      appPlatform = EndDevice.other;
      isMobileDevice = false;
    }

    clickToRetry = appPlatform == EndDevice.web?"ClickToRetry":"TapToRetry";

    if (kDebugMode) {
      container.read(webHostProvider.notifier).state = webHosts.last;
    }

    await PreferencesHelper.readAllPrefs(container);
  }

  static WindowWidth getWindowWidth(double width) {
    //these values defines sizes for Web & Desktop
    double smallWidth = 500;
    double midWidth = 700;
    double largeWidth = 1000;

    if (defaultTargetPlatform == TargetPlatform.android){
      smallWidth = 600;
      midWidth = 840;
      largeWidth = 1000;
    }
    else if (defaultTargetPlatform == TargetPlatform.iOS){
      smallWidth = 450;
      midWidth = 800;
      largeWidth = 1000;
    }

    if (width < smallWidth) {
      return WindowWidth.small;
    } else if (width < midWidth) {
      return WindowWidth.mid;
    } else {
      return WindowWidth.large;
    }
  }

  static String getCurrentDateTime({required DateTimeType dateTimeType, required List<String> dateFormat, required DateTimeOrder dateTimeOrder}) {
    var curDateTime = DateTime.now();

    var appTime = DateTime(curDateTime.year, curDateTime.month, curDateTime.day,
        curDateTime.hour, curDateTime.minute, curDateTime.second);

    var appDate = DateTime(curDateTime.year, curDateTime.month, curDateTime.day,
        curDateTime.hour, curDateTime.minute, curDateTime.second);

    if (dateTimeType == DateTimeType.utc) {
      appTime = appTime.toUtc();
      appDate = appDate.toUtc();
    }

    var appTimeFormatted = dtf.formatDate(appTime, [dtf.HH, ':', dtf.nn, ':', dtf.ss]);
    var appDateFormatted = dtf.formatDate(appDate, dateFormat);

    if (dateTimeOrder == DateTimeOrder.dateTime) {
      return "$appDateFormatted $appTimeFormatted";
    } else {
      return "$appTimeFormatted $appDateFormatted";
    }
  }

  static void dismissKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  static bool isEmailValid(String email) {
    if (email.length < 3) return false; //min email length is 3

    if (!email.contains("@")) return false;

    var name = email.substring(0, email.indexOf("@"));
    if (name.isEmpty) return false;

    var domain = email.substring(email.indexOf("@")+1);
    if (domain.isEmpty) return false;

    return true;
  }

  static Uri generateUri({required Uri host, required apiController, required String apiHandler}) {
    Uri uri;

    if (host.scheme == 'https') {
      uri = Uri.https(host.path, "/$apiController/$apiHandler");
    } else {
      uri = Uri.http(host.path, "/$apiController/$apiHandler");
    }

    return uri;
  }

  static void initFonts(BuildContext context, double fontSizeDelta) {
    textStyleTitleLarge = Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: fontSizeDelta);
    textStyleTitleMedium = Theme.of(context).textTheme.titleMedium!.apply(fontSizeDelta: fontSizeDelta);
    textStyleHeadlineSmall = Theme.of(context).textTheme.headlineSmall!.apply(fontWeightDelta: 1, fontSizeDelta: fontSizeDelta);
    textStyleHeadlineSmallButton = Theme.of(context).textTheme.headlineSmall!.apply(fontSizeDelta: fontSizeDelta, color: Colors.white);
    textStyleBodyLarge = Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: fontSizeDelta);
    textStyleBodyMedium = Theme.of(context).textTheme.bodyMedium!.apply(fontSizeDelta: fontSizeDelta);
  }

  static void showSnack({required BuildContext context, required String message, int msec = 1500}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(milliseconds: msec), content: Text(message)));
  }

  static exitApp({int exitCode = 0}) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    exit(exitCode);
  }
}