import 'package:flutter/material.dart';

class SwitchOrCheckListTile extends StatelessWidget {
  final bool isMobileDevice;
  final FocusNode focusNode;
  final Widget title;
  final ListTileControlAffinity controlAffinity;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SwitchOrCheckListTile(
      {super.key,
      required this.isMobileDevice,
      required this.focusNode,
      required this.title,
      this.controlAffinity = ListTileControlAffinity.platform,
      required this.value,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (isMobileDevice) {
      return Expanded(
        child: SwitchListTile(focusNode: focusNode, title: title, controlAffinity: controlAffinity, value: value, onChanged: onChanged != null ? ((val) => onChanged!(val)) : null),
      );
    } else {
      return Expanded(
        child: CheckboxListTile(
            focusNode: focusNode,
            controlAffinity: controlAffinity,
            value: value,
            title: title,
            onChanged: (val) => onChanged != null ? (val != null ? onChanged!(val) : null) : null),
      );
    }
  }
}
