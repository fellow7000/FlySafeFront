import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Core/Vars/globals.dart';
import '../../Core/Vars/providers.dart';
import '../Themes/app_themes.dart';

//Current / new / confirmation password fields shared by the user and the club password change forms.
//The parent owns the controllers and gets notified about the validity of the whole input.
class PasswordChangeFields extends ConsumerStatefulWidget {
  const PasswordChangeFields({
    super.key,
    required this.currentController,
    required this.newController,
    required this.confirmController,
    required this.currentLabel,
    required this.newLabel,
    required this.confirmLabel,
    required this.minLength,
    required this.allowEmptyCurrent,
    required this.onValidityChanged,
    this.maxLength,
    this.enabled = true,
  });

  final TextEditingController currentController;
  final TextEditingController newController;
  final TextEditingController confirmController;
  final String currentLabel;
  final String newLabel;
  final String confirmLabel;
  final int minLength;
  final int? maxLength;
  final bool allowEmptyCurrent;
  final bool enabled;
  final ValueChanged<bool> onValidityChanged;

  //new password is valid if it is long enough (an empty one is valid only when no minimum length is required)
  static bool isNewPasswordValid(String newPassword, int minLength) => newPassword.length >= minLength;

  static bool isInputValid({
    required String current,
    required String newPassword,
    required String confirmation,
    required int minLength,
    required bool allowEmptyCurrent,
  }) {
    if (!allowEmptyCurrent && current.isEmpty) return false;
    if (!isNewPasswordValid(newPassword, minLength)) return false;
    return newPassword == confirmation;
  }

  @override
  ConsumerState<PasswordChangeFields> createState() => _PasswordChangeFieldsState();
}

class _PasswordChangeFieldsState extends ConsumerState<PasswordChangeFields> {
  static const double _topPadding = 5;

  final FocusNode _focusCurrent = FocusNode();
  final FocusNode _focusNew = FocusNode();
  final FocusNode _focusConfirm = FocusNode();

  bool _hidden = true;
  bool _newTouched = false;
  bool _confirmTouched = false;
  bool? _lastReportedValidity;

  @override
  void initState() {
    super.initState();
    widget.currentController.addListener(_onTextChanged);
    widget.newController.addListener(_onTextChanged);
    widget.confirmController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportValidity());
  }

  @override
  void dispose() {
    widget.currentController.removeListener(_onTextChanged);
    widget.newController.removeListener(_onTextChanged);
    widget.confirmController.removeListener(_onTextChanged);
    _focusCurrent.dispose();
    _focusNew.dispose();
    _focusConfirm.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!mounted) return;
    setState(() {});
    _reportValidity();
  }

  void _reportValidity() {
    if (!mounted) return;
    final valid = PasswordChangeFields.isInputValid(
      current: widget.currentController.text,
      newPassword: widget.newController.text,
      confirmation: widget.confirmController.text,
      minLength: widget.minLength,
      allowEmptyCurrent: widget.allowEmptyCurrent,
    );
    if (valid != _lastReportedValidity) {
      _lastReportedValidity = valid;
      widget.onValidityChanged(valid);
    }
  }

  Color? _stateColor(bool? valid) {
    if (valid == null) return null;
    final light = Theme.of(context).brightness == Brightness.light;
    return valid ? (light ? validColorLight : validColorDark) : (light ? notValidColorLight : notValidColorDark);
  }

  //null = neutral, true = valid, false = invalid
  bool? get _newState {
    if (!_newTouched) return null;
    final text = widget.newController.text;
    if (text.isEmpty && widget.minLength > 0) return false;
    if (!PasswordChangeFields.isNewPasswordValid(text, widget.minLength)) return null;
    return true;
  }

  bool? get _confirmState {
    if (!_confirmTouched) return null;
    if (widget.confirmController.text.isEmpty && widget.newController.text.isEmpty && widget.minLength > 0) return null;
    return widget.confirmController.text == widget.newController.text;
  }

  String? _newValidator() => _newState == false ? "FieldIsRequired".tr() : null;

  String? _confirmValidator() => _confirmState == false ? "PasswordsMismatch".tr() : null;

  Widget _suffix(double iconSize, VoidCallback onClear) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: <Widget>[
      IconButton(
        icon: Icon(!_hidden ? visibleIcon : notVisibleIcon, size: iconSize),
        onPressed: () => setState(() => _hidden = !_hidden),
      ),
      IconButton(icon: Icon(clearTextIcon, size: iconSize), onPressed: onClear),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeDelta = ref.watch(deltaFontSizeProvider);
    final iconSize = appIconBasisSize + fontSizeDelta;
    final textStyleTitleLarge = Theme.of(context).textTheme.titleLarge!.apply(fontSizeDelta: fontSizeDelta);
    final textBodyLarge = Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: fontSizeDelta);
    final textBodyMedium = Theme.of(context).textTheme.bodyMedium!.apply(fontSizeDelta: fontSizeDelta);
    final formatters = <TextInputFormatter>[
      FilteringTextInputFormatter.deny(RegExp(r'[ ]')),
      if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength),
    ];
    final hint = widget.minLength > 0 ? "MinPasswordLength".tr(args: [widget.minLength.toString()]) : null;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: _topPadding),
        child: TextField(
          controller: widget.currentController,
          focusNode: _focusCurrent,
          style: textStyleTitleLarge,
          obscureText: _hidden,
          inputFormatters: formatters,
          enabled: widget.enabled,
          decoration: InputDecoration(
              labelText: widget.currentLabel,
              labelStyle: textBodyLarge,
              prefixIcon: Icon(passwordIcon, size: iconSize),
              suffixIcon: _suffix(iconSize, () {
                widget.currentController.clear();
                _focusCurrent.requestFocus();
              })),
          onSubmitted: (_) => _focusNew.requestFocus(),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: _topPadding),
        child: TextFormField(
          controller: widget.newController,
          focusNode: _focusNew,
          style: textStyleTitleLarge,
          obscureText: _hidden,
          autovalidateMode: AutovalidateMode.always,
          inputFormatters: formatters,
          enabled: widget.enabled,
          decoration: InputDecoration(
              hintText: hint,
              hintStyle: textBodyMedium,
              labelText: widget.newLabel,
              labelStyle: textBodyLarge,
              prefixIcon: Icon(passwordIcon, size: iconSize, color: _stateColor(_newState)),
              suffixIcon: _suffix(iconSize, () {
                _newTouched = true;
                widget.newController.clear();
              })),
          onChanged: (_) => _newTouched = true,
          onFieldSubmitted: (_) => _focusConfirm.requestFocus(),
          validator: (_) => _newValidator(),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: _topPadding),
        child: TextFormField(
          controller: widget.confirmController,
          focusNode: _focusConfirm,
          style: textStyleTitleLarge,
          obscureText: _hidden,
          autovalidateMode: AutovalidateMode.always,
          inputFormatters: formatters,
          enabled: widget.enabled,
          decoration: InputDecoration(
              hintText: hint,
              hintStyle: textBodyMedium,
              labelText: widget.confirmLabel,
              labelStyle: textBodyLarge,
              prefixIcon: Icon(passwordIcon, size: iconSize, color: _stateColor(_confirmState)),
              suffixIcon: _suffix(iconSize, () {
                _confirmTouched = true;
                widget.confirmController.clear();
                _focusConfirm.requestFocus();
              })),
          onChanged: (_) => _confirmTouched = true,
          validator: (_) => _confirmValidator(),
        ),
      ),
    ]);
  }
}
