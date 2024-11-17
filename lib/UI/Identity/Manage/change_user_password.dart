import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/change_user_password_request.dart';
import 'package:fs_front/Core/DTO/Identity/Manage/change_user_password_response.dart';
import 'package:fs_front/Helpers/app_helper.dart';
import 'package:fs_front/UI/Elements/basis_form.dart';

import '../../../Core/DTO/Base/call_error.dart';
import '../../../Core/Vars/enums.dart';
import '../../../Core/Vars/globals.dart';
import '../../../Core/Vars/providers.dart';
import '../../../Helpers/identity_helper.dart';
import '../../../Infrastructure/BackEnd/backend_call.dart';
import '../../Elements/MainSidePanel/api_error_messages.dart';
import '../../Themes/app_themes.dart';

class ChangeUserPassword extends ConsumerWidget {

  ChangeUserPassword({super.key,
  });

  final _formKey = GlobalKey<FormState>();

  static const double myTopPadding = 5;

  final _formStateProvider = StateProvider.autoDispose<AppFormState>((ref) => AppFormState.dataInput);

  final FocusNode _focusCurrentPassword = FocusNode();
  final FocusNode _focusNewPassword = FocusNode();
  final FocusNode _focusNewPasswordConfirmation = FocusNode();
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

  String? _newPasswordValidator;
  String? _newPasswordConfirmationValidator;

  final _isNewPasswordValidProvider = StateProvider<bool?>((ref) => null);
  final _isNewPasswordConfirmationValidProvider = StateProvider<bool?>((ref) => null);

  final _isPasswordHiddenProvider = StateProvider<bool>((ref) => true);

  final _isChangePossibleProvider = StateProvider<bool>((ref) => false);

  List<CallError> _callErrors = []; //TODO: implementation of error handling is open!

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(_formStateProvider);
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    final iconSize = appIconBasisSize + fontSizeDelta;
    TextStyle textStyleTitleLarge = Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: fontSizeDelta);
    TextStyle textBodyLarge = Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: fontSizeDelta);
    TextStyle textBodyMedium = Theme.of(context).textTheme.bodyMedium!.apply(fontSizeDelta: fontSizeDelta);
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

    fields.add(
        Padding(
          padding: const EdgeInsets.only(top: myTopPadding),
          child: TextField(
            controller: ref.watch(_currentPasswordInputControllerProvider),
            focusNode: _focusCurrentPassword,
            style: textStyleTitleLarge,
            obscureText: ref.watch(_isPasswordHiddenProvider),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
            ],
            enabled: !isProcessing,
            decoration: InputDecoration(
                labelText: "Password".tr(),
                labelStyle: textBodyLarge,
                prefixIcon: Icon(
                  passwordIcon,
                  size: iconSize,
                ),
                suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end, //shift all stuff to the right (end)
                    mainAxisSize: MainAxisSize.min, //make row of the size of two icons
                    children: <Widget>[
                      IconButton(
                        icon: Icon(!ref.watch(_isPasswordHiddenProvider) ? visibleIcon : notVisibleIcon, size: iconSize),
                        onPressed: () => _togglePasswordVisibility(ref),
                      ),
                      IconButton(
                          icon: Icon(
                            clearTextIcon,
                            size: iconSize,
                          ),
                          onPressed: () => _clearCurrentPassword(context, ref)),
                    ])),
            onSubmitted: (val) => FocusScope.of(context).requestFocus(_focusNewPassword),
          ),
        )
    );

    //New Password
    fields.add(
      Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            late final MaterialColor? iconColor;

            if (ref.watch(_isNewPasswordValidProvider) == null) {
              iconColor = null;
            } else if (ref.watch(_isNewPasswordValidProvider) == false) {
              iconColor = Theme.of(context).brightness == Brightness.light ? notValidColorLight : notValidColorDark;
            } else if (ref.watch(_isNewPasswordValidProvider) == true) {
              iconColor = Theme.of(context).brightness == Brightness.light ? validColorLight : validColorDark;
            }

            return Padding(
              padding: const EdgeInsets.only(top: myTopPadding),
              child: TextFormField(
                controller: ref.watch(_newPasswordInputControllerProvider),
                focusNode: _focusNewPassword,
                style: textStyleTitleLarge,
                obscureText: ref.watch(_isPasswordHiddenProvider),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
                ],
                enabled: !isProcessing,
                decoration: InputDecoration(
                    hintText: "MinPasswordLength".tr(args: [minUserPasswordLength.toString()]),
                    hintStyle: textBodyMedium,
                    labelText: "NewPassword".tr(),
                    labelStyle: textBodyLarge,
                    prefixIcon: Icon(
                      passwordIcon,
                      size: iconSize,
                      color: iconColor,
                    ),
                    suffixIcon: Row(
                        mainAxisAlignment: MainAxisAlignment.end, //shift all stuff to the right (end)
                        mainAxisSize: MainAxisSize.min, //make row of the size of two icons
                        children: <Widget>[
                          IconButton(
                            icon: Icon(!ref.watch(_isPasswordHiddenProvider) ? visibleIcon : notVisibleIcon, size: iconSize),
                            onPressed: () => _togglePasswordVisibility(ref),
                          ),
                          IconButton(
                              icon: Icon(
                                clearTextIcon,
                                size: iconSize,
                              ),
                              onPressed: () => _clearNewPassword(ref)),
                        ])),
                onChanged: (_) => _validateNewPassword(ref),
                onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(_focusNewPasswordConfirmation),
                validator: (_) => _newPasswordValidator, //(val) => val.isEmpty ? FlutterI18n.translate(context, "FldReq") : null,
              ),
            );
          }),
    );

    //New Password Confirmation
    fields.add(
      Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            late final MaterialColor? iconColor;

            if (ref.watch(_isNewPasswordConfirmationValidProvider) == null) {
              iconColor = null;
            } else if (ref.watch(_isNewPasswordConfirmationValidProvider) == false) {
              iconColor = Theme.of(context).brightness == Brightness.light ? notValidColorLight : notValidColorDark;
            } else if (ref.watch(_isNewPasswordConfirmationValidProvider) == true) {
              iconColor = Theme.of(context).brightness == Brightness.light ? validColorLight : validColorDark;
            }

            return Padding(
              padding: const EdgeInsets.only(top: myTopPadding),
              child: TextFormField(
                controller: ref.watch(_newPasswordConfirmationInputControllerProvider),
                focusNode: _focusNewPasswordConfirmation,
                style: textStyleTitleLarge,
                obscureText: ref.watch(_isPasswordHiddenProvider),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
                ],
                enabled: !isProcessing,
                decoration: InputDecoration(
                    hintText: "MinPasswordLength".tr(args: [minUserPasswordLength.toString()]),
                    hintStyle: textBodyMedium,
                    labelText: "ConfirmPassword".tr(),
                    labelStyle: textBodyLarge,
                    prefixIcon: Icon(
                      passwordIcon,
                      size: iconSize,
                      color: iconColor,
                    ),
                    suffixIcon: Row(
                        mainAxisAlignment: MainAxisAlignment.end, //shift all stuff to the right (end)
                        mainAxisSize: MainAxisSize.min, //make row of the size of two icons
                        children: <Widget>[
                          IconButton(
                            icon: Icon(!ref.watch(_isPasswordHiddenProvider) ? visibleIcon : notVisibleIcon, size: iconSize),
                            onPressed: () => _togglePasswordVisibility(ref),
                          ),
                          IconButton(
                              icon: Icon(
                                clearTextIcon,
                                size: iconSize,
                              ),
                              onPressed: () => _clearNewPasswordConfirmation(context, ref)),
                        ])),
                onChanged: (_) => _validateNewPasswordConfirmation(ref),
                onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(_focusNewPasswordConfirmation),
                validator: (_) => _newPasswordConfirmationValidator, //(val) => val.isEmpty ? FlutterI18n.translate(context, "FldReq") : null,
              ),
            );
          }),
    );

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

  void _togglePasswordVisibility(WidgetRef ref) {
    ref.read(_isPasswordHiddenProvider.notifier).state = !ref.read(_isPasswordHiddenProvider.notifier).state;
  }

  void _clearCurrentPassword(BuildContext context, WidgetRef ref) {
    ref.read(_currentPasswordInputControllerProvider).text = "";
    _checkChangePossible(ref);
    FocusScope.of(context).requestFocus(_focusCurrentPassword);
  }

  void _clearNewPassword(WidgetRef ref) {
    ref.read(_newPasswordInputControllerProvider).text = "";
    ref.read(_isNewPasswordValidProvider.notifier).state = null;
    _validateNewPassword(ref);
  }

  void _clearNewPasswordConfirmation(BuildContext context, WidgetRef ref) {
    ref.read(_newPasswordConfirmationInputControllerProvider).text = "";
    _validateNewPasswordConfirmation(ref);
    FocusScope.of(context).requestFocus(_focusNewPasswordConfirmation);
  }

  void _validateNewPassword(WidgetRef ref) {
    var val = ref.read(_newPasswordInputControllerProvider).text;

    if (val.isEmpty) {
      _newPasswordValidator = "FieldIsRequired".tr();
      ref.read(_isNewPasswordValidProvider.notifier).state = false;
    } else if (val.length < minUserPasswordLength){
      _newPasswordValidator = null;
      ref.read(_isNewPasswordValidProvider.notifier).state = null;
    } else {
      _newPasswordValidator = null;
      ref.read(_isNewPasswordValidProvider.notifier).state = true;
    }
    if (ref.read(_newPasswordConfirmationInputControllerProvider).text.isNotEmpty) _validateNewPasswordConfirmation(ref);
    _checkChangePossible(ref);
  }

  void _validateNewPasswordConfirmation(WidgetRef ref) {
    var val = ref.read(_newPasswordConfirmationInputControllerProvider).text;

    if (val.isEmpty && ref.read(_newPasswordInputControllerProvider).text.isEmpty) {
      _newPasswordConfirmationValidator = null;
      ref.read(_isNewPasswordConfirmationValidProvider.notifier).state = null;
      return;
    }

    if (val != ref.read(_newPasswordInputControllerProvider).text) {
      _newPasswordConfirmationValidator = "PasswordsMismatch".tr();
      ref.read(_isNewPasswordConfirmationValidProvider.notifier).state = false;
    } else {
      _newPasswordConfirmationValidator = null;
      ref.read(_isNewPasswordConfirmationValidProvider.notifier).state = true;
    }
    _checkChangePossible(ref);
  }

  void _checkChangePossible(WidgetRef ref) {
    bool isNewPasswordValid = ref.read(_isNewPasswordValidProvider.notifier).state != null? ref.read(_isNewPasswordValidProvider.notifier).state! : false;
    bool isNewPasswordConfirmationValid = ref.read(_isNewPasswordConfirmationValidProvider.notifier).state != null? ref.read(_isNewPasswordConfirmationValidProvider.notifier).state! : false;

    ref.read(_isChangePossibleProvider.notifier).state = (isNewPasswordValid & isNewPasswordConfirmationValid);
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
        ref.read(_isNewPasswordValidProvider.notifier).state = null;
        ref.read(_newPasswordConfirmationInputControllerProvider).text = "";
        ref.read(_isNewPasswordConfirmationValidProvider.notifier).state = null;
        _checkChangePossible(ref);
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