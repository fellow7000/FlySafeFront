import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Helpers/app_helper.dart';
import 'package:fs_front/Infrastructure/LocalDB/local_db_names.dart';
import 'package:fs_front/UI/Elements/Dialogs/warning_dialog.dart';
import 'package:fs_front/UI/Elements/basis_form.dart';
import 'package:fs_front/UI/Elements/app_process_indicator.dart';

import '../../Core/Vars/providers.dart';
import '../../Infrastructure/LocalDB/local_db.dart';
import '../Themes/app_themes.dart';

class ArtefactsManager extends ConsumerWidget {
  ArtefactsManager({super.key});

  final _formState = StateProvider((ref) => AppFormState.dataInput);
  final _toClearAviaArtefactsProvider = StateProvider((ref) => false);
  final _toClearTimeStampsProvider = StateProvider((ref) => false);
  final _toClearNotesProvider = StateProvider((ref) => false);
  final _toClearEntireDBProvider = StateProvider((ref) => false);
  final _isActionPossibleProvider = StateProvider((ref) => false);
  final double spacingTop = 10;
  static const double divIntent = 15;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deltaFontSize = ref.watch(deltaFontSizeProvider);
    TextStyle textStyleTile = Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: deltaFontSize);

    List<Widget> fields = [
      CheckboxListTile(
          title: Text("DeleteAviaArtifacts".tr(), style: textStyleTile),
          value: ref.watch(_toClearAviaArtefactsProvider),
          enabled: !ref.watch(_toClearEntireDBProvider),
          onChanged: (val) => _toggleClearAviaArtefacts(val!, ref)),
      const Divider(
        indent: divIntent,
        endIndent: divIntent,
      ),
      CheckboxListTile(
          title: Text("DeleteTimeStamps".tr(), style: textStyleTile),
          value: ref.watch(_toClearTimeStampsProvider),
          enabled: !ref.watch(_toClearEntireDBProvider),
          onChanged: (val) => _toggleClearTimeStamps(val!, ref)),
      const Divider(
        indent: divIntent,
        endIndent: divIntent,
      ),
      CheckboxListTile(
          title: Text("DeleteNotes".tr(), style: textStyleTile),
          value: ref.watch(_toClearNotesProvider),
          enabled: !ref.watch(_toClearEntireDBProvider),
          onChanged: (val) => _toggleClearNotes(val!, ref)),
      const Divider(
        indent: divIntent,
        endIndent: divIntent,
      ),
      CheckboxListTile(title: Text("ClearDB".tr(), style: textStyleTile), value: ref.watch(_toClearEntireDBProvider), onChanged: (val) => _toggleClearEntireDB(val!, ref)),

      SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return ref.watch(_formState) == AppFormState.processing
            ?AppProcessIndicator(message: "Processing".tr())
            :ElevatedButton(
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Theme.of(context).brightness == Brightness.light ? primaryWarningButtonDisabledColorLight : primaryWarningButtonDisabledColorDark,
                backgroundColor: Theme.of(context).brightness == Brightness.light ? primaryWarningButtonEnabledColorLight : primaryWarningButtonEnabledColorDark,
              ),
              onPressed: ref.watch(_isActionPossibleProvider) ? () => _execute(context, ref) : null,
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("Execute".tr(),
                          textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider), color: Colors.white)))),
            );})
          ),
        ),
    ];

    return BasisForm(
      formTitle: "ManageArtefacts".tr(),
      form: Column(children: fields),
    );
  }

  void _toggleClearAviaArtefacts(bool val, WidgetRef ref) {
    ref.read(_toClearAviaArtefactsProvider.notifier).state = val;
    _checkActionPossible(ref);
  }

  void _toggleClearTimeStamps(bool val, WidgetRef ref) {
    ref.read(_toClearTimeStampsProvider.notifier).state = val;
    _checkActionPossible(ref);
  }

  void _toggleClearNotes(bool val, WidgetRef ref) {
    ref.read(_toClearNotesProvider.notifier).state = val;
    _checkActionPossible(ref);
  }

  void _toggleClearEntireDB(bool val, WidgetRef ref) {
    ref.read(_toClearAviaArtefactsProvider.notifier).state = val;
    ref.read(_toClearTimeStampsProvider.notifier).state = val;
    ref.read(_toClearNotesProvider.notifier).state = val;
    ref.read(_toClearEntireDBProvider.notifier).state = val;
    ref.read(_isActionPossibleProvider.notifier).state = val;
  }

  void _checkActionPossible(WidgetRef ref) {
    ref.read(_isActionPossibleProvider.notifier).state =
        (ref.read(_toClearAviaArtefactsProvider.notifier).state | ref.read(_toClearTimeStampsProvider.notifier).state | ref.read(_toClearNotesProvider.notifier).state);
  }

  void _execute(BuildContext context, WidgetRef ref) {

    void callback() async {
      ref.read(_formState.notifier).state = AppFormState.processing;
      Navigator.of(context).pop();
      if (ref.watch(_toClearAviaArtefactsProvider)) {
        //await LocalDB.db.redoDB(deleteAirFromDB);
        ref.read(_toClearAviaArtefactsProvider.notifier).state = false;
      }
      if (ref.watch(_toClearTimeStampsProvider)) {
        await LocalDB.db.redoDB(deleteAllFromTableNotes);
        ref.read(_toClearTimeStampsProvider.notifier).state = false;
      }
      if (ref.watch(_toClearNotesProvider)) {
        await LocalDB.db.redoDB(deleteAllFromTableTimeStamps);
        ref.read(_toClearNotesProvider.notifier).state = false;
      }
      ref.read(_toClearEntireDBProvider.notifier).state = false;
      ref.read(_isActionPossibleProvider.notifier).state = false;

      ref.read(_formState.notifier).state = AppFormState.dataInput;

      if (!context.mounted) return;
      AppHelper.showSnack(context: context, message: "Done".tr());
    }

    String confirmationMessage = "ConfirmActions".tr();

    if (ref.read(_toClearAviaArtefactsProvider)) {
      confirmationMessage = '$confirmationMessage\n - ${"DeleteAviaArtifacts".tr()}';
    }

    if (ref.read(_toClearTimeStampsProvider)) {
      confirmationMessage = '$confirmationMessage\n - ${"DeleteTimeStamps".tr()}';
    }

    if (ref.read(_toClearNotesProvider)) {
      confirmationMessage = '$confirmationMessage\n - ${"DeleteNotes".tr()}';
    }

    WarningConfirmationDialog.confirm(
      ref: ref,
      context: context,
      title: "Warning".tr(),
      dialogText: confirmationMessage,
      continueLabel: "Delete".tr(),
      exitLabel: "Cancel".tr(),
      yesCallBack: callback,
    );

  }
}