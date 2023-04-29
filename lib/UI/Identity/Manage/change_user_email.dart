import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/UI/Elements/basis_form.dart';

import '../../../Core/DTO/Base/call_error.dart';
import '../../../Core/DTO/Generic/check_value_request.dart';
import '../../../Core/DTO/Identity/Manage/change_user_email.request.dart';
import '../../../Core/DTO/Identity/Manage/change_user_email_response.dart';
import '../../../Core/DTO/Identity/Manage/user_profile_response.dart';
import '../../../Core/Vars/enums.dart';
import '../../../Core/Vars/globals.dart';
import '../../../Core/Vars/providers.dart';
import '../../../Helpers/app_helper.dart';
import '../../../Infrastructure/BackEnd/IdentityCalls/i_api_identity.dart';
import '../../../Infrastructure/BackEnd/backend_call.dart';
import '../../Elements/MainSidePanel/api_error_messages.dart';
import '../../Elements/textformfield_validate.dart';
import '../../Themes/app_themes.dart';

class ChangeUserEmail extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final _formStateProvider = StateProvider.autoDispose<AppFormState>((ref) => AppFormState.dataInput);

  final _signUpStateProvider = StateProvider.autoDispose<AppFormState>((ref) => AppFormState.dataInput);

  final UserProfileResponse userProfile;

  static const double myTopPadding = 0;

  final _isEmailValidProvider = StateProvider<bool>((ref) => true);
  final _checkEmailValidProvider = StateProvider<CheckValueRequest?>(
          (ref) => const CheckValueRequest(value: "", timeStamp: "", apiController: IApiIdentity.identityController, apiHandler: IApiIdentity.checkEmailFreeFreeHandler, isAuthorized: true));
  final _emailValidationStateProvider = StateProvider<ValidationStatus>((ref) => ValidationStatus.ok);

  late final AutoDisposeProvider<TextEditingController> _emailInputControllerProvider;

  List<CallError> _callErrors = []; //TODO: implementation of error handling is open!

  ChangeUserEmail({required this.userProfile, super.key}) {
    _emailInputControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
      final textController = TextEditingController(text: userProfile.email);
      ref.onDispose(() {
        textController.dispose();
      });
      return textController;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(_formStateProvider);
    final isEnabled = formState != AppFormState.processing;
    final logAs = ref.watch(authStateProvider);
    final isError = (formState == AppFormState.httpError || formState == AppFormState.exception || formState == AppFormState.resultFailed);

    List<Widget> fields = <Widget>[];

    fields.add(Padding(
      padding: const EdgeInsets.all(10),
      child: Text("${"User".tr()} ${userProfile.userName}",
          textAlign: TextAlign.center, style: textStyleHeadlineSmall), //TODO: replace with code label
    ));

    //User email
    if (logAs == LogAs.user) {
      fields.add(Padding(
        padding: const EdgeInsets.only(top: myTopPadding),
        child: TextFormFieldOnlineValidate(
          validationType: ValidationType.email,
          fieldNotValidLabel: "EmailAlreadyTaken".tr(),
          isFieldValidProvider: _isEmailValidProvider,
          checkValueRequestProvider: _checkEmailValidProvider,
          validationStateProvider: _emailValidationStateProvider,
          timeStampChecker: emailValidationStampProvider,
          prefixIcon: emailIcon,
          keyboardType: TextInputType.emailAddress,
          controller: ref.watch(_emailInputControllerProvider),
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ ]'))],
          enabled: isEnabled,
          style: Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
          decoration: InputDecoration(labelText: "Email".tr(), labelStyle: textStyleTitleLarge),
          //onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(_focusUserPassword)
        ),
      ));
    }

    //Error Message
    if (isError) {
      fields.add(ApiErrorMessages(callErrors: _callErrors, deltaFontSize: ref.watch(deltaFontSizeProvider)));
    }

    //Change Email Button
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
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: primaryActionButtonDefDisabledColor,
                    backgroundColor: Theme
                        .of(context)
                        .brightness == Brightness.light ? primaryActionButtonDefEnabledColorLight : null,
                  ),
                  onPressed: ref.watch(_isEmailValidProvider) ? () => _changeUserEmail(context, ref) : null,
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("ChangeEmail".tr(), textAlign: TextAlign.center, style: textStyleHeadlineSmallButton))),
                )),
          );
        }
    ));

    return BasisForm(
      formTitle: "Email".tr(),
      form:
      Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(children: fields), //Sign-in Form
        ),
      ),
    );
  }

  void _changeUserEmail(BuildContext context, WidgetRef ref) {
    _callErrors = [];
    ref.read(_formStateProvider.notifier).state = AppFormState.processing;

    ref.read(changeUserEmailRequestProvider.notifier).state = ChangeUserEmailRequest(
        newEmail: ref.read(_emailInputControllerProvider).text);

    var changeResult = ref.watch(changeUserEmailProvider.future);

    changeResult.then((data) {
      if (data.success) {
        ref.read(_formStateProvider.notifier).state = AppFormState.resultOk;
        AppHelper.showSnack(context: context, message: "EmailChangeSuccess".tr());
        ref.invalidate(getUserProfileProvider);
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