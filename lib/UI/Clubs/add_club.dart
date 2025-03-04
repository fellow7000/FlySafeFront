import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/DTO/Generic/check_value_request.dart';
import 'package:fs_front/UI/Elements/app_process_indicator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../Core/DTO/Base/call_error.dart';
import '../../Core/DTO/Club/add_club_request.dart';
import '../../Core/DTO/Club/add_club_response.dart';
import '../../Core/DTO/Identity/Manage/user_profile_response.dart';
import '../../Core/Vars/enums.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/app_helper.dart';
import '../../Infrastructure/BackEnd/ClubCalls/i_api_club.dart';
import '../../Infrastructure/BackEnd/backend_call.dart';
import '../Elements/MainSidePanel/api_error_messages.dart';
import '../Elements/basis_form.dart';
import '../Elements/switch_or_check_list_tile.dart';
import '../Themes/app_themes.dart';

class AddClub extends ConsumerStatefulWidget {
  const AddClub({super.key});

  @override
  ConsumerState<AddClub> createState() => AddClubWidget();
}

class AddClubWidget extends ConsumerState<AddClub> {
  final double _myElevation = 3;
  static const double myTopPadding = 5;

  late WebSocketChannel _channel;

  final _formStateProvider = StateProvider.autoDispose<AppFormState>((ref) =>
      AppFormState
          .connectingToHost); //first we need to connect to the websocket

  final _clubNameInputControllerProvider =
      Provider.autoDispose<TextEditingController>((ref) {
    final textController = TextEditingController();
    ref.onDispose(() {
      textController.dispose();
    });
    return textController;
  });

  final TextEditingController _clubCommentInputController =
      TextEditingController();

  final FocusNode _focusClubName = FocusNode();
  final FocusNode _focusClubComment = FocusNode();
  final FocusNode _focusClubPassword = FocusNode();
  final FocusNode _focusConfirmClubPassword = FocusNode();
  final FocusNode _focusClubVisibility = FocusNode();
  final FocusNode _focusNodeSignUp = FocusNode();

  final _isClubNameValidProvider = StateProvider<bool>((ref) => false);
  final _clubNameValidationStateProvider =
      StateProvider<ValidationStatus>((ref) => ValidationStatus.init);
  final _clubNameValidatorMessage = StateProvider<String?>((ref) => null);

  final TextEditingController _clubPasswordInputController =
      TextEditingController();
  final TextEditingController _clubPasswordConfirmationInputController =
      TextEditingController();

  final _isClubPasswordHiddenProvider = StateProvider<bool>((ref) => true);

  final _isClubPasswordConfirmationValidProvider = StateProvider<bool>(
      (ref) => true); //empty club passwords are valid by default

  String? _clubPasswordConfirmationValidator;

  final _isClubPublicProvider = StateProvider<bool>((ref) => false);

  final _isAddClubPossibleProvider = StateProvider<bool>((ref) => false);

  bool _isWebSocketConnected = false;

  List<CallError> _callErrors =
      []; //TODO: implementation of error handling is open!

  static const Widget _validateInProgress = Padding(
    padding: EdgeInsets.all(2),
    child: CircularProgressIndicator(),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _connectToWebSocket());
  }

  @override
  void dispose() {
    _channel.sink.close();
    _clubCommentInputController.dispose();
    _clubPasswordInputController.dispose();
    _clubPasswordConfirmationInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(_formStateProvider);
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    final iconSize = appIconBasisSize + fontSizeDelta;
    List<Widget> fields = <Widget>[];
    final isReadOnly = formState == AppFormState.processing;
    final validationStatus = ref.watch(_clubNameValidationStateProvider);
    final isError = (formState == AppFormState.httpError ||
        formState == AppFormState.exception ||
        formState == AppFormState.resultFailed);

    fields.add(Padding(
      padding: const EdgeInsets.all(10),
      child: Text("AddClub".tr(),
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.apply(fontWeightDelta: 1, fontSizeDelta: fontSizeDelta)),
    ));

    if (ref.watch(_formStateProvider) == AppFormState.connectingToHost) {
      fields.add(Padding(
          padding: const EdgeInsets.only(top: formPadding, bottom: formPadding),
          child: AppProcessIndicator(message: "StandBy".tr())));

      return BasisForm(
          formTitle: "Club".tr(),
          form: Card(
            elevation: _myElevation,
            child: Padding(
              padding: const EdgeInsets.all(formPadding),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: fields), //Sign-in Form
            ),
          ));
    }

    late final MaterialColor? iconColor;

    if (validationStatus == ValidationStatus.init ||
        validationStatus == ValidationStatus.validating) {
      iconColor = null;
    } else if (validationStatus == ValidationStatus.failed ||
        validationStatus == ValidationStatus.notValid) {
      iconColor = Theme.of(context).brightness == Brightness.light
          ? notValidColorLight
          : notValidColorDark;
    } else if (validationStatus == ValidationStatus.ok) {
      iconColor = Theme.of(context).brightness == Brightness.light
          ? validColorLight
          : validColorDark;
    }

    //Club Name
    fields.add(
      TextFormField(
          controller: ref.watch(_clubNameInputControllerProvider),
          // inputFormatters: [
          //   FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
          // ],
          focusNode: _focusClubName,
          readOnly: isReadOnly,
          style: textStyleTitleLarge,
          decoration: InputDecoration(
              labelText: "ClubName".tr(),
              labelStyle: textStyleBodyLarge,
              prefixIcon: validationStatus == ValidationStatus.validating
                  ? const FittedBox(
                      fit: BoxFit.scaleDown, child: _validateInProgress)
                  : Icon(
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
              )),
          onChanged: (value) => _sendNameForValidation(value),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (_) => ref.watch(_isClubNameValidProvider)
              ? null
              : ref.watch(_clubNameValidatorMessage),
          onFieldSubmitted: (val) =>
              FocusScope.of(context).requestFocus(_focusClubComment)),
    );

    //Club Comment
    fields.add(
      TextFormField(
          controller: _clubCommentInputController,
          focusNode: _focusClubComment,
          readOnly: isReadOnly,
          style: textStyleTitleLarge,
          decoration: InputDecoration(
              labelText: "Comment".tr(),
              labelStyle: textStyleBodyLarge,
              hintText: "Optional".tr(),
              hintStyle: textStyleBodyMedium,
              prefixIcon: Icon(
                commentIcon,
                size: iconSize,
                color: Theme.of(context).brightness == Brightness.light
                    ? validColorLight
                    : validColorDark,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  clearTextIcon,
                  size: iconSize,
                ),
                onPressed: () => _clearClubCommentInputField(),
              )),
          onFieldSubmitted: (val) =>
              FocusScope.of(context).requestFocus(_focusClubPassword)),
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
        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ ]'))],
        readOnly: isReadOnly,
        decoration: InputDecoration(
            labelText: "ClubPassword".tr(),
            labelStyle: textStyleBodyLarge,
            hintText: "Optional".tr(),
            hintStyle: textStyleBodyMedium,
            prefixIcon: Icon(
              passwordIcon,
              size: iconSize,
              color: Theme.of(context).brightness == Brightness.light
                  ? validColorLight
                  : validColorDark,
            ),
            suffixIcon: Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, //shift all stuff to the right (end)
                mainAxisSize:
                    MainAxisSize.min, //make row of the size of two icons
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                        !ref.watch(_isClubPasswordHiddenProvider)
                            ? visibleIcon
                            : notVisibleIcon,
                        size: iconSize),
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
        onFieldSubmitted: (val) =>
            FocusScope.of(context).requestFocus(_focusConfirmClubPassword),
        validator: null,
      );
    }));

    fields.add(
      const SizedBox(
        height: myTopPadding,
      ),
    );

    //Club Password Confirmation
    fields.add(
      Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
        late final MaterialColor? iconColor;

        if (ref.watch(_isClubPasswordConfirmationValidProvider) == false) {
          iconColor = Theme.of(context).brightness == Brightness.light
              ? notValidColorLight
              : notValidColorDark;
        } else if (ref.watch(_isClubPasswordConfirmationValidProvider) ==
            true) {
          iconColor = Theme.of(context).brightness == Brightness.light
              ? notValidColorLight
              : notValidColorDark;
        } else if (ref.watch(_isClubPasswordConfirmationValidProvider) ==
            true) {
          iconColor = Theme.of(context).brightness == Brightness.light
              ? validColorLight
              : validColorDark;
        }

        return TextFormField(
          controller: _clubPasswordConfirmationInputController,
          focusNode: _focusConfirmClubPassword,
          style: textStyleTitleLarge,
          obscureText: ref.watch(_isClubPasswordHiddenProvider),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ ]'))],
          readOnly: isReadOnly,
          decoration: InputDecoration(
              labelText: "ConfirmClubPassword".tr(),
              labelStyle: textStyleBodyLarge,
              prefixIcon: Icon(
                passwordIcon,
                size: iconSize,
                color: iconColor,
              ),
              suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .end, //shift all stuff to the right (end)
                  mainAxisSize:
                      MainAxisSize.min, //make row of the size of two icons
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                          !ref.watch(_isClubPasswordHiddenProvider)
                              ? visibleIcon
                              : notVisibleIcon,
                          size: iconSize),
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
          onFieldSubmitted: ref.watch(_isAddClubPossibleProvider)
              ? (val) => _addClub()
              : null,
          validator: (_) => _clubPasswordConfirmationValidator,
        );
      }),
    );

    //Club visibility checkbox
    fields.add(Row(
      children: [
        SwitchOrCheckListTile(
          isMobileDevice: isMobileDevice,
          focusNode: _focusClubVisibility,
          title: Text("MakeClubPublic".tr(),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .apply(fontSizeDelta: ref.watch(deltaFontSizeProvider))),
          value: ref.watch(_isClubPublicProvider),
          controlAffinity: ListTileControlAffinity.trailing,
          onChanged: (val) => _toggleClubVisibility(val),
        )
      ],
    ));

    //Error Message
    if (isError) {
      fields.add(ApiErrorMessages(
          callErrors: _callErrors,
          deltaFontSize: ref.watch(deltaFontSizeProvider)));
    }

    //Sign-Up Button. Wrapping into consumer is need in order to avoid rebuilding of verification fields
    fields.add(
        Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
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
                    disabledBackgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? primaryActionButtonOkDisabledColorLight
                            : primaryActionButtonOkDisabledColorDark,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? primaryActionButtonOkEnabledColorLight
                            : null,
                  ),
                  onPressed:
                      ref.watch(_isAddClubPossibleProvider) ? _addClub : null,
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("Create".tr(),
                              textAlign: TextAlign.center,
                              style: textStyleHeadlineSmall.apply(
                                  fontSizeDelta:
                                      ref.watch(deltaFontSizeProvider),
                                  color: Colors.white)))),
                )),
      );
    }));

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

  void _connectToWebSocket() async {
    final url = AppHelper.generateUri(
        host: ref.read(webHostProvider.notifier).state,
        apiController: IApiClub.webSocketController,
        apiHandler: IApiClub.checkValueSocket);
    final Uri uri = Uri.parse(url
        .toString()
        .replaceFirst("http://", "ws://")
        .replaceFirst("https://", "wss://"));

    _channel = WebSocketChannel.connect(uri);

    _isWebSocketConnected = true;

    _channel.stream.listen((message) {
      // Handle incoming messages here
      _processValidationResponse(message);
    }, onDone: () {
      debugPrint('WebSocket disconnected');
      _isWebSocketConnected = false;
    }, onError: (error) {
      debugPrint('Error connecting to WebSocket: $error');
      _isWebSocketConnected = false;
    });

    debugPrint('Connected to the WebSocket $url');
    ref.read(_formStateProvider.notifier).state = AppFormState.dataInput;
  }

  void _sendNameForValidation(String value) async {
    if (value.isEmpty) {
      _processEmptyClubName();
      return;
    } else {
      ref.read(_clubNameValidatorMessage.notifier).state = null;
    }

    ref.read(_clubNameValidationStateProvider.notifier).state =
        ValidationStatus.validating;

    String timeStamp = DateTime.now().toUtc().toString();

    ref.read(clubNameValidationStampProvider.notifier).state = timeStamp;

    CheckValueRequest checkValueRequest = CheckValueRequest(
      value: value,
      timeStamp: timeStamp,
      apiController: '',
      apiHandler: '',
      isAuthorized: true,
    );

    if (!_isWebSocketConnected) {
      _connectToWebSocket();
      //TODO: how to check if connection is really established?..
    }

    //ref.read(_formStateProvider.notifier).state = AppFormState.processing;

    _channel.sink.add(jsonEncode(checkValueRequest.toJson()));
  }

  void _processValidationResponse(String message) {
    if (ref.watch(_clubNameInputControllerProvider).text.isEmpty) {
      _processEmptyClubName();
      return;
    }

    try {
      // 25.11.2024 refactoring to drop CheckValueResponse in favor of CheckValue API, which returns bool
      // final checkResult = CheckValueResponse.fromJson(jsonDecode(message));

      // if (checkResult.resultCode == AppResultCode.ok && checkResult.isValueValid && checkResult.timeStamp == ref.read(clubNameValidationStampProvider.notifier).state) {
      //   ref.read(_clubNameValidatorMessage.notifier).state = null;
      //   ref.read(_clubNameValidationStateProvider.notifier).state = ValidationStatus.ok;
      //   ref.read(_isClubNameValidProvider.notifier).state = true;
      // } else if (checkResult.resultCode == AppResultCode.ok && !checkResult.isValueValid && checkResult.timeStamp == ref.read(clubNameValidationStampProvider.notifier).state) {
      //   ref.read(_clubNameValidatorMessage.notifier).state = "ClubNameAlreadyTaken".tr();
      //   ref.read(_clubNameValidationStateProvider.notifier).state = ValidationStatus.notValid;
      //   ref.read(_isClubNameValidProvider.notifier).state = false;
      // } else if (checkResult.resultCode != AppResultCode.ok || checkResult.timeStamp == ""){
      //   ref.read(_clubNameValidatorMessage.notifier).state = "ValidationError".tr();
      //   ref.read(_clubNameValidationStateProvider.notifier).state = ValidationStatus.failed;
      //   ref.read(_isClubNameValidProvider.notifier).state = false;
      // } else {
      //   debugPrint("Request Timestamp=${checkResult.timeStamp}, Provider Timestamp = ${ref.read(clubNameValidationStampProvider.notifier).state}");
      // }

      final isValueValid = jsonDecode(message) as bool;

      if (isValueValid) {
        ref.read(_clubNameValidatorMessage.notifier).state = null;
        ref.read(_clubNameValidationStateProvider.notifier).state = ValidationStatus.ok;
        ref.read(_isClubNameValidProvider.notifier).state = true;
      } else {
        ref.read(_clubNameValidatorMessage.notifier).state = "ClubNameAlreadyTaken".tr();
        ref.read(_clubNameValidationStateProvider.notifier).state = ValidationStatus.notValid;
        ref.read(_isClubNameValidProvider.notifier).state = false;
      }

      ref.read(_formStateProvider.notifier).state = AppFormState.resultOk;
    } catch (e) {
      ref.read(_formStateProvider.notifier).state = AppFormState.resultFailed;
    }
    
    _checkAddClubPossible();
  }

  void _clearClubNameInputField(context) {
    ref.watch(_clubNameInputControllerProvider).clear();
    _sendNameForValidation("");
    _checkAddClubPossible();
    FocusScope.of(context).requestFocus(_focusClubName);
  }

  void _clearClubCommentInputField() {
    _clubCommentInputController.text = "";
    FocusScope.of(context).requestFocus(_focusClubComment);
  }

  void _processEmptyClubName() {
    ref.read(_isClubNameValidProvider.notifier).state = false;
    ref.read(_clubNameValidationStateProvider.notifier).state =
        ValidationStatus.notValid;
    ref.read(_clubNameValidatorMessage.notifier).state = "FieldIsRequired".tr();
    _checkAddClubPossible();
    //if (groupValidation != null) groupValidation!();
  }

  void _toggleClubPasswordVisibility() {
    ref.read(_isClubPasswordHiddenProvider.notifier).state =
        !ref.read(_isClubPasswordHiddenProvider.notifier).state;
  }

  void _validateClubPassword() {
    if (_clubPasswordInputController.text ==
        _clubPasswordConfirmationInputController.text) {
      _clubPasswordConfirmationValidator = null;
      ref.read(_isClubPasswordConfirmationValidProvider.notifier).state = true;
    } else {
      _clubPasswordConfirmationValidator = "PasswordsMismatch".tr();
      ref.read(_isClubPasswordConfirmationValidProvider.notifier).state = false;
    }
    _checkAddClubPossible();
  }

  void _clearClubPassword() {
    _clubPasswordInputController.text = "";
    _validateClubPassword();
    FocusScope.of(context).requestFocus(_focusClubPassword);
  }

  void _clearClubPasswordConfirmation() {
    _clubPasswordConfirmationInputController.text = "";
    _validateClubPassword();
    FocusScope.of(context).requestFocus(_focusConfirmClubPassword);
  }

  void _toggleClubVisibility(bool val) {
    ref.read(_isClubPublicProvider.notifier).state =
        !ref.read(_isClubPublicProvider.notifier).state;
  }

  _checkAddClubPossible() {
    ref.read(_isAddClubPossibleProvider.notifier).state =
        ref.read(_isClubPasswordConfirmationValidProvider.notifier).state &
            ref.read(_isClubNameValidProvider.notifier).state;
  }

  _addClub() {
    if (!ref.watch(_isAddClubPossibleProvider)) return;

    _callErrors = [];

    ref.read(_formStateProvider.notifier).state = AppFormState.processing;

    ref.read(addClubRequestProvider.notifier).state = AddClubRequest(
        clubName: ref.watch(_clubNameInputControllerProvider).text,
        clubPassword: _clubPasswordInputController.text,
        clubComment: _clubCommentInputController.text,
        clubType: ref.read(_isClubPublicProvider.notifier).state
            ? ClubType.publicClub
            : ClubType.nonListedClub,
        endDevice: appPlatform);

    var addClubResult = ref.watch(addClubProvider.future);

    addClubResult.then((data) {
      if (data.resultCode == AppResultCode.ok) {
        ref.read(_formStateProvider.notifier).state = AppFormState.resultOk;
        if (mounted) {
          AppHelper.showSnack(context: context, message: "ClubCreated".tr());
          ref.invalidate(getUserProfileProvider);
          Navigator.pop(context);
        }
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
