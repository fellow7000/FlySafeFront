import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fs_front/Core/Vars/enums.dart';

import '../../Core/DTO/Generic/check_value_request.dart';
import '../../Core/DTO/Generic/check_value_response.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/app_helper.dart';
import '../Themes/app_themes.dart';

class TextFormFieldOnlineValidate extends ConsumerWidget {
  //final WidgetRef ref;
  final StateProvider<bool> isFieldValidProvider;
  final TextEditingController? controller;
  final IconData prefixIcon;
  final ValidationType validationType;
  final String fieldNotValidLabel;
  final StateProvider<String> timeStampChecker; //a global variable, which is re-assigned everytime when request is fired

  //final String apiController;
  //final String apiHandler;
  final StateProvider checkValueRequestProvider;
  final bool allowEmptyValue;

  //final String? initialValue;
  final FocusNode? focusNode;
  final InputDecoration decoration;

  final TextInputType? keyboardType;
  // TextCapitalization textCapitalization = TextCapitalization.none,
  //     TextInputAction? textInputAction,
  final TextStyle? style;

  //     StrutStyle? strutStyle,
  // TextDirection? textDirection,
  //     TextAlign textAlign = TextAlign.start,
  // TextAlignVertical? textAlignVertical,
  final bool autofocus;

  final bool readOnly;
  // @Deprecated(
  //   'Use `contextMenuBuilder` instead. '
  //       'This feature was deprecated after v3.3.0-0.5.pre.',
  // )
  // ToolbarOptions? toolbarOptions,
  //     bool? showCursor,
  // String obscuringCharacter = '•',
  //     bool obscureText = false,
  // bool autocorrect = true,
  //     SmartDashesType? smartDashesType,
  // SmartQuotesType? smartQuotesType,
  //     bool enableSuggestions = true,
  // MaxLengthEnforcement? maxLengthEnforcement,
  //     int? maxLines = 1,
  // int? minLines,
  //     bool expands = false,
  // int? maxLength,
  //final ValueChanged<String>? groupValidation;
  final Function? groupValidation;

  // GestureTapCallback? onTap,
  //     TapRegionCallback? onTapOutside,
  // VoidCallback? onEditingComplete,
  final ValueChanged<String>? onFieldSubmitted;

  // super.onSaved,
  // super.validator,
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  // double cursorWidth = 2.0,
  //     double? cursorHeight,
  // Radius? cursorRadius,
  //     Color? cursorColor,
  // Brightness? keyboardAppearance,
  //     EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
  // bool? enableInteractiveSelection,
  //     TextSelectionControls? selectionControls,
  // InputCounterWidgetBuilder? buildCounter,
  //     ScrollPhysics? scrollPhysics,
  // Iterable<String>? autofillHints,
  //     AutovalidateMode? autovalidateMode,
  // ScrollController? scrollController,
  // super.restorationId,
  // bool enableIMEPersonalizedLearning = true,
  //     MouseCursor? mouseCursor,
  // EditableTextContextMenuBuilder? contextMenuBuilder,
  //

  late final AutoDisposeFutureProvider<CheckValueResponse> checkValueProvider;

  final _fieldValidatorMessage = StateProvider<String?>((ref) => null);
  //final _validationStatusProvider = StateProvider<ValidationStatus>((ref) => ValidationStatus.init);

  final StateProvider<ValidationStatus> validationStateProvider; // = StateProvider<ValidationStatus>((ref) => ValidationStatus.init);

  static const Widget _validateInProgress = Padding(
    padding: EdgeInsets.all(2),
    child: CircularProgressIndicator(),
  );

  TextFormFieldOnlineValidate({
    super.key,
    //required this.ref,
    required this.validationType,
    required this.fieldNotValidLabel,
    required this.isFieldValidProvider,
    required this.controller,
    required this.prefixIcon,
    //required this.apiController,
    //required this.apiHandler,
    required this.checkValueRequestProvider,
    required this.validationStateProvider,
    this.allowEmptyValue = false,
    required this.timeStampChecker,
    // String? initialValue,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    // TextCapitalization textCapitalization = TextCapitalization.none,
    // TextInputAction? textInputAction,
    this.style,
    // StrutStyle? strutStyle,
    // TextDirection? textDirection,
    // TextAlign textAlign = TextAlign.start,
    // TextAlignVertical? textAlignVertical,
    this.autofocus = false,
    this.readOnly = false,
    // @Deprecated(
    //   'Use `contextMenuBuilder` instead. '
    //       'This feature was deprecated after v3.3.0-0.5.pre.',
    // )
    // ToolbarOptions? toolbarOptions,
    // bool? showCursor,
    // String obscuringCharacter = '•',
    // bool obscureText = false,
    // bool autocorrect = true,
    // SmartDashesType? smartDashesType,
    // SmartQuotesType? smartQuotesType,
    // bool enableSuggestions = true,
    // MaxLengthEnforcement? maxLengthEnforcement,
    // int? maxLines = 1,
    // int? minLines,
    // bool expands = false,
    // int? maxLength,
    this.groupValidation,
    // GestureTapCallback? onTap,
    // TapRegionCallback? onTapOutside,
    // VoidCallback? onEditingComplete,
    this.onFieldSubmitted,
    // super.onSaved,
    // super.validator,
    this.inputFormatters,
    this.enabled = true,
    // double cursorWidth = 2.0,
    // double? cursorHeight,
    // Radius? cursorRadius,
    // Color? cursorColor,
    // Brightness? keyboardAppearance,
    // EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    // bool? enableInteractiveSelection,
    // TextSelectionControls? selectionControls,
    // InputCounterWidgetBuilder? buildCounter,
    // ScrollPhysics? scrollPhysics,
    // Iterable<String>? autofillHints,
    // AutovalidateMode? autovalidateMode,
    // ScrollController? scrollController,
    // super.restorationId,
    // bool enableIMEPersonalizedLearning = true,
    // MouseCursor? mouseCursor,
    // EditableTextContextMenuBuilder? contextMenuBuilder,
  }) {
    checkValueProvider = FutureProvider.autoDispose<CheckValueResponse>((ref) {
      final checkValueRequest = ref.watch(checkValueRequestProvider);
      return ref.watch(backEndGeneric).checkValue(checkValueRequest: checkValueRequest!);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconSize = appIconBasisSize + ref.watch(deltaFontSizeProvider);
    final validationStatus = ref.watch(validationStateProvider);

    late final MaterialColor? iconColor;

    if (validationStatus == ValidationStatus.init || validationStatus == ValidationStatus.validating) {
      iconColor = null;
    } else if (validationStatus == ValidationStatus.failed || validationStatus == ValidationStatus.notValid) {
      iconColor = Theme.of(context).brightness == Brightness.light ? notValidColorLight : notValidColorDark;
    } else if (validationStatus == ValidationStatus.ok) {
      iconColor = Theme.of(context).brightness == Brightness.light ? validColorLight : validColorDark;
    }

    InputDecoration decor = InputDecoration(
    labelText: decoration.labelText,
    labelStyle:  decoration.labelStyle,
    hintText: decoration.hintText,
    hintStyle: decoration.hintStyle,
    prefixIcon : ref.watch(validationStateProvider) == ValidationStatus.validating
        ? const FittedBox(fit: BoxFit.scaleDown, child: _validateInProgress)
        : Icon(
      prefixIcon,
      size: iconSize,
      color: iconColor,
    ),
    suffixIcon: IconButton(
      icon: Icon(
        clearTextIcon,
        size: iconSize,
      ),
      onPressed: () => _clearInputField(ref, context),
    ));


    return TextFormField(
      focusNode: focusNode,
      autofocus: autofocus,
      controller: controller,
      decoration: decor,
      keyboardType: keyboardType,
      style: style,
      readOnly: readOnly,
      enabled: enabled,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (_) => ref.watch(isFieldValidProvider) ? null : ref.watch(_fieldValidatorMessage),
      onChanged: (val) => _checkField(val, ref),
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  void _checkField(String? val, WidgetRef ref) async {
    //this check data on the moment of the function call
    if (val == null || val.isEmpty) {
      if (allowEmptyValue) {
        ref
            .read(isFieldValidProvider.notifier)
            .state = true;
        ref
            .read(validationStateProvider.notifier)
            .state = ValidationStatus.ok;
        ref
            .read(_fieldValidatorMessage.notifier)
            .state = null;
        if (groupValidation != null) groupValidation!();
      } else {
        ref
            .read(isFieldValidProvider.notifier)
            .state = false;
        ref
            .read(validationStateProvider.notifier)
            .state = ValidationStatus.notValid;
        ref
            .read(_fieldValidatorMessage.notifier)
            .state = "FieldIsRequired".tr();
        if (groupValidation != null) groupValidation!();
      }
      return;
    }

    if (validationType == ValidationType.email) {
      if (AppHelper.isEmailValid(val)) {
        ref.read(_fieldValidatorMessage.notifier).state = null;
        ref.read(validationStateProvider.notifier).state = ValidationStatus.ok;
        ref.read(isFieldValidProvider.notifier).state = true;
      } else {
        ref.read(_fieldValidatorMessage.notifier).state = null;
        ref.read(validationStateProvider.notifier).state = ValidationStatus.init;
        ref.read(isFieldValidProvider.notifier).state = false;
        if (groupValidation != null) groupValidation!();
        return;
      }
    }

    ref.read(validationStateProvider.notifier).state = ValidationStatus.validating;

    String timeStamp = DateTime.now().toUtc().toString();

    ref.read(timeStampChecker.notifier).state = timeStamp;

    ref.read(checkValueRequestProvider.notifier).state =
        CheckValueRequest(value: val, timeStamp: timeStamp, apiController: ref.read(checkValueRequestProvider).apiController, apiHandler: ref.read(checkValueRequestProvider).apiHandler, isAuthorized: ref.read(checkValueRequestProvider).isAuthorized);

    CheckValueResponse checkResult = await ref.watch(checkValueProvider.future);

    //during await user can clear the field, so we need to check controller state
    if (controller?.text == null || controller!.text.isEmpty) {
      ref.read(validationStateProvider.notifier).state = ValidationStatus.init;
      ref.read(isFieldValidProvider.notifier).state = false;
      ref.read(_fieldValidatorMessage.notifier).state = "FieldIsRequired".tr();
      if (groupValidation != null) groupValidation!();
      return;
    }

    if (checkResult.resultCode == AppResultCode.ok && checkResult.isValueValid && checkResult.timeStamp == ref.read(timeStampChecker.notifier).state) {
      ref.read(_fieldValidatorMessage.notifier).state = null;
      ref.read(validationStateProvider.notifier).state = ValidationStatus.ok;
      ref.read(isFieldValidProvider.notifier).state = true;
    } else if (checkResult.resultCode == AppResultCode.ok && !checkResult.isValueValid && checkResult.timeStamp == ref.read(timeStampChecker.notifier).state) {
      ref.read(_fieldValidatorMessage.notifier).state = fieldNotValidLabel;
      ref.read(validationStateProvider.notifier).state = ValidationStatus.notValid;
      ref.read(isFieldValidProvider.notifier).state = false;
    } else if (checkResult.resultCode != AppResultCode.ok || checkResult.timeStamp == ""){
      ref.read(_fieldValidatorMessage.notifier).state = "ValidationError".tr();
      ref.read(validationStateProvider.notifier).state = ValidationStatus.failed;
      ref.read(isFieldValidProvider.notifier).state = false;
    } else {
      debugPrint("Request Timestamp=${checkResult.timeStamp}, Provider Timestamp = ${ref.read(timeStampChecker.notifier).state}");
      //Request Timestamp=2023-02-06 22:32:11.321Z, Provider Timestamp = 2023-02-06 22:32:11.786Z

    // {"Value":"t","TimeStamp":"2023-02-06 22:33:42.135Z"}
    // {"Value":"te","TimeStamp":"2023-02-06 22:33:42.211Z"}
    // {"Value":"tes","TimeStamp":"2023-02-06 22:33:42.396Z"}
    // {"Value":"test","TimeStamp":"2023-02-06 22:33:42.468Z"}
    // api call success http://192.168.1.106:5200/api/user/checkusernamefree
    // Request Timestamp=2023-02-06 22:33:42.135Z, Provider Timestamp = 2023-02-06 22:33:42.468Z
    // api call success http://192.168.1.106:5200/api/user/checkusernamefree
    // api call success http://192.168.1.106:5200/api/user/checkusernamefree
    // {"Value":"test4","TimeStamp":"2023-02-06 22:33:42.702Z"}
    // api call success http://192.168.1.106:5200/api/user/checkusernamefree
    // api call success http://192.168.1.106:5200/api/user/checkusernamefree
    // {"Value":"t@y","TimeStamp":"2023-02-06 22:33:45.412Z"}
    // api call success http://192.168.1.106:5200/api/user/checkemailfree

      //ref.read(validationStateProvider.notifier).state = ValidationStatus.validating;
    }
    if (groupValidation != null) groupValidation!();
  }

  void _clearInputField(WidgetRef ref, BuildContext context) {
    controller!.clear();
    _checkField("", ref);
    FocusScope.of(context).requestFocus(focusNode);
  }
}
