import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fs_front/Core/Vars/enums.dart';

import '../../Core/DTO/Generic/check_value_request.dart';
import '../../Core/DTO/Generic/check_value_response.dart';
import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../../Helpers/app_helper.dart';
import '../../Infrastructure/BackEnd/backend_call.dart';
import '../Themes/app_themes.dart';

/// Text field whose value is checked on the back end while the user types (user name, email, club name).
///
/// Input is trimmed and debounced, so only the last value after a typing pause is sent. Answers to older
/// requests, answers arriving after dispose and failed calls (network, 429 rate limit) are handled explicitly.
class TextFormFieldOnlineValidate extends ConsumerStatefulWidget {
  static const Duration defaultDebounce = Duration(milliseconds: 400);

  final StateProvider<bool> isFieldValidProvider;
  final TextEditingController? controller;
  final IconData prefixIcon;
  final ValidationType validationType;
  final String fieldNotValidLabel;

  /// Time stamp of the latest request for this field; answers carrying another stamp are ignored.
  final StateProvider<String> timeStampChecker;

  /// Supplies the endpoint (controller, handler, authorization) of the check; value and stamp are set per request.
  final StateProvider<CheckValueRequest?> checkValueRequestProvider;
  final StateProvider<ValidationStatus> validationStateProvider;
  final bool allowEmptyValue;
  final Duration debounce;

  final FocusNode? focusNode;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextStyle? style;
  final bool autofocus;
  final bool readOnly;
  final Function? groupValidation;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;

  const TextFormFieldOnlineValidate({
    super.key,
    required this.validationType,
    required this.fieldNotValidLabel,
    required this.isFieldValidProvider,
    required this.controller,
    required this.prefixIcon,
    required this.checkValueRequestProvider,
    required this.validationStateProvider,
    required this.timeStampChecker,
    this.allowEmptyValue = false,
    this.debounce = defaultDebounce,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.style,
    this.autofocus = false,
    this.readOnly = false,
    this.groupValidation,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.enabled = true,
  });

  @override
  ConsumerState<TextFormFieldOnlineValidate> createState() => _TextFormFieldOnlineValidateState();
}

class _TextFormFieldOnlineValidateState extends ConsumerState<TextFormFieldOnlineValidate> {
  static const Widget _validateInProgress = Padding(
    padding: EdgeInsets.all(2),
    child: CircularProgressIndicator(),
  );

  Timer? _debounceTimer;
  String? _validatorMessage;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = appIconBasisSize + ref.watch(deltaFontSizeProvider);
    final validationStatus = ref.watch(widget.validationStateProvider);
    final isFieldValid = ref.watch(widget.isFieldValidProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    final MaterialColor? iconColor = switch (validationStatus) {
      ValidationStatus.failed || ValidationStatus.notValid => isLight ? notValidColorLight : notValidColorDark,
      ValidationStatus.ok => isLight ? validColorLight : validColorDark,
      _ => null,
    };

    final decoration = InputDecoration(
        labelText: widget.decoration.labelText,
        labelStyle: widget.decoration.labelStyle,
        hintText: widget.decoration.hintText,
        hintStyle: widget.decoration.hintStyle,
        prefixIcon: validationStatus == ValidationStatus.validating
            ? const FittedBox(fit: BoxFit.scaleDown, child: _validateInProgress)
            : Icon(widget.prefixIcon, size: iconSize, color: iconColor),
        suffixIcon: IconButton(
          icon: Icon(clearTextIcon, size: iconSize),
          onPressed: _clearInputField,
        ));

    return TextFormField(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      controller: widget.controller,
      decoration: decoration,
      keyboardType: widget.keyboardType,
      style: widget.style,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      inputFormatters: widget.inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (_) => isFieldValid ? null : _validatorMessage,
      onChanged: _onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }

  void _onChanged(String? rawValue) {
    _debounceTimer?.cancel();
    //any answer still in flight belongs to an older value
    ref.read(widget.timeStampChecker.notifier).state = _newTimeStamp();

    final value = (rawValue ?? "").trim();

    if (value.isEmpty) {
      if (widget.allowEmptyValue) {
        _apply(ValidationStatus.ok, isValid: true, message: null);
      } else {
        _apply(ValidationStatus.notValid, isValid: false, message: "FieldIsRequired".tr());
      }
      return;
    }

    if (widget.validationType == ValidationType.email && !AppHelper.isEmailValid(value)) {
      _apply(ValidationStatus.init, isValid: false, message: null);
      return;
    }

    //the field is not valid until the back end confirmed the current value
    _apply(ValidationStatus.validating, isValid: false, message: null);
    _debounceTimer = Timer(widget.debounce, () => _checkOnBackEnd(value));
  }

  Future<void> _checkOnBackEnd(String value) async {
    if (!mounted) return;

    final timeStamp = _newTimeStamp();
    ref.read(widget.timeStampChecker.notifier).state = timeStamp;

    final endpoint = ref.read(widget.checkValueRequestProvider)!;
    final request = CheckValueRequest(
        value: value,
        timeStamp: timeStamp,
        apiController: endpoint.apiController,
        apiHandler: endpoint.apiHandler,
        isAuthorized: endpoint.isAuthorized);

    CheckValueResponse? result;
    try {
      result = await ref.read(backEndGeneric).checkValue(checkValueRequest: request);
    } catch (e) {
      debugPrint("online validation of ${endpoint.apiHandler} failed: $e");
    }

    if (!mounted || ref.read(widget.timeStampChecker) != timeStamp) return;

    if (result == null || result.resultCode != AppResultCode.ok || result.timeStamp != timeStamp) {
      final isRateLimited = result?.errors.any((e) => e.code == BackEndCall.tooManyRequestsError.code) ?? false;
      _apply(ValidationStatus.failed, isValid: false, message: (isRateLimited ? "TooManyRequests" : "ValidationError").tr());
      return;
    }

    if (result.isValueValid) {
      _apply(ValidationStatus.ok, isValid: true, message: null);
    } else {
      _apply(ValidationStatus.notValid, isValid: false, message: widget.fieldNotValidLabel);
    }
  }

  void _apply(ValidationStatus status, {required bool isValid, required String? message}) {
    if (!mounted) return;
    setState(() => _validatorMessage = message);
    ref.read(widget.validationStateProvider.notifier).state = status;
    ref.read(widget.isFieldValidProvider.notifier).state = isValid;
    widget.groupValidation?.call();
  }

  void _clearInputField() {
    widget.controller?.clear();
    _onChanged("");
    FocusScope.of(context).requestFocus(widget.focusNode);
  }

  static String _newTimeStamp() => DateTime.now().toUtc().toIso8601String();
}
