import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/delete_user_account_request.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/delete_user_account_response.dart';

import '../../../Core/DTO/Base/call_error.dart';
import '../../../Core/DTO/Identity/Manage/user_profile_response.dart';
import '../../../Core/Vars/enums.dart';
import '../../../Core/Vars/globals.dart';
import '../../../Core/Vars/providers.dart';
import '../../../Helpers/identity_helper.dart';
import '../../../Infrastructure/BackEnd/backend_call.dart';
import '../../Elements/MainSidePanel/api_error_messages.dart';
import '../../Elements/basis_form.dart';
import '../../Elements/app_process_indicator.dart';
import '../../Themes/app_themes.dart';

class DeleteUserAccount extends ConsumerStatefulWidget {
  final UserProfileResponse userProfile;

  const DeleteUserAccount({required this.userProfile, super.key});

  @override
  ConsumerState<DeleteUserAccount> createState() => DeleteUserAccountWidget();
}

class DeleteUserAccountWidget extends ConsumerState<DeleteUserAccount> {
  DeleteUserAccountWidget();

  late final UserProfileResponse userProfile;

  final _formStateProvider =
      StateProvider.autoDispose<AppFormState>((ref) => AppFormState.dataInput);

  final _isDeleteConfirmedProvider = StateProvider<bool>((ref) => false);

  static const double myTopPadding = 5;

  final _callErrors = StateProvider<List<CallError>>(
      (ref) => []); //TODO: implementation of error handling is open!

  @override
  void initState() {
    userProfile = widget.userProfile;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(_formStateProvider);
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    final iconSize = appIconBasisSize + fontSizeDelta;
    final isProcessing = formState == AppFormState.processing;
    final isError = (formState == AppFormState.httpError ||
        formState == AppFormState.exception ||
        formState == AppFormState.resultFailed);

    List<Widget> fields = <Widget>[];

    //Delete Title
    fields.add(Padding(
      padding: const EdgeInsets.all(myTopPadding * 2),
      child: Text("DeleteUserAccount".tr(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.apply(
              fontWeightDelta: 1,
              fontSizeDelta: fontSizeDelta)), //TODO: replace with code label
    ));

    //Text Warning
    fields.add(Padding(
      padding: const EdgeInsets.all(myTopPadding),
      child: Text("DeleteUserAccountWarning".tr(),
          textAlign: TextAlign.center,
          style: textStyleTitleMedium.apply(
              color: Colors.red)), //TODO: replace with code label
    ));

    //Checkbox confirmation
    fields.add(Padding(
      padding: const EdgeInsets.all(myTopPadding),
      child: CheckboxListTile(
        value: ref.watch(_isDeleteConfirmedProvider),
        title: Text("IConfirm".tr(),
            textAlign: TextAlign.center,
            style: textStyleTitleLarge.apply(color: Colors.red)),
        onChanged: (val) => _toggleDelConfirmation(ref, val),
      ), //TODO: replace with code label
    ));

    //Error Message
    if (isError) {
      fields.add(ApiErrorMessages(
          callErrors: ref.watch(_callErrors),
          deltaFontSize: ref.watch(deltaFontSizeProvider)));
    }

    //Delete User Account Button
    fields.add(
        Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
      //child:
      return Padding(
        padding: const EdgeInsets.only(top: myTopPadding * 4),
        child: formState == AppFormState.processing
            ? AppProcessIndicator(message: "Processing".tr())
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? primaryWarningButtonEnabledColorLight
                            : primaryWarningButtonEnabledColorDark,
                  ),
                  onPressed: ref.watch(_isDeleteConfirmedProvider)
                      ? () => _deleteUserAccount(context, ref)
                      : null,
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("Delete".tr(),
                              textAlign: TextAlign.center,
                              style: textStyleHeadlineSmall.copyWith(
                                  color: ref.watch(_isDeleteConfirmedProvider)
                                      ? Colors.white
                                      : null)))),
                )),
      );
    }));

    Widget changePasswordForm = Padding(
      padding: const EdgeInsets.all(myTopPadding * 3),
      child: Column(children: fields), //Sign-in Form
    );

    return BasisForm(
      key: scaffoldKeyDeleteUserAccount,
      formTitle: "UserProfile".tr(),
      form: Form(
        key: GlobalKey<FormState>(),
        child: Card(
          elevation: 3,
          child: changePasswordForm,
        ),
      ),
    );
  }

  void _toggleDelConfirmation(WidgetRef ref, bool? val) {
    ref.read(_isDeleteConfirmedProvider.notifier).state = val!;
  }

  _deleteUserAccount(BuildContext context, WidgetRef ref) {
    ref.read(_callErrors.notifier).state = [];
    ref.read(_formStateProvider.notifier).state = AppFormState.processing;

    ref.read(deleteUserAccountRequestProvider.notifier).state =
        DeleteUserAccountRequest(userName: userProfile.userName);

    var deleteResult = ref.watch(deleteUserAccountProvider.future);

    deleteResult.then((data) {
      if (!mounted) return;

      // Handle successful deletion
      if (data.resultCode == AppResultCode.ok) {
        // Call a method to handle all context-dependent operations
        _handleSuccessfulDeletion();
      } else {
        // Update state for errors
        ref.read(_callErrors.notifier).state = data.errors;
        ref.read(_formStateProvider.notifier).state = AppFormState.resultFailed;
      }
    }).onError((error, stackTrace) {
      if (!mounted) return;

      // Update state for error handling
      ref.read(_callErrors.notifier).state = [BackEndCall.callExceptionError];
      ref.read(_formStateProvider.notifier).state = AppFormState.httpError;
    });
  }

  // Define a method to handle context-dependent actions
  void _handleSuccessfulDeletion() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('UserAccountDelete'.tr()),
    ));

    // Sign out and navigate
    IdentityHelper.processSignOut(ref: globalRef);
    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }
}
