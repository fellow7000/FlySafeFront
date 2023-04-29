import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../Core/Vars/providers.dart';
import '../../Themes/app_themes.dart';

class WarningConfirmationDialog {
  static void confirm({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String dialogText,
    Widget content = const SizedBox(),
    //required String showWarningLabel,
    required String continueLabel,
    required String exitLabel,
    required Function yesCallBack,
  }) {
    final deltaFontSize = ref.watch(deltaFontSizeProvider);
    final Color warningColor = Theme.of(context).brightness == Brightness.light ? primaryWarningButtonEnabledColorLight : primaryWarningButtonEnabledColorDark;
    final Color cancelColor = Theme.of(context).brightness == Brightness.light ? primaryActionButtonDefEnabledColorLight : primaryActionButtonDefEnabledColorDark!;

    Alert(
      context: context,
      style: AlertStyle(
          animationType: AnimationType.grow,
          isOverlayTapDismiss: true,
          isCloseButton: false,
          descStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12 + deltaFontSize),
          titleStyle: TextStyle(fontWeight: FontWeight.bold, color: warningColor)),
      type: AlertType.warning,
      title: title,
      desc: dialogText,
      content: content,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.of(context).pop(),
          color: cancelColor,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              exitLabel,
              style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white, fontSizeDelta: deltaFontSize),
            ),
          ),
        ),
        DialogButton(
          onPressed: () => yesCallBack(), //TODO: this WILL NOT work on iOS need to figure out a solution,
          color: warningColor,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              continueLabel,
              style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white, fontSizeDelta: deltaFontSize),
            ),
          ),
        ),
      ],
    ).show();
  }
}