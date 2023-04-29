import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Helpers/app_helper.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../Core/Vars/providers.dart';

class ExitDialog {
  static Future<bool> exitConfirmation(
      {required BuildContext context, required WidgetRef ref, required String title, required String dialogText, required String noLabel, required String yesLabel}) async {
    if (ref.read(isConfirmationOnExitProvider.notifier).state) {
      Alert(
        context: context,
        style: const AlertStyle(
            animationType: AnimationType.grow,
            isOverlayTapDismiss: true,
            isCloseButton: false,
            descStyle: TextStyle(fontWeight: FontWeight.normal),
            titleStyle: TextStyle(color: Colors.black)),
        type: AlertType.none,
        title: title,
        desc: dialogText,
        buttons: [
          DialogButton(
            onPressed: () => Navigator.of(context).pop(false),
            color: Colors.red,
            child: Text(
              noLabel,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          DialogButton(
            onPressed: () => AppHelper.exitApp(), //this is for Android only. for IOS we need to figure it out //Navigator.of(context).pop(true),
            color: Colors.green,
            child: Text(
              yesLabel,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ],
      ).show();
      return false;
    } else {
      return true;
    }
  }
}
