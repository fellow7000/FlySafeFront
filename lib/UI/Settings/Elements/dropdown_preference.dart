import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Helpers/preferences_helper.dart';

class DropdownPreference<T> extends ConsumerWidget {
  final String title;
  final String? description;
  final String prefKey;
  final T value;
  final List<T> values;
  final List<String>? displayValues;
  final Function? onChange;
  final bool isDisabled;
  final TextStyle? textStyle;
  final double deltaFontSize;

  const DropdownPreference({
    super.key,
    required this.title,
    this.description,
    required this.prefKey,
    required this.value,
    required this.values,
    this.displayValues,
    this.onChange,
    this.isDisabled = false,
    this.textStyle,
    this.deltaFontSize = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    TextStyle titleTextStyle = textStyle ?? Theme.of(context).textTheme.bodyLarge!.apply(fontSizeDelta: deltaFontSize);
    TextStyle descriptionTextStyle = textStyle ?? Theme.of(context).textTheme.bodySmall!.apply(fontSizeDelta: deltaFontSize);

    return ListTile(
      title: Text(title, style: titleTextStyle,),
      subtitle: description == null ? null : Text(description!, style: descriptionTextStyle),
      trailing: DropdownButton<T>(
        items: values.map((var val) {
          return DropdownMenuItem<T>(
            value: val,
            child: Text(
              displayValues == null
                  ? val.toString()
                  : displayValues![values.indexOf(val)],
              style: titleTextStyle,
              textAlign: TextAlign.end,
            ),
          );
        }).toList(),
        onChanged: isDisabled
            ? null
            : (newVal) => _setPreference(newVal),
        value: value,
      ),
    );
  }

  _setPreference(newVal) async {
    if (newVal is String) {
      PreferencesHelper.setStringPref(prefName: prefKey, prefValue: newVal);
    } else if (newVal is int) {
      PreferencesHelper.setIntPref(prefName: prefKey, prefValue: newVal);
    } else if (newVal is double) {
    PreferencesHelper.setDoublePref(prefName: prefKey, prefValue: newVal);
    } else if (newVal is bool) {
    PreferencesHelper.setBoolPref(prefName: prefKey, prefValue: newVal);
    }

    if (onChange != null) onChange!(newVal);
  }

}