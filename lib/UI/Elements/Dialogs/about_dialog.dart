import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fs_front/Core/Vars/globals.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Core/Vars/enums.dart';

class AppDialogs{

  static void aboutDialog({required BuildContext context, required TextStyle textStyle}) async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) async {
      String buildNumber = packageInfo.buildNumber;
      String bldType = "";

      if (kDebugMode) {
        bldType = "Debug".tr();
      } else {
        switch (appBuildE) {
          case AppBuild.alpha:
            bldType = "Alpha".tr();
            break;
          case AppBuild.closedBeta:
            bldType = "ClosedBeta".tr();
            break;
          case AppBuild.publicBeta:
            bldType = "PublicBeta".tr();
            break;
          case AppBuild.releaseCandidate:
            bldType = "ReleaseCandidate".tr();
            break;
          case AppBuild.release:
            bldType = "Release".tr();
            break;
          default:
            bldType = "Debug".tr();
        }
      }

      showAboutDialog(
          context: context,
          applicationIcon: Image.asset(appIcon),
          applicationName: "AppTitle".tr(),
          applicationVersion: "${packageInfo.version} $bldType\n${"Build".tr()}: $buildNumber",
          applicationLegalese: copyRightLabel,
          children: <Widget>[
            const SizedBox(height: 24),
            InkWell(
              onTap: () => _showTutorial(tutorialUrl),
              child: Text("TutorialVideo".tr(),
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 18.0,
                  )),
            ),
            const Divider(
              height: 20,
            ),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(style: textStyle, text: "AppAboutTxt".tr()),
                ],
              ),
            ),
            const Divider(
              height: 20,
            ),
            InkWell(
              child: const Text(
                  f7email,
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 18.0,
                  )),
              onTap: () async {
                await launchUrl(Uri.parse("mailto:tower@fellow7000.com"));
              },
            ),
          ]);
    });
  }

  static _showTutorial(Uri tutorialUrl) async {
    launchUrl(tutorialUrl).then((result) {
      if (!result) {
        if (kDebugMode) {
          log("Cannot launch ${tutorialUrl.toString()}");
        }
      }
    });
  }
}