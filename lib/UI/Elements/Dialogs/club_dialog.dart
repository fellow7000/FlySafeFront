import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/material.dart';

class ClubDialog {
  static void showClubExplanation({required BuildContext context, required String title, required String explanationText, required String okLabel, required double deltaFontSize}) {
    Alert(
      context: context,
      style: AlertStyle(
          animationType: AnimationType.grow,
          isOverlayTapDismiss: true,
          isCloseButton: true,
          titleStyle: Theme.of(context).textTheme.titleLarge!,
          descStyle: Theme.of(context).textTheme.bodyMedium!,
          descTextAlign: TextAlign.justify),
      type: AlertType.none,
      title: title,
      desc: explanationText,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(), //this is for Android only. for IOS we need to figure it out //Navigator.of(context).pop(true),
          color: Colors.blue,
          child: Text(
            okLabel,
            style: Theme.of(context).textTheme.headlineSmall!.apply(fontSizeDelta: deltaFontSize, color: Colors.white),
          ),
        )
      ],
    ).show();
  }
}