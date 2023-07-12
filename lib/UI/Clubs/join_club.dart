import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Core/DTO/Base/call_error.dart';
import '../../Core/DTO/Club/join_club_request.dart';
import '../../Core/DTO/Club/join_club_response.dart';
import '../../Core/DTO/Identity/Manage/user_profile_response.dart';
import '../../Core/Vars/enums.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/app_helper.dart';
import '../../Infrastructure/BackEnd/backend_call.dart';
import '../Elements/MainSidePanel/api_error_messages.dart';
import '../Elements/basis_form.dart';
import '../Themes/app_themes.dart';

class JoinClub extends ConsumerStatefulWidget {
  const JoinClub({Key? key})
      : super(key: key);

  @override
  ConsumerState<JoinClub> createState() => JoinClubWidget();
}

class JoinClubWidget extends ConsumerState<JoinClub> {
  final double _myElevation = 3;

  final _formStateProvider = StateProvider.autoDispose<AppFormState>((ref) => AppFormState.dataInput);

  final _clubNameInputController = TextEditingController();
  final _clubPasswordInputController = TextEditingController();
  final _isClubPasswordHiddenProvider = StateProvider<bool>((ref) => true);

  final _clubNameValidationStateProvider = StateProvider<ValidationStatus>((ref) => ValidationStatus.init);

  final FocusNode _focusClubName = FocusNode();
  final FocusNode _focusClubPassword = FocusNode();
  final FocusNode _focusNodeJoinClub = FocusNode();

  final _clubNameValidatorMessage = StateProvider<String?>((ref) => null);

  List<CallError> _callErrors = []; //TODO: implementation of error handling is open!

  @override
  void dispose() {
    _clubNameInputController.dispose();
    _clubPasswordInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(_formStateProvider);
    List<Widget> fields = <Widget>[];
    final isReadOnly = formState == AppFormState.processing;
    final validationStatus = ref.watch(_clubNameValidationStateProvider);
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    final iconSize = appIconBasisSize + fontSizeDelta;
    final isError = (formState == AppFormState.httpError || formState == AppFormState.exception || formState == AppFormState.resultFailed);

    fields.add(Padding(
      padding: const EdgeInsets.all(10),
      child: Text("BecomeMember".tr(),
          textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.apply(fontWeightDelta: 1, fontSizeDelta: fontSizeDelta)),
    ));

    late final MaterialColor? iconColor;

    if (validationStatus == ValidationStatus.init) {
      iconColor = null;
    } else if (validationStatus == ValidationStatus.notValid) {
      iconColor = Theme.of(context).brightness == Brightness.light ? notValidColorLight : notValidColorDark;
    } else if (validationStatus == ValidationStatus.ok) {
      iconColor = Theme.of(context).brightness == Brightness.light ? validColorLight : validColorDark;
    }

    InputDecoration clubDecoration = InputDecoration(
        labelText: "ClubName".tr(),
        labelStyle: textStyleBodyLarge,
        prefixIcon : Icon(
          clubIcon,
          size: iconSize,
          color: iconColor,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            clearTextIcon,
            size: iconSize,
          ),
          onPressed: () => _clearClubNameInputField(context),
        ));

    //Club Name
    fields.add(
      TextFormField(
        controller: _clubNameInputController,
        focusNode: _focusClubName,
        readOnly: isReadOnly,
        style: textStyleTitleLarge,
        decoration: clubDecoration,
        onChanged: (value) => _validateClubName(value),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (_) => validationStatus == ValidationStatus.ok? null:ref.watch(_clubNameValidatorMessage),
        //onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(_focusClubPassword)
      ),
    );

    //Club Password
    fields.add(
        Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return TextFormField(
            controller: _clubPasswordInputController,
            focusNode: _focusClubPassword,
            style: textStyleTitleLarge,
            obscureText: ref.watch(_isClubPasswordHiddenProvider),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
            ],
            readOnly: isReadOnly,
            decoration: InputDecoration(
                labelText: "ClubPassword".tr(),
                labelStyle: textStyleBodyLarge,
                hintText: "Optional".tr(),
                hintStyle: textStyleBodyMedium,
                prefixIcon: Icon(
                  passwordIcon,
                  size: iconSize,
                  color: Theme.of(context).brightness == Brightness.light ? validColorLight : validColorDark,
                ),
                suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end, //shift all stuff to the right (end)
                    mainAxisSize: MainAxisSize.min, //make row of the size of two icons
                    children: <Widget>[
                      IconButton(
                        icon: Icon(!ref.watch(_isClubPasswordHiddenProvider) ? visibleIcon : notVisibleIcon, size: iconSize),
                        onPressed: _toggleClubPasswordVisibility,
                      ),
                      IconButton(
                          icon: Icon(
                            clearTextIcon,
                            size: iconSize,
                          ),
                          onPressed: _clearClubPassword),
                    ])),
            onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(_focusNodeJoinClub), //TODO: we need to fire joining club if possible
            validator: null,
          );
        }
        )
    );

    //Error Message
    if (isError) {
      fields.add(ApiErrorMessages(callErrors: _callErrors, deltaFontSize: fontSizeDelta));
    }

    //Join Button. Wrapping into consumer is need in order to avoid rebuilding of verification fields
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
                  focusNode: _focusNodeJoinClub,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Theme
                        .of(context)
                        .brightness == Brightness.light ? primaryActionButtonOkDisabledColorLight : primaryActionButtonOkDisabledColorDark,
                    backgroundColor: Theme
                        .of(context)
                        .brightness == Brightness.light ? primaryActionButtonOkEnabledColorLight : null,
                  ),
                  onPressed: validationStatus == ValidationStatus.ok ? _joinClub : null,
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("JoinClub".tr(), textAlign: TextAlign.center, style: textStyleHeadlineSmall.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider), color: Colors.white)))),
                )),
          );
        }
    ));

    Widget addClubWidget = Column(
      children: [
        Card(
          elevation: _myElevation,
          child: Padding(
            padding: const EdgeInsets.all(formPadding),
            child: Column(children: fields), //Sign-in Form
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: formPadding)),
      ],
    );


    return BasisForm(formTitle: "Clubs".tr(), form: addClubWidget);
  }

  _clearClubNameInputField(BuildContext context) {
    _clubNameInputController.clear();
    _validateClubName(_clubNameInputController.text);
    FocusScope.of(context).requestFocus(_focusClubName);
  }

  _validateClubName(String value) {
    if (value.isEmpty) {
      ref.read(_clubNameValidatorMessage.notifier).state = "FieldIsRequired".tr();
      ref.read(_clubNameValidationStateProvider.notifier).state = ValidationStatus.notValid;
    } else {
      ref.read(_clubNameValidatorMessage.notifier).state = null;
      ref.read(_clubNameValidationStateProvider.notifier).state = ValidationStatus.ok;
    }
  }

  void _toggleClubPasswordVisibility() {
    ref.read(_isClubPasswordHiddenProvider.notifier).state = !ref.read(_isClubPasswordHiddenProvider.notifier).state;
  }

  void _clearClubPassword() {
    _clubPasswordInputController.text = "";
  }

  _joinClub() {
    _callErrors = [];

    ref.read(_formStateProvider.notifier).state = AppFormState.processing;

    ref.read(joinClubRequestProvider.notifier).state = JoinClubRequest(
        clubName: _clubNameInputController.text,
        clubPassword: _clubPasswordInputController.text,
        passwordType: PasswordType.plainText,
        endDevice: appPlatform);

    var joinClubResult = ref.watch(joinClubProvider.future);

    joinClubResult.then((data) {
      if (data.resultCode == AppResultCode.ok) {
        ref.read(_formStateProvider.notifier).state = AppFormState.resultOk;
        AppHelper.showSnack(context: context, message: "WelcomeToClub".tr(args: [_clubNameInputController.text]));
        ref.invalidate(getUserProfileProvider);
        Navigator.pop(context);
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