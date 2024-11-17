import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Identity/reset_user_password_request.dart';
import 'package:fs_front/Core/Vars/globals.dart';
import 'package:fs_front/Helpers/app_helper.dart';

import '../../Core/DTO/Base/call_error.dart';
import '../../Core/DTO/Identity/reset_user_password_response.dart';
import '../../Core/Vars/enums.dart';
import '../../Core/Vars/providers.dart';
import '../../Infrastructure/BackEnd/backend_call.dart';
import '../Elements/MainSidePanel/api_error_messages.dart';
import '../Elements/hyper_link.dart';
import '../Themes/app_themes.dart';
import 'Elements/or_divider.dart';

class RequestPasswordReset extends ConsumerStatefulWidget {
  final String forgotPasswordHeader;
  final String forgotPasswordHint;
  final String enterEmailLabel;
  final String emailHint;
  final String emailLabel;
  final String resetLabel;
  final String orLabel;
  final String logInLabel;
  final String fieldIsRequiredLabel;
  final String resetPasswordConfirmationLabel;

  const RequestPasswordReset(
      {super.key,
      required this.forgotPasswordHeader,
      required this.forgotPasswordHint,
      required this.enterEmailLabel,
      required this.emailHint,
      required this.emailLabel,
      required this.resetLabel,
      required this.orLabel,
      required this.logInLabel,
      required this.fieldIsRequiredLabel,
      required this.resetPasswordConfirmationLabel});

  @override
  ConsumerState<RequestPasswordReset> createState() =>
      RequestPasswordResetWidget();
}

class RequestPasswordResetWidget extends ConsumerState<RequestPasswordReset> {
  final _formKey = GlobalKey<FormState>();

  final _emailInputControllerProvider =
      Provider.autoDispose<TextEditingController>((ref) {
    final textController = TextEditingController();
    ref.onDispose(() {
      textController.dispose();
    });
    return textController;
  });

  final FocusNode _focusEmail = FocusNode();

  final _isResetPossibleProvider =
      StateProvider.autoDispose<bool>((ref) => false);
  final _resetStateProvider =
      StateProvider.autoDispose<AppFormState>((ref) => AppFormState.dataInput);

  final _isError = StateProvider<bool>((ref) => false);
  List<CallError> _callErrors =
      []; //TODO: implementation of error handling is open!

  @override
  Widget build(BuildContext context) {
    final iconSize = appIconBasisSize + ref.watch(deltaFontSizeProvider);
    final resetPasswordState = ref.watch(_resetStateProvider);

    List<Widget> fields = <Widget>[];

    if (resetPasswordState == AppFormState.dataInput ||
        resetPasswordState == AppFormState.processing ||
        resetPasswordState == AppFormState.resultFailed ||
        resetPasswordState == AppFormState.httpError) {
      fields.add(Padding(
        padding: const EdgeInsets.all(10),
        child: Text(widget.forgotPasswordHeader,
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.apply(fontWeightDelta: 1)),
      ));

      fields.add(Padding(
        padding: const EdgeInsets.all(10),
        child: Text(widget.forgotPasswordHint,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.apply(fontWeightDelta: 0)),
      ));

      //Email input field
      fields.add(TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: ref.watch(_emailInputControllerProvider),
          focusNode: _focusEmail,
          autofocus: kIsWeb ? true : false,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ ]'))],
          style: Theme.of(context).textTheme.titleLarge,
          decoration: InputDecoration(
              hintText: widget.emailHint,
              hintStyle: Theme.of(context).textTheme.bodyMedium,
              labelText: widget.emailLabel,
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              prefixIcon: Icon(
                Icons.email,
                size: iconSize,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () => _clearEmailField(ref),
              )),
          validator: (val) =>
              AppHelper.isEmailValid(val!) ? null : widget.fieldIsRequiredLabel,
          onChanged: (value) => AppHelper.isEmailValid(value)
              ? ref.read(_isResetPossibleProvider.notifier).state = true
              : ref.read(_isResetPossibleProvider.notifier).state = false,
          onFieldSubmitted: ((value) =>
              ref.watch(_isResetPossibleProvider) ? _resetPassword() : null)));

      //Error Message
      if (ref.watch(_isError)) {
        fields.add(ApiErrorMessages(
            callErrors: _callErrors,
            deltaFontSize: ref.watch(deltaFontSizeProvider)));
      }

      //Reset Button
      fields.add(Padding(
        padding: const EdgeInsets.only(top: 20),
        child: resetPasswordState == AppFormState.processing
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? primaryActionButtonOkDisabledColorLight
                            : primaryActionButtonOkDisabledColorDark,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? primaryActionButtonOkEnabledColorLight
                            : null,
                  ),
                  onPressed: ref.watch(_isResetPossibleProvider)
                      ? _resetPassword
                      : null,
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(widget.resetLabel,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.apply(color: Colors.white)))),
                )),
      ));

      fields.add(OrDivider(orLabel: widget.orLabel));
    } else if (resetPasswordState == AppFormState.resultOk) {
      //Email sent confirmation text
      fields.add(Padding(
        padding: const EdgeInsets.all(10),
        child: Text(widget.resetPasswordConfirmationLabel,
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.apply(fontWeightDelta: 0)),
      ));

      fields.add(const Divider(
        thickness: 2,
        height: 2,
      ));
    } //TODO: not all alternatives and error handling implemented!!!

    //Sign-in link
    fields.add(Padding(
      padding: const EdgeInsets.only(top: 10),
      child: GestureDetector(
        onTap: _toSignIn,
        child: HyperLink(
            link: widget.logInLabel,
            style: Theme.of(context).textTheme.titleLarge?.apply(
                fontWeightDelta: -1,
                color: Colors.blue[
                    Theme.of(context).brightness == Brightness.light
                        ? 900
                        : 500])),
      ),
    ));

    Widget forgotPasswordForm = Padding(
      padding: const EdgeInsets.all(15),
      child: Column(children: fields), //Sign-in Form
    );

    return Form(
        key: _formKey,
        child: Column(
          children: [
            Card(
              elevation: 3,
              child: forgotPasswordForm,
            ),
            const Padding(padding: EdgeInsets.only(top: 15)),
          ],
        ));
  }

  void _clearEmailField(WidgetRef ref) {
    ref.read(_emailInputControllerProvider).clear();
    ref.read(_isResetPossibleProvider.notifier).state = false;
  }

  void _resetPassword() {
    final form = _formKey.currentState;
    form?.validate(); //TODO: what to do if form validation fails?

    ref.read(_isError.notifier).state = false;
    _callErrors = [];

    ref.read(_resetStateProvider.notifier).state = AppFormState.processing;

    ref.read(resetUserPasswordRequestProvider.notifier).state =
        ResetUserPasswordRequest(
            locale: context.locale.toString().replaceAll("_", "-"),
            email: ref.read(_emailInputControllerProvider).text,
            endDevice: appPlatform);

    var passwordResetResult = ref.watch(resetUserPasswordProvider.future);

    passwordResetResult.then((data) {
      if (data.resultCode == AppResultCode.ok) {
        // Update the state for a successful result
        ref.read(_resetStateProvider.notifier).state = AppFormState.resultOk;
      } else {
        // Call a method to handle errors, including context-dependent actions
        _handlePasswordResetFailure(data.errors);
      }
    }).onError((error, stackTrace) {
      // Handle exceptions and call the error handler
      _handlePasswordResetFailure([BackEndCall.callExceptionError]);
    });
  }

// Define a method to handle password reset failure
  void _handlePasswordResetFailure(List<CallError> errors) {
    _callErrors = errors;
    ref.read(_isError.notifier).state = true;
    ref.read(_resetStateProvider.notifier).state = AppFormState.resultFailed;
    ref.read(_isResetPossibleProvider.notifier).state = true;

    // Perform context-dependent operations only if mounted
    if (mounted) {
      FocusScope.of(context).requestFocus(_focusEmail);
    }
  }

  void _toSignIn() {
    ref.read(toSignAsProvider.notifier).state = LogAs.userOrClub;
  }
}
