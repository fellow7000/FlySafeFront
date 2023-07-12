import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Base/call_error.dart';
import 'package:fs_front/Core/DTO/Identity/authentification_requrest.dart';
import 'package:fs_front/Core/DTO/Identity/authentification_response.dart';
import 'package:fs_front/Core/Vars/globals.dart';
import 'package:fs_front/Helpers/identity_helper.dart';
import 'package:fs_front/UI/Elements/MainSidePanel/api_error_messages.dart';
import 'package:fs_front/UI/Elements/hyper_link.dart';
import 'package:fs_front/UI/Identity/Elements/or_divider.dart';

import '../../Core/Vars/enums.dart';
import '../../Core/Vars/providers.dart';
import '../../Infrastructure/BackEnd/backend_call.dart';
import '../Themes/app_themes.dart';

class LogInUserOrClub extends ConsumerStatefulWidget {
  final List<String>? publicClubs;
  final String selectClubHint;
  final String logInLabel;
  final String closeLabel;
  final String orLabel;
  final String toggleLoginTypeLabel;
  final String userFieldLabel;
  final String userNameOrEmailOrClubNameLabel;
  final String passwordLabel;
  final String forgotPasswordLabel;
  final String dontHaveAccountLabel;
  final String signUpLabel;
  final String itsFreeLabel;
  final String fieldIsRequiredLabel;

  const LogInUserOrClub(
      {this.publicClubs,
      required this.selectClubHint,
      required this.logInLabel,
      required this.closeLabel,
      required this.orLabel,
      required this.toggleLoginTypeLabel,
      required this.userFieldLabel,
      required this.userNameOrEmailOrClubNameLabel,
      required this.passwordLabel,
      required this.forgotPasswordLabel,
      required this.dontHaveAccountLabel,
      required this.signUpLabel,
      required this.itsFreeLabel,
      required this.fieldIsRequiredLabel,
      Key? key})
      : super(key: key);

  @override
  ConsumerState<LogInUserOrClub> createState() => LogInUserOrClubWidget();
}

class LogInUserOrClubWidget extends ConsumerState<LogInUserOrClub> {
  final _formKey = GlobalKey<FormState>();

  final _userNameInputControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
    final textController = TextEditingController();
    ref.onDispose(() {
      textController.dispose();
    });
    return textController;
  });

  final TextEditingController _passwordInputController = TextEditingController();
  final FocusNode _focusUserName = FocusNode();
  final FocusNode _focusUserOrClubPassword = FocusNode();
  final FocusNode _focusNodeSignIn = FocusNode();

  final _isLoggingInProvider = StateProvider.autoDispose<bool>((ref) => false);

  final _isPasswordHiddenProvider = StateProvider<bool>((ref) => true);
  final _isLoginPossibleProvider = StateProvider<bool>((ref) => false);

  final _isError = StateProvider<bool>((ref) => false);
  List<CallError> _callErrors = []; //TODO: implementation of error handling is open!

  @override
  void dispose() {
    super.dispose();
    _passwordInputController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    final iconSize = appIconBasisSize + fontSizeDelta;
    TextStyle textStyleTitleLarge = Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: fontSizeDelta);
    TextStyle textStyleBodyMediumLink = Theme.of(context).textTheme.bodyLarge!.apply(color: Colors.blue[Theme.of(context).brightness == Brightness.light ? 900 : 500], fontSizeDelta: fontSizeDelta);
    TextStyle textStyleBodyLarge = Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: fontSizeDelta);

    List<Widget> fields = <Widget>[];

    fields.add(Padding(
      padding: const EdgeInsets.all(10),
      child: Text("LogInToFlySafe".tr(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.apply(fontWeightDelta: 1, fontSizeDelta: fontSizeDelta)), //TODO: replace with code label
    ));

    if (ref.watch(toSignAsProvider) == LogAs.userOrClub) {
      //User or Club Name
      fields.add(FocusTraversalOrder(
        order: const NumericFocusOrder(1),
        child: TextFormField(
            controller: ref.watch(_userNameInputControllerProvider),
            focusNode: _focusUserName,
            autofocus: kIsWeb ? true : false,
            style: textStyleTitleLarge,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
            ],
            enableSuggestions: true,
            decoration: InputDecoration(
                hintText: widget.userFieldLabel,
                hintStyle: textStyleBodyLarge,
                labelText: widget.userNameOrEmailOrClubNameLabel,
                labelStyle: textStyleBodyLarge,
                prefixIcon: Icon(
                  userIcon,
                  size: iconSize,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    clearTextIcon,
                    size: iconSize,
                  ),
                  onPressed: () => _clearUserNameField(ref),
                )),
            validator: (val) => val!.isEmpty ? widget.fieldIsRequiredLabel : null,
            onChanged: (value) => value.isEmpty ? ref.read(_isLoginPossibleProvider.notifier).state = false : ref.read(_isLoginPossibleProvider.notifier).state = true,
            //onSaved: (val) => InitValue.uName = val,
            onFieldSubmitted: (val) {
              FocusScope.of(context).requestFocus(_focusUserOrClubPassword);
            }),
      ));
    } else {
      //Dropdown Public Clubs
      Widget selectClubDropDownButton = FocusTraversalOrder(
        order: const NumericFocusOrder(1),
        child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              prefixIcon: Icon(clubIcon, size: iconSize),
              suffixIcon: IconButton(onPressed: _reloadPublicClubs, icon: Icon(
                retryIcon,
                size: iconSize,
              ))
            ),
            selectedItemBuilder: (BuildContext context) {
              return widget.publicClubs!=null
                ? widget.publicClubs!.map<Widget>((String item) {
                return Container(
                  alignment: Alignment.centerLeft,
                  constraints: const BoxConstraints(minWidth: 100),
                  child: Text(
                    item,
                    style: textStyleBodyLarge,
                  ),
                );
              }).toList()
              : [];
            },
            isExpanded: true,
            items: widget.publicClubs?.map((String club) {
              return DropdownMenuItem<String>(value: club, child: Padding(padding: const EdgeInsets.only(left: 5), child: FittedBox(fit: BoxFit.scaleDown, child: Text(club, style: textStyleBodyLarge,))));
            }).toList(),
            value: ref.watch(selectedPublicClubProvider),
            hint: Padding(padding: const EdgeInsets.only(left: 10), child: Text(widget.selectClubHint, style: textStyleBodyLarge,)),
            onChanged: (club) => _selectPublicClub(club!)),
      );

      fields.add(selectClubDropDownButton);
    }

    //User or Club Password
    fields.add(
      Padding(
        padding: const EdgeInsets.only(top:5),
        child: FocusTraversalOrder(
          order: const NumericFocusOrder(2),
          child: TextFormField(
            controller: _passwordInputController,
            focusNode: _focusUserOrClubPassword,
            style: textStyleTitleLarge,
            obscureText: ref.watch(_isPasswordHiddenProvider),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
            ],
            decoration: InputDecoration(
                hintText: widget.passwordLabel,
                hintStyle: textStyleBodyLarge,
                labelText: widget.passwordLabel,
                labelStyle: textStyleBodyLarge,
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
                        onPressed: _togglePasswordVisibility,
                      ),
                      IconButton(icon: Icon(clearTextIcon, size: iconSize), onPressed: _passwordInputController.clear),
                    ])),
            onFieldSubmitted: (value) => ref.watch(_isLoginPossibleProvider) ? _logIn() : null,
            validator: null, //(val) => val.isEmpty ? FlutterI18n.translate(context, "FldReq") : null,
          ),
        ),
      ),
    );

    //Error Message
    if (ref.watch(_isError)) {
      fields.add(ApiErrorMessages(callErrors: _callErrors, deltaFontSize: ref.watch(deltaFontSizeProvider)));
    }

    //Forgot Password
    if (ref.watch(toSignAsProvider) == LogAs.userOrClub) {
      fields.add(Padding(
        padding: const EdgeInsets.only(top: 20),
        child: GestureDetector(
          onTap: _toPasswordRecovery,
          child: HyperLink(
            link: widget.forgotPasswordLabel,
            style: textStyleBodyMediumLink,
          ),
        ),
      ));
    }

    //log in to the system Button
    Widget logInButton = Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ref.watch(_isLoggingInProvider)
          ? const CircularProgressIndicator()
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                focusNode: _focusNodeSignIn,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Theme.of(context).brightness == Brightness.light ? primaryActionButtonOkDisabledColorLight : primaryActionButtonOkDisabledColorDark,
                  backgroundColor: Theme.of(context).brightness == Brightness.light ? primaryActionButtonOkEnabledColorLight : null,
                ),
                onPressed: ref.watch(_isLoginPossibleProvider) ? _logIn : null,
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(widget.logInLabel, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.apply(color: Colors.white, fontSizeDelta: fontSizeDelta)))),
              )),
    );
    fields.add(logInButton);

    fields.add(OrDivider(orLabel: widget.orLabel));

    //To public or user / non-listed clubs
    fields.add(Padding(
      padding: const EdgeInsets.only(top: 10),
      child: GestureDetector(
        onTap: _toggleLoginType,
        child: HyperLink(
            link: widget.toggleLoginTypeLabel,
            style: Theme.of(context).textTheme.titleLarge?.apply(fontSizeDelta: fontSizeDelta, fontWeightDelta: -1, color: Colors.blue[Theme.of(context).brightness == Brightness.light ? 900 : 500])),
      ),
    ));

    Widget signInForm = Padding(
      padding: const EdgeInsets.all(15),
      child: Column(children: fields), //Sign-in Form
    );

    return Form(
        key: _formKey,
        child: Column(
          children: [
            Card(
              elevation: 3,
              child: signInForm,
            ),
            const Padding(padding: EdgeInsets.only(top: 15)),
          ],
        ));
  }

  void _clearUserNameField(WidgetRef ref) {
    ref.read(_userNameInputControllerProvider).clear();
    ref.read(_isLoginPossibleProvider.notifier).state = false;
  }

  void _togglePasswordVisibility() {
    ref.read(_isPasswordHiddenProvider.notifier).state = !ref.read(_isPasswordHiddenProvider.notifier).state;
  }

  void _logIn() {
    ref.read(_isLoggingInProvider.notifier).state = true;

    final form = _formKey.currentState;
    form?.validate(); //TODO: not clear what to do if validation fails

    ref.read(_isError.notifier).state = false;
    _callErrors = [];

    var loginName = ref.read(toSignAsProvider.notifier).state == LogAs.userOrClub?ref.read(_userNameInputControllerProvider).text:ref.read(selectedPublicClubProvider.notifier).state!;

    ref.read(authentificationRequestProvider.notifier).state = AuthentificationRequest(
        userNameOrEmail: loginName,
        password: _passwordInputController.text,
        passwordType: PasswordType.plainText,
        logAs: ref.read(toSignAsProvider.notifier).state,
        returnPasswordHash: true,
        endDevice: appPlatform,
        keepSignedIn: true);

    var loginResult = ref.watch(signInProvider.future);

    loginResult.then((data) {
      ref.read(_isLoggingInProvider.notifier).state = false;
      if (data.resultCode == AppResultCode.ok) {
        IdentityHelper.processSignInUpResponse(ref: ref, loginName: loginName, hash: data.hash, token: data.accessToken, logAs: data.logAs);
        ref.read(_isError.notifier).state = false;
        _callErrors = [];
        requestStartUpSignIn = false;
        Navigator.pop(scaffoldKeySignIn.currentContext!);
      } else {
        _passwordInputController.clear();
        _callErrors = data.errors;
        ref.read(_isError.notifier).state = true;
        FocusScope.of(context).requestFocus(_focusUserOrClubPassword);
      }
    }).onError((error, stackTrace) {
      _callErrors = [BackEndCall.callExceptionError];
      ref.read(_isError.notifier).state = true;
      ref.read(_isLoggingInProvider.notifier).state = false;
    });
  }

  void _selectPublicClub(String club) {
    ref.read(selectedPublicClubProvider.notifier).state = club;
    ref.read(_isLoginPossibleProvider.notifier).state = true;
  }

  void _reloadPublicClubs() {
    ref.read(selectedPublicClubProvider.notifier).state = null;
    return ref.refresh(publicClubsProvider);
  }

  void _toggleLoginType() {
    _clearInputFields();

    if (ref.read(toSignAsProvider.notifier).state == LogAs.userOrClub) {
      ref.read(toSignAsProvider.notifier).state = LogAs.club;
    } else {
      ref.read(toSignAsProvider.notifier).state = LogAs.userOrClub;
    }
  }

  void _toPasswordRecovery() {
    ref.read(toSignAsProvider.notifier).state = LogAs.forgotPassword;
  }

  void _clearInputFields() {
    _passwordInputController.clear();
    ref.read(_userNameInputControllerProvider).clear();
    ref.watch(selectedPublicClubProvider.notifier).state = null;
    ref.read(_isLoginPossibleProvider.notifier).state = false;
  }
}
