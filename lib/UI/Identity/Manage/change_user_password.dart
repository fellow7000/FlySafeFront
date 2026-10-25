import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/change_user_password_request.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/change_user_password_response.dart';
import 'package:fs_front/Helpers/app_helper.dart';
import 'package:fs_front/UI/Elements/basis_form.dart';
import 'package:fs_front/UI/Elements/password_change_fields.dart';

import '../../../Core/DTO/Base/call_error.dart';
import '../../../Core/Vars/enums.dart';
import '../../../Core/Vars/globals.dart';
import '../../../Core/Vars/providers.dart';
import '../../../Helpers/identity_helper.dart';
import '../../../Infrastructure/BackEnd/backend_call.dart';
import '../../Elements/MainSidePanel/api_error_messages.dart';
import '../../Themes/app_themes.dart';

class ChangeUserPassword extends ConsumerStatefulWidget {
  const ChangeUserPassword({super.key});

  @override
  ConsumerState<ChangeUserPassword> createState() => _ChangeUserPasswordState();
}

class _ChangeUserPasswordState extends ConsumerState<ChangeUserPassword> {

  final _formKey = GlobalKey<FormState>();

  int _fieldsResetCount = 0;

  final _formStateProvider = StateProvider.autoDispose<AppFormState>((ref) => AppFormState.dataInput);

  final FocusNode _focusNodeChangeButton = FocusNode();

  final _currentPasswordInputControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
    final textController = TextEditingController();
    ref.onDispose(() {
      textController.dispose();
    });
    return textController;
  });

  final _newPasswordInputControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
    final textController = TextEditingController();
    ref.onDispose(() {
      textController.dispose();
    });
    return textController;
  });

  final _newPasswordConfirmationInputControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
    final textController = TextEditingController();
    ref.onDispose(() {
      textController.dispose();
    });
    return textController;
  });

  final _isChangePossibleProvider = StateProvider<bool>((ref) => false);

  List<CallError> _callErrors = []; //TODO: implementation of error handling is open!

  @override
  void dispose() {
    _focusNodeChangeButton.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(_formStateProvider);
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    TextStyle textHeadlineSmall = Theme.of(context).textTheme.headlineSmall!.apply(fontSizeDelta: fontSizeDelta, color: Colors.white);
    final isProcessing = formState == AppFormState.processing;
    final isError = (formState == AppFormState.httpError || formState == AppFormState.exception || formState == AppFormState.resultFailed);

    List<Widget> fields = <Widget>[];

    fields.add(
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text("ChangeUserPassword".tr(),
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.apply(fontWeightDelta: 1, fontSizeDelta: fontSizeDelta)), //TODO: replace with code label
        )
    );

    fields.add(PasswordChangeFields(
      key: ValueKey(_fieldsResetCount),
      currentController: ref.watch(_currentPasswordInputControllerProvider),
      newController: ref.watch(_newPasswordInputControllerProvider),
      confirmController: ref.watch(_newPasswordConfirmationInputControllerProvider),
      currentLabel: "Password".tr(),
      newLabel: "NewPassword".tr(),
      confirmLabel: "ConfirmPassword".tr(),
      minLength: minUserPasswordLength,
      allowEmptyCurrent: false,
      enabled: !isProcessing,
      onValidityChanged: (valid) => ref.read(_isChangePossibleProvider.notifier).state = valid,
    ));

    //Error Message
    if (isError) {
      fields.add(ApiErrorMessages(callErrors: _callErrors, deltaFontSize: ref.watch(deltaFontSizeProvider)));
    }

    //Change Password Button
    fields.add(Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          //child:
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: formState == AppFormState.processing
                ? const CircularProgressIndicator()
                : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  focusNode: _focusNodeChangeButton,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: primaryActionButtonDefDisabledColor,
                    backgroundColor: Theme
                        .of(context)
                        .brightness == Brightness.light ? primaryActionButtonDefEnabledColorLight : null,
                  ),
                  onPressed: ref.watch(_isChangePossibleProvider) ? () => _changePassword(context, ref) : null,
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("ChangePassword".tr(), textAlign: TextAlign.center, style: textHeadlineSmall))),
                )),
          );
        }
    ));

    Widget changePasswordForm = Padding(
      padding: const EdgeInsets.all(15),
      child: Column(children: fields), //Sign-in Form
    );

    return BasisForm(
      formTitle: "Password".tr(),
      form: Form(
          key: _formKey,
          child: Card(
                elevation: 3,
                child: changePasswordForm,
              ),
          ),
    );

  }

  void _changePassword(BuildContext context, WidgetRef ref) {
    _callErrors = [];
    ref.read(_formStateProvider.notifier).state = AppFormState.processing;

    ref.read(changeUserPasswordRequestProvider.notifier).state = ChangeUserPasswordRequest(
        oldUserPassword: ref.read(_currentPasswordInputControllerProvider).text,
        newUserPassword: ref.read(_newPasswordInputControllerProvider).text,
        newUserPasswordConfirmation: ref.read(_newPasswordConfirmationInputControllerProvider).text);

    var changeResult = ref.watch(changeUserPasswordProvider.future);

    changeResult.then((data) {
      if (data.resultCode == AppResultCode.ok) {
        ref.read(_formStateProvider.notifier).state = AppFormState.resultOk;
        IdentityHelper.processUserPasswordChange(ref: ref, newHash: data.newUserPasswordHash, newToken: data.newAccessToken);
        if (context.mounted) {
          AppHelper.showSnack(context: context, message: "PasswordChangeSuccess".tr());
        }
        ref.read(_currentPasswordInputControllerProvider).text = "";
        ref.read(_newPasswordInputControllerProvider).text = "";
        ref.read(_newPasswordConfirmationInputControllerProvider).text = "";
        setState(() => _fieldsResetCount++); //resets the fields' touched state
      } else {
        _callErrors = data.errors;
        ref.read(_formStateProvider.notifier).state = AppFormState.resultFailed;
      }
    }).onError((error, stackTrace) {
      _callErrors = [BackEndCall.callExceptionError];
      ref.read(_formStateProvider.notifier).state = AppFormState.httpError;
    });
  }

}
