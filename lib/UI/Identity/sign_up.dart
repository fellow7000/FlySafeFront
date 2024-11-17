import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Infrastructure/BackEnd/IdentityCalls/i_api_identity.dart';
import 'package:fs_front/UI/Elements/Dialogs/club_dialog.dart';
import 'package:fs_front/UI/Elements/switch_or_check_list_tile.dart';

import '../../Core/DTO/Base/call_error.dart';
import '../../Core/DTO/Generic/check_value_request.dart';
import '../../Core/DTO/Identity/registration_request.dart';
import '../../Core/DTO/Identity/registration_response.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/identity_helper.dart';
import '../../Infrastructure/BackEnd/ClubCalls/i_api_club.dart';
import '../../Infrastructure/BackEnd/backend_call.dart';
import '../Elements/MainSidePanel/api_error_messages.dart';
import '../Elements/textformfield_validate.dart';
import '../Themes/app_themes.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => SignUpWidget();
}

class SignUpWidget extends ConsumerState<SignUp> {
  final _formKey = GlobalKey<FormState>();

  final _signUpStateProvider = StateProvider.autoDispose<AppFormState>((ref) => AppFormState.dataInput);

  final _userNameInputControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
    final textController = TextEditingController();
    ref.onDispose(() {
      textController.dispose();
    });
    return textController;
  });

  final _emailInputControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
    final textController = TextEditingController();
    ref.onDispose(() {
      textController.dispose();
    });
    return textController;
  });

  final _userPasswordInputControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
    final textController = TextEditingController();
    ref.onDispose(() {
      textController.dispose();
    });
    return textController;
  });

  final _clubNameInputControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
    final textController = TextEditingController();
    ref.onDispose(() {
      textController.dispose();
    });
    return textController;
  });

  final TextEditingController _clubCommentInputController = TextEditingController();

  final TextEditingController _userPasswordConfirmationInputController = TextEditingController();

  //final TextEditingController _clubNameInputController = TextEditingController();
  final TextEditingController _clubPasswordInputController = TextEditingController();
  final TextEditingController _clubPasswordConfirmationInputController = TextEditingController();

  //final _isSigningUnProvider = StateProvider.autoDispose<bool>((ref) => false);

  final _isUserPasswordHiddenProvider = StateProvider<bool>((ref) => true);
  final _isClubPasswordHiddenProvider = StateProvider<bool>((ref) => true);

  final _isClubPublicProvider = StateProvider<bool>((ref) => false);

  final _isSignUpPossibleProvider = StateProvider<bool>((ref) => false);

  final FocusNode _focusUserName = FocusNode();
  final FocusNode _focusEmail = FocusNode();
  final FocusNode _focusUserPassword = FocusNode();
  final FocusNode _focusUserPasswordConfirmation = FocusNode();
  final FocusNode _focusNodeSignUp = FocusNode();
  final FocusNode _focusClubName = FocusNode();
  final FocusNode _focusClubComment = FocusNode();
  final FocusNode _focusClubPassword = FocusNode();
  final FocusNode _focusClubPasswordConfirmation = FocusNode();
  final FocusNode _focusClubVisibility = FocusNode();

  final _checkUserNameValidProvider = StateProvider<CheckValueRequest?>((ref) => const CheckValueRequest(value: "",timeStamp: "", apiController: IApiIdentity.identityController, apiHandler: IApiIdentity.checkUserNameFreeHandler, isAuthorized: false));
  final _usernameValidationStateProvider = StateProvider<ValidationStatus>((ref) => ValidationStatus.init);

  final _checkEmailValidProvider = StateProvider<CheckValueRequest?>((ref) => const CheckValueRequest(value: "",timeStamp: "",  apiController: IApiIdentity.identityController, apiHandler: IApiIdentity.checkEmailFreeFreeHandler, isAuthorized: false));
  final _emailValidationStateProvider = StateProvider<ValidationStatus>((ref) => ValidationStatus.init);

  final _isUserNameValidProvider = StateProvider<bool>((ref) => false);
  final _isEmailValidProvider = StateProvider<bool>((ref) => false);

  final _isUserPasswordValidProvider = StateProvider<bool?>((ref) => null);
  String? _userPasswordValidator;

  final _isUserPasswordConfirmationValidProvider = StateProvider<bool?>((ref) => null);
  String? _userPasswordConfirmationValidator;

  final _checkClubNameValidProvider = StateProvider<CheckValueRequest?>((ref) => const CheckValueRequest(value: "",timeStamp: "",  apiController: IApiClub.clubController, apiHandler: IApiClub.checkClubNameFreeHandler, isAuthorized: false));
  final _clubNameValidationStateProvider = StateProvider<ValidationStatus>((ref) => ValidationStatus.ok); //by default it's ok
  final _isClubNameValidProvider = StateProvider<bool>((ref) => true); //empty club name is valid

  final _isClubPasswordConfirmationValidProvider = StateProvider<bool>((ref) => true); //empty club passwords are valid by default
  String? _clubPasswordConfirmationValidator;

  List<CallError> _callErrors = []; //TODO: implementation of error handling is open!

  static const double myTopPadding = 5;

  @override
  void dispose() {
    super.dispose();
    _userPasswordConfirmationInputController.dispose();
    _clubCommentInputController.dispose();
    //_clubNameInputController.dispose();
    _clubPasswordInputController.dispose();
    _clubPasswordConfirmationInputController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(_signUpStateProvider);
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    final iconSize = appIconBasisSize + ref.watch(deltaFontSizeProvider);
    final myFont = Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider));
    debugPrint(myFont.toString());
    final isReadOnly = formState == AppFormState.processing;
    final isError = (formState == AppFormState.httpError || formState == AppFormState.exception || formState == AppFormState.resultFailed);

    List<Widget> fields = <Widget>[];

    fields.add(Padding(
      padding: const EdgeInsets.all(10),
      child: Text("${"SignUp".tr()}. ${"ItsFree".tr()}", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.apply(fontWeightDelta: 1, fontSizeDelta: ref.watch(deltaFontSizeProvider))), //TODO: replace with code label
    ));

    //Username
    fields.add(TextFormFieldOnlineValidate(
        validationType: ValidationType.field,
        fieldNotValidLabel: "UserNameAlreadyTaken".tr(),
        isFieldValidProvider: _isUserNameValidProvider,
        checkValueRequestProvider: _checkUserNameValidProvider,
        validationStateProvider: _usernameValidationStateProvider,
        timeStampChecker: userNameValidationStampProvider,
        prefixIcon: userIcon,
        controller: ref.watch(_userNameInputControllerProvider),
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
        ],
        focusNode: _focusUserName,
        autofocus: kIsWeb ? true : false,
        readOnly: isReadOnly,
        style: Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
        decoration: InputDecoration(
            labelText: "UserName".tr(),
            labelStyle: Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider))),
        groupValidation: _checkSignUpPossible,
        onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(_focusEmail)));

    //Email
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
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
          ],
          focusNode: _focusEmail,
          readOnly: isReadOnly,
          style: Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
          decoration: InputDecoration(
              labelText: "Email".tr(),
              labelStyle: Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider))),
          groupValidation: _checkSignUpPossible,
          onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(_focusUserPassword)),
    ));

    //User Password
    fields.add(
      Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          late final MaterialColor? iconColor;

          if (ref.watch(_isUserPasswordValidProvider) == null) {
            iconColor = null;
          } else if (ref.watch(_isUserPasswordValidProvider) == false) {
            iconColor = Theme.of(context).brightness == Brightness.light ? notValidColorLight : notValidColorDark;
          } else if (ref.watch(_isUserPasswordValidProvider) == true) {
            iconColor = Theme.of(context).brightness == Brightness.light ? validColorLight : validColorDark;
          }

          return Padding(
            padding: const EdgeInsets.only(top: myTopPadding),
            child: TextFormField(
              controller: ref.watch(_userPasswordInputControllerProvider),
              focusNode: _focusUserPassword,
              style: Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
              obscureText: ref.watch(_isUserPasswordHiddenProvider),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
              ],
              readOnly: isReadOnly,
              decoration: InputDecoration(
                hintText: "MinPasswordLength".tr(args: [minUserPasswordLength.toString()]),
                hintStyle: Theme.of(context).textTheme.bodyMedium!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
                labelText: "Password".tr(),
                labelStyle: Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
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
                          icon: Icon(!ref.watch(_isUserPasswordHiddenProvider) ? visibleIcon : notVisibleIcon, size: iconSize),
                          onPressed: _toggleUserPasswordVisibility,
                        ),
                        IconButton(
                            icon: Icon(
                              clearTextIcon,
                              size: iconSize,
                            ),
                            onPressed: () => _clearUserPassword(ref)),
                      ])),
              onChanged: (_) => _validateUserPassword(),
              onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(_focusUserPasswordConfirmation),
              validator: (_) => _userPasswordValidator, //(val) => val.isEmpty ? FlutterI18n.translate(context, "FldReq") : null,
            ),
          );
        }),
    );

    //User Password Confirmation
    fields.add(
      Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
        late final MaterialColor? iconColor;

        if (ref.watch(_isUserPasswordConfirmationValidProvider) == null) {
          iconColor = null;
        } else if (ref.watch(_isUserPasswordConfirmationValidProvider) == false) {
          iconColor = Theme.of(context).brightness == Brightness.light ? notValidColorLight : notValidColorDark;
        } else if (ref.watch(_isUserPasswordConfirmationValidProvider) == true) {
          iconColor = Theme.of(context).brightness == Brightness.light ? validColorLight : validColorDark;
        }

        return Padding(
          padding: const EdgeInsets.only(top: myTopPadding),
          child: TextFormField(
            controller: _userPasswordConfirmationInputController,
            focusNode: _focusUserPasswordConfirmation,
            style: Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
            obscureText: ref.watch(_isUserPasswordHiddenProvider),
            autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
              ],
            readOnly: isReadOnly,
            decoration: InputDecoration(
                labelText: "ConfirmPassword".tr(),
                labelStyle: Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
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
                        icon: Icon(!ref.watch(_isUserPasswordHiddenProvider) ? visibleIcon : notVisibleIcon, size: iconSize),
                        onPressed: _toggleUserPasswordVisibility,
                      ),
                      IconButton(
                          icon: Icon(
                            clearTextIcon,
                            size: iconSize,
                          ),
                          onPressed: () => _clearUserPasswordConfirmation(ref)),
                    ])),
            onChanged: (_) => _validateUserPasswordConfirmation(),
            onFieldSubmitted: (value) => ref.watch(_isSignUpPossibleProvider) ? _signUp() : null,
            validator: (_) => _userPasswordConfirmationValidator
          ),
        );},
      ),
    );

    //Club parameters
    fields.add(Padding(
        padding: const EdgeInsets.only(top: myTopPadding),
        child: ExpansionTile(
          title: Row(
            children: [
              Expanded(child: Text("ClubParameters".tr(), style: Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),)),
              IconButton(onPressed: _showClubExplanation, icon: Icon(helpIcon, size: iconSize,), ),
            ],
          ),
          children: [
            //Club Name
            TextFormFieldOnlineValidate(
                validationType: ValidationType.field,
                fieldNotValidLabel: "ClubNameAlreadyTaken".tr(),
                isFieldValidProvider: _isClubNameValidProvider,
                checkValueRequestProvider: _checkClubNameValidProvider,
                validationStateProvider: _clubNameValidationStateProvider,
                timeStampChecker: clubNameValidationStampProvider,
                allowEmptyValue: true,
                prefixIcon: clubIcon,
                controller: ref.watch(_clubNameInputControllerProvider),
                // inputFormatters: [
                //   FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
                // ],
                focusNode: _focusClubName,
                readOnly: isReadOnly,
                style: Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: fontSizeDelta),
                decoration: InputDecoration(
                    labelText: "ClubName".tr(),
                    labelStyle: Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
                    hintText: "Optional".tr(),
                    hintStyle: Theme.of(context).textTheme.bodyMedium!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),),
                groupValidation: _checkSignUpPossible,
                onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(_focusClubPassword)),

            const SizedBox(height: myTopPadding,),

            //Club Comment
            TextFormField(
                controller: _clubCommentInputController,
                focusNode: _focusClubComment,
                readOnly: isReadOnly,
                style: textStyleTitleLarge,
                decoration: InputDecoration(
                    labelText: "Comment".tr(),
                    labelStyle: Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: fontSizeDelta),
                  hintText: "Optional".tr(),
                  hintStyle: Theme.of(context).textTheme.bodyMedium!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
                    prefixIcon : Icon(
                      commentIcon,
                      size: iconSize,
                      color: Theme.of(context).brightness == Brightness.light ? validColorLight : validColorDark,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        clearTextIcon,
                        size: iconSize,
                      ),
                      onPressed: () => _clearClubCommentInputField(),
                    )),
                onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(_focusClubPassword)
            ),

            const SizedBox(height: myTopPadding,),

            //Club Password
            Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return TextFormField(
                controller: _clubPasswordInputController,
                focusNode: _focusClubPassword,
                style: Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
                obscureText: ref.watch(_isClubPasswordHiddenProvider),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
                ],
                readOnly: isReadOnly,
                decoration: InputDecoration(
                    labelText: "ClubPassword".tr(),
                    labelStyle: Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
                    hintText: "Optional".tr(),
                    hintStyle: Theme.of(context).textTheme.bodyMedium!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
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
                onChanged: (_) => _validateClubPassword(),
                onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(_focusClubPasswordConfirmation),
                validator: null,
              );
            }
            ),

            const SizedBox(height: myTopPadding,),

            //Club Password Confirmation
            Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
              late final MaterialColor? iconColor;

              if (ref.watch(_isClubPasswordConfirmationValidProvider) == false) {
                iconColor = Theme.of(context).brightness == Brightness.light ? notValidColorLight : notValidColorDark;
              } else if (ref.watch(_isClubPasswordConfirmationValidProvider) == true) {
                iconColor = Theme.of(context).brightness == Brightness.light ? notValidColorLight : notValidColorDark;
              } else if (ref.watch(_isClubPasswordConfirmationValidProvider) == true) {
                iconColor = Theme.of(context).brightness == Brightness.light ? validColorLight : validColorDark;
              }

              return TextFormField(
                controller: _clubPasswordConfirmationInputController,
                focusNode: _focusClubPasswordConfirmation,
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
                obscureText: ref.watch(_isClubPasswordHiddenProvider),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
                ],
                readOnly: isReadOnly,
                decoration: InputDecoration(
                    labelText: "ConfirmClubPassword".tr(),
                    labelStyle: Theme
                        .of(context)
                        .textTheme
                        .bodyLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider)),
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
                            icon: Icon(!ref.watch(_isClubPasswordHiddenProvider) ? visibleIcon : notVisibleIcon, size: iconSize),
                            onPressed: _toggleClubPasswordVisibility,
                          ),
                          IconButton(
                              icon: Icon(
                                clearTextIcon,
                                size: iconSize,
                              ),
                              onPressed: _clearClubPasswordConfirmation),
                        ])),
                onChanged: (_) => _validateClubPassword(),
                onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(_focusClubVisibility),
                //((value) => ref.watch(_isSignUpPossibleProvider) ? _signUp() : null),
                validator: (_) => _clubPasswordConfirmationValidator,
              );
            }
            ),

            const SizedBox(height: myTopPadding,),

            //Club visibility checkbox
            Row(
              children: [
                SwitchOrCheckListTile(
                    isMobileDevice: isMobileDevice,
                    focusNode: _focusClubVisibility,
                    title: Text("MakeClubPublic".tr(), style: Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: ref.watch(deltaFontSizeProvider))),
                    value: ref.watch(_isClubPublicProvider),
                    controlAffinity: ListTileControlAffinity.trailing,
                    onChanged: (val) => _toggleClubVisibility(val),)
              ],
            )
          ],
        ),));

    //Error Message
    if (isError) {
      fields.add(ApiErrorMessages(callErrors: _callErrors, deltaFontSize: ref.watch(deltaFontSizeProvider)));
    }

    //Sign-Up Button. Wrapping into consumer is need in order to avoid rebuilding of verification fields
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
                    focusNode: _focusNodeSignUp,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Theme
                          .of(context)
                          .brightness == Brightness.light ? primaryActionButtonOkDisabledColorLight : primaryActionButtonOkDisabledColorDark,
                      backgroundColor: Theme
                          .of(context)
                          .brightness == Brightness.light ? primaryActionButtonOkEnabledColorLight : null,
                    ),
                    onPressed: ref.watch(_isSignUpPossibleProvider) ? _signUp : null,
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text("SignUp".tr(), textAlign: TextAlign.center, style: Theme
                                .of(context)
                                .textTheme
                                .headlineSmall!
                                .apply(fontSizeDelta: ref.watch(deltaFontSizeProvider), color: Colors.white)))),
                  )),
            );
          }
      ));

    Widget signInForm = Padding(
      padding: const EdgeInsets.all(15),
      child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(children: fields)), //Sign-in Form
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

  void _toggleUserPasswordVisibility() {
    ref.read(_isUserPasswordHiddenProvider.notifier).state = !ref.read(_isUserPasswordHiddenProvider.notifier).state;
  }

  void _toggleClubPasswordVisibility() {
    ref.read(_isClubPasswordHiddenProvider.notifier).state = !ref.read(_isClubPasswordHiddenProvider.notifier).state;
  }

  void _toggleClubVisibility(bool val) {
    ref.read(_isClubPublicProvider.notifier).state = !ref.read(_isClubPublicProvider.notifier).state;
  }

  void _clearUserPassword(WidgetRef ref) {
    ref.read(_userPasswordInputControllerProvider).text = "";
    ref.read(_isUserPasswordValidProvider.notifier).state = null;
    _validateUserPassword();
    FocusScope.of(context).requestFocus(_focusUserPassword);
  }

  void _validateUserPassword() {
    var val = ref.read(_userPasswordInputControllerProvider).text;

    if (val.isEmpty) {
      _userPasswordValidator = "FieldIsRequired".tr();
      ref.read(_isUserPasswordValidProvider.notifier).state = false;
    } else if (val.length < minUserPasswordLength){
      _userPasswordValidator = null;
      ref.read(_isUserPasswordValidProvider.notifier).state = null;
    } else {
      _userPasswordValidator = null;
      ref.read(_isUserPasswordValidProvider.notifier).state = true;
    }
    if (_userPasswordConfirmationInputController.text.isNotEmpty) _validateUserPasswordConfirmation();
    _checkSignUpPossible();
  }

  void _clearUserPasswordConfirmation(WidgetRef ref) {
    _userPasswordConfirmationInputController.text = "";
    _validateUserPasswordConfirmation();
    FocusScope.of(context).requestFocus(_focusUserPasswordConfirmation);
  }

  void _validateUserPasswordConfirmation() {
    var val = _userPasswordConfirmationInputController.text;

    if (val.isEmpty && ref.read(_userPasswordInputControllerProvider).text.isEmpty) {
      _userPasswordConfirmationValidator = null;
      ref.read(_isUserPasswordConfirmationValidProvider.notifier).state = null;
      return;
    }

    if (val != ref.read(_userPasswordInputControllerProvider).text) {
      _userPasswordConfirmationValidator = "PasswordsMismatch".tr();
      ref.read(_isUserPasswordConfirmationValidProvider.notifier).state = false;
    } else {
      _userPasswordConfirmationValidator = null;
      ref.read(_isUserPasswordConfirmationValidProvider.notifier).state = true;
    }
    _checkSignUpPossible();
  }

  void _clearClubCommentInputField() {
    _clubCommentInputController.text = "";
    FocusScope.of(context).requestFocus(_focusClubComment);
  }

  void _clearClubPassword() {
    _clubPasswordInputController.text = "";
    _validateClubPassword();
    FocusScope.of(context).requestFocus(_focusClubPassword);
  }

  void _clearClubPasswordConfirmation() {
    _clubPasswordConfirmationInputController.text = "";
    _validateClubPassword();
    FocusScope.of(context).requestFocus(_focusClubPasswordConfirmation);
  }

  void _validateClubPassword() {
    if (_clubPasswordInputController.text == _clubPasswordConfirmationInputController.text) {
        _clubPasswordConfirmationValidator = null;
        ref.read(_isClubPasswordConfirmationValidProvider.notifier).state = true;
    } else {
      _clubPasswordConfirmationValidator = "PasswordsMismatch".tr();
      ref.read(_isClubPasswordConfirmationValidProvider.notifier).state = false;
    }
    _checkSignUpPossible();
  }

  void _checkSignUpPossible() {
    bool isUserPasswordValid = ref.read(_isUserPasswordValidProvider.notifier).state != null? ref.read(_isUserPasswordValidProvider.notifier).state! : false;
    bool isUserPasswordConfirmationValid = ref.read(_isUserPasswordConfirmationValidProvider.notifier).state != null? ref.read(_isUserPasswordConfirmationValidProvider.notifier).state! : false;
    bool isClubPasswordsMatch = ref.read(_isClubPasswordConfirmationValidProvider.notifier).state;

    ref.read(_isSignUpPossibleProvider.notifier).state = (ref.read(_isUserNameValidProvider.notifier).state
        & ref.read(_isEmailValidProvider.notifier).state & isUserPasswordValid & isUserPasswordConfirmationValid & isClubPasswordsMatch);
  }

  void _showClubExplanation() {
    ClubDialog.showClubExplanation(context: context, title: "WhyClub".tr(), explanationText: "ClubExplanation".tr(), okLabel: "Ok".tr(), deltaFontSize: ref.watch(deltaFontSizeProvider));
  }

  void _signUp() {
    final form = _formKey.currentState; //TODO: what to do with form validation?..

    _callErrors = [];
    ref.read(_signUpStateProvider.notifier).state = AppFormState.processing;

    ref.read(registrationRequestProvider.notifier).state = RegistrationRequest(
        userName: ref.read(_userNameInputControllerProvider).text,
        email: ref.read(_emailInputControllerProvider).text,
        userPassword: ref.read(_userPasswordInputControllerProvider).text,
        clubName: ref.watch(_clubNameInputControllerProvider).text.isNotEmpty?ref.watch(_clubNameInputControllerProvider).text:ref.read(_userNameInputControllerProvider).text,
        clubPassword: _clubPasswordInputController.text,
        clubComment: _clubCommentInputController.text,
        clubType: ref.read(_isClubPublicProvider.notifier).state?ClubType.publicClub:ClubType.nonListedClub,
        endDevice: appPlatform);

    var registrationResult = ref.watch(registrationProvider.future);

    registrationResult.then((data) {
      if (data.resultCode == AppResultCode.ok) {
        ref.read(_signUpStateProvider.notifier).state = AppFormState.resultOk;
        IdentityHelper.processSignInUpResponse(ref: ref, loginName: data.userName, hash: data.userPasswordHash, token: data.accessToken, logAs: data.logAs);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _callErrors = data.errors;
        ref.read(_signUpStateProvider.notifier).state = AppFormState.resultFailed;
      }
    }).onError((error, stackTrace) {
      _callErrors = [BackEndCall.callExceptionError];
      ref.read(_signUpStateProvider.notifier).state = AppFormState.httpError;
    });

  }

}