import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Helpers/preferences_helper.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../Core/Vars/providers.dart';
import '../../../Helpers/app_helper.dart';

class StartDialog {

  void startDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String dialogText,
    required String showWarningLabel,
    required String continueLabel,
    required String exitLabel,
  }) {
    Alert(
      context: context,
      style: const AlertStyle(
          animationType: AnimationType.grow,
          isOverlayTapDismiss: false,
          isCloseButton: false,
          descStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          titleStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
      type: AlertType.warning,
      title: title,
      desc: dialogText,
      content: ToggleStartDialog(
        context: context,
        toggleLabel: showWarningLabel,
      ),
      buttons: [
        if (Platform.isAndroid || Platform.isFuchsia)
          DialogButton(
            onPressed: () => AppHelper.exitApp(), //TODO: this WILL NOT work on iOS need to figure out a solution,
            color: Colors.red,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                exitLabel,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
              ),
            ),
          ),
        DialogButton(
          onPressed: () => _continue(ref, context),
          color: Colors.green,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              continueLabel,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
            ),
          ),
        )
      ],
    ).show();
  }

  void _continue(WidgetRef ref, BuildContext context) {
    ref.read(isStartConfirmedProvider.notifier).state = true;
    Navigator.pop(context);
  }
}

class ToggleStartDialog extends ConsumerWidget {
  final BuildContext context;
  final String toggleLabel;

  const ToggleStartDialog({Key? key, required this.context, required this.toggleLabel}) : super(key : key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckboxListTile(
      value: ref.watch(isShowStartDialogProvider),
      title: Padding(
          padding: const EdgeInsets.only(left: 47),
          child: Text(toggleLabel, textAlign: TextAlign.center)),
      onChanged: (value) => _toggleStartDialog(ref, value!),
    );
  }

  void _toggleStartDialog(WidgetRef ref, bool newValue) async {
    ref.read(isShowStartDialogProvider.notifier).state = newValue;
    PreferencesHelper.setBoolPref(prefName: PreferencesHelper.isShowStartDialogPref, prefValue: newValue);
  }
}